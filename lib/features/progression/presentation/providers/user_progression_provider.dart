import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stryde/core/database/local_cache_service.dart';
import 'package:stryde/core/providers/loading_flag_notifier.dart';
import 'package:stryde/core/sync/sync_service.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/home/presentation/providers/login_streak_provider.dart';
import 'package:stryde/features/medals/presentation/providers/medals_provider.dart';
import 'package:stryde/features/profile/data/profile_repository.dart';
import 'package:stryde/features/progression/data/xp_history_repository.dart';
import 'package:stryde/features/progression/domain/entities/rank.dart';
import 'package:stryde/features/progression/domain/entities/user_progression.dart';
import 'package:stryde/features/progression/domain/services/xp_progression_engine.dart';
import 'package:stryde/features/progression/presentation/providers/global_notification_provider.dart';

final userProgressionProvider =
    NotifierProvider<UserProgressionNotifier, UserProgression>(
      UserProgressionNotifier.new,
    );

final userProgressionLoadingProvider =
    NotifierProvider<LoadingFlagNotifier, bool>(LoadingFlagNotifier.new);

class UserProgressionNotifier extends Notifier<UserProgression> {
  ProfileRepository? get _repository => ref.read(profileRepositoryProvider);

  String? _activeUserId;
  String? _hydratingUserId;
  bool _hydrated = false;
  int _pendingXp = 0;
  Future<void> _persistenceQueue = Future<void>.value();

  @override
  UserProgression build() {
    final user = ref.read(currentUserProvider);
    _activeUserId = user?.id;
    final shouldHydrate = user != null && _repository != null;
    _hydrated = !shouldHydrate;

    if (shouldHydrate) {
      Future.microtask(() {
        if (_activeUserId == user.id) {
          ref.read(userProgressionLoadingProvider.notifier).setLoading(true);
        }
      });
      unawaited(_hydrate(user.id));
    }

    ref.listen(currentUserProvider, (_, user) {
      _handleUserChanged(user);
    });

    return const UserProgression(currentLevel: 1, currentXp: 0);
  }

  void _handleUserChanged(User? user) {
    final userId = user?.id;
    if (userId == _activeUserId) return;

    _activeUserId = userId;
    _hydratingUserId = null;
    final shouldHydrate = userId != null && _repository != null;
    _hydrated = !shouldHydrate;
    _pendingXp = 0;
    state = const UserProgression(currentLevel: 1, currentXp: 0);

    ref.read(userProgressionLoadingProvider.notifier).setLoading(shouldHydrate);
    if (shouldHydrate) unawaited(_hydrate(userId));
  }

  Future<void> _hydrate(String userId) async {
    if (_activeUserId != userId || _hydrated || _hydratingUserId == userId) {
      return;
    }

    final repository = _repository;
    if (repository == null) {
      ref.read(userProgressionLoadingProvider.notifier).setLoading(false);
      return;
    }
    _hydratingUserId = userId;

    try {
      final profile = await repository.getOrFetchProfile(userId);
      if (_activeUserId != userId) return;

      final pendingXp = _pendingXp;
      final existingSkillPoints =
          (profile?.availableSkillPoints ?? profile?.skillPoints ?? 0).clamp(
            0,
            1 << 31,
          );

      int totalXp = profile?.totalXp ?? 0;
      if (totalXp <= 0) {
        final xpHistoryRepo = ref.read(xpHistoryRepositoryProvider);
        if (xpHistoryRepo != null) {
          try {
            final txs = await xpHistoryRepo.fetch(userId);
            final historyTotal = txs.fold<int>(0, (sum, tx) => sum + tx.amount);
            if (historyTotal > 0) {
              totalXp = historyTotal;
            }
          } catch (_) {}
        }
      }

      final UserProgression loaded;
      if (totalXp > 0) {
        loaded = XpProgressionEngine.progressionFromTotalXp(
          totalXp,
          skillPoints: existingSkillPoints,
        );
      } else {
        loaded = XpProgressionEngine.recalculateFromOldProgression(
          oldLevel: profile?.level ?? 1,
          oldXp: profile?.xp ?? 0,
          existingSkillPoints: existingSkillPoints,
        );
      }
      final previousLevel = loaded.currentLevel;
      state = _addXpTo(loaded, pendingXp);
      _pendingXp = 0;
      _hydrated = true;

      if (pendingXp > 0 && state.currentLevel > previousLevel) {
        final notifications = calculateProgressionNotifications(
          fromLevel: previousLevel,
          toLevel: state.currentLevel,
        );
        if (notifications.isNotEmpty) {
          ref.read(globalNotificationProvider.notifier).enqueue(notifications);
        }
      }

      ref
          .read(loginStreakProvider.notifier)
          .hydrate(
            streak: profile?.streak ?? 0,
            lastActivityOn: profile?.lastActivityOn,
          );

      if ((profile?.totalXp == null || profile!.totalXp! <= 0) &&
          state.totalXp > 0) {
        _queuePersist();
      } else if (pendingXp > 0) {
        _queuePersist();
      }
      ref
          .read(medalsProvider.notifier)
          .evaluateAndUnlock(level: state.currentLevel);
      unawaited(
        ref.read(syncServiceProvider.notifier).reconcileProfile(userId),
      );
    } catch (_) {
      if (_activeUserId == userId) {
        final shouldPersist = _pendingXp > 0;
        _pendingXp = 0;
        _hydrated = true;
        ref.read(loginStreakProvider.notifier).useLocalFallback();
        if (shouldPersist) _queuePersist();
      }
    } finally {
      if (_hydratingUserId == userId) _hydratingUserId = null;
      if (_activeUserId == userId) {
        ref.read(userProgressionLoadingProvider.notifier).setLoading(false);
      }
    }
  }

  void addXp(int amount) {
    if (amount <= 0) return;

    final oldLevel = state.currentLevel;
    state = _addXpTo(state, amount);
    final newLevel = state.currentLevel;

    if (_hydrated && newLevel > oldLevel) {
      final notifications = calculateProgressionNotifications(
        fromLevel: oldLevel,
        toLevel: newLevel,
      );
      if (notifications.isNotEmpty) {
        ref.read(globalNotificationProvider.notifier).enqueue(notifications);
      }
    }

    ref
        .read(medalsProvider.notifier)
        .evaluateAndUnlock(level: state.currentLevel);
    if (_activeUserId != null && !_hydrated) {
      _pendingXp += amount;
      return;
    }
    _queuePersist();
  }

  UserProgression _addXpTo(UserProgression progression, int amount) {
    if (amount <= 0) return progression;

    var level = progression.currentLevel;
    var xp = progression.currentXp + amount;
    var levelsGained = 0;
    var bonusSkillPoints = 0;

    while (level < UserProgression.maxLevel &&
        xp >= XpProgressionEngine.xpRequiredForLevel(level)) {
      xp -= XpProgressionEngine.xpRequiredForLevel(level);
      level += 1;
      levelsGained += 1;
      if (Ranks.breakthroughLevels.contains(level)) {
        bonusSkillPoints += 3;
      }
    }

    if (level >= UserProgression.maxLevel) {
      xp = xp.clamp(0, XpProgressionEngine.xpRequiredForLevel(level)).toInt();
    }

    return progression.copyWith(
      currentLevel: level,
      currentXp: xp,
      totalXp: progression.totalXp + amount,
      skillPoints: progression.skillPoints + levelsGained + bonusSkillPoints,
      levelUpRevision: progression.levelUpRevision + (levelsGained > 0 ? 1 : 0),
    );
  }

  void _queuePersist() {
    final userId = _activeUserId;
    if (userId == null) return;

    final xp = state.currentXp;
    final level = state.currentLevel;
    final skillPoints = state.skillPoints;
    final totalXp = state.totalXp;
    final localCache = ref.read(localCacheServiceProvider);

    _persistenceQueue = _persistenceQueue.then((_) async {
      try {
        final repo = _repository;
        if (repo != null) {
          try {
            await repo.saveProgression(
              userId: userId,
              xp: xp,
              level: level,
              skillPoints: skillPoints,
              totalXp: totalXp,
              availableSkillPoints: skillPoints,
            );
          } catch (_) {}
        }

        final now = DateTime.now();
        await localCache.updateCachedProfile(
          userId,
          xp: xp,
          level: level,
          skillPoints: skillPoints,
          totalXp: totalXp,
          availableSkillPoints: skillPoints,
          lastUpdated: now,
        );
        await localCache.enqueue(
          entityType: 'profile',
          action: 'update',
          payload: <String, dynamic>{
            'userId': userId,
            'values': <String, dynamic>{
              'xp': xp,
              'level': level,
              'skill_points': skillPoints,
              'available_skill_points': skillPoints,
              'total_xp': totalXp,
              'updated_at': now.toUtc().toIso8601String(),
            },
          },
        );
        unawaited(ref.read(syncServiceProvider.notifier).syncPending());
      } catch (_) {
        // Keep the optimistic local progression while offline.
      }
    });
  }

  bool spendSkillPoint() {
    if (state.skillPoints <= 0) return false;
    state = state.copyWith(skillPoints: state.skillPoints - 1);
    _queuePersist();
    return true;
  }
}
