import 'package:stryde/features/progression/domain/entities/rank.dart';
import 'package:stryde/features/progression/domain/services/xp_progression_engine.dart';

class UserProgression {
  const UserProgression({
    required this.currentLevel,
    required this.currentXp,
    int? totalXp,
    this.skillPoints = 0,
    this.levelUpRevision = 0,
  }) : _explicitTotalXp = totalXp,
       assert(currentLevel >= 1 && currentLevel <= maxLevel),
       assert(currentXp >= 0);

  // Backward-compatibility alias for tests referencing xpPerLevel
  static const int xpPerLevel = 500;
  static const int maxLevel = 999;

  final int currentLevel;
  final int currentXp;
  final int? _explicitTotalXp;
  final int skillPoints;

  /// Increments whenever one or more levels are gained in a single XP award.
  /// Presentation can use this as an animation key without storing animation
  /// concerns in the domain model.
  final int levelUpRevision;

  /// Total lifetime XP earned across all levels.
  int get totalXp =>
      _explicitTotalXp ??
      (XpProgressionEngine.cumulativeXpForLevel(currentLevel) + currentXp);

  /// XP required to level up from [currentLevel] to [currentLevel + 1].
  int get xpToNextLevel => XpProgressionEngine.xpRequiredForLevel(currentLevel);

  /// XP remaining until the next level.
  int get xpRemaining => currentLevel >= maxLevel
      ? 0
      : (xpToNextLevel - currentXp).clamp(0, xpToNextLevel);

  /// Normalized progress from 0.0 to 1.0 through the current level.
  double get progress {
    if (currentLevel >= maxLevel) return 1.0;
    final req = xpToNextLevel;
    if (req <= 0) return 1.0;
    return (currentXp / req).clamp(0.0, 1.0).toDouble();
  }

  /// Current rank based on [currentLevel].
  Rank get rank => Ranks.forLevel(currentLevel);

  /// Display title of current rank.
  String get rankTitle => rank.name;

  UserProgression copyWith({
    int? currentLevel,
    int? currentXp,
    int? totalXp,
    int? skillPoints,
    int? levelUpRevision,
  }) {
    return UserProgression(
      currentLevel: currentLevel ?? this.currentLevel,
      currentXp: currentXp ?? this.currentXp,
      totalXp: totalXp ?? this.totalXp,
      skillPoints: skillPoints ?? this.skillPoints,
      levelUpRevision: levelUpRevision ?? this.levelUpRevision,
    );
  }
}
