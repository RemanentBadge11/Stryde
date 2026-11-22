class ProfileGoals {
  const ProfileGoals({
    this.steps = 10000,
    this.waterLiters = 4.0,
    this.proteinGrams = 160,
  });

  final int steps;
  final double waterLiters;
  final int proteinGrams;

  ProfileGoals copyWith({int? steps, double? waterLiters, int? proteinGrams}) {
    return ProfileGoals(
      steps: steps ?? this.steps,
      waterLiters: waterLiters ?? this.waterLiters,
      proteinGrams: proteinGrams ?? this.proteinGrams,
    );
  }

  factory ProfileGoals.fromRow(Map<String, dynamic> row) {
    return ProfileGoals(
      steps: _asInt(row['goal_steps'], fallback: 10000),
      waterLiters: _asDouble(row['goal_water'], fallback: 4.0),
      proteinGrams: _asInt(row['goal_protein'], fallback: 160),
    );
  }

  Map<String, dynamic> toRow() {
    return <String, dynamic>{
      'goal_steps': steps,
      'goal_water': waterLiters,
      'goal_protein': proteinGrams,
    };
  }
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _asDouble(dynamic value, {double fallback = 0.0}) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}
