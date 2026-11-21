import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stryde/features/home/domain/services/daily_goal_matcher.dart';
import 'package:stryde/features/home/presentation/providers/daily_goals_provider.dart';
import 'package:stryde/features/progression/presentation/providers/user_progression_provider.dart';
import 'package:stryde/features/routines/data/mock_workout_data.dart';
import 'package:stryde/features/workout_history/domain/entities/completed_workout.dart';
import 'package:stryde/features/workout_history/presentation/providers/workout_history_provider.dart';

void main() {
  group('Daily Goal set matching', () {
    test('lower actual weight never completes the goal', () {
      expect(
        setMeetsDailyGoalTarget(
          targetWeight: 100,
          targetReps: 10,
          actualWeight: 99.5,
          actualReps: 20,
        ),
        isFalse,
      );
    });

    test('higher actual weight completes regardless of reps', () {
      expect(
        setMeetsDailyGoalTarget(
          targetWeight: 100,
          targetReps: 10,
          actualWeight: 100.5,
          actualReps: 1,
        ),
        isTrue,
      );
    });

    test('equal weight and reps completes the goal', () {
      expect(
        setMeetsDailyGoalTarget(
          targetWeight: 100,
          targetReps: 10,
          actualWeight: 100,
          actualReps: 10,
        ),
        isTrue,
      );
    });

    test('equal weight uses volume when reps differ', () {
      expect(
        setMeetsDailyGoalTarget(
          targetWeight: 100,
          targetReps: 10,
          actualWeight: 100,
          actualReps: 11,
        ),
        isTrue,
      );
      expect(
        setMeetsDailyGoalTarget(
          targetWeight: 100,
          targetReps: 10,
          actualWeight: 100,
          actualReps: 9,
        ),
        isFalse,
      );
    });
  });

  test('generated goals retain targets and auto-complete after a workout', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(workoutHistoryProvider.notifier)
        .addWorkout(_workout(weight: 80, reps: 10));

    final generatedGoal = container.read(dailyGoalsProvider).goals.first;
    expect(generatedGoal.exerciseId, MockWorkoutData.benchPress.id);
    expect(generatedGoal.targetWeight, 82.5);
    expect(generatedGoal.targetReps, 8);

    final completed = container
        .read(dailyGoalsProvider.notifier)
        .evaluateWorkout(_workout(weight: 82.5, reps: 8));

    expect(completed, 1);
    expect(container.read(dailyGoalsProvider).goals.first.isCompleted, isTrue);
    expect(container.read(userProgressionProvider).currentXp, 25);
  });
}

CompletedWorkout _workout({required double weight, required int reps}) {
  return CompletedWorkout(
    id: '$weight-$reps',
    routineId: MockWorkoutData.pushDay.id,
    routineName: MockWorkoutData.pushDay.name,
    completedAt: DateTime(2026, 11, 21),
    duration: const Duration(minutes: 30),
    exercises: <CompletedWorkoutExercise>[
      CompletedWorkoutExercise(
        exerciseId: MockWorkoutData.benchPress.id,
        exerciseName: MockWorkoutData.benchPress.name,
        sets: <CompletedWorkoutSet>[
          CompletedWorkoutSet(setNumber: 1, weightKg: weight, reps: reps),
        ],
      ),
    ],
  );
}
