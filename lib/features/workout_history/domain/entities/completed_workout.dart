class CompletedWorkoutSet {
  const CompletedWorkoutSet({
    required this.setNumber,
    required this.weightKg,
    required this.reps,
  });

  final int setNumber;
  final double weightKg;
  final int reps;

  double get volume => weightKg * reps;
}

class CompletedWorkoutExercise {
  const CompletedWorkoutExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
  });

  final String exerciseId;
  final String exerciseName;
  final List<CompletedWorkoutSet> sets;
}

class CompletedWorkout {
  const CompletedWorkout({
    required this.id,
    required this.routineId,
    required this.routineName,
    required this.completedAt,
    required this.duration,
    required this.exercises,
  });

  final String id;
  final String routineId;
  final String routineName;
  final DateTime completedAt;
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
}
