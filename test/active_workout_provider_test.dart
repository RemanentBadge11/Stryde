import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stryde/features/home/presentation/providers/daily_goals_provider.dart';
import 'package:stryde/features/home/presentation/providers/login_streak_provider.dart';
import 'package:stryde/features/progression/presentation/providers/user_progression_provider.dart';
import 'package:stryde/features/progression/presentation/providers/xp_transactions_provider.dart';
import 'package:stryde/features/routines/data/mock_workout_data.dart';
import 'package:stryde/features/workout_history/domain/entities/completed_workout.dart';
import 'package:stryde/features/workout_history/presentation/providers/workout_history_provider.dart';
import 'package:stryde/features/workout_logging/presentation/providers/active_workout_provider.dart';

void main() {
  test('active session preserves drafts and finishes through one notifier', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(activeWorkoutProvider.notifier);
    final startedAt = DateTime.now().subtract(const Duration(minutes: 2));

    expect(
      notifier.startWorkout(MockWorkoutData.pushDay, startedAt: startedAt),
      isTrue,
    );
    notifier.updateWeight(0, 0, '82.5');
    notifier.updateReps(0, 0, '8');
    expect(notifier.toggleSetCompletion(0, 0), SetCompletionResult.completed);

    final ongoing = container.read(activeWorkoutProvider);
    expect(ongoing.isOngoing, isTrue);
    expect(ongoing.session!.exercises.first.sets.first.weightText, '82.5');
    expect(ongoing.session!.exercises.first.sets.first.isCompleted, isTrue);
    expect(ongoing.restSecondsRemaining, isNotNull);

    final result = notifier.finishWorkout(
      completedAt: startedAt.add(const Duration(minutes: 2)),
    );

    expect(result, isNotNull);
    expect(result!.xpAwarded, 100);
    expect(container.read(activeWorkoutProvider).isOngoing, isFalse);
    expect(container.read(workoutHistoryProvider), hasLength(1));
    expect(
      container
          .read(workoutHistoryProvider)
          .first
          .exercises
          .first
          .sets
          .first
          .weightKg,
      82.5,
    );
    expect(container.read(userProgressionProvider).currentXp, 100);
    expect(container.read(loginStreakProvider).streak, 1);
    expect(container.read(dailyGoalsProvider).goals.first.hasSetTarget, isTrue);
  });

  test('finishing an empty workout saves but awards zero XP', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(activeWorkoutProvider.notifier);

    notifier.startWorkout(MockWorkoutData.freeTraining);
    final result = notifier.finishWorkout();

    expect(result, isNotNull);
    expect(result!.workout.exercises, isEmpty);
    expect(result.xpAwarded, 0);
    expect(container.read(workoutHistoryProvider), hasLength(1));
    expect(container.read(userProgressionProvider).currentXp, 0);
    expect(container.read(xpTransactionsProvider), isEmpty);
    expect(container.read(activeWorkoutProvider).isOngoing, isFalse);
  });

  test('discard wipes the session without history, streak, or XP', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(activeWorkoutProvider.notifier);

    notifier.startWorkout(MockWorkoutData.pushDay);
    notifier.updateWeight(0, 0, '80');
    notifier.updateReps(0, 0, '8');
    notifier.toggleSetCompletion(0, 0);

    expect(notifier.discardWorkout(), isTrue);
    expect(container.read(activeWorkoutProvider).isOngoing, isFalse);
    expect(container.read(workoutHistoryProvider), isEmpty);
    expect(container.read(userProgressionProvider).currentXp, 0);
    expect(container.read(xpTransactionsProvider), isEmpty);
    expect(container.read(loginStreakProvider).streak, 0);
  });

  test('pause freezes elapsed time and play resumes from that value', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(activeWorkoutProvider.notifier);
    final startedAt = DateTime(2030, 1, 1, 12);

    notifier.startWorkout(MockWorkoutData.freeTraining, startedAt: startedAt);
    notifier.toggleTimer(startedAt.add(const Duration(seconds: 10)));
    expect(container.read(activeWorkoutProvider).isPaused, isTrue);
    expect(
      container.read(activeWorkoutProvider).elapsed,
      const Duration(seconds: 10),
    );

    notifier.toggleTimer(startedAt.add(const Duration(seconds: 40)));
    expect(container.read(activeWorkoutProvider).isPaused, isFalse);
    expect(
      container.read(activeWorkoutProvider).elapsed,
      const Duration(seconds: 10),
    );

    final result = notifier.finishWorkout(
      completedAt: startedAt.add(const Duration(seconds: 50)),
    );
    expect(result!.workout.duration, const Duration(seconds: 20));
  });

  test('finishing triggers targeted Daily Goal evaluation automatically', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container
        .read(workoutHistoryProvider.notifier)
        .addWorkout(
          CompletedWorkout(
            id: 'prior',
            routineId: MockWorkoutData.pushDay.id,
            routineName: MockWorkoutData.pushDay.name,
            completedAt: DateTime.now().subtract(const Duration(days: 1)),
            duration: const Duration(minutes: 30),
            exercises: const <CompletedWorkoutExercise>[
              CompletedWorkoutExercise(
                exerciseId: 'bench-press',
                exerciseName: 'Bench Press',
                sets: <CompletedWorkoutSet>[
                  CompletedWorkoutSet(setNumber: 1, weightKg: 80, reps: 10),
                ],
              ),
            ],
          ),
        );

    final notifier = container.read(activeWorkoutProvider.notifier);
    notifier.startWorkout(MockWorkoutData.pushDay);
    notifier.updateWeight(0, 0, '82.5');
    notifier.updateReps(0, 0, '8');
    notifier.toggleSetCompletion(0, 0);

    final result = notifier.finishWorkout();

    expect(result!.completedDailyGoals, 1);
    expect(container.read(dailyGoalsProvider).goals.first.isCompleted, isTrue);
    expect(container.read(userProgressionProvider).currentXp, 125);
  });
}
