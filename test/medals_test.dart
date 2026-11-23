import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/home/presentation/widgets/medal_notification_banner.dart';
import 'package:stryde/features/medals/data/medals_repository.dart';
import 'package:stryde/features/medals/domain/entities/medal.dart';
import 'package:stryde/features/medals/presentation/providers/medal_notification_provider.dart';
import 'package:stryde/features/medals/presentation/providers/medals_provider.dart';
import 'package:stryde/features/medals/presentation/screens/medals_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeMedalsRepository implements MedalsRepository {
  final Map<String, DateTime> database = <String, DateTime>{};
  int unlockCallCount = 0;

  @override
  Future<Map<String, DateTime>> fetchUnlockedMedals(String userId) async {
    return Map<String, DateTime>.from(database);
  }

  @override
  Future<void> unlockMedal({
    required String userId,
    required String medalId,
  }) async {
    unlockCallCount++;
    database[medalId] = DateTime.now();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('1. Medal Definitions, Rarity & Category Specifications', () {
    test('contains exactly 20 medals across 5 categories', () {
      expect(kStaticMedals.length, 20);

      for (final category in MedalCategory.values) {
        final categoryMedals = kStaticMedals
            .where((m) => m.category == category)
            .toList();
        expect(categoryMedals.length, 4);
      }
    });

    test('rarity colors match exact requested color values', () {
      expect(MedalRarity.common.color, const Color(0xFFA0A0A0));
      expect(MedalRarity.rare.color, const Color(0xFF60A5FA));
      expect(MedalRarity.epic.color, const Color(0xFFB18AF4));
      expect(MedalRarity.legendary.color, const Color(0xFFE6BC70));
    });

    test('each medal has correct category, rarity, and title', () {
      final titles = kStaticMedals.map((m) => m.title).toSet();
      expect(titles.length, 20);

      // Verify specific sample medals
      final firstBlood = kStaticMedals.firstWhere((m) => m.id == 'first_blood');
      expect(firstBlood.title, 'First Blood');
      expect(firstBlood.category, MedalCategory.strengthPrs);
      expect(firstBlood.rarity, MedalRarity.common);

      final centurion = kStaticMedals.firstWhere((m) => m.id == 'centurion');
      expect(centurion.title, 'Centurion');
      expect(centurion.category, MedalCategory.workoutMilestones);
      expect(centurion.rarity, MedalRarity.legendary);

      final masterOfAll = kStaticMedals.firstWhere(
        (m) => m.id == 'master_of_all',
      );
      expect(masterOfAll.title, 'Master of All');
      expect(masterOfAll.category, MedalCategory.muscleMastery);
      expect(masterOfAll.rarity, MedalRarity.legendary);

      final godslayer = kStaticMedals.firstWhere((m) => m.id == 'godslayer');
      expect(godslayer.title, 'Godslayer');
      expect(godslayer.category, MedalCategory.rankAscension);
      expect(godslayer.rarity, MedalRarity.legendary);
    });
  });

  group('2. SVG Asset Resolution', () {
    test('maps all 20 medals to non-empty SVG file paths', () {
      for (final medal in kStaticMedals) {
        expect(medal.assetPath, startsWith('assets/Medals/'));
        expect(medal.assetPath, endsWith('.svg'));
      }
    });

    test(
      'resolves names case-insensitively, ignoring hyphens, underscores and spaces',
      () {
        expect(
          MedalAssetResolver.getSvgAssetPath('first_blood'),
          'assets/Medals/First Blood.svg',
        );
        expect(
          MedalAssetResolver.getSvgAssetPath('FIRST-BLOOD'),
          'assets/Medals/First Blood.svg',
        );
        expect(
          MedalAssetResolver.getSvgAssetPath('all-rounder'),
          'assets/Medals/All rounder.svg',
        );
        expect(
          MedalAssetResolver.getSvgAssetPath('All Rounder'),
          'assets/Medals/All rounder.svg',
        );
        expect(
          MedalAssetResolver.getSvgAssetPath('GATES OF OLYMPUS'),
          'assets/Medals/Gates of Olympus.svg',
        );
        expect(
          MedalAssetResolver.getSvgAssetPath('master_of_all'),
          'assets/Medals/Master of all.svg',
        );
      },
    );
  });

  group('3. All 20 Unlock Conditions', () {
    late _FakeMedalsRepository fakeRepo;
    late ProviderContainer container;

    setUp(() {
      fakeRepo = _FakeMedalsRepository();
      container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(
            User(
              id: 'user-medal-test',
              appMetadata: const {},
              userMetadata: const {},
              aud: 'authenticated',
              createdAt: DateTime.now().toIso8601String(),
            ),
          ),
          medalsRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('Strength & PRs unlock at 1, 5, 25, 100 PRs', () async {
      final notifier = container.read(medalsProvider.notifier);

      await notifier.evaluateAndUnlock(totalPrs: 0);
      expect(container.read(medalsProvider).isUnlocked('first_blood'), isFalse);

      await notifier.evaluateAndUnlock(totalPrs: 1);
      expect(container.read(medalsProvider).isUnlocked('first_blood'), isTrue);
      expect(
        container.read(medalsProvider).isUnlocked('record_breaker'),
        isFalse,
      );

      await notifier.evaluateAndUnlock(totalPrs: 5);
      expect(
        container.read(medalsProvider).isUnlocked('record_breaker'),
        isTrue,
      );
      expect(
        container.read(medalsProvider).isUnlocked('limit_breaker'),
        isFalse,
      );

      await notifier.evaluateAndUnlock(totalPrs: 25);
      expect(
        container.read(medalsProvider).isUnlocked('limit_breaker'),
        isTrue,
      );
      expect(container.read(medalsProvider).isUnlocked('unstoppable'), isFalse);

      await notifier.evaluateAndUnlock(totalPrs: 100);
      expect(container.read(medalsProvider).isUnlocked('unstoppable'), isTrue);
    });

    test('Consistency unlocks at 7, 30, 90, 365 day streaks', () async {
      final notifier = container.read(medalsProvider.notifier);

      await notifier.evaluateAndUnlock(streak: 6);
      expect(container.read(medalsProvider).isUnlocked('first_flame'), isFalse);

      await notifier.evaluateAndUnlock(streak: 7);
      expect(container.read(medalsProvider).isUnlocked('first_flame'), isTrue);
      expect(
        container.read(medalsProvider).isUnlocked('iron_discipline'),
        isFalse,
      );

      await notifier.evaluateAndUnlock(streak: 30);
      expect(
        container.read(medalsProvider).isUnlocked('iron_discipline'),
        isTrue,
      );
      expect(container.read(medalsProvider).isUnlocked('relentless'), isFalse);

      await notifier.evaluateAndUnlock(streak: 90);
      expect(container.read(medalsProvider).isUnlocked('relentless'), isTrue);
      expect(
        container.read(medalsProvider).isUnlocked('eternal_flame'),
        isFalse,
      );

      await notifier.evaluateAndUnlock(streak: 365);
      expect(
        container.read(medalsProvider).isUnlocked('eternal_flame'),
        isTrue,
      );
    });

    test('Workout Milestones unlock at 1, 10, 100, 500 workouts', () async {
      final notifier = container.read(medalsProvider.notifier);

      await notifier.evaluateAndUnlock(totalWorkouts: 0);
      expect(container.read(medalsProvider).isUnlocked('first_step'), isFalse);

      await notifier.evaluateAndUnlock(totalWorkouts: 1);
      expect(container.read(medalsProvider).isUnlocked('first_step'), isTrue);
      expect(
        container.read(medalsProvider).isUnlocked('no_turning_back'),
        isFalse,
      );

      await notifier.evaluateAndUnlock(totalWorkouts: 10);
      expect(
        container.read(medalsProvider).isUnlocked('no_turning_back'),
        isTrue,
      );
      expect(
        container.read(medalsProvider).isUnlocked('battle_hardened'),
        isFalse,
      );

      await notifier.evaluateAndUnlock(totalWorkouts: 100);
      expect(
        container.read(medalsProvider).isUnlocked('battle_hardened'),
        isTrue,
      );
      expect(container.read(medalsProvider).isUnlocked('centurion'), isFalse);

      await notifier.evaluateAndUnlock(totalWorkouts: 500);
      expect(container.read(medalsProvider).isUnlocked('centurion'), isTrue);
    });

    test(
      'Muscle Mastery unlocks at 1 ind, 1 comb, 6 ind, 11 total routines',
      () async {
        final notifier = container.read(medalsProvider.notifier);

        await notifier.evaluateAndUnlock(
          individualMasteryCount: 0,
          combinedMasteryCount: 0,
          totalMasteryCount: 0,
        );
        expect(container.read(medalsProvider).isUnlocked('awakened'), isFalse);

        await notifier.evaluateAndUnlock(
          individualMasteryCount: 1,
          combinedMasteryCount: 0,
          totalMasteryCount: 1,
        );
        expect(container.read(medalsProvider).isUnlocked('awakened'), isTrue);
        expect(
          container.read(medalsProvider).isUnlocked('dual_wielder'),
          isFalse,
        );

        await notifier.evaluateAndUnlock(
          individualMasteryCount: 1,
          combinedMasteryCount: 1,
          totalMasteryCount: 2,
        );
        expect(
          container.read(medalsProvider).isUnlocked('dual_wielder'),
          isTrue,
        );
        expect(
          container.read(medalsProvider).isUnlocked('all_rounder'),
          isFalse,
        );

        await notifier.evaluateAndUnlock(
          individualMasteryCount: 6,
          combinedMasteryCount: 1,
          totalMasteryCount: 7,
        );
        expect(
          container.read(medalsProvider).isUnlocked('all_rounder'),
          isTrue,
        );
        expect(
          container.read(medalsProvider).isUnlocked('master_of_all'),
          isFalse,
        );

        await notifier.evaluateAndUnlock(
          individualMasteryCount: 6,
          combinedMasteryCount: 5,
          totalMasteryCount: 11,
        );
        expect(
          container.read(medalsProvider).isUnlocked('master_of_all'),
          isTrue,
        );
      },
    );

    test('Rank & Ascension unlocks at Level 23, 31, 41, 100', () async {
      final notifier = container.read(medalsProvider.notifier);

      await notifier.evaluateAndUnlock(level: 22);
      expect(
        container.read(medalsProvider).isUnlocked('the_ascended'),
        isFalse,
      );

      await notifier.evaluateAndUnlock(level: 23);
      expect(container.read(medalsProvider).isUnlocked('the_ascended'), isTrue);
      expect(container.read(medalsProvider).isUnlocked('royal_blood'), isFalse);

      await notifier.evaluateAndUnlock(level: 31);
      expect(container.read(medalsProvider).isUnlocked('royal_blood'), isTrue);
      expect(
        container.read(medalsProvider).isUnlocked('gates_of_olympus'),
        isFalse,
      );

      await notifier.evaluateAndUnlock(level: 41);
      expect(
        container.read(medalsProvider).isUnlocked('gates_of_olympus'),
        isTrue,
      );
      expect(container.read(medalsProvider).isUnlocked('godslayer'), isFalse);

      await notifier.evaluateAndUnlock(level: 100);
      expect(container.read(medalsProvider).isUnlocked('godslayer'), isTrue);
    });
  });

  group('4. Duplicate Prevention & Persistence', () {
    test(
      'does not duplicate awards or repository writes on repeated evaluations',
      () async {
        final fakeRepo = _FakeMedalsRepository();
        final container = ProviderContainer(
          overrides: [
            currentUserProvider.overrideWithValue(
              User(
                id: 'user-dup-test',
                appMetadata: const {},
                userMetadata: const {},
                aud: 'authenticated',
                createdAt: DateTime.now().toIso8601String(),
              ),
            ),
            medalsRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(medalsProvider.notifier);

        final firstRun = await notifier.evaluateAndUnlock(
          totalPrs: 1,
          totalWorkouts: 1,
        );
        expect(firstRun.length, 2);
        final initialCalls = fakeRepo.unlockCallCount;
        expect(initialCalls, 2);

        // Re-evaluating with same or higher metrics does not duplicate
        final secondRun = await notifier.evaluateAndUnlock(
          totalPrs: 1,
          totalWorkouts: 1,
        );
        expect(secondRun, isEmpty);
        expect(fakeRepo.unlockCallCount, initialCalls);
        expect(container.read(medalsProvider).unlockedCount, 2);
      },
    );
  });

  group('5. Home Notification Queue & Reconciliation Guard', () {
    test('initial reconciliation does not enqueue notifications', () async {
      final fakeRepo = _FakeMedalsRepository();
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(
            User(
              id: 'user-rec-test',
              appMetadata: const {},
              userMetadata: const {},
              aud: 'authenticated',
              createdAt: DateTime.now().toIso8601String(),
            ),
          ),
          medalsRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(medalsProvider.notifier);

      // Historical reconciliation (isReconciling: true)
      await notifier.evaluateAndUnlock(
        totalPrs: 5,
        totalWorkouts: 10,
        isReconciling: true,
      );

      final notificationState = container.read(medalNotificationProvider);
      expect(notificationState.currentMedal, isNull);
      expect(notificationState.queue, isEmpty);
      expect(notificationState.isVisible, isFalse);
    });

    test('runtime unlock enqueues notifications sequentially', () async {
      final fakeRepo = _FakeMedalsRepository();
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(
            User(
              id: 'user-notif-test',
              appMetadata: const {},
              userMetadata: const {},
              aud: 'authenticated',
              createdAt: DateTime.now().toIso8601String(),
            ),
          ),
          medalsRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(medalsProvider.notifier);

      // Active runtime unlock (isReconciling: false)
      await notifier.evaluateAndUnlock(
        totalPrs: 1,
        totalWorkouts: 1,
        isReconciling: false,
      );

      final notificationState = container.read(medalNotificationProvider);
      expect(notificationState.currentMedal, isNotNull);
      expect(notificationState.isVisible, isTrue);
      expect(notificationState.queue.length, 1);
    });

    testWidgets(
      'MedalNotificationBanner renders artwork, title, and handles tap',
      (tester) async {
        final fakeRepo = _FakeMedalsRepository();
        final container = ProviderContainer(
          overrides: [
            currentUserProvider.overrideWithValue(
              User(
                id: 'user-banner-test',
                appMetadata: const {},
                userMetadata: const {},
                aud: 'authenticated',
                createdAt: DateTime.now().toIso8601String(),
              ),
            ),
            medalsRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        );
        addTearDown(container.dispose);

        final firstBlood = kStaticMedals.firstWhere(
          (m) => m.id == 'first_blood',
        );
        container.read(medalNotificationProvider.notifier).enqueue([
          firstBlood,
        ]);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: Stack(children: [MedalNotificationBanner()]),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Medal Awarded'), findsOneWidget);
        expect(find.text('First Blood'), findsOneWidget);
        expect(find.text('• COMMON'), findsOneWidget);
        expect(find.byType(SvgPicture), findsOneWidget);

        // Tap dismisses the notification
        await tester.tap(find.text('First Blood'));
        await tester.pumpAndSettle();
        expect(container.read(medalNotificationProvider).isVisible, isFalse);
      },
    );
  });

  group('6. Medals Screen Layout & Card Hierarchy', () {
    testWidgets(
      'renders all 5 categories, 20 cards, and lock overlay on locked cards',
      (tester) async {
        final fakeRepo = _FakeMedalsRepository()
          ..database['first_blood'] = DateTime.now();

        await tester.binding.setSurfaceSize(const Size(800, 3200));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentUserProvider.overrideWithValue(
                User(
                  id: 'user-screen-test',
                  appMetadata: const {},
                  userMetadata: const {},
                  aud: 'authenticated',
                  createdAt: DateTime.now().toIso8601String(),
                ),
              ),
              medalsRepositoryProvider.overrideWithValue(fakeRepo),
            ],
            child: const MaterialApp(home: MedalsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Header summary
        expect(find.text('Medals'), findsOneWidget);
        expect(find.text('1 of 20 Unlocked'), findsOneWidget);

        // Category Headers
        expect(find.text('STRENGTH & PRs'), findsOneWidget);
        expect(find.text('CONSISTENCY'), findsOneWidget);
        expect(find.text('WORKOUT MILESTONES'), findsOneWidget);
        expect(find.text('MUSCLE MASTERY'), findsOneWidget);
        expect(find.text('RANK & ASCENSION'), findsOneWidget);

        // Verify all 20 cards are present
        for (final medal in kStaticMedals) {
          expect(
            find.byKey(ValueKey<String>('medal-card-${medal.id}')),
            findsOneWidget,
          );
        }

        // Check UNLOCKED and LOCKED badges
        expect(find.text('UNLOCKED'), findsWidgets);
        expect(find.text('LOCKED'), findsWidgets);

        // Verify Rarity labels are rendered
        expect(find.text('COMMON'), findsWidgets);
        expect(find.text('RARE'), findsWidgets);
        expect(find.text('EPIC'), findsWidgets);
        expect(find.text('LEGENDARY'), findsWidgets);
      },
    );
  });
}
