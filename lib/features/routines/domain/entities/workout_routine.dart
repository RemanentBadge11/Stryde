import 'package:stryde/features/routines/domain/entities/exercise.dart';

class WorkoutRoutine {
  const WorkoutRoutine({
    required this.id,
    required this.name,
    required this.focus,
    required this.estimatedMinutes,
    required this.exercises,
    this.isCustom = false,
    this.savedFromUsername,
  });

  final String id;
  final String name;
  final String focus;
  final int estimatedMinutes;
  final List<RoutineExercise> exercises;
  final bool isCustom;
  final String? savedFromUsername;

  WorkoutRoutine copyWith({
    String? id,
    String? name,
    String? focus,
    int? estimatedMinutes,
    List<RoutineExercise>? exercises,
    bool? isCustom,
    String? savedFromUsername,
  }) {
    return WorkoutRoutine(
      id: id ?? this.id,
      name: name ?? this.name,
      focus: focus ?? this.focus,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      exercises: exercises ?? this.exercises,
      isCustom: isCustom ?? this.isCustom,
      savedFromUsername: savedFromUsername ?? this.savedFromUsername,
    );
  }
}

class RoutineSetTarget {
  const RoutineSetTarget({
    this.weightKg,
    this.reps,
    this.durationSeconds,
    this.distance,
    this.incline,
    this.steps,
    this.resistanceLevel,
    this.setType,
    this.notes,
  });

  final double? weightKg;
  final int? reps;
  final int? durationSeconds;
  final double? distance;
  final double? incline;
  final int? steps;
  final String? resistanceLevel;
  final String? setType;
  final String? notes;
}

class RoutineExercise {
  const RoutineExercise({
    required this.exercise,
    required this.targetSets,
    this.targetReps,
    this.targetSetDetails,
  }) : assert(targetSets > 0),
       assert(targetReps == null || targetReps > 0);

  final Exercise exercise;
  final int targetSets;
  final int? targetReps;
  final List<RoutineSetTarget>? targetSetDetails;

  RoutineExercise copyWith({
    int? targetSets,
    int? targetReps,
    bool clearTargetReps = false,
    List<RoutineSetTarget>? targetSetDetails,
  }) {
    return RoutineExercise(
      exercise: exercise,
      targetSets: targetSets ?? this.targetSets,
      targetReps: clearTargetReps ? null : (targetReps ?? this.targetReps),
      targetSetDetails: targetSetDetails ?? this.targetSetDetails,
    );
  }
}
