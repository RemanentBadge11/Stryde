class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.primaryMuscle,
    required this.equipment,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String primaryMuscle;
  final String equipment;

  /// Either a bundled source such as `asset:assets/images/squat.png` or a
  /// legacy network URL. Bundled sources are preferred at render time.
  final String imageUrl;

  String get muscleGroup => primaryMuscle;

  bool get hasBundledImage => imageUrl.startsWith('asset:');

  String get imageAssetPath =>
      hasBundledImage ? imageUrl.substring('asset:'.length) : imageUrl;

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      primaryMuscle: json['primaryMuscle'] as String,
      equipment: json['equipment'] as String,
      imageUrl: (json['imageUrl'] ?? json['image'] ?? '') as String,
    );
  }
}
