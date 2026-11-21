import 'package:stryde/features/progression/domain/entities/rank.dart';

class UserProgression {
  const UserProgression({
    required this.currentLevel,
    required this.currentXp,
    this.skillPoints = 0,
    this.levelUpRevision = 0,
  }) : assert(currentLevel >= 1 && currentLevel <= maxLevel),
       assert(currentXp >= 0);

  static const int xpPerLevel = 500;
  static const int maxLevel = 999;

  final int currentLevel;
  final int currentXp;
  final int skillPoints;

  /// Increments whenever one or more levels are gained in a single XP award.
  /// Presentation can use this as an animation key without storing animation
  /// concerns in the domain model.
  final int levelUpRevision;

  int get xpToNextLevel => xpPerLevel;

  int get xpRemaining => currentLevel >= maxLevel
      ? 0
      : (xpPerLevel - currentXp).clamp(0, xpPerLevel);

  double get progress {
    if (currentLevel >= maxLevel) return 1;
    return (currentXp / xpPerLevel).clamp(0.0, 1.0).toDouble();
  }

  Rank get rank => Ranks.forLevel(currentLevel);

  String get rankTitle => rank.name;

  UserProgression copyWith({
    int? currentLevel,
    int? currentXp,
    int? skillPoints,
    int? levelUpRevision,
  }) {
    return UserProgression(
      currentLevel: currentLevel ?? this.currentLevel,
      currentXp: currentXp ?? this.currentXp,
      skillPoints: skillPoints ?? this.skillPoints,
      levelUpRevision: levelUpRevision ?? this.levelUpRevision,
    );
  }
}
