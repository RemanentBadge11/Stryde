abstract final class ExerciseType {
  static const strength = 'strength';
  static const bodyweight = 'bodyweight';
  static const weighted = 'weighted';
  static const time = 'time';
  static const resistance = 'resistance';
  static const cardio = 'cardio';
  static const inclineCardio = 'incline_cardio';
  static const timeOnlyCardio = 'time_only_cardio';
  static const stepsCardio = 'steps_cardio';
  static const distanceCardio = 'distance_cardio';
  static const repsOnlyCardio = 'reps_only_cardio';
}

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.primaryMuscle,
    required this.equipment,
    required this.imageUrl,
    this.localImage,
    this.type = ExerciseType.strength,
  });

  final String id;
  final String name;
  final String primaryMuscle;
  final String equipment;

  /// Either a bundled source such as `asset:assets/images/squat.png` or a
  /// legacy network URL. Bundled sources are preferred at render time.
  final String imageUrl;

  /// Local bundled visual illustration path (e.g. `assets/Visuals/images/push_up.jpg`).
  final String? localImage;

  /// The logging and input type for this exercise (e.g. strength, bodyweight,
  /// cardio, time, resistance, etc.).
  final String type;

  String get muscleGroup => primaryMuscle;

  bool get hasBundledImage =>
      (localImage != null && localImage!.isNotEmpty) ||
      imageUrl.startsWith('asset:');

  String get imageAssetPath {
    if (localImage != null && localImage!.isNotEmpty) return localImage!;
    return hasBundledImage ? imageUrl.substring('asset:'.length) : imageUrl;
  }

  bool get isStrength => type == ExerciseType.strength;
  bool get isBodyweight => type == ExerciseType.bodyweight;
  bool get isWeighted => type == ExerciseType.weighted;
  bool get isTime => type == ExerciseType.time;
  bool get isResistance => type == ExerciseType.resistance;
  bool get isCardio => type == ExerciseType.cardio;
  bool get isInclineCardio => type == ExerciseType.inclineCardio;
  bool get isTimeOnlyCardio => type == ExerciseType.timeOnlyCardio;
  bool get isStepsCardio => type == ExerciseType.stepsCardio;
  bool get isDistanceCardio => type == ExerciseType.distanceCardio;
  bool get isRepsOnlyCardio => type == ExerciseType.repsOnlyCardio;

  bool get isCardioExercise =>
      primaryMuscle.trim().toLowerCase() == 'cardio' ||
      type.toLowerCase().contains('cardio');

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      primaryMuscle: json['primaryMuscle'] as String,
      equipment: json['equipment'] as String,
      imageUrl: (json['imageUrl'] ?? json['image'] ?? '') as String,
      localImage: json['local_image'] as String?,
      type: (json['type'] as String?) ?? ExerciseType.strength,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'primaryMuscle': primaryMuscle,
    'equipment': equipment,
    'imageUrl': imageUrl,
    if (localImage != null) 'local_image': localImage,
    'type': type,
  };
}
