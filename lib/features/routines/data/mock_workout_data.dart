import 'package:stryde/features/routines/domain/entities/exercise.dart';
import 'package:stryde/features/routines/domain/entities/workout_routine.dart';

abstract final class MockWorkoutData {
  static const benchPress = Exercise(
    id: 'bench-press',
    name: 'Bench Press',
    primaryMuscle: 'Chest',
    equipment: 'Barbell',
    imageUrl: 'asset:assets/images/bench_press.png',
  );

  static const overheadPress = Exercise(
    id: 'overhead-press',
    name: 'Overhead Press',
    primaryMuscle: 'Shoulders',
    equipment: 'Barbell',
    imageUrl: 'asset:assets/images/bench_press.png',
  );

  static const tricepsPushdown = Exercise(
    id: 'triceps-pushdown',
    name: 'Triceps Pushdown',
    primaryMuscle: 'Triceps',
    equipment: 'Cable',
    imageUrl: 'asset:assets/images/bench_press.png',
  );

  static const pullUp = Exercise(
    id: 'pull-up',
    name: 'Pull Up',
    primaryMuscle: 'Back',
    equipment: 'Bodyweight',
    imageUrl: 'asset:assets/images/pullup.png',
  );

  static const barbellRow = Exercise(
    id: 'barbell-row',
    name: 'Barbell Row',
    primaryMuscle: 'Back',
    equipment: 'Barbell',
    imageUrl: 'asset:assets/images/pullup.png',
  );

  static const bicepsCurl = Exercise(
    id: 'biceps-curl',
    name: 'Biceps Curl',
    primaryMuscle: 'Biceps',
    equipment: 'Dumbbells',
    imageUrl: 'asset:assets/images/generic.png',
  );

  static const squat = Exercise(
    id: 'squat',
    name: 'Squat',
    primaryMuscle: 'Quadriceps',
    equipment: 'Barbell',
    imageUrl: 'asset:assets/images/squat.png',
  );

  static const romanianDeadlift = Exercise(
    id: 'romanian-deadlift',
    name: 'Romanian Deadlift',
    primaryMuscle: 'Hamstrings',
    equipment: 'Barbell',
    imageUrl: 'asset:assets/images/squat.png',
  );

  static const legExtension = Exercise(
    id: 'leg-extension',
    name: 'Leg Extension',
    primaryMuscle: 'Quadriceps',
    equipment: 'Machine',
    imageUrl: 'asset:assets/images/squat.png',
  );

  static const pushDay = WorkoutRoutine(
    id: 'push-day',
    name: 'Push Day',
    focus: 'Chest · Shoulders · Triceps',
    estimatedMinutes: 55,
    exercises: <RoutineExercise>[
      RoutineExercise(exercise: benchPress, targetSets: 4, targetReps: 8),
      RoutineExercise(exercise: overheadPress, targetSets: 3, targetReps: 10),
      RoutineExercise(exercise: tricepsPushdown, targetSets: 3, targetReps: 12),
    ],
  );

  static const pullDay = WorkoutRoutine(
    id: 'pull-day',
    name: 'Pull Day',
    focus: 'Back · Biceps',
    estimatedMinutes: 50,
    exercises: <RoutineExercise>[
      RoutineExercise(exercise: pullUp, targetSets: 3, targetReps: 8),
      RoutineExercise(exercise: barbellRow, targetSets: 4, targetReps: 8),
      RoutineExercise(exercise: bicepsCurl, targetSets: 3, targetReps: 12),
    ],
  );

  static const legDay = WorkoutRoutine(
    id: 'leg-day',
    name: 'Leg Day',
    focus: 'Quads · Hamstrings · Glutes',
    estimatedMinutes: 60,
    exercises: <RoutineExercise>[
      RoutineExercise(exercise: squat, targetSets: 4, targetReps: 8),
      RoutineExercise(
        exercise: romanianDeadlift,
        targetSets: 3,
        targetReps: 10,
      ),
      RoutineExercise(exercise: legExtension, targetSets: 3, targetReps: 12),
    ],
  );

  static const freeTraining = WorkoutRoutine(
    id: 'free-training',
    name: 'Free Training',
    focus: 'Build your session as you go',
    estimatedMinutes: 0,
    exercises: <RoutineExercise>[],
    isCustom: true,
  );

  static const routines = <WorkoutRoutine>[pushDay, pullDay, legDay];

  static WorkoutRoutine? routineById(String id) {
    for (final routine in routines) {
      if (routine.id == id) return routine;
    }
    return null;
  }
}
