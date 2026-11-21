class ProfileGoals {
  const ProfileGoals({
    this.steps = 10000,
    this.waterLiters = 4,
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
}
