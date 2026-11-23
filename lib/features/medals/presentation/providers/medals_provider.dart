import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stryde/core/database/local_cache_service.dart';
import 'package:stryde/core/sync/sync_service.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/home/presentation/providers/login_streak_provider.dart';
import 'package:stryde/features/medals/data/medals_repository.dart';
import 'package:stryde/features/medals/domain/entities/medal.dart';
import 'package:stryde/features/medals/presentation/providers/medal_notification_provider.dart';
import 'package:stryde/features/progression/presentation/providers/skill_allocations_provider.dart';
import 'package:stryde/features/progression/presentation/providers/user_progression_provider.dart';
import 'package:stryde/features/routines/domain/entities/mastery_routine_definition.dart';
import 'package:stryde/features/workout_history/domain/entities/completed_workout.dart';
import 'package:stryde/features/workout_history/presentation/providers/workout_history_provider.dart';

int calculateTotalPrsFromHistory(List<CompletedWorkout> history) {
  final sorted = List<CompletedWorkout>.from(history)
    ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

  final exerciseMaxVolumes = <String, double>{};
  int prCount = 0;

  for (final workout in sorted) {
    for (final exercise in workout.exercises) {
      final prevMax = exerciseMaxVolumes[exercise.exerciseId] ?? 0;
      double sessionMax = 0;
      for (final s in exercise.sets) {
        if (s.volume > sessionMax) {
          sessionMax = s.volume;
        }
      }
      if (sessionMax > 0 && sessionMax > prevMax) {
        prCount++;
        exerciseMaxVolumes[exercise.exerciseId] = sessionMax;
      }
    }
  }

  return prCount;
}

class MedalsState {
  const MedalsState({
    this.unlockedMedals = const <String, DateTime>{},
    this.isLoading = false,
  });

  final Map<String, DateTime> unlockedMedals;
  final bool isLoading;

  bool isUnlocked(String medalId) {
    if (unlockedMedals.containsKey(medalId)) return true;
    final alias = kLegacyMedalAliases[medalId];
    if (alias != null && unlockedMedals.containsKey(alias)) return true;
    // Also reverse check if canonical is checked against legacy
    for (final entry in kLegacyMedalAliases.entries) {
      if (entry.value == medalId && unlockedMedals.containsKey(entry.key)) {
        return true;
      }
    }
    return false;
  }

  int get unlockedCount {
    final unlockedIds = <String>{};
    for (final medal in kStaticMedals) {
      if (isUnlocked(medal.id)) {
        unlockedIds.add(medal.id);
      }
    }
    return unlockedIds.length;
  }

  MedalsState copyWith({
    Map<String, DateTime>? unlockedMedals,
    bool? isLoading,
  }) {
    return MedalsState(
      unlockedMedals: unlockedMedals ?? this.unlockedMedals,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final medalsProvider = NotifierProvider<MedalsNotifier, MedalsState>(
  MedalsNotifier.new,
);

class MedalsNotifier extends Notifier<MedalsState> {
  String? _activeUserId;
  bool _mounted = true;
  MedalsRepository? _repository;
  late LocalCacheService _localCache;

  @override
  MedalsState build() {
    _mounted = true;
    _repository = ref.read(medalsRepositoryProvider);
    _localCache = ref.read(localCacheServiceProvider);
    ref.onDispose(() => _mounted = false);

    final user = ref.watch(currentUserProvider);
    _activeUserId = user?.id;

    if (user != null && _repository != null) {
      unawaited(_hydrate(user.id));
    }

    return const MedalsState();
  }

  Future<void> _hydrate(String userId) async {
    if (!_mounted) return;

    // 1. Load from local cache first
    try {
      final cached = await _localCache.getCachedMedals(userId);
      if (!_mounted) return;
      if (_activeUserId == userId && cached.isNotEmpty) {
        final mapped = <String, DateTime>{};
        for (final entry in cached.entries) {
          mapped[entry.key] = entry.value;
          final canonical = kLegacyMedalAliases[entry.key];
          if (canonical != null) mapped[canonical] = entry.value;
        }
        state = state.copyWith(
          unlockedMedals: <String, DateTime>{
            ...mapped,
            ...state.unlockedMedals,
          },
        );
      }
    } catch (_) {}

    final repo = _repository;
    if (repo == null || !_mounted) return;

    // 2. Fetch remote in background
    try {
      final medals = await repo.fetchUnlockedMedals(userId);
      if (!_mounted || _activeUserId != userId) return;
      final mappedMedals = <String, DateTime>{};
      for (final entry in medals.entries) {
        mappedMedals[entry.key] = entry.value;
        final canonical = kLegacyMedalAliases[entry.key];
        if (canonical != null) {
          mappedMedals[canonical] = entry.value;
        }
      }
      final merged = <String, DateTime>{
        ...mappedMedals,
        ...state.unlockedMedals,
      };
      state = state.copyWith(unlockedMedals: merged);
      await _localCache.setCachedMedals(userId, merged);

      if (!_mounted) return;
      // Reconcile historical achievements silently (no notifications)
      await evaluateAndUnlock(isReconciling: true);
    } catch (_) {
      // Degrades gracefully
    }
  }

  /// Evaluates and unlocks medals based on current or passed metrics.
  /// When [isReconciling] is true, historical unlocks are saved without
  /// queuing Home Screen notifications.
  Future<List<Medal>> evaluateAndUnlock({
    int? level,
    int? streak,
    int? totalPrs,
    int? totalWorkouts,
    int? individualMasteryCount,
    int? combinedMasteryCount,
    int? totalMasteryCount,
    bool? hasNewPr,
    bool isReconciling = false,
  }) async {
    final userId = _activeUserId;
    final repo = _repository;

    // Resolve metrics from providers if not explicitly passed
    final resolvedLevel =
        level ?? ref.read(userProgressionProvider).currentLevel;
    final resolvedStreak =
        streak ?? ref.read(loginStreakProvider).currentStreak;

    final history = ref.read(workoutHistoryProvider);
    final resolvedWorkouts = totalWorkouts ?? history.length;
    final resolvedPrs = totalPrs ?? calculateTotalPrsFromHistory(history);

    int resolvedIndividualMastery = individualMasteryCount ?? 0;
    int resolvedCombinedMastery = combinedMasteryCount ?? 0;
    int resolvedTotalMastery = totalMasteryCount ?? 0;

    if (individualMasteryCount == null ||
        combinedMasteryCount == null ||
        totalMasteryCount == null) {
      final allocations = ref.read(skillAllocationsProvider);
      int ind = 0;
      int comb = 0;
      int tot = 0;
      for (final def in MasteryRoutineDefinitions.all) {
        if (def.isUnlocked(allocations)) {
          tot++;
          if (def.requiredPoints.length == 1) {
            ind++;
          } else {
            comb++;
          }
        }
      }
      resolvedIndividualMastery = ind;
      resolvedCombinedMastery = comb;
      resolvedTotalMastery = tot;
    }

    final updated = Map<String, DateTime>.from(state.unlockedMedals);
    final newlyUnlocked = <Medal>[];

    for (final medal in kStaticMedals) {
      if (state.isUnlocked(medal.id)) continue;

      bool shouldUnlock = false;
      switch (medal.id) {
        // STRENGTH & PRs
        case 'first_blood':
          shouldUnlock = hasNewPr == true || resolvedPrs >= 1;
        case 'record_breaker':
          shouldUnlock = resolvedPrs >= 5;
        case 'limit_breaker':
          shouldUnlock = resolvedPrs >= 25;
        case 'unstoppable':
          shouldUnlock = resolvedPrs >= 100;

        // CONSISTENCY
        case 'first_flame':
          shouldUnlock = resolvedStreak >= 7;
        case 'iron_discipline':
          shouldUnlock = resolvedStreak >= 30;
        case 'relentless':
          shouldUnlock = resolvedStreak >= 90;
        case 'eternal_flame':
          shouldUnlock = resolvedStreak >= 365;

        // WORKOUT MILESTONES
        case 'first_step':
          shouldUnlock = resolvedWorkouts >= 1;
        case 'no_turning_back':
          shouldUnlock = resolvedWorkouts >= 10;
        case 'battle_hardened':
          shouldUnlock = resolvedWorkouts >= 100;
        case 'centurion':
          shouldUnlock = resolvedWorkouts >= 500;

        // MUSCLE MASTERY
        case 'awakened':
          shouldUnlock = resolvedIndividualMastery >= 1;
        case 'dual_wielder':
          shouldUnlock = resolvedCombinedMastery >= 1;
        case 'all_rounder':
          shouldUnlock = resolvedIndividualMastery >= 6;
        case 'master_of_all':
          shouldUnlock = resolvedTotalMastery >= 11;

        // RANK & ASCENSION
        case 'the_ascended':
          shouldUnlock = resolvedLevel >= 23;
        case 'royal_blood':
          shouldUnlock = resolvedLevel >= 31;
        case 'gates_of_olympus':
          shouldUnlock = resolvedLevel >= 41;
        case 'godslayer':
          shouldUnlock = resolvedLevel >= 100;
      }

      if (shouldUnlock) {
        final now = DateTime.now();
        updated[medal.id] = now;
        newlyUnlocked.add(medal);
      }
    }

    // Also support legacy unlock IDs in test/patch code
    if (resolvedLevel >= 5 && !updated.containsKey('level_5')) {
      updated['level_5'] = DateTime.now();
      if (userId != null && repo != null) {
        unawaited(repo.unlockMedal(userId: userId, medalId: 'level_5'));
      }
    }
    if (resolvedLevel >= 10 && !updated.containsKey('level_10')) {
      updated['level_10'] = DateTime.now();
      if (userId != null && repo != null) {
        unawaited(repo.unlockMedal(userId: userId, medalId: 'level_10'));
      }
    }

    if (updated.length > state.unlockedMedals.length) {
      state = state.copyWith(unlockedMedals: updated);

      if (userId != null && _mounted) {
        for (final medal in newlyUnlocked) {
          final unlockedTime = updated[medal.id] ?? DateTime.now();
          unawaited(
            _localCache.saveCachedMedal(userId, medal.id, unlockedTime),
          );
          unawaited(
            _localCache.enqueue(
              entityType: 'medal',
              action: 'insert',
              payload: <String, dynamic>{
                'userId': userId,
                'medalId': medal.id,
                'unlockedAt': unlockedTime.toUtc().toIso8601String(),
              },
            ),
          );
          if (repo != null) {
            unawaited(repo.unlockMedal(userId: userId, medalId: medal.id));
          }
        }
        if (_mounted) {
          unawaited(ref.read(syncServiceProvider.notifier).syncPending());
        }
      }

      // Enqueue notification only during active runtime, not during initial reconciliation
      if (!isReconciling && newlyUnlocked.isNotEmpty) {
        ref.read(medalNotificationProvider.notifier).enqueue(newlyUnlocked);
      }
    }

    return newlyUnlocked;
  }
}
