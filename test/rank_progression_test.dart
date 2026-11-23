import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stryde/features/progression/domain/entities/rank.dart';
import 'package:stryde/features/progression/domain/services/xp_progression_engine.dart';
import 'package:stryde/features/progression/presentation/providers/user_progression_provider.dart';

void main() {
  group('1. Rank Hierarchy & Boundaries (12 Ranks)', () {
    test('contains exactly 12 ranks in correct order', () {
      expect(Ranks.all.length, 12);
      final names = Ranks.all.map((r) => r.name).toList();
      expect(names, <String>[
        'Initiate',
        'Fresher',
        'Rising Star',
        'Locked In',
        'Vanguard',
        'Ascendant',
        'Sovereign',
        'Olympian',
        'Titan',
        'Demigod',
        'Celestial',
        'Godslayer',
      ]);
    });

    test('validates every rank boundary', () {
      // Initiate: 1-3
      expect(Ranks.forLevel(1).name, 'Initiate');
      expect(Ranks.forLevel(2).name, 'Initiate');
      expect(Ranks.forLevel(3).name, 'Initiate');

      // Fresher: 4-6
      expect(Ranks.forLevel(4).name, 'Fresher');
      expect(Ranks.forLevel(5).name, 'Fresher');
      expect(Ranks.forLevel(6).name, 'Fresher');

      // Rising Star: 7-10
      expect(Ranks.forLevel(7).name, 'Rising Star');
      expect(Ranks.forLevel(8).name, 'Rising Star');
      expect(Ranks.forLevel(9).name, 'Rising Star');
      expect(Ranks.forLevel(10).name, 'Rising Star');

      // Locked In: 11-15
      expect(Ranks.forLevel(11).name, 'Locked In');
      expect(Ranks.forLevel(13).name, 'Locked In');
      expect(Ranks.forLevel(15).name, 'Locked In');

      // Vanguard: 16-22
      expect(Ranks.forLevel(16).name, 'Vanguard');
      expect(Ranks.forLevel(19).name, 'Vanguard');
      expect(Ranks.forLevel(22).name, 'Vanguard');

      // Ascendant: 23-30
      expect(Ranks.forLevel(23).name, 'Ascendant');
      expect(Ranks.forLevel(26).name, 'Ascendant');
      expect(Ranks.forLevel(30).name, 'Ascendant');

      // Sovereign: 31-40
      expect(Ranks.forLevel(31).name, 'Sovereign');
      expect(Ranks.forLevel(35).name, 'Sovereign');
      expect(Ranks.forLevel(40).name, 'Sovereign');

      // Olympian: 41-50
      expect(Ranks.forLevel(41).name, 'Olympian');
      expect(Ranks.forLevel(45).name, 'Olympian');
      expect(Ranks.forLevel(50).name, 'Olympian');

      // Titan: 51-65
      expect(Ranks.forLevel(51).name, 'Titan');
      expect(Ranks.forLevel(58).name, 'Titan');
      expect(Ranks.forLevel(65).name, 'Titan');

      // Demigod: 66-80
      expect(Ranks.forLevel(66).name, 'Demigod');
      expect(Ranks.forLevel(73).name, 'Demigod');
      expect(Ranks.forLevel(80).name, 'Demigod');

      // Celestial: 81-99
      expect(Ranks.forLevel(81).name, 'Celestial');
      expect(Ranks.forLevel(90).name, 'Celestial');
      expect(Ranks.forLevel(99).name, 'Celestial');

      // Godslayer: 100+
      expect(Ranks.forLevel(100).name, 'Godslayer');
      expect(Ranks.forLevel(101).name, 'Godslayer');
      expect(Ranks.forLevel(250).name, 'Godslayer');
    });

    test('breakthrough promotion levels match rank boundaries', () {
      expect(
        Ranks.breakthroughLevels,
        containsAll(<int>[4, 7, 11, 16, 23, 31, 41, 51, 66, 81, 100]),
      );
      expect(Ranks.breakthroughLevels.length, 11);
    });
  });

  group('2. Progressive XP Calculations & Promotion Increments', () {
    test('per-level increments increase by 50 per rank promotion', () {
      expect(XpProgressionEngine.getRankIncrement(1), 50); // Initiate
      expect(XpProgressionEngine.getRankIncrement(2), 50);
      expect(XpProgressionEngine.getRankIncrement(3), 50);

      expect(XpProgressionEngine.getRankIncrement(4), 100); // Fresher
      expect(XpProgressionEngine.getRankIncrement(6), 100);

      expect(XpProgressionEngine.getRankIncrement(7), 150); // Rising Star
      expect(XpProgressionEngine.getRankIncrement(10), 150);

      expect(XpProgressionEngine.getRankIncrement(11), 200); // Locked In
      expect(XpProgressionEngine.getRankIncrement(15), 200);

      expect(XpProgressionEngine.getRankIncrement(16), 250); // Vanguard
      expect(XpProgressionEngine.getRankIncrement(23), 300); // Ascendant
      expect(XpProgressionEngine.getRankIncrement(31), 350); // Sovereign
      expect(XpProgressionEngine.getRankIncrement(41), 400); // Olympian
      expect(XpProgressionEngine.getRankIncrement(51), 450); // Titan
      expect(XpProgressionEngine.getRankIncrement(66), 500); // Demigod
      expect(XpProgressionEngine.getRankIncrement(81), 550); // Celestial
      expect(XpProgressionEngine.getRankIncrement(100), 600); // Godslayer
    });

    test('per-level costs match the required progression example', () {
      // 1->2: 100
      expect(XpProgressionEngine.xpRequiredForLevel(1), 100);
      // 2->3: 150
      expect(XpProgressionEngine.xpRequiredForLevel(2), 150);
      // 3->4: 200
      expect(XpProgressionEngine.xpRequiredForLevel(3), 200);
      // 4->5: 300 (promoted to Fresher, +100 relative to previous 200)
      expect(XpProgressionEngine.xpRequiredForLevel(4), 300);
      // 5->6: 400
      expect(XpProgressionEngine.xpRequiredForLevel(5), 400);
      // 6->7: 500
      expect(XpProgressionEngine.xpRequiredForLevel(6), 500);
      // 7->8: 650 (promoted to Rising Star, +150 relative to previous 500)
      expect(XpProgressionEngine.xpRequiredForLevel(7), 650);
      // 8->9: 800
      expect(XpProgressionEngine.xpRequiredForLevel(8), 800);
      // 9->10: 950
      expect(XpProgressionEngine.xpRequiredForLevel(9), 950);
      // 10->11: 1100
      expect(XpProgressionEngine.xpRequiredForLevel(10), 1100);
      // 11->12: 1300 (promoted to Locked In, +200 relative to previous 1100)
      expect(XpProgressionEngine.xpRequiredForLevel(11), 1300);
    });

    test('cumulative XP thresholds match exact summation', () {
      expect(XpProgressionEngine.cumulativeXpForLevel(1), 0);
      expect(XpProgressionEngine.cumulativeXpForLevel(2), 100);
      expect(XpProgressionEngine.cumulativeXpForLevel(3), 250); // 100 + 150
      expect(XpProgressionEngine.cumulativeXpForLevel(4), 450); // 250 + 200
      expect(XpProgressionEngine.cumulativeXpForLevel(5), 750); // 450 + 300
      expect(XpProgressionEngine.cumulativeXpForLevel(6), 1150); // 750 + 400
      expect(XpProgressionEngine.cumulativeXpForLevel(7), 1650); // 1150 + 500
      expect(XpProgressionEngine.cumulativeXpForLevel(8), 2300); // 1650 + 650
      expect(XpProgressionEngine.cumulativeXpForLevel(9), 3100); // 2300 + 800
      expect(XpProgressionEngine.cumulativeXpForLevel(10), 4050); // 3100 + 950
      expect(XpProgressionEngine.cumulativeXpForLevel(11), 5150); // 4050 + 1100
    });

    test('correctly computes level and progress for any total XP', () {
      // 0 XP -> Level 1, 0 XP into level
      var calc = XpProgressionEngine.calculateLevelAndProgress(0);
      expect(calc.level, 1);
      expect(calc.currentXp, 0);
      expect(calc.xpToNextLevel, 100);
      expect(calc.progress, 0.0);

      // 50 XP -> Level 1, 50/100 XP
      calc = XpProgressionEngine.calculateLevelAndProgress(50);
      expect(calc.level, 1);
      expect(calc.currentXp, 50);
      expect(calc.xpToNextLevel, 100);
      expect(calc.progress, 0.5);

      // 100 XP -> exactly Level 2, 0/150 XP
      calc = XpProgressionEngine.calculateLevelAndProgress(100);
      expect(calc.level, 2);
      expect(calc.currentXp, 0);
      expect(calc.xpToNextLevel, 150);

      // 500 XP -> Level 4 (450 <= 500 < 750), 50/300 XP
      calc = XpProgressionEngine.calculateLevelAndProgress(500);
      expect(calc.level, 4);
      expect(calc.currentXp, 50);
      expect(calc.xpToNextLevel, 300);
      expect(calc.progress, closeTo(50 / 300, 0.0001));

      // 2000 XP -> Level 7 (1650 <= 2000 < 2300), 350/650 XP
      calc = XpProgressionEngine.calculateLevelAndProgress(2000);
      expect(calc.level, 7);
      expect(calc.currentXp, 350);
      expect(calc.xpToNextLevel, 650);
    });
  });

  group('3. Level 100+ & High-Level Calculations', () {
    test('handles level 100+ and beyond smoothly', () {
      final cum100 = XpProgressionEngine.cumulativeXpForLevel(100);
      expect(cum100, greaterThan(0));

      // Cost from 100->101
      final cost100 = XpProgressionEngine.xpRequiredForLevel(100);
      expect(cost100, greaterThan(0));

      // Cost from 101->102 uses +600 increment
      final cost101 = XpProgressionEngine.xpRequiredForLevel(101);
      expect(cost101, cost100 + 600);

      // Total XP corresponding to level 100 + 200 XP
      final calc = XpProgressionEngine.calculateLevelAndProgress(cum100 + 200);
      expect(calc.level, 100);
      expect(calc.currentXp, 200);
      expect(Ranks.forLevel(calc.level).name, 'Godslayer');

      // Total XP for Level 105
      final cum105 = XpProgressionEngine.cumulativeXpForLevel(105);
      final calc105 = XpProgressionEngine.calculateLevelAndProgress(cum105);
      expect(calc105.level, 105);
      expect(Ranks.forLevel(calc105.level).name, 'Godslayer');
    });
  });

  group('4. Existing-User Progression Recalculation', () {
    test('recalculates old progression without granting duplicate skill points', () {
      // User had level 1 with 0 XP, 0 skill points
      var recalculated = XpProgressionEngine.recalculateFromOldProgression(
        oldLevel: 1,
        oldXp: 0,
        existingSkillPoints: 0,
      );
      expect(recalculated.currentLevel, 1);
      expect(recalculated.currentXp, 0);
      expect(recalculated.skillPoints, 0);
      expect(recalculated.rankTitle, 'Initiate');

      // User had level 2 with 0 XP under old system (total 500 XP), 2 skill points saved
      recalculated = XpProgressionEngine.recalculateFromOldProgression(
        oldLevel: 2,
        oldXp: 0,
        existingSkillPoints: 2,
      );
      // Under new system: 500 XP puts user at Level 4 (450 cumulative) with 50 XP
      expect(recalculated.currentLevel, 4);
      expect(recalculated.currentXp, 50);
      expect(recalculated.skillPoints, 2); // Preserved! No duplicates!
      expect(recalculated.rankTitle, 'Fresher');

      // User had level 3 with 200 XP under old system (total 1200 XP), 5 skill points saved
      recalculated = XpProgressionEngine.recalculateFromOldProgression(
        oldLevel: 3,
        oldXp: 200,
        existingSkillPoints: 5,
      );
      // Under new system: Level 6 starts at 1150 XP. 1200 - 1150 = 50 XP into level 6
      expect(recalculated.currentLevel, 6);
      expect(recalculated.currentXp, 50);
      expect(recalculated.skillPoints, 5); // Preserved!
      expect(recalculated.rankTitle, 'Fresher');
    });

    test(
      'future earned XP grants +1 skill point per level and +3 on rank promotion',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(userProgressionProvider.notifier);

        // User earns 100 XP -> reaches level 2 (+1 skill point)
        notifier.addXp(100);
        expect(container.read(userProgressionProvider).currentLevel, 2);
        expect(container.read(userProgressionProvider).skillPoints, 1);

        // User earns 150 XP -> reaches level 3 (+1 skill point -> total 2)
        notifier.addXp(150);
        expect(container.read(userProgressionProvider).currentLevel, 3);
        expect(container.read(userProgressionProvider).skillPoints, 2);

        // User earns 200 XP -> reaches level 4 (Fresher promotion! +1 regular + 3 bonus -> total 6)
        notifier.addXp(200);
        expect(container.read(userProgressionProvider).currentLevel, 4);
        expect(container.read(userProgressionProvider).rankTitle, 'Fresher');
        expect(container.read(userProgressionProvider).skillPoints, 6);
      },
    );
  });

  group('5. SVG Asset Mapping (All 12 Ranks)', () {
    test('maps all 12 ranks to valid SVG files in assets/Ranks', () {
      for (final rank in Ranks.all) {
        final path = rank.assetPath;
        expect(path, startsWith('assets/Ranks/'));
        expect(path, endsWith('.svg'));

        final file = File(path);
        expect(
          file.existsSync(),
          isTrue,
          reason: 'File $path must exist on disk for rank ${rank.name}',
        );
        expect(
          file.lengthSync(),
          greaterThan(0),
          reason: 'File $path must not be empty',
        );
      }
    });

    test(
      'case-insensitively resolves rank names with spaces and underscores',
      () {
        expect(
          RankAssetResolver.getSvgAssetPath('INITIATE'),
          'assets/Ranks/initiate.svg',
        );
        expect(
          RankAssetResolver.getSvgAssetPath('fresher'),
          'assets/Ranks/Fresher.svg',
        );
        expect(
          RankAssetResolver.getSvgAssetPath('RISING STAR'),
          'assets/Ranks/rising star.svg',
        );
        expect(
          RankAssetResolver.getSvgAssetPath('rising_star'),
          'assets/Ranks/rising star.svg',
        );
        expect(
          RankAssetResolver.getSvgAssetPath('LOCKED IN'),
          'assets/Ranks/locked in.svg',
        );
        expect(
          RankAssetResolver.getSvgAssetPath('locked_in'),
          'assets/Ranks/locked in.svg',
        );
        expect(
          RankAssetResolver.getSvgAssetPath('Vanguard'),
          'assets/Ranks/vanguard.svg',
        );
        expect(
          RankAssetResolver.getSvgAssetPath('ASCENDANT'),
          'assets/Ranks/ascendant.svg',
        );
        expect(
          RankAssetResolver.getSvgAssetPath('Sovereign'),
          'assets/Ranks/sovereign.svg',
        );
        expect(
          RankAssetResolver.getSvgAssetPath('olympian'),
          'assets/Ranks/Olympian.svg',
        );
        expect(
          RankAssetResolver.getSvgAssetPath('TITAN'),
          'assets/Ranks/titan.svg',
        );
        expect(
          RankAssetResolver.getSvgAssetPath('Demigod'),
          'assets/Ranks/demigod.svg',
        );
        expect(
          RankAssetResolver.getSvgAssetPath('CELESTIAL'),
          'assets/Ranks/celestial.svg',
        );
        expect(
          RankAssetResolver.getSvgAssetPath('godslayer'),
          'assets/Ranks/Godslayer.svg',
        );
      },
    );
  });
}
