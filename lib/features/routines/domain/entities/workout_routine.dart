import 'package:stryde/features/routines/domain/entities/exercise.dart';

class WorkoutRoutine {
  const WorkoutRoutine({
    required this.id,
    required this.name,
    required this.focus,
    required this.estimatedMinutes,
    required this.exercises,
    this.isCustom = false,
  });

  final String id;
  final String name;
  final String focus;
  final int estimatedMinutes;
  final List<RoutineExercise> exercises;
  final bool isCustom;
}

class RoutineExercise {
  const RoutineExercise({
    required this.exercise,
    required this.targetSets,
    required this.targetReps,
  }) : assert(targetSets > 0),
       assert(targetReps > 0);

  final Exercise exercise;
  final int targetSets;
  final int targetReps;

  RoutineExercise copyWith({int? targetSets, int? targetReps}) {
    return RoutineExercise(
      exercise: exercise,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
    );
  }
}
