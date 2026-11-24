import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stryde/core/database/local_cache_service.dart';
import 'package:stryde/core/services/location_timezone_service.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/home/data/completed_quests_repository.dart';
import 'package:stryde/features/home/data/user_quests_repository.dart';
import 'package:stryde/features/home/domain/entities/daily_goal.dart';
import 'package:stryde/features/home/domain/services/daily_goal_matcher.dart';
import 'package:stryde/features/progression/domain/entities/xp_transaction.dart';
import 'package:stryde/features/progression/presentation/providers/user_progression_provider.dart';
import 'package:stryde/features/progression/presentation/providers/xp_transactions_provider.dart';
import 'package:stryde/features/workout_history/domain/entities/completed_workout.dart';
import 'package:stryde/features/workout_history/presentation/providers/workout_history_provider.dart';

final dailyGoalsProvider = NotifierProvider<DailyGoalsNotifier, DailyGoalState>(
  DailyGoalsNotifier.new,
);

class DailyGoalsNotifier extends Notifier<DailyGoalState> {
  static const int maxGoals = 3;
  static const int goalXp = 25;

  String? _activeUserId;

  @override
  DailyGoalState build() {
    final user = ref.watch(currentUserProvider);
    final history = ref.read(workoutHistoryProvider);
    final repo = ref.read(userQuestsRepositoryProvider);
    final tzService = ref.read(locationTimezoneServiceProvider);
    _activeUserId = user?.id;

    final initialQuests = repo.generateDailyGoals(
      userId: user?.id ?? 'local_user',
      timezone: tzService.getDeviceTimezone(),
      history: history,
    );

    final initial = DailyGoalState(
      goals: List<DailyGoal>.unmodifiable(
        initialQuests.map(DailyGoal.fromUserQuest),
      ),
      endsAt: initialQuests.first.expiresAt.toLocal(),
      isEmptyOffline: false,
    );

    ref.listen(currentUserProvider, (_, nextUser) {
      final nextId = nextUser?.id;
      if (nextId == _activeUserId) return;
      _activeUserId = nextId;
      unawaited(_hydrate(nextId));
    });

    Future.microtask(() => _hydrate(user?.id));

    return initial;
  }

  Future<void> _hydrate(String? userId) async {
    final repo = ref.read(userQuestsRepositoryProvider);
    final tzService = ref.read(locationTimezoneServiceProvider);
    final localCache = ref.read(localCacheServiceProvider);
    final history = ref.read(workoutHistoryProvider);
    final effectiveUserId = userId ?? 'local_user';

    final profile = await localCache.getCachedProfile(effectiveUserId);
    if (!ref.mounted) return;
    final timezone = profile?.timezone ?? tzService.getDeviceTimezone();

    try {
      final userQuests = await repo.getOrGenerateQuests(
        userId: effectiveUserId,
        questType: 'daily',
        timezone: timezone,
        history: history,
      );

      if (!ref.mounted || _activeUserId != userId) return;

      if (userQuests.isEmpty) {
        state = DailyGoalState(
          goals: const <DailyGoal>[],
          endsAt: tzService.nextDailyMidnight(timezone: timezone).toLocal(),
          isEmptyOffline: true,
        );
        return;
      }

      final goals = userQuests.map(DailyGoal.fromUserQuest).toList();
      final endsAt = userQuests.first.expiresAt.toLocal();

      state = DailyGoalState(
        goals: List<DailyGoal>.unmodifiable(goals),
        endsAt: endsAt,
        isEmptyOffline: false,
      );

      final completedRepo = ref.read(completedQuestsRepositoryProvider);
      if (completedRepo != null && userId != null) {
        final records = await completedRepo.fetch(effectiveUserId);
        if (records.isNotEmpty) {
          final completedIds = records
              .where((r) => r.questType == 'goal' || r.questType == 'daily')
              .where((r) => r.isWithinWindow(const Duration(hours: 24)))
              .map((r) => r.questId)
              .toSet();
          if (completedIds.isNotEmpty && ref.mounted) {
            state = DailyGoalState(
              goals: List<DailyGoal>.unmodifiable([
                for (final g in state.goals)
                  completedIds.contains(g.id)
                      ? g.copyWith(isCompleted: true)
                      : g,
              ]),
              endsAt: state.endsAt,
              isEmptyOffline: state.isEmptyOffline,
            );
          }
        }
      }
    } catch (_) {
      // Degrades gracefully
    }
  }

  bool complete(String id) {
    refreshIfNeeded();
    final index = state.goals.indexWhere((goal) => goal.id == id);
    if (index == -1 || state.goals[index].isCompleted) return false;

    final goal = state.goals[index];
    final now = DateTime.now();

    state = DailyGoalState(
      goals: <DailyGoal>[
        for (var i = 0; i < state.goals.length; i++)
          if (i == index)
            state.goals[i].copyWith(isCompleted: true)
          else
            state.goals[i],
      ],
      endsAt: state.endsAt,
      isEmptyOffline: state.isEmptyOffline,
    );

    final userId = _activeUserId ?? 'local_user';
    final repo = ref.read(userQuestsRepositoryProvider);
    unawaited(
      repo.completeQuest(
        userId: userId,
        questId: id,
        questType: 'daily',
        completedAt: now,
      ),
    );

    final completedRepo = ref.read(completedQuestsRepositoryProvider);
    if (completedRepo != null && _activeUserId != null) {
      unawaited(
        completedRepo.insert(
          userId: _activeUserId!,
          questId: id,
          questType: 'goal',
          completedAt: now,
        ),
      );
    }

    ref.read(userProgressionProvider.notifier).addXp(goal.xp);
    ref
        .read(xpTransactionsProvider.notifier)
        .log(
          description: 'Daily Goal · ${goal.title}',
          amount: goal.xp,
          source: XpSource.goal,
        );
    return true;
  }

  int evaluateWorkout(CompletedWorkout workout) {
    refreshIfNeeded();
    final matchingIds = <String>[];

    for (final goal in state.goals) {
      if (goal.isCompleted) continue;
      if (_workoutCompletesGoal(workout, goal)) matchingIds.add(goal.id);
    }

    var completedCount = 0;
    for (final id in matchingIds) {
      if (complete(id)) completedCount++;
    }
    return completedCount;
  }

  void refreshFromHistory() {
    unawaited(_hydrate(_activeUserId));
  }

  void generateFromHistoryIfNeeded() {
    if (state.goals.any((goal) => goal.hasSetTarget)) return;
    final history = ref.read(workoutHistoryProvider);
    if (history.isEmpty) return;

    final repo = ref.read(userQuestsRepositoryProvider);
    final tzService = ref.read(locationTimezoneServiceProvider);
    final generated = repo.generateDailyGoals(
      userId: _activeUserId ?? 'local_user',
      timezone: tzService.getDeviceTimezone(),
      history: history,
    );

    final completedIds = state.goals
        .where((goal) => goal.isCompleted)
        .map((goal) => goal.id)
        .toSet();

    state = DailyGoalState(
      goals: List<DailyGoal>.unmodifiable([
        for (final q in generated)
          () {
            final goal = DailyGoal.fromUserQuest(q);
            return completedIds.contains(goal.id)
                ? goal.copyWith(isCompleted: true)
                : goal;
          }(),
      ]),
      endsAt: state.endsAt,
      isEmptyOffline: false,
    );

    final localCache = ref.read(localCacheServiceProvider);
    try {
      unawaited(
        localCache.saveCachedQuests(
          _activeUserId ?? 'local_user',
          generated.map((q) => q.toDrift()).toList(),
        ),
      );
    } catch (_) {}
  }

  void refresh() {
    unawaited(_hydrate(_activeUserId));
  }

  void refreshIfNeeded({bool force = false}) {
    final now = DateTime.now();
    if (force || !now.isBefore(state.endsAt)) {
      unawaited(_hydrate(_activeUserId));
    }
  }

  bool _workoutCompletesGoal(CompletedWorkout workout, DailyGoal goal) {
    if (goal.hasSetTarget) {
      for (final exercise in workout.exercises) {
        if (exercise.exerciseName != goal.detail &&
            exercise.exerciseId != goal.exerciseId &&
            exercise.exerciseName != goal.exerciseId) {
          continue;
        }
        for (final set in exercise.sets) {
          if (setMeetsDailyGoalTarget(
            targetWeight: goal.targetWeight!,
            targetReps: goal.targetReps ?? 1,
            actualWeight: set.weightKg,
            actualReps: set.reps,
          )) {
            return true;
          }
        }
      }
      return false;
    }

    return false;
  }
}
