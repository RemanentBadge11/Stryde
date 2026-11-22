class Rank {
  const Rank({
    required this.name,
    required this.minLevel,
    required this.maxLevel,
    required this.tagline,
  });

  final String name;
  final int minLevel;
  final int maxLevel;
  final String tagline;

  bool get isOpenEnded => maxLevel >= 999;

  String get levelRange =>
      isOpenEnded ? 'Level $minLevel+' : 'Level $minLevel–$maxLevel';

  bool containsLevel(int level) => level >= minLevel && level <= maxLevel;
}

abstract final class Ranks {
  static const Rank fresher = Rank(
    name: 'Fresher',
    minLevel: 1,
    maxLevel: 5,
    tagline: 'Every legend starts at zero.',
  );

  static const Rank risingStar = Rank(
    name: 'Rising Star',
    minLevel: 6,
    maxLevel: 10,
    tagline: 'The work starts to become a habit.',
  );

  static const Rank lockedIn = Rank(
    name: 'Locked In',
    minLevel: 11,
    maxLevel: 15,
    tagline: 'Forged by consistency and intent.',
  );

  static const Rank comingSoon = Rank(
    name: 'More Coming Soon',
    minLevel: 16,
    maxLevel: 999,
    tagline: 'The next tier is still being forged.',
  );

  // Backward compatibility aliases
  static const Rank newBlood = fresher;
  static const Rank prodigy = risingStar;
  static const Rank hunter = lockedIn;

  static const List<Rank> all = <Rank>[fresher, risingStar, lockedIn, comingSoon];

  /// Levels that cross into a new rank and grant the +3 skill point bonus.
  static const Set<int> breakthroughLevels = <int>{6, 11, 16};

  static Rank forLevel(int level) {
    for (final rank in all) {
      if (rank.containsLevel(level)) return rank;
    }
    return comingSoon;
  }
}
