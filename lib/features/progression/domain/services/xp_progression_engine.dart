import 'package:stryde/features/progression/domain/entities/user_progression.dart';

abstract final class XpProgressionEngine {
  /// Returns the per-level XP increment for the rank containing [level].
  ///
  /// - Initiate (1–3): +50
  /// - Fresher (4–6): +100
  /// - Rising Star (7–10): +150
  /// - Locked In (11–15): +200
  /// - Vanguard (16–22): +250
  /// - Ascendant (23–30): +300
  /// - Sovereign (31–40): +350
  /// - Olympian (41–50): +400
  /// - Titan (51–65): +450
  /// - Demigod (66–80): +500
  /// - Celestial (81–99): +550
  /// - Godslayer (100+): +600
  static int getRankIncrement(int level) {
    if (level <= 3) return 50;
    if (level <= 6) return 100;
    if (level <= 10) return 150;
    if (level <= 15) return 200;
    if (level <= 22) return 250;
    if (level <= 30) return 300;
    if (level <= 40) return 350;
    if (level <= 50) return 400;
    if (level <= 65) return 450;
    if (level <= 80) return 500;
    if (level <= 99) return 550;
    return 600;
  }

  /// Precomputed level costs up to level 250.
  /// Index L represents the cost from Level L to Level L+1.
  static final List<int> _levelCosts = () {
    final list = <int>[0, 100]; // index 0 unused, index 1 = cost 1->2 (100)
    for (var l = 2; l <= 250; l++) {
      list.add(list[l - 1] + getRankIncrement(l));
    }
    return list;
  }();

  /// Precomputed cumulative XP thresholds up to level 250.
  /// Index L represents the total XP needed to reach Level L.
  static final List<int> _cumulativeThresholds = () {
    final list = <int>[0, 0]; // index 0 unused, Level 1 = 0 XP
    for (var l = 2; l <= 250; l++) {
      list.add(list[l - 1] + _levelCosts[l - 1]);
    }
    return list;
  }();

  /// XP required to level up from [level] to [level + 1].
  static int xpRequiredForLevel(int level) {
    if (level < 1) return 100;
    if (level < _levelCosts.length) return _levelCosts[level];
    var cost = _levelCosts.last;
    for (var l = _levelCosts.length; l <= level; l++) {
      cost += getRankIncrement(l);
    }
    return cost;
  }

  /// Total cumulative XP required to reach [level] from level 1.
  static int cumulativeXpForLevel(int level) {
    if (level <= 1) return 0;
    if (level < _cumulativeThresholds.length) {
      return _cumulativeThresholds[level];
    }
    var cum = _cumulativeThresholds.last;
    for (var l = _cumulativeThresholds.length; l <= level; l++) {
      cum += xpRequiredForLevel(l - 1);
    }
    return cum;
  }

  /// Calculates the current level and XP into that level given [totalXp].
  static ({int level, int currentXp, int xpToNextLevel, double progress})
  calculateLevelAndProgress(int totalXp) {
    if (totalXp <= 0) {
      return (
        level: 1,
        currentXp: 0,
        xpToNextLevel: xpRequiredForLevel(1),
        progress: 0.0,
      );
    }

    var level = 1;
    while (level < UserProgression.maxLevel &&
        totalXp >= cumulativeXpForLevel(level + 1)) {
      level++;
    }

    final cumAtLevel = cumulativeXpForLevel(level);
    final inLevel = totalXp - cumAtLevel;
    final cost = xpRequiredForLevel(level);
    final prog = cost <= 0 ? 1.0 : (inLevel / cost).clamp(0.0, 1.0);

    return (
      level: level,
      currentXp: inLevel,
      xpToNextLevel: cost,
      progress: prog,
    );
  }

  /// Converts a total lifetime XP amount into a [UserProgression] instance,
  /// preserving the user's existing [skillPoints] and [levelUpRevision].
  static UserProgression progressionFromTotalXp(
    int totalXp, {
    int skillPoints = 0,
    int levelUpRevision = 0,
  }) {
    final calc = calculateLevelAndProgress(totalXp);
    return UserProgression(
      currentLevel: calc.level,
      currentXp: calc.currentXp,
      totalXp: totalXp,
      skillPoints: skillPoints,
      levelUpRevision: levelUpRevision,
    );
  }

  /// Recalculates an existing user's progression from their old 500-XP-per-level
  /// stats ([oldLevel] and [oldXp]), preserving their [existingSkillPoints].
  static UserProgression recalculateFromOldProgression({
    required int oldLevel,
    required int oldXp,
    int existingSkillPoints = 0,
    int levelUpRevision = 0,
  }) {
    final effectiveLevel = oldLevel.clamp(1, UserProgression.maxLevel);
    final effectiveXp = oldXp.clamp(0, 1000000);
    final oldTotalXp = (effectiveLevel - 1) * 500 + effectiveXp;

    return progressionFromTotalXp(
      oldTotalXp,
      skillPoints: existingSkillPoints,
      levelUpRevision: levelUpRevision,
    );
  }
}
