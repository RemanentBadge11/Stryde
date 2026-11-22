class CompletedWorkoutSet {
  const CompletedWorkoutSet({
    required this.setNumber,
    this.weightKg = 0,
    this.reps = 0,
    this.durationSeconds,
    this.resistanceLevel,
    this.distance,
    this.incline,
    this.steps,
  });

  final int setNumber;
  final double weightKg;
  final int reps;
  final int? durationSeconds;
  final String? resistanceLevel;
  final double? distance;
  final double? incline;
  final int? steps;

  double get volume => weightKg * reps;
}

class CompletedWorkoutExercise {
  const CompletedWorkoutExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
    this.exerciseType = 'strength',
  });

  final String exerciseId;
  final String exerciseName;
  final List<CompletedWorkoutSet> sets;
  final String exerciseType;
}

class CompletedWorkout {
  const CompletedWorkout({
    required this.id,
    required this.routineId,
    required this.routineName,
    required this.completedAt,
    required this.duration,
    required this.exercises,
    this.startedAt,
  });

  final String id;
  final String routineId;
  final String routineName;
  final DateTime completedAt;
  final DateTime? startedAt;
  final Duration duration;
  final List<CompletedWorkoutExercise> exercises;

  int get totalSets =>
      exercises.fold<int>(0, (total, exercise) => total + exercise.sets.length);

  int get totalReps => exercises.fold<int>(
    0,
    (total, exercise) =>
        total + exercise.sets.fold<int>(0, (sum, set) => sum + set.reps),
  );

  double get totalVolume => exercises.fold<double>(
    0,
    (total, exercise) =>
        total + exercise.sets.fold<double>(0, (sum, set) => sum + set.volume),
  );

  CompletedWorkout copyWith({String? id}) {
    return CompletedWorkout(
      id: id ?? this.id,
      routineId: routineId,
      routineName: routineName,
      completedAt: completedAt,
      startedAt: startedAt,
      duration: duration,
      exercises: exercises,
    );
  }
}
