import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  static const Duration cycle = Duration(hours: 24);

  @override
  DailyGoalState build() => _build(ref.read(workoutHistoryProvider));

  DailyGoalState _build(List<CompletedWorkout> history) {
    final now = DateTime.now();
    final goals = <DailyGoal>[];
    final usedIds = <String>{};

    for (final workout in history) {
      for (final exercise in workout.exercises) {
        if (exercise.sets.isEmpty || goals.length == maxGoals) continue;
        final bestSet = exercise.sets.reduce(
          (best, set) => set.weightKg >= best.weightKg ? set : best,
        );
        final id = 'progress-${exercise.exerciseId}';
        if (!usedIds.add(id)) continue;

        final targetWeight = bestSet.weightKg + 2.5;
        final targetReps = (bestSet.reps - 2).clamp(1, 999).toInt();
        goals.add(
          DailyGoal(
            id: id,
            title: '${_formatWeight(targetWeight)} kg × $targetReps reps',
            detail: exercise.exerciseName,
            xp: goalXp,
            exerciseId: exercise.exerciseId,
            targetWeight: targetWeight,
            targetReps: targetReps,
          ),
        );
      }
      if (goals.length == maxGoals) break;
    }

    for (final fallback in _fallbackGoals) {
      if (goals.length == maxGoals) break;
      if (usedIds.add(fallback.id)) goals.add(fallback);
    }

    return DailyGoalState(
      goals: List<DailyGoal>.unmodifiable(goals.take(maxGoals)),
      endsAt: now.add(cycle),
    );
  }

  bool complete(String id) {
    refreshIfNeeded();
    final index = state.goals.indexWhere((goal) => goal.id == id);
    if (index == -1 || state.goals[index].isCompleted) return false;

    final goal = state.goals[index];
    state = DailyGoalState(
      goals: <DailyGoal>[
        for (var i = 0; i < state.goals.length; i++)
          if (i == index)
            state.goals[i].copyWith(isCompleted: true)
          else
            state.goals[i],
      ],
      endsAt: state.endsAt,
    );
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

  /// Evaluates every unfinished goal against a completed session and returns
  /// the number of goals that were completed automatically.
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

  /// Rebuilds tomorrow's challenges from the freshest workout history.
  void refreshFromHistory() {
    state = _build(ref.read(workoutHistoryProvider));
  }

  /// Replaces the initial fallback-only list once an in-memory workout exists.
  /// Existing targeted goals are left untouched for the rest of their cycle.
  void generateFromHistoryIfNeeded() {
    if (state.goals.any((goal) => goal.hasSetTarget)) return;
    final history = ref.read(workoutHistoryProvider);
    if (history.isEmpty) return;

    final completedIds = state.goals
        .where((goal) => goal.isCompleted)
        .map((goal) => goal.id)
        .toSet();
    final generated = _build(history);
    state = DailyGoalState(
      goals: <DailyGoal>[
        for (final goal in generated.goals)
          completedIds.contains(goal.id)
              ? goal.copyWith(isCompleted: true)
              : goal,
      ],
      endsAt: state.endsAt,
    );
  }

  void refreshIfNeeded() {
    if (!DateTime.now().isBefore(state.endsAt)) {
      state = _build(ref.read(workoutHistoryProvider));
    }
  }

  bool _workoutCompletesGoal(CompletedWorkout workout, DailyGoal goal) {
    if (goal.hasSetTarget) {
      for (final exercise in workout.exercises) {
        if (exercise.exerciseId != goal.exerciseId) continue;
        for (final set in exercise.sets) {
          if (setMeetsDailyGoalTarget(
            targetWeight: goal.targetWeight!,
            targetReps: goal.targetReps!,
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

  static const List<DailyGoal> _fallbackGoals = <DailyGoal>[
    DailyGoal(
      id: 'fallback-sets',
      title: 'Complete 3 working sets',
      detail: 'Any exercise',
      xp: goalXp,
    ),
    DailyGoal(
      id: 'fallback-reps',
      title: 'Log 50 total reps',
      detail: 'Across your session',
      xp: goalXp,
    ),
    DailyGoal(
      id: 'fallback-session',
      title: 'Finish a workout',
      detail: 'Any routine or free training',
      xp: goalXp,
    ),
  ];
}

String _formatWeight(double value) => value == value.roundToDouble()
    ? value.toStringAsFixed(0)
    : value.toStringAsFixed(1);
