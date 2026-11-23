class RankAssetResolver {
  static const Map<String, String> _rankToAsset = <String, String>{
    'initiate': 'assets/Ranks/initiate.svg',
    'fresher': 'assets/Ranks/Fresher.svg',
    'rising star': 'assets/Ranks/rising star.svg',
    'rising_star': 'assets/Ranks/rising star.svg',
    'locked in': 'assets/Ranks/locked in.svg',
    'locked_in': 'assets/Ranks/locked in.svg',
    'vanguard': 'assets/Ranks/vanguard.svg',
    'ascendant': 'assets/Ranks/ascendant.svg',
    'sovereign': 'assets/Ranks/sovereign.svg',
    'olympian': 'assets/Ranks/Olympian.svg',
    'titan': 'assets/Ranks/titan.svg',
    'demigod': 'assets/Ranks/demigod.svg',
    'celestial': 'assets/Ranks/celestial.svg',
    'godslayer': 'assets/Ranks/Godslayer.svg',
  };

  /// Matches the rank name case-insensitively to its corresponding SVG file in assets/Ranks.
  static String getSvgAssetPath(String rankName) {
    final normalized = rankName.trim().toLowerCase();
    if (_rankToAsset.containsKey(normalized)) {
      return _rankToAsset[normalized]!;
    }
    // Also try replacing hyphens/underscores with space
    final withSpaces = normalized.replaceAll(RegExp(r'[-_]'), ' ');
    if (_rankToAsset.containsKey(withSpaces)) {
      return _rankToAsset[withSpaces]!;
    }
    return 'assets/Ranks/initiate.svg';
  }
}

class Rank {
  const Rank({
    required this.name,
    required this.minLevel,
    required this.maxLevel,
    required this.tagline,
    required this.assetPath,
  });

  final String name;
  final int minLevel;
  final int maxLevel;
  final String tagline;
  final String assetPath;

  bool get isOpenEnded => maxLevel >= 999;

  String get levelRange =>
      isOpenEnded ? 'Level $minLevel+' : 'Level $minLevel–$maxLevel';

  bool containsLevel(int level) => level >= minLevel && level <= maxLevel;
}

abstract final class Ranks {
  // 12 Stryde Ranks
  static const Rank initiate = Rank(
    name: 'Initiate',
    minLevel: 1,
    maxLevel: 3,
    tagline: 'Your journey begins. Build the foundation.',
    assetPath: 'assets/Ranks/initiate.svg',
  );

  static const Rank fresher = Rank(
    name: 'Fresher',
    minLevel: 4,
    maxLevel: 6,
    tagline: 'Every legend starts at zero.',
    assetPath: 'assets/Ranks/Fresher.svg',
  );

  static const Rank risingStar = Rank(
    name: 'Rising Star',
    minLevel: 7,
    maxLevel: 10,
    tagline: 'The work starts to become a habit.',
    assetPath: 'assets/Ranks/rising star.svg',
  );

  static const Rank lockedIn = Rank(
    name: 'Locked In',
    minLevel: 11,
    maxLevel: 15,
    tagline: 'Forged by consistency and intent.',
    assetPath: 'assets/Ranks/locked in.svg',
  );

  static const Rank vanguard = Rank(
    name: 'Vanguard',
    minLevel: 16,
    maxLevel: 22,
    tagline: 'Leading from the front through discipline.',
    assetPath: 'assets/Ranks/vanguard.svg',
  );

  static const Rank ascendant = Rank(
    name: 'Ascendant',
    minLevel: 23,
    maxLevel: 30,
    tagline: 'Rising above limits and standard standards.',
    assetPath: 'assets/Ranks/ascendant.svg',
  );

  static const Rank sovereign = Rank(
    name: 'Sovereign',
    minLevel: 31,
    maxLevel: 40,
    tagline: 'Master of your body, mind, and iron.',
    assetPath: 'assets/Ranks/sovereign.svg',
  );

  static const Rank olympian = Rank(
    name: 'Olympian',
    minLevel: 41,
    maxLevel: 50,
    tagline: 'Peak human power and relentless dedication.',
    assetPath: 'assets/Ranks/Olympian.svg',
  );

  static const Rank titan = Rank(
    name: 'Titan',
    minLevel: 51,
    maxLevel: 65,
    tagline: 'A force of nature built through iron will.',
    assetPath: 'assets/Ranks/titan.svg',
  );

  static const Rank demigod = Rank(
    name: 'Demigod',
    minLevel: 66,
    maxLevel: 80,
    tagline: 'Surpassing the realm of ordinary mortals.',
    assetPath: 'assets/Ranks/demigod.svg',
  );

  static const Rank celestial = Rank(
    name: 'Celestial',
    minLevel: 81,
    maxLevel: 99,
    tagline: 'Radiant strength among the highest stars.',
    assetPath: 'assets/Ranks/celestial.svg',
  );

  static const Rank godslayer = Rank(
    name: 'Godslayer',
    minLevel: 100,
    maxLevel: 999,
    tagline: 'Beyond all boundaries. A mythical standard.',
    assetPath: 'assets/Ranks/Godslayer.svg',
  );

  // Backward compatibility aliases
  static const Rank newBlood = initiate;
  static const Rank prodigy = risingStar;
  static const Rank hunter = lockedIn;
  static const Rank comingSoon = godslayer;

  static const List<Rank> all = <Rank>[
    initiate,
    fresher,
    risingStar,
    lockedIn,
    vanguard,
    ascendant,
    sovereign,
    olympian,
    titan,
    demigod,
    celestial,
    godslayer,
  ];

  /// Levels that cross into a new rank and grant the +3 bonus skill points.
  static const Set<int> breakthroughLevels = <int>{
    4,
    7,
    11,
    16,
    23,
    31,
    41,
    51,
    66,
    81,
    100,
  };

  static Rank forLevel(int level) {
    if (level < 1) return initiate;
    if (level >= 100) return godslayer;
    for (final rank in all) {
      if (rank.containsLevel(level)) return rank;
    }
    return godslayer;
  }
}
