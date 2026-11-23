import 'package:stryde/features/routines/domain/entities/exercise.dart';
import 'package:stryde/features/routines/domain/entities/workout_routine.dart';

abstract final class MockWorkoutData {
  // Push Day Exercises
  static const benchPress = Exercise(
    id: 'bench-press',
    name: 'Bench Press',
    primaryMuscle: 'Chest',
    equipment: 'Barbell',
    imageUrl: 'asset:assets/images/bench_press.png',
    localImage: 'assets/Visuals/images/bench_press.jpg',
  );

  static const inclineDumbbellPress = Exercise(
    id: 'incline-dumbbell-press',
    name: 'Incline Dumbbell Press',
    primaryMuscle: 'Chest',
    equipment: 'Dumbbell',
    imageUrl: 'asset:assets/images/bench_press.png',
    localImage: 'assets/Visuals/images/incline_dumbbell_press.jpg',
  );

  static const overheadPress = Exercise(
    id: 'overhead-press',
    name: 'Overhead Press',
    primaryMuscle: 'Shoulders',
    equipment: 'Barbell',
    imageUrl: 'asset:assets/images/bench_press.png',
    localImage: 'assets/Visuals/images/seated_barbell_shoulder_press.jpg',
  );

  static const dumbbellLateralRaise = Exercise(
    id: 'dumbbell-lateral-raise',
    name: 'Dumbbell Lateral Raise',
    primaryMuscle: 'Shoulders',
    equipment: 'Dumbbell',
    imageUrl: 'asset:assets/images/generic.png',
    localImage: 'assets/Visuals/images/dumbbell_lateral_raise.jpg',
  );

  static const skullCrusher = Exercise(
    id: 'skull-crusher',
    name: 'Skull Crusher',
    primaryMuscle: 'Triceps',
    equipment: 'EZ Bar',
    imageUrl: 'asset:assets/images/bench_press.png',
    localImage: 'assets/Visuals/images/skull_crusher.jpg',
  );

  static const tricepsPushdown = Exercise(
    id: 'triceps-pushdown',
    name: 'Triceps Pushdown',
    primaryMuscle: 'Triceps',
    equipment: 'Cable',
    imageUrl: 'asset:assets/images/bench_press.png',
    localImage: 'assets/Visuals/images/triceps_pushdown.jpg',
  );

  // Pull Day Exercises
  static const pullUp = Exercise(
    id: 'pull-up',
    name: 'Pull Up',
    primaryMuscle: 'Back',
    equipment: 'Bodyweight',
    imageUrl: 'asset:assets/images/pullup.png',
    localImage: 'assets/Visuals/images/pull_up.jpg',
  );

  static const barbellRow = Exercise(
    id: 'barbell-row',
    name: 'Barbell Row',
    primaryMuscle: 'Back',
    equipment: 'Barbell',
    imageUrl: 'asset:assets/images/pullup.png',
    localImage: 'assets/Visuals/images/barbell_row.jpg',
  );

  static const latPulldown = Exercise(
    id: 'lat-pulldown',
    name: 'Lat Pulldown',
    primaryMuscle: 'Back',
    equipment: 'Cable',
    imageUrl: 'asset:assets/images/pullup.png',
    localImage: 'assets/Visuals/images/lat_pulldown.jpg',
  );

  static const seatedCableRow = Exercise(
    id: 'seated-cable-row',
    name: 'Seated Cable Row',
    primaryMuscle: 'Back',
    equipment: 'Cable',
    imageUrl: 'asset:assets/images/pullup.png',
    localImage: 'assets/Visuals/images/seated_cable_row.jpg',
  );

  static const inclineDumbbellCurl = Exercise(
    id: 'incline-dumbbell-curl',
    name: 'Incline Dumbbell Curl',
    primaryMuscle: 'Biceps',
    equipment: 'Dumbbell',
    imageUrl: 'asset:assets/images/generic.png',
    localImage: 'assets/Visuals/images/incline_dumbbell_curl.jpg',
  );

  static const hammerCurl = Exercise(
    id: 'hammer-curl',
    name: 'Hammer Curl',
    primaryMuscle: 'Biceps',
    equipment: 'Dumbbell',
    imageUrl: 'asset:assets/images/generic.png',
    localImage: 'assets/Visuals/images/hammer_curl.jpg',
  );

  // Leg Day Exercises
  static const squat = Exercise(
    id: 'squat',
    name: 'Squat',
    primaryMuscle: 'Quadriceps',
    equipment: 'Barbell',
    imageUrl: 'asset:assets/images/squat.png',
    localImage: 'assets/Visuals/images/back_squat.jpg',
  );

  static const romanianDeadlift = Exercise(
    id: 'romanian-deadlift',
    name: 'Romanian Deadlift',
    primaryMuscle: 'Hamstrings',
    equipment: 'Barbell',
    imageUrl: 'asset:assets/images/squat.png',
    localImage: 'assets/Visuals/images/romanian_deadlift.jpg',
  );

  static const legPress = Exercise(
    id: 'leg-press',
    name: 'Leg Press',
    primaryMuscle: 'Quadriceps',
    equipment: 'Machine',
    imageUrl: 'asset:assets/images/squat.png',
    localImage: 'assets/Visuals/images/leg_press.jpg',
  );

  static const legExtension = Exercise(
    id: 'leg-extension',
    name: 'Leg Extension',
    primaryMuscle: 'Quadriceps',
    equipment: 'Machine',
    imageUrl: 'asset:assets/images/squat.png',
    localImage: 'assets/Visuals/images/leg_extension.jpg',
  );

  static const lyingLegCurl = Exercise(
    id: 'lying-leg-curl',
    name: 'Lying Leg Curl',
    primaryMuscle: 'Hamstrings',
    equipment: 'Machine',
    imageUrl: 'asset:assets/images/squat.png',
    localImage: 'assets/Visuals/images/lying_leg_curl.jpg',
  );

  static const standingCalfRaise = Exercise(
    id: 'standing-calf-raise',
    name: 'Standing Calf Raise',
    primaryMuscle: 'Calves',
    equipment: 'Machine',
    imageUrl: 'asset:assets/images/squat.png',
    localImage: 'assets/Visuals/images/standing_calf_raise.jpg',
  );

  // Backward compatibility alias
  static const bicepsCurl = hammerCurl;

  static const pushDay = WorkoutRoutine(
    id: 'push-day',
    name: 'Push Day',
    focus: 'Chest · Shoulders · Triceps',
    estimatedMinutes: 65,
    exercises: <RoutineExercise>[
      RoutineExercise(exercise: benchPress, targetSets: 4, targetReps: 8),
      RoutineExercise(
        exercise: inclineDumbbellPress,
        targetSets: 3,
        targetReps: 10,
      ),
      RoutineExercise(exercise: overheadPress, targetSets: 3, targetReps: 10),
      RoutineExercise(
        exercise: dumbbellLateralRaise,
        targetSets: 3,
        targetReps: 12,
      ),
      RoutineExercise(exercise: skullCrusher, targetSets: 3, targetReps: 10),
      RoutineExercise(exercise: tricepsPushdown, targetSets: 3, targetReps: 12),
    ],
  );

  static const pullDay = WorkoutRoutine(
    id: 'pull-day',
    name: 'Pull Day',
    focus: 'Back · Biceps',
    estimatedMinutes: 60,
    exercises: <RoutineExercise>[
      RoutineExercise(exercise: pullUp, targetSets: 3, targetReps: 8),
      RoutineExercise(exercise: barbellRow, targetSets: 4, targetReps: 8),
      RoutineExercise(exercise: latPulldown, targetSets: 3, targetReps: 10),
      RoutineExercise(exercise: seatedCableRow, targetSets: 3, targetReps: 12),
      RoutineExercise(
        exercise: inclineDumbbellCurl,
        targetSets: 3,
        targetReps: 10,
      ),
      RoutineExercise(exercise: hammerCurl, targetSets: 3, targetReps: 12),
    ],
  );

  static const legDay = WorkoutRoutine(
    id: 'leg-day',
    name: 'Leg Day',
    focus: 'Quads · Hamstrings · Glutes · Calves',
    estimatedMinutes: 65,
    exercises: <RoutineExercise>[
      RoutineExercise(exercise: squat, targetSets: 4, targetReps: 8),
      RoutineExercise(
        exercise: romanianDeadlift,
        targetSets: 3,
        targetReps: 10,
      ),
      RoutineExercise(exercise: legPress, targetSets: 3, targetReps: 10),
      RoutineExercise(exercise: legExtension, targetSets: 3, targetReps: 12),
      RoutineExercise(exercise: lyingLegCurl, targetSets: 3, targetReps: 12),
      RoutineExercise(
        exercise: standingCalfRaise,
        targetSets: 4,
        targetReps: 15,
      ),
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
