import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stryde/core/providers/loading_flag_notifier.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/home/presentation/providers/login_streak_provider.dart';
import 'package:stryde/features/medals/presentation/providers/medals_provider.dart';
import 'package:stryde/features/profile/data/profile_repository.dart';
import 'package:stryde/features/progression/domain/entities/rank.dart';
import 'package:stryde/features/progression/domain/entities/user_progression.dart';

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
    if (user != null && _repository != null) {
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
    _hydrated = false;
    _pendingXp = 0;
    state = const UserProgression(currentLevel: 1, currentXp: 0);

    final loading = userId != null && _repository != null;
    ref.read(userProgressionLoadingProvider.notifier).setLoading(loading);
    if (loading) unawaited(_hydrate(userId));
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
      final profile = await repository.fetch(userId);
      if (_activeUserId != userId) return;

      final pendingXp = _pendingXp;
      final loaded = UserProgression(
        currentLevel: (profile?.level ?? 1).clamp(1, UserProgression.maxLevel),
        currentXp: (profile?.xp ?? 0).clamp(0, UserProgression.xpPerLevel),
        skillPoints: (profile?.skillPoints ?? 0).clamp(0, 1 << 31),
      );
      state = _addXpTo(loaded, pendingXp);
      _pendingXp = 0;
      _hydrated = true;

      ref
          .read(loginStreakProvider.notifier)
          .hydrate(
            streak: profile?.streak ?? 0,
            lastActivityOn: profile?.lastActivityOn,
          );

      if (pendingXp > 0) _queuePersist();
      ref
          .read(medalsProvider.notifier)
          .evaluateAndUnlock(level: state.currentLevel);
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

    state = _addXpTo(state, amount);
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
        xp >= UserProgression.xpPerLevel) {
      xp -= UserProgression.xpPerLevel;
      level += 1;
      levelsGained += 1;
      if (Ranks.breakthroughLevels.contains(level)) {
        bonusSkillPoints += 3;
      }
    }

    if (level >= UserProgression.maxLevel) {
      xp = xp.clamp(0, UserProgression.xpPerLevel).toInt();
    }

    return progression.copyWith(
      currentLevel: level,
      currentXp: xp,
      skillPoints: progression.skillPoints + levelsGained + bonusSkillPoints,
      levelUpRevision: progression.levelUpRevision + (levelsGained > 0 ? 1 : 0),
    );
  }

  void _queuePersist() {
    final userId = _activeUserId;
    final repository = _repository;
    if (userId == null || repository == null) return;

    final xp = state.currentXp;
    final level = state.currentLevel;
    final skillPoints = state.skillPoints;
    _persistenceQueue = _persistenceQueue.then((_) async {
      try {
        await repository.saveProgression(
          userId: userId,
          xp: xp,
          level: level,
          skillPoints: skillPoints,
        );
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
