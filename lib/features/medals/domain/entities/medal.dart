import 'package:material_ui/material_ui.dart';

enum MedalCategory {
  strengthPrs('STRENGTH & PRs'),
  consistency('CONSISTENCY'),
  workoutMilestones('WORKOUT MILESTONES'),
  muscleMastery('MUSCLE MASTERY'),
  rankAscension('RANK & ASCENSION');

  const MedalCategory(this.displayName);
  final String displayName;
}

enum MedalRarity {
  common(label: 'COMMON', color: Color(0xFFA0A0A0)),
  rare(label: 'RARE', color: Color(0xFF60A5FA)),
  epic(label: 'EPIC', color: Color(0xFFB18AF4)),
  legendary(label: 'LEGENDARY', color: Color(0xFFE6BC70));

  const MedalRarity({required this.label, required this.color});
  final String label;
  final Color color;
}

class MedalAssetResolver {
  static const Map<String, String> _assetMap = <String, String>{
    'firstblood': 'assets/Medals/First Blood.svg',
    'recordbreaker': 'assets/Medals/Record Breaker.svg',
    'limitbreaker': 'assets/Medals/Limit Breaker.svg',
    'unstoppable': 'assets/Medals/Unstoppable.svg',
    'firstflame': 'assets/Medals/First Flame.svg',
    'irondiscipline': 'assets/Medals/Iron Discipline.svg',
    'relentless': 'assets/Medals/Relentless.svg',
    'eternalflame': 'assets/Medals/Eternal Flame.svg',
    'firststep': 'assets/Medals/First step.svg',
    'noturningback': 'assets/Medals/No turning back.svg',
    'battlehardened': 'assets/Medals/Battle Hardened.svg',
    'centurion': 'assets/Medals/Centurion.svg',
    'awakened': 'assets/Medals/Awakened.svg',
    'dualwielder': 'assets/Medals/Dual Wielder.svg',
    'allrounder': 'assets/Medals/All rounder.svg',
    'masterofall': 'assets/Medals/Master of all.svg',
    'theascended': 'assets/Medals/The Ascended.svg',
    'royalblood': 'assets/Medals/Royal Blood.svg',
    'gatesofolympus': 'assets/Medals/Gates of Olympus.svg',
    'godslayer': 'assets/Medals/Godslayer.svg',
  };

  /// Matches medal name case-insensitively, ignoring spaces, underscores, and hyphens.
  static String getSvgAssetPath(String name) {
    final normalized = name.trim().toLowerCase().replaceAll(
      RegExp(r'[\s_\-]'),
      '',
    );
    return _assetMap[normalized] ?? 'assets/Medals/First Blood.svg';
  }
}

class Medal {
  const Medal({
    required this.id,
    required this.title,
    required this.category,
    required this.rarity,
    required this.description,
    required this.assetPath,
  });

  final String id;
  final String title;
  final MedalCategory category;
  final MedalRarity rarity;
  final String description;
  final String assetPath;
}

const Map<String, String> kLegacyMedalAliases = <String, String>{
  'first_pr': 'first_blood',
  'five_prs': 'record_breaker',
  'streak_7': 'first_flame',
  'streak_30': 'iron_discipline',
};

Medal? findMedalById(String id) {
  final canonical = kLegacyMedalAliases[id] ?? id;
  for (final medal in kStaticMedals) {
    if (medal.id == canonical) return medal;
  }
  return null;
}

const List<Medal> kStaticMedals = <Medal>[
  // STRENGTH & PRs
  Medal(
    id: 'first_blood',
    title: 'First Blood',
    category: MedalCategory.strengthPrs,
    rarity: MedalRarity.common,
    description: 'Set your first personal record',
    assetPath: 'assets/Medals/First Blood.svg',
  ),
  Medal(
    id: 'record_breaker',
    title: 'Record Breaker',
    category: MedalCategory.strengthPrs,
    rarity: MedalRarity.rare,
    description: 'Set 5 personal records',
    assetPath: 'assets/Medals/Record Breaker.svg',
  ),
  Medal(
    id: 'limit_breaker',
    title: 'Limit Breaker',
    category: MedalCategory.strengthPrs,
    rarity: MedalRarity.epic,
    description: 'Set 25 personal records',
    assetPath: 'assets/Medals/Limit Breaker.svg',
  ),
  Medal(
    id: 'unstoppable',
    title: 'Unstoppable',
    category: MedalCategory.strengthPrs,
    rarity: MedalRarity.legendary,
    description: 'Set 100 personal records',
    assetPath: 'assets/Medals/Unstoppable.svg',
  ),

  // CONSISTENCY
  Medal(
    id: 'first_flame',
    title: 'First Flame',
    category: MedalCategory.consistency,
    rarity: MedalRarity.common,
    description: 'Complete a 7-day training streak',
    assetPath: 'assets/Medals/First Flame.svg',
  ),
  Medal(
    id: 'iron_discipline',
    title: 'Iron Discipline',
    category: MedalCategory.consistency,
    rarity: MedalRarity.rare,
    description: 'Complete a 30-day training streak',
    assetPath: 'assets/Medals/Iron Discipline.svg',
  ),
  Medal(
    id: 'relentless',
    title: 'Relentless',
    category: MedalCategory.consistency,
    rarity: MedalRarity.epic,
    description: 'Complete a 90-day training streak',
    assetPath: 'assets/Medals/Relentless.svg',
  ),
  Medal(
    id: 'eternal_flame',
    title: 'Eternal Flame',
    category: MedalCategory.consistency,
    rarity: MedalRarity.legendary,
    description: 'Complete a 365-day training streak',
    assetPath: 'assets/Medals/Eternal Flame.svg',
  ),

  // WORKOUT MILESTONES
  Medal(
    id: 'first_step',
    title: 'First Step',
    category: MedalCategory.workoutMilestones,
    rarity: MedalRarity.common,
    description: 'Complete 1 workout',
    assetPath: 'assets/Medals/First step.svg',
  ),
  Medal(
    id: 'no_turning_back',
    title: 'No Turning Back',
    category: MedalCategory.workoutMilestones,
    rarity: MedalRarity.rare,
    description: 'Complete 10 workouts',
    assetPath: 'assets/Medals/No turning back.svg',
  ),
  Medal(
    id: 'battle_hardened',
    title: 'Battle Hardened',
    category: MedalCategory.workoutMilestones,
    rarity: MedalRarity.epic,
    description: 'Complete 100 workouts',
    assetPath: 'assets/Medals/Battle Hardened.svg',
  ),
  Medal(
    id: 'centurion',
    title: 'Centurion',
    category: MedalCategory.workoutMilestones,
    rarity: MedalRarity.legendary,
    description: 'Complete 500 workouts',
    assetPath: 'assets/Medals/Centurion.svg',
  ),

  // MUSCLE MASTERY
  Medal(
    id: 'awakened',
    title: 'Awakened',
    category: MedalCategory.muscleMastery,
    rarity: MedalRarity.common,
    description: 'Unlock 1 individual Mastery routine',
    assetPath: 'assets/Medals/Awakened.svg',
  ),
  Medal(
    id: 'dual_wielder',
    title: 'Dual Wielder',
    category: MedalCategory.muscleMastery,
    rarity: MedalRarity.rare,
    description: 'Unlock 1 combined Mastery routine',
    assetPath: 'assets/Medals/Dual Wielder.svg',
  ),
  Medal(
    id: 'all_rounder',
    title: 'All-Rounder',
    category: MedalCategory.muscleMastery,
    rarity: MedalRarity.epic,
    description: 'Unlock all 6 individual Mastery routines',
    assetPath: 'assets/Medals/All rounder.svg',
  ),
  Medal(
    id: 'master_of_all',
    title: 'Master of All',
    category: MedalCategory.muscleMastery,
    rarity: MedalRarity.legendary,
    description: 'Unlock all 11 Mastery routines',
    assetPath: 'assets/Medals/Master of all.svg',
  ),

  // RANK & ASCENSION
  Medal(
    id: 'the_ascended',
    title: 'The Ascended',
    category: MedalCategory.rankAscension,
    rarity: MedalRarity.common,
    description: 'Reach Ascendant',
    assetPath: 'assets/Medals/The Ascended.svg',
  ),
  Medal(
    id: 'royal_blood',
    title: 'Royal Blood',
    category: MedalCategory.rankAscension,
    rarity: MedalRarity.rare,
    description: 'Reach Sovereign',
    assetPath: 'assets/Medals/Royal Blood.svg',
  ),
  Medal(
    id: 'gates_of_olympus',
    title: 'Gates of Olympus',
    category: MedalCategory.rankAscension,
    rarity: MedalRarity.epic,
    description: 'Reach Olympian',
    assetPath: 'assets/Medals/Gates of Olympus.svg',
  ),
  Medal(
    id: 'godslayer',
    title: 'Godslayer',
    category: MedalCategory.rankAscension,
    rarity: MedalRarity.legendary,
    description: 'Reach level 100',
    assetPath: 'assets/Medals/Godslayer.svg',
  ),
];
