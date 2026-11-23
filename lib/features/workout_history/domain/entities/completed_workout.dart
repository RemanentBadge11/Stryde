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

  Map<String, dynamic> toJson() => <String, dynamic>{
    'setNumber': setNumber,
    'weightKg': weightKg,
    'reps': reps,
    if (durationSeconds != null) 'durationSeconds': durationSeconds,
    if (resistanceLevel != null) 'resistanceLevel': resistanceLevel,
    if (distance != null) 'distance': distance,
    if (incline != null) 'incline': incline,
    if (steps != null) 'steps': steps,
  };

  factory CompletedWorkoutSet.fromJson(Map<String, dynamic> json) =>
      CompletedWorkoutSet(
        setNumber: json['setNumber'] as int? ?? 1,
        weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0.0,
        reps: json['reps'] as int? ?? 0,
        durationSeconds: json['durationSeconds'] as int?,
        resistanceLevel: json['resistanceLevel']?.toString(),
        distance: (json['distance'] as num?)?.toDouble(),
        incline: (json['incline'] as num?)?.toDouble(),
        steps: json['steps'] as int?,
      );
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

  Map<String, dynamic> toJson() => <String, dynamic>{
    'exerciseId': exerciseId,
    'exerciseName': exerciseName,
    'exerciseType': exerciseType,
    'sets': sets.map((s) => s.toJson()).toList(),
  };

  factory CompletedWorkoutExercise.fromJson(Map<String, dynamic> json) =>
      CompletedWorkoutExercise(
        exerciseId: json['exerciseId']?.toString() ?? '',
        exerciseName: json['exerciseName']?.toString() ?? '',
        exerciseType: json['exerciseType']?.toString() ?? 'strength',
        sets:
            (json['sets'] as List<dynamic>?)
                ?.map(
                  (s) =>
                      CompletedWorkoutSet.fromJson(s as Map<String, dynamic>),
                )
                .toList() ??
            const <CompletedWorkoutSet>[],
      );
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

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'routineId': routineId,
    'routineName': routineName,
    'completedAt': completedAt.toUtc().toIso8601String(),
    if (startedAt != null) 'startedAt': startedAt!.toUtc().toIso8601String(),
    'durationSeconds': duration.inSeconds,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };

  factory CompletedWorkout.fromJson(
    Map<String, dynamic> json,
  ) => CompletedWorkout(
    id: json['id']?.toString() ?? '',
    routineId: json['routineId']?.toString() ?? '',
    routineName: json['routineName']?.toString() ?? '',
    completedAt:
        DateTime.tryParse(json['completedAt']?.toString() ?? '')?.toLocal() ??
        DateTime.now(),
    startedAt: json['startedAt'] != null
        ? DateTime.tryParse(json['startedAt'].toString())?.toLocal()
        : null,
    duration: Duration(seconds: json['durationSeconds'] as int? ?? 0),
    exercises:
        (json['exercises'] as List<dynamic>?)
            ?.map(
              (e) =>
                  CompletedWorkoutExercise.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        const <CompletedWorkoutExercise>[],
  );

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
