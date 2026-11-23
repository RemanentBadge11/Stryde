import 'package:stryde/features/routines/data/mock_workout_data.dart';
import 'package:stryde/features/routines/domain/entities/exercise.dart';
import 'package:stryde/features/routines/domain/entities/mastery_routine_definition.dart';
import 'package:stryde/features/routines/domain/entities/workout_routine.dart';
import 'package:stryde/features/workout_history/domain/entities/completed_workout.dart';

class _ExerciseHistoryStats {
  _ExerciseHistoryStats({
    required this.exerciseId,
    required this.exerciseName,
    required this.muscleGroup,
  });

  final String exerciseId;
  final String exerciseName;
  final String muscleGroup;
  int frequency = 0;
  int totalSets = 0;
  int totalReps = 0;
  int totalRepsCount = 0;
  DateTime? latestCompletion;

  int get averageSets {
    if (frequency == 0) return 3;
    final avg = (totalSets / frequency).round();
    return avg.clamp(3, 4);
  }

  int get averageReps {
    if (totalRepsCount == 0) return 10;
    final avg = (totalReps / totalRepsCount).round();
    return avg.clamp(6, 15);
  }
}

class MasteryPersonalizationEngine {
  const MasteryPersonalizationEngine();

  static final Map<String, Exercise> _knownExerciseCatalog = () {
    final map = <String, Exercise>{};
    void add(Exercise ex) {
      map[ex.id.toLowerCase()] = ex;
      map[ex.name.toLowerCase()] = ex;
    }

    add(MockWorkoutData.benchPress);
    add(MockWorkoutData.inclineDumbbellPress);
    add(MockWorkoutData.overheadPress);
    add(MockWorkoutData.dumbbellLateralRaise);
    add(MockWorkoutData.skullCrusher);
    add(MockWorkoutData.tricepsPushdown);
    add(MockWorkoutData.pullUp);
    add(MockWorkoutData.barbellRow);
    add(MockWorkoutData.latPulldown);
    add(MockWorkoutData.seatedCableRow);
    add(MockWorkoutData.inclineDumbbellCurl);
    add(MockWorkoutData.hammerCurl);
    add(MockWorkoutData.squat);
    add(MockWorkoutData.romanianDeadlift);
    add(MockWorkoutData.legPress);
    add(MockWorkoutData.legExtension);
    add(MockWorkoutData.lyingLegCurl);
    add(MockWorkoutData.standingCalfRaise);

    add(MasteryRoutineDefinitions.dumbbellFly);
    add(MasteryRoutineDefinitions.cableFly);
    add(MasteryRoutineDefinitions.dumbbellShoulderPress);
    add(MasteryRoutineDefinitions.cableLateralRaise);
    add(MasteryRoutineDefinitions.barbellCurl);
    add(MasteryRoutineDefinitions.preacherCurl);
    add(MasteryRoutineDefinitions.closeGripBenchPress);
    add(MasteryRoutineDefinitions.ropePushdown);

    return map;
  }();

  /// Maps an exercise ID, name, or primary muscle to one of the 6 skill groups:
  /// Chest, Back, Legs, Shoulders, Biceps, Triceps.
  static String? detectSkillMuscleGroup({
    required String exerciseId,
    required String exerciseName,
    String? primaryMuscle,
  }) {
    if (primaryMuscle != null && primaryMuscle.isNotEmpty) {
      final mapped = _mapPrimaryMuscle(primaryMuscle);
      if (mapped != null) return mapped;
    }

    final known =
        _knownExerciseCatalog[exerciseId.toLowerCase()] ??
        _knownExerciseCatalog[exerciseName.toLowerCase()];
    if (known != null) {
      final mapped = _mapPrimaryMuscle(known.primaryMuscle);
      if (mapped != null) return mapped;
    }

    final lower = '$exerciseId $exerciseName'.toLowerCase();
    if (lower.contains('bench press') ||
        lower.contains('chest') ||
        lower.contains('pec') ||
        lower.contains('push up') ||
        lower.contains('cable fly')) {
      return 'Chest';
    }
    if (lower.contains('pull up') ||
        lower.contains('chin up') ||
        lower.contains('row') ||
        lower.contains('lat pulldown') ||
        lower.contains('back') ||
        lower.contains('deadlift')) {
      return 'Back';
    }
    if (lower.contains('squat') ||
        lower.contains('leg') ||
        lower.contains('calf') ||
        lower.contains('quad') ||
        lower.contains('hamstring') ||
        lower.contains('lunge')) {
      return 'Legs';
    }
    if (lower.contains('overhead press') ||
        lower.contains('shoulder') ||
        lower.contains('lateral raise') ||
        lower.contains('delt')) {
      return 'Shoulders';
    }
    if (lower.contains('curl') || lower.contains('bicep')) {
      return 'Biceps';
    }
    if (lower.contains('skull crusher') ||
        lower.contains('pushdown') ||
        lower.contains('tricep') ||
        lower.contains('dip')) {
      return 'Triceps';
    }

    return null;
  }

  static String? _mapPrimaryMuscle(String muscle) {
    final lower = muscle.toLowerCase();
    if (lower == 'chest' || lower == 'pectorals') return 'Chest';
    if (lower == 'back' ||
        lower == 'lower back' ||
        lower == 'traps' ||
        lower == 'lats') {
      return 'Back';
    }
    if (lower == 'legs' ||
        lower == 'quadriceps' ||
        lower == 'hamstrings' ||
        lower == 'calves' ||
        lower == 'glutes' ||
        lower == 'adductors' ||
        lower == 'abductors') {
      return 'Legs';
    }
    if (lower == 'shoulders' || lower == 'deltoids') return 'Shoulders';
    if (lower == 'biceps' || lower == 'forearms') return 'Biceps';
    if (lower == 'triceps') return 'Triceps';
    return null;
  }

  static Exercise _resolveExercise({
    required String exerciseId,
    required String exerciseName,
    required String muscleGroup,
    List<RoutineExercise>? defaultList,
  }) {
    if (defaultList != null) {
      for (final def in defaultList) {
        if (def.exercise.id.toLowerCase() == exerciseId.toLowerCase() ||
            def.exercise.name.toLowerCase() == exerciseName.toLowerCase()) {
          return def.exercise;
        }
      }
    }

    final catalogMatch =
        _knownExerciseCatalog[exerciseId.toLowerCase()] ??
        _knownExerciseCatalog[exerciseName.toLowerCase()];
    if (catalogMatch != null) return catalogMatch;

    return Exercise(
      id: exerciseId,
      name: exerciseName,
      primaryMuscle: muscleGroup,
      equipment: 'Standard',
      imageUrl: 'asset:assets/images/generic.png',
      type: ExerciseType.strength,
    );
  }

  /// Personalizes a mastery routine based on the user's completed workout history.
  WorkoutRoutine personalize({
    required MasteryRoutineDefinition definition,
    required List<CompletedWorkout> history,
  }) {
    if (history.isEmpty) {
      return definition.toDefaultRoutine();
    }

    // Step 1: Collect exercise stats from history for target muscles
    final statsMap = <String, _ExerciseHistoryStats>{};

    for (final workout in history) {
      for (final ex in workout.exercises) {
        final muscle = detectSkillMuscleGroup(
          exerciseId: ex.exerciseId,
          exerciseName: ex.exerciseName,
        );
        if (muscle == null || !definition.targetMuscleGroups.contains(muscle)) {
          continue;
        }

        final key = ex.exerciseId.toLowerCase();
        final stats = statsMap.putIfAbsent(
          key,
          () => _ExerciseHistoryStats(
            exerciseId: ex.exerciseId,
            exerciseName: ex.exerciseName,
            muscleGroup: muscle,
          ),
        );

        stats.frequency += 1;
        stats.totalSets += ex.sets.length;
        if (stats.latestCompletion == null ||
            workout.completedAt.isAfter(stats.latestCompletion!)) {
          stats.latestCompletion = workout.completedAt;
        }
        for (final s in ex.sets) {
          if (s.reps > 0) {
            stats.totalReps += s.reps;
            stats.totalRepsCount += 1;
          }
        }
      }
    }

    if (statsMap.isEmpty) {
      return definition.toDefaultRoutine();
    }

    final selectedExercises = <RoutineExercise>[];
    final selectedIds = <String>{};

    void addExercise(RoutineExercise routineEx) {
      final idLower = routineEx.exercise.id.toLowerCase();
      if (!selectedIds.contains(idLower)) {
        selectedIds.add(idLower);
        selectedExercises.add(routineEx);
      }
    }

    // Single muscle group vs combined muscle groups
    if (definition.targetMuscleGroups.length == 1) {
      final targetMuscle = definition.targetMuscleGroups.first;
      final candidates =
          statsMap.values.where((s) => s.muscleGroup == targetMuscle).toList()
            ..sort((a, b) {
              final cmp = b.frequency.compareTo(a.frequency);
              if (cmp != 0) return cmp;
              final aDate = a.latestCompletion ?? DateTime(2000);
              final bDate = b.latestCompletion ?? DateTime(2000);
              return bDate.compareTo(aDate);
            });

      // Pick top up to 4 exercises from history
      for (final stat in candidates.take(4)) {
        final exerciseObj = _resolveExercise(
          exerciseId: stat.exerciseId,
          exerciseName: stat.exerciseName,
          muscleGroup: targetMuscle,
          defaultList: definition.defaultExercises,
        );
        addExercise(
          RoutineExercise(
            exercise: exerciseObj,
            targetSets: stat.averageSets,
            targetReps: stat.averageReps,
          ),
        );
      }

      // Supplement from defaults up to 4 exercises
      for (final defEx in definition.defaultExercises) {
        if (selectedExercises.length >= 4) break;
        addExercise(defEx);
      }
    } else {
      // Dual muscle group (e.g. Chest + Triceps, Biceps + Triceps, etc.)
      final muscleA = definition.targetMuscleGroups[0];
      final muscleB = definition.targetMuscleGroups[1];

      final candidatesA =
          statsMap.values.where((s) => s.muscleGroup == muscleA).toList()
            ..sort((a, b) => b.frequency.compareTo(a.frequency));

      final candidatesB =
          statsMap.values.where((s) => s.muscleGroup == muscleB).toList()
            ..sort((a, b) => b.frequency.compareTo(a.frequency));

      // Up to 3 from A, up to 3 from B
      final listA = <RoutineExercise>[];
      for (final stat in candidatesA.take(3)) {
        final exerciseObj = _resolveExercise(
          exerciseId: stat.exerciseId,
          exerciseName: stat.exerciseName,
          muscleGroup: muscleA,
          defaultList: definition.defaultExercises,
        );
        listA.add(
          RoutineExercise(
            exercise: exerciseObj,
            targetSets: stat.averageSets,
            targetReps: stat.averageReps,
          ),
        );
      }

      // Supplement muscle A from defaults if needed
      for (final defEx in definition.defaultExercises) {
        if (listA.length >= 3) break;
        final muscle = detectSkillMuscleGroup(
          exerciseId: defEx.exercise.id,
          exerciseName: defEx.exercise.name,
          primaryMuscle: defEx.exercise.primaryMuscle,
        );
        if (muscle == muscleA &&
            !listA.any(
              (e) =>
                  e.exercise.id.toLowerCase() ==
                  defEx.exercise.id.toLowerCase(),
            )) {
          listA.add(defEx);
        }
      }

      final listB = <RoutineExercise>[];
      for (final stat in candidatesB.take(3)) {
        final exerciseObj = _resolveExercise(
          exerciseId: stat.exerciseId,
          exerciseName: stat.exerciseName,
          muscleGroup: muscleB,
          defaultList: definition.defaultExercises,
        );
        listB.add(
          RoutineExercise(
            exercise: exerciseObj,
            targetSets: stat.averageSets,
            targetReps: stat.averageReps,
          ),
        );
      }

      // Supplement muscle B from defaults if needed
      for (final defEx in definition.defaultExercises) {
        if (listB.length >= 3) break;
        final muscle = detectSkillMuscleGroup(
          exerciseId: defEx.exercise.id,
          exerciseName: defEx.exercise.name,
          primaryMuscle: defEx.exercise.primaryMuscle,
        );
        if (muscle == muscleB &&
            !listB.any(
              (e) =>
                  e.exercise.id.toLowerCase() ==
                  defEx.exercise.id.toLowerCase(),
            )) {
          listB.add(defEx);
        }
      }

      // Interleave or combine muscle A and muscle B exercises
      for (final item in listA) {
        addExercise(item);
      }
      for (final item in listB) {
        addExercise(item);
      }
    }

    final estimatedMinutes = (selectedExercises.length * 11).clamp(40, 70);

    return WorkoutRoutine(
      id: definition.id,
      name: definition.name,
      focus: definition.focus,
      estimatedMinutes: estimatedMinutes,
      exercises: selectedExercises,
      isCustom: false,
    );
  }
}
