import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stryde/features/progression/domain/entities/rank.dart';
import 'package:stryde/features/progression/domain/entities/user_progression.dart';

final userProgressionProvider =
    NotifierProvider<UserProgressionNotifier, UserProgression>(
      UserProgressionNotifier.new,
    );

class UserProgressionNotifier extends Notifier<UserProgression> {
  @override
  UserProgression build() {
    // Intentionally in-memory mock state. A fresh ProviderScope resets it.
    return const UserProgression(currentLevel: 1, currentXp: 0);
  }

  void addXp(int amount) {
    if (amount <= 0) return;

    var level = state.currentLevel;
    var xp = state.currentXp + amount;
    var levelsGained = 0;
    var bonusSkillPoints = 0;

    while (level < UserProgression.maxLevel &&
        xp >= UserProgression.xpPerLevel) {
      xp -= UserProgression.xpPerLevel;
      level += 1;
      levelsGained += 1;
      if (Ranks.breakthroughLevels.contains(level)) {
        bonusSkillPoints += 3;
      }
    }

    if (level >= UserProgression.maxLevel) {
      xp = xp.clamp(0, UserProgression.xpPerLevel).toInt();
    }

    state = state.copyWith(
      currentLevel: level,
      currentXp: xp,
      skillPoints: state.skillPoints + levelsGained + bonusSkillPoints,
      levelUpRevision: state.levelUpRevision + (levelsGained > 0 ? 1 : 0),
    );
  }

  bool spendSkillPoint() {
    if (state.skillPoints <= 0) return false;
    state = state.copyWith(skillPoints: state.skillPoints - 1);
    return true;
  }
}
