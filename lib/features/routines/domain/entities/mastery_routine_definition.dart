import 'package:stryde/features/routines/data/mock_workout_data.dart';
import 'package:stryde/features/routines/domain/entities/exercise.dart';
import 'package:stryde/features/routines/domain/entities/workout_routine.dart';

class MasteryRoutineDefinition {
  const MasteryRoutineDefinition({
    required this.id,
    required this.name,
    required this.focus,
    required this.requiredPoints,
    required this.targetMuscleGroups,
    required this.defaultExercises,
    required this.estimatedMinutes,
  });

  final String id;
  final String name;
  final String focus;
  final Map<String, int> requiredPoints;
  final List<String> targetMuscleGroups;
  final List<RoutineExercise> defaultExercises;
  final int estimatedMinutes;

  bool isUnlocked(Map<String, int> allocations) {
    for (final entry in requiredPoints.entries) {
      final current = allocations[entry.key] ?? 0;
      if (current < entry.value) {
        return false;
      }
    }
    return true;
  }

  String get requirementsDescription {
    final parts = requiredPoints.entries
        .map((e) => '${e.value} ${e.key}')
        .toList(growable: false);
    if (parts.length == 1) {
      return 'Requires ${parts.first} points';
    }
    return 'Requires ${parts.join(' & ')} points';
  }

  WorkoutRoutine toDefaultRoutine() {
    return WorkoutRoutine(
      id: id,
      name: name,
      focus: focus,
      estimatedMinutes: estimatedMinutes,
      exercises: defaultExercises,
      isCustom: false,
    );
  }
}

class MasteryRoutineItem {
  const MasteryRoutineItem({
    required this.definition,
    required this.routine,
    required this.isUnlocked,
    required this.allocations,
  });

  final MasteryRoutineDefinition definition;
  final WorkoutRoutine routine;
  final bool isUnlocked;
  final Map<String, int> allocations;

  String get id => definition.id;
  String get name => definition.name;
  String get focus => definition.focus;
  String get requirementsDescription => definition.requirementsDescription;
}

abstract final class MasteryRoutineDefinitions {
  // Additional supplementary exercises with assets
  static const dumbbellFly = Exercise(
    id: 'dumbbell-fly',
    name: 'Dumbbell Fly',
    primaryMuscle: 'Chest',
    equipment: 'Dumbbell',
    imageUrl: 'asset:assets/images/bench_press.png',
    localImage: 'assets/Visuals/images/dumbbell_fly.jpg',
  );

  static const cableFly = Exercise(
    id: 'cable-fly',
    name: 'Cable Fly',
    primaryMuscle: 'Chest',
    equipment: 'Cable',
    imageUrl: 'asset:assets/images/bench_press.png',
    localImage: 'assets/Visuals/images/cable_fly.jpg',
  );

  static const dumbbellShoulderPress = Exercise(
    id: 'dumbbell-shoulder-press',
    name: 'Dumbbell Shoulder Press',
    primaryMuscle: 'Shoulders',
    equipment: 'Dumbbell',
    imageUrl: 'asset:assets/images/bench_press.png',
    localImage: 'assets/Visuals/images/dumbbell_shoulder_press.jpg',
  );

  static const cableLateralRaise = Exercise(
    id: 'cable-lateral-raise',
    name: 'Cable Lateral Raise',
    primaryMuscle: 'Shoulders',
    equipment: 'Cable',
    imageUrl: 'asset:assets/images/generic.png',
    localImage: 'assets/Visuals/images/cable_lateral_raise.jpg',
  );

  static const barbellCurl = Exercise(
    id: 'barbell-curl',
    name: 'Barbell Curl',
    primaryMuscle: 'Biceps',
    equipment: 'Barbell',
    imageUrl: 'asset:assets/images/generic.png',
    localImage: 'assets/Visuals/images/barbell_curl.jpg',
  );

  static const preacherCurl = Exercise(
    id: 'preacher-curl',
    name: 'Preacher Curl',
    primaryMuscle: 'Biceps',
    equipment: 'EZ Bar',
    imageUrl: 'asset:assets/images/generic.png',
    localImage: 'assets/Visuals/images/preacher_curl.jpg',
  );

  static const closeGripBenchPress = Exercise(
    id: 'close-grip-bench-press',
    name: 'Close Grip Bench Press',
    primaryMuscle: 'Triceps',
    equipment: 'Barbell',
    imageUrl: 'asset:assets/images/bench_press.png',
    localImage: 'assets/Visuals/images/close_grip_bench_press.jpg',
  );

  static const ropePushdown = Exercise(
    id: 'rope-pushdown',
    name: 'Rope Pushdown',
    primaryMuscle: 'Triceps',
    equipment: 'Cable',
    imageUrl: 'asset:assets/images/bench_press.png',
    localImage: 'assets/Visuals/images/rope_pushdown.jpg',
  );

  // 1. Chest Mastery
  static const chestMastery = MasteryRoutineDefinition(
    id: 'chest-mastery',
    name: 'Chest Mastery',
    focus: 'Hypertrophy · Pectoral Specialization',
    requiredPoints: <String, int>{'Chest': 5},
    targetMuscleGroups: <String>['Chest'],
    estimatedMinutes: 50,
    defaultExercises: <RoutineExercise>[
      RoutineExercise(
        exercise: MockWorkoutData.benchPress,
        targetSets: 4,
        targetReps: 8,
      ),
      RoutineExercise(
        exercise: MockWorkoutData.inclineDumbbellPress,
        targetSets: 3,
        targetReps: 10,
      ),
      RoutineExercise(exercise: dumbbellFly, targetSets: 3, targetReps: 12),
      RoutineExercise(exercise: cableFly, targetSets: 3, targetReps: 12),
    ],
  );

  // 2. Back Mastery
  static const backMastery = MasteryRoutineDefinition(
    id: 'back-mastery',
    name: 'Back Mastery',
    focus: 'Width & Thickness · Lat & Trap Specialization',
    requiredPoints: <String, int>{'Back': 5},
    targetMuscleGroups: <String>['Back'],
    estimatedMinutes: 55,
    defaultExercises: <RoutineExercise>[
      RoutineExercise(
        exercise: MockWorkoutData.pullUp,
        targetSets: 3,
        targetReps: 8,
      ),
      RoutineExercise(
        exercise: MockWorkoutData.barbellRow,
        targetSets: 4,
        targetReps: 8,
      ),
      RoutineExercise(
        exercise: MockWorkoutData.latPulldown,
        targetSets: 3,
        targetReps: 10,
      ),
      RoutineExercise(
        exercise: MockWorkoutData.seatedCableRow,
        targetSets: 3,
        targetReps: 12,
      ),
    ],
  );

  // 3. Legs Mastery
  static const legsMastery = MasteryRoutineDefinition(
    id: 'legs-mastery',
    name: 'Legs Mastery',
    focus: 'Lower Body Power · Quad & Posterior Chain',
    requiredPoints: <String, int>{'Legs': 5},
    targetMuscleGroups: <String>['Legs'],
    estimatedMinutes: 65,
    defaultExercises: <RoutineExercise>[
      RoutineExercise(
        exercise: MockWorkoutData.squat,
        targetSets: 4,
        targetReps: 8,
      ),
      RoutineExercise(
        exercise: MockWorkoutData.romanianDeadlift,
        targetSets: 3,
        targetReps: 10,
      ),
      RoutineExercise(
        exercise: MockWorkoutData.legPress,
        targetSets: 3,
        targetReps: 10,
      ),
      RoutineExercise(
        exercise: MockWorkoutData.legExtension,
        targetSets: 3,
        targetReps: 12,
      ),
      RoutineExercise(
        exercise: MockWorkoutData.lyingLegCurl,
        targetSets: 3,
        targetReps: 12,
      ),
      RoutineExercise(
        exercise: MockWorkoutData.standingCalfRaise,
        targetSets: 4,
        targetReps: 15,
      ),
    ],
  );

  // 4. Shoulders Mastery
  static const shouldersMastery = MasteryRoutineDefinition(
    id: 'shoulders-mastery',
    name: 'Shoulders Mastery',
    focus: 'Deltoid Definition · Overhead & Lateral Focus',
    requiredPoints: <String, int>{'Shoulders': 5},
    targetMuscleGroups: <String>['Shoulders'],
    estimatedMinutes: 50,
    defaultExercises: <RoutineExercise>[
      RoutineExercise(
        exercise: MockWorkoutData.overheadPress,
        targetSets: 4,
        targetReps: 8,
      ),
      RoutineExercise(
        exercise: MockWorkoutData.dumbbellLateralRaise,
        targetSets: 4,
        targetReps: 12,
      ),
      RoutineExercise(
        exercise: dumbbellShoulderPress,
        targetSets: 3,
        targetReps: 10,
      ),
      RoutineExercise(
        exercise: cableLateralRaise,
        targetSets: 3,
        targetReps: 12,
      ),
    ],
  );

  // 5. Biceps Mastery
  static const bicepsMastery = MasteryRoutineDefinition(
    id: 'biceps-mastery',
    name: 'Biceps Mastery',
    focus: 'Arm Hypertrophy · Peak & Grip Development',
    requiredPoints: <String, int>{'Biceps': 5},
    targetMuscleGroups: <String>['Biceps'],
    estimatedMinutes: 45,
    defaultExercises: <RoutineExercise>[
      RoutineExercise(
        exercise: MockWorkoutData.inclineDumbbellCurl,
        targetSets: 4,
        targetReps: 10,
      ),
      RoutineExercise(
        exercise: MockWorkoutData.hammerCurl,
        targetSets: 4,
        targetReps: 10,
      ),
      RoutineExercise(exercise: barbellCurl, targetSets: 3, targetReps: 10),
      RoutineExercise(exercise: preacherCurl, targetSets: 3, targetReps: 12),
    ],
  );

  // 6. Triceps Mastery
  static const tricepsMastery = MasteryRoutineDefinition(
    id: 'triceps-mastery',
    name: 'Triceps Mastery',
    focus: 'Triceps Lockout · Horseshoe Definition',
    requiredPoints: <String, int>{'Triceps': 5},
    targetMuscleGroups: <String>['Triceps'],
    estimatedMinutes: 45,
    defaultExercises: <RoutineExercise>[
      RoutineExercise(
        exercise: MockWorkoutData.skullCrusher,
        targetSets: 4,
        targetReps: 10,
      ),
      RoutineExercise(
        exercise: MockWorkoutData.tricepsPushdown,
        targetSets: 4,
        targetReps: 12,
      ),
      RoutineExercise(
        exercise: closeGripBenchPress,
        targetSets: 3,
        targetReps: 10,
      ),
      RoutineExercise(exercise: ropePushdown, targetSets: 3, targetReps: 12),
    ],
  );

  // 7. Chest + Triceps Mastery
  static const chestTricepsMastery = MasteryRoutineDefinition(
    id: 'chest-triceps-mastery',
    name: 'Chest + Triceps Mastery',
    focus: 'Upper Push · Chest & Triceps Synergy',
    requiredPoints: <String, int>{'Chest': 5, 'Triceps': 5},
    targetMuscleGroups: <String>['Chest', 'Triceps'],
    estimatedMinutes: 60,
    defaultExercises: <RoutineExercise>[
      RoutineExercise(
        exercise: MockWorkoutData.benchPress,
        targetSets: 4,
        targetReps: 8,
      ),
      RoutineExercise(
        exercise: MockWorkoutData.inclineDumbbellPress,
        targetSets: 3,
        targetReps: 10,
      ),
      RoutineExercise(
        exercise: MockWorkoutData.skullCrusher,
        targetSets: 3,
        targetReps: 10,
      ),
      RoutineExercise(
        exercise: MockWorkoutData.tricepsPushdown,
        targetSets: 3,
        targetReps: 12,
      ),
      RoutineExercise(exercise: cableFly, targetSets: 3, targetReps: 12),
    ],
  );

  // 8. Arms Mastery (Biceps + Triceps)
  static const armsMastery = MasteryRoutineDefinition(
    id: 'arms-mastery',
    name: 'Arms Mastery',
    focus: 'Biceps & Triceps Complete Isolation',
    requiredPoints: <String, int>{'Biceps': 5, 'Triceps': 5},
    targetMuscleGroups: <String>['Biceps', 'Triceps'],
    estimatedMinutes: 55,
    defaultExercises: <RoutineExercise>[
      RoutineExercise(
        exercise: MockWorkoutData.inclineDumbbellCurl,
        targetSets: 3,
        targetReps: 10,
      ),
      RoutineExercise(
        exercise: MockWorkoutData.skullCrusher,
        targetSets: 3,
        targetReps: 10,
      ),
      RoutineExercise(
        exercise: MockWorkoutData.hammerCurl,
        targetSets: 3,
        targetReps: 12,
      ),
      RoutineExercise(
        exercise: MockWorkoutData.tricepsPushdown,
        targetSets: 3,
        targetReps: 12,
      ),
      RoutineExercise(exercise: barbellCurl, targetSets: 3, targetReps: 10),
    ],
  );

  // 9. Legs + Shoulders Mastery
  static const legsShouldersMastery = MasteryRoutineDefinition(
    id: 'legs-shoulders-mastery',
    name: 'Legs + Shoulders Mastery',
    focus: 'Full Body Pillar · Squats & Delts',
    requiredPoints: <String, int>{'Legs': 5, 'Shoulders': 5},
    targetMuscleGroups: <String>['Legs', 'Shoulders'],
    estimatedMinutes: 65,
    defaultExercises: <RoutineExercise>[
      RoutineExercise(
        exercise: MockWorkoutData.squat,
        targetSets: 4,
        targetReps: 8,
      ),
      RoutineExercise(
        exercise: MockWorkoutData.overheadPress,
        targetSets: 4,
        targetReps: 8,
      ),
      RoutineExercise(
        exercise: MockWorkoutData.romanianDeadlift,
        targetSets: 3,
        targetReps: 10,
      ),
      RoutineExercise(
        exercise: MockWorkoutData.dumbbellLateralRaise,
        targetSets: 4,
        targetReps: 12,
      ),
      RoutineExercise(
        exercise: MockWorkoutData.legExtension,
        targetSets: 3,
        targetReps: 12,
      ),
    ],
  );

  // 10. Back + Biceps Mastery
  static const backBicepsMastery = MasteryRoutineDefinition(
    id: 'back-biceps-mastery',
    name: 'Back + Biceps Mastery',
    focus: 'Pull Specialization · Back & Arm Synergy',
    requiredPoints: <String, int>{'Back': 5, 'Biceps': 5},
    targetMuscleGroups: <String>['Back', 'Biceps'],
    estimatedMinutes: 60,
    defaultExercises: <RoutineExercise>[
      RoutineExercise(
        exercise: MockWorkoutData.pullUp,
        targetSets: 3,
        targetReps: 8,
      ),
      RoutineExercise(
        exercise: MockWorkoutData.barbellRow,
        targetSets: 4,
        targetReps: 8,
      ),
      RoutineExercise(
        exercise: MockWorkoutData.latPulldown,
        targetSets: 3,
        targetReps: 10,
      ),
      RoutineExercise(
        exercise: MockWorkoutData.inclineDumbbellCurl,
        targetSets: 3,
        targetReps: 10,
      ),
      RoutineExercise(
        exercise: MockWorkoutData.hammerCurl,
        targetSets: 3,
        targetReps: 12,
      ),
    ],
  );

  // 11. Chest + Back Mastery
  static const chestBackMastery = MasteryRoutineDefinition(
    id: 'chest-back-mastery',
    name: 'Chest + Back Mastery',
    focus: 'Antagonist Upper Body · Push-Pull Balance',
    requiredPoints: <String, int>{'Chest': 5, 'Back': 5},
    targetMuscleGroups: <String>['Chest', 'Back'],
    estimatedMinutes: 65,
    defaultExercises: <RoutineExercise>[
      RoutineExercise(
        exercise: MockWorkoutData.benchPress,
        targetSets: 4,
        targetReps: 8,
      ),
      RoutineExercise(
        exercise: MockWorkoutData.pullUp,
        targetSets: 3,
        targetReps: 8,
      ),
      RoutineExercise(
        exercise: MockWorkoutData.inclineDumbbellPress,
        targetSets: 3,
        targetReps: 10,
      ),
      RoutineExercise(
        exercise: MockWorkoutData.barbellRow,
        targetSets: 4,
        targetReps: 8,
      ),
      RoutineExercise(
        exercise: MockWorkoutData.seatedCableRow,
        targetSets: 3,
        targetReps: 12,
      ),
    ],
  );

  static const List<MasteryRoutineDefinition> all = <MasteryRoutineDefinition>[
    chestMastery,
    backMastery,
    legsMastery,
    shouldersMastery,
    bicepsMastery,
    tricepsMastery,
    chestTricepsMastery,
    armsMastery,
    legsShouldersMastery,
    backBicepsMastery,
    chestBackMastery,
  ];

  static WorkoutRoutine? findDefaultRoutineById(String id) {
    for (final def in all) {
      if (def.id == id) return def.toDefaultRoutine();
    }
    return null;
  }
}
