import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stryde/features/routines/domain/entities/exercise.dart';
import 'package:stryde/features/routines/domain/entities/workout_routine.dart';
import 'package:stryde/features/workout_logging/presentation/providers/active_workout_provider.dart';

void main() {
  test('workout logger validates each exercise type correctly', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(activeWorkoutProvider.notifier);

    final routine = WorkoutRoutine(
      id: 'mixed-routine',
      name: 'Mixed Routine',
      focus: 'All types',
      estimatedMinutes: 45,
      exercises: <RoutineExercise>[
        // 0: strength
        const RoutineExercise(
          exercise: Exercise(
            id: 'bench-press',
            name: 'Bench Press',
            primaryMuscle: 'Chest',
            equipment: 'Barbell',
            imageUrl: 'asset:assets/images/bench_press.png',
            type: ExerciseType.strength,
          ),
          targetSets: 1,
          targetReps: 8,
        ),
        // 1: bodyweight
        const RoutineExercise(
          exercise: Exercise(
            id: 'push-up',
            name: 'Push Up',
            primaryMuscle: 'Chest',
            equipment: 'Bodyweight',
            imageUrl: 'asset:assets/images/bench_press.png',
            type: ExerciseType.bodyweight,
          ),
          targetSets: 1,
          targetReps: 15,
        ),
        // 2: time
        const RoutineExercise(
          exercise: Exercise(
            id: 'plank',
            name: 'Plank',
            primaryMuscle: 'Abs',
            equipment: 'Bodyweight',
            imageUrl: 'asset:assets/images/bench_press.png',
            type: ExerciseType.time,
          ),
          targetSets: 1,
          targetReps: 1,
        ),
        // 3: resistance
        const RoutineExercise(
          exercise: Exercise(
            id: 'band-lateral-raise',
            name: 'Resistance Band Lateral Raise',
            primaryMuscle: 'Shoulders',
            equipment: 'Bands',
            imageUrl: 'asset:assets/images/bench_press.png',
            type: ExerciseType.resistance,
          ),
          targetSets: 1,
          targetReps: 12,
        ),
        // 4: cardio
        const RoutineExercise(
          exercise: Exercise(
            id: 'treadmill-run',
            name: 'Treadmill Run',
            primaryMuscle: 'Cardio',
            equipment: 'Other',
            imageUrl: 'asset:assets/images/generic.png',
            type: ExerciseType.cardio,
          ),
          targetSets: 1,
          targetReps: 1,
        ),
        // 5: incline_cardio
        const RoutineExercise(
          exercise: Exercise(
            id: 'incline-walk',
            name: 'Incline Treadmill Walk',
            primaryMuscle: 'Cardio',
            equipment: 'Other',
            imageUrl: 'asset:assets/images/generic.png',
            type: ExerciseType.inclineCardio,
          ),
          targetSets: 1,
          targetReps: 1,
        ),
        // 6: steps_cardio
        const RoutineExercise(
          exercise: Exercise(
            id: 'stair-climber',
            name: 'Stair Climber',
            primaryMuscle: 'Cardio',
            equipment: 'Other',
            imageUrl: 'asset:assets/images/generic.png',
            type: ExerciseType.stepsCardio,
          ),
          targetSets: 1,
          targetReps: 1,
        ),
      ],
    );

    notifier.startWorkout(routine);

    // 0: Strength - invalid without weight/reps
    expect(notifier.toggleSetCompletion(0, 0), SetCompletionResult.invalid);
    notifier.updateWeight(0, 0, '80');
    notifier.updateReps(0, 0, '8');
    expect(notifier.toggleSetCompletion(0, 0), SetCompletionResult.completed);

    // 1: Bodyweight - requires reps only (no weight needed)
    expect(notifier.toggleSetCompletion(1, 0), SetCompletionResult.completed);

    // 2: Time - invalid without MM:SS
    expect(notifier.toggleSetCompletion(2, 0), SetCompletionResult.invalid);
    notifier.updateTime(2, 0, '01:30');
    expect(notifier.toggleSetCompletion(2, 0), SetCompletionResult.completed);

    // 3: Resistance - invalid without resistance level
    expect(notifier.toggleSetCompletion(3, 0), SetCompletionResult.invalid);
    notifier.updateResistance(3, 0, 'Medium');
    expect(notifier.toggleSetCompletion(3, 0), SetCompletionResult.completed);

    // 4: Cardio - invalid without duration & distance
    expect(notifier.toggleSetCompletion(4, 0), SetCompletionResult.invalid);
    notifier.updateTime(4, 0, '15:00');
    notifier.updateDistance(4, 0, '2.5');
    expect(notifier.toggleSetCompletion(4, 0), SetCompletionResult.completed);

    // 5: Incline Cardio - invalid without incline, distance & time
    expect(notifier.toggleSetCompletion(5, 0), SetCompletionResult.invalid);
    notifier.updateIncline(5, 0, '8.0');
    notifier.updateDistance(5, 0, '1.5');
    notifier.updateTime(5, 0, '20:00');
    expect(notifier.toggleSetCompletion(5, 0), SetCompletionResult.completed);

    // 6: Steps Cardio - invalid without steps & time
    expect(notifier.toggleSetCompletion(6, 0), SetCompletionResult.invalid);
    notifier.updateSteps(6, 0, '1200');
    notifier.updateTime(6, 0, '12:00');
    expect(notifier.toggleSetCompletion(6, 0), SetCompletionResult.completed);

    // Finish workout and verify mapping
    final finishResult = notifier.finishWorkout();
    expect(finishResult, isNotNull);
    final workout = finishResult!.workout;
    expect(workout.exercises.length, 7);

    // Check strength set
    final strengthSet = workout.exercises[0].sets.first;
    expect(strengthSet.weightKg, 80);
    expect(strengthSet.reps, 8);

    // Check bodyweight set
    final bodyweightSet = workout.exercises[1].sets.first;
    expect(bodyweightSet.reps, 15);

    // Check time set
    final timeSet = workout.exercises[2].sets.first;
    expect(timeSet.durationSeconds, 90);

    // Check resistance set
    final resistanceSet = workout.exercises[3].sets.first;
    expect(resistanceSet.resistanceLevel, 'Medium');
    expect(resistanceSet.reps, 12);

    // Check cardio set
    final cardioSet = workout.exercises[4].sets.first;
    expect(cardioSet.durationSeconds, 900);
    expect(cardioSet.distance, 2.5);

    // Check incline cardio set
    final inclineSet = workout.exercises[5].sets.first;
    expect(inclineSet.incline, 8.0);
    expect(inclineSet.distance, 1.5);
    expect(inclineSet.durationSeconds, 1200);

    // Check steps cardio set
    final stepsSet = workout.exercises[6].sets.first;
    expect(stepsSet.steps, 1200);
    expect(stepsSet.durationSeconds, 720);
  });
}
