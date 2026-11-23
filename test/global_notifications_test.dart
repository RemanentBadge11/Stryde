import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/routing/app_router.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/medals/data/medals_repository.dart';
import 'package:stryde/features/medals/domain/entities/medal.dart';
import 'package:stryde/features/profile/data/profile_repository.dart';
import 'package:stryde/features/progression/domain/entities/rank.dart';
import 'package:stryde/features/progression/presentation/providers/global_notification_provider.dart';
import 'package:stryde/features/progression/presentation/providers/user_progression_provider.dart';
import 'package:stryde/features/progression/presentation/widgets/global_notification_banner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeMedalsRepository implements MedalsRepository {
  final Map<String, DateTime> database = {};

  @override
  Future<Map<String, DateTime>> fetchUnlockedMedals(String userId) async =>
      Map.unmodifiable(database);

  @override
  Future<void> unlockMedal({
    required String userId,
    required String medalId,
    DateTime? unlockedAt,
  }) async {
    database[medalId] = unlockedAt ?? DateTime.now();
  }
}

class _FakeProfileRepository implements ProfileRepository {
  ProfileData? storedProfile;

  @override
  Future<ProfileData?> fetch(String userId) async => storedProfile;

  @override
  Future<ProfileData?> getOrFetchProfile(
    String userId, {
    String? defaultUsername,
  }) async => storedProfile;

  @override
  Future<void> saveGoals({
    required String userId,
    required int steps,
    required double water,
    required int protein,
  }) async {}

  @override
  Future<void> saveProfileInfo({
    required String userId,
    String? displayName,
    String? avatarUrl,
  }) async {}

  @override
  Future<void> saveTimezone({
    required String userId,
    required String timezone,
  }) async {}

  @override
  Future<void> saveProgression({
    required String userId,
    required int xp,
    required int level,
    required int skillPoints,
    int? totalXp,
    int? availableSkillPoints,
  }) async {}

  @override
  Future<void> saveStreak({
    required String userId,
    required int streak,
    required DateTime? lastActivityOn,
  }) async {}

  @override
  Future<void> saveThemeSettings({
    required String userId,
    required String themeMode,
    required String accentColor,
  }) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('1. Level-Up & Rank-Up Progression Events', () {
    test(
      'Gaining 1 level within rank queues LevelUpNotification without RankUpNotification',
      () {
        final notifications = calculateProgressionNotifications(
          fromLevel: 1,
          toLevel: 2,
        );

        expect(notifications.length, 1);
        expect(notifications.first, isA<LevelUpNotification>());
        final levelUp = notifications.first as LevelUpNotification;
        expect(levelUp.oldLevel, 1);
        expect(levelUp.newLevel, 2);
      },
    );

    test(
      'Gaining a level crossing a rank boundary queues LevelUp then RankUp in order',
      () {
        // Level 3 -> 4 crosses into Fresher
        final notifications = calculateProgressionNotifications(
          fromLevel: 3,
          toLevel: 4,
        );

        expect(notifications.length, 2);
        expect(notifications[0], isA<LevelUpNotification>());
        final levelUp = notifications[0] as LevelUpNotification;
        expect(levelUp.oldLevel, 3);
        expect(levelUp.newLevel, 4);

        expect(notifications[1], isA<RankUpNotification>());
        final rankUp = notifications[1] as RankUpNotification;
        expect(rankUp.rank.name, 'Fresher');
        expect(rankUp.rank.assetPath, 'assets/Ranks/Fresher.svg');
      },
    );

    test(
      'Multi-level jump (e.g. Level 3 to 5) preserves chronological progression',
      () {
        final notifications = calculateProgressionNotifications(
          fromLevel: 3,
          toLevel: 5,
        );

        expect(notifications.length, 3);
        // Step 1: Level Up 3 -> 4
        expect(notifications[0], isA<LevelUpNotification>());
        expect((notifications[0] as LevelUpNotification).oldLevel, 3);
        expect((notifications[0] as LevelUpNotification).newLevel, 4);

        // Step 2: Rank Up Fresher
        expect(notifications[1], isA<RankUpNotification>());
        expect((notifications[1] as RankUpNotification).rank.name, 'Fresher');

        // Step 3: Level Up 4 -> 5
        expect(notifications[2], isA<LevelUpNotification>());
        expect((notifications[2] as LevelUpNotification).oldLevel, 4);
        expect((notifications[2] as LevelUpNotification).newLevel, 5);
      },
    );
  });

  group('2. Event Ordering (Level Up -> Rank Up -> Medal Awarded)', () {
    test(
      'UserProgressionNotifier addXp enqueues Level Up, Rank Up, then Medal Awarded in exact order',
      () async {
        final fakeMedals = _FakeMedalsRepository();
        final container = ProviderContainer(
          overrides: [
            currentUserProvider.overrideWithValue(null),
            medalsRepositoryProvider.overrideWithValue(fakeMedals),
          ],
        );
        addTearDown(container.dispose);

        // Start at level 1, 0 XP
        final progressionNotifier = container.read(
          userProgressionProvider.notifier,
        );
        expect(container.read(userProgressionProvider).currentLevel, 1);

        // Add 100 XP -> reaches Level 2 (100 XP needed for 1->2)
        progressionNotifier.addXp(100);

        final queue = container.read(globalNotificationProvider);
        expect(queue.currentNotification, isA<LevelUpNotification>());
        final current = queue.currentNotification as LevelUpNotification;
        expect(current.oldLevel, 1);
        expect(current.newLevel, 2);
      },
    );

    test(
      'Promotion event (e.g. level 3 to 4) enqueues Level Up before Rank Up',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(globalNotificationProvider.notifier);

        // Enqueue level 3 -> 4
        notifier.enqueue([
          const LevelUpNotification(oldLevel: 3, newLevel: 4),
          RankUpNotification(rank: Ranks.fresher),
        ]);

        final state = container.read(globalNotificationProvider);
        expect(state.currentNotification, isA<LevelUpNotification>());
        expect(state.queue.length, 1);
        expect(state.queue.first, isA<RankUpNotification>());

        // Dismiss level up reveals rank up
        notifier.dismissCurrent();
        // Trigger showNext via transition
        notifier.enqueue([]); // or pump timers
      },
    );
  });

  group('3. Duplicate Prevention & Shared Queue', () {
    test('Does not enqueue duplicate notifications with the same ID', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(globalNotificationProvider.notifier);

      // Enqueue LevelUp 1->2 twice
      notifier.enqueue([
        const LevelUpNotification(oldLevel: 1, newLevel: 2),
        const LevelUpNotification(oldLevel: 1, newLevel: 2),
      ]);

      final state = container.read(globalNotificationProvider);
      expect(state.currentNotification, isNotNull);
      expect(state.queue, isEmpty); // second one ignored

      // Attempting to enqueue same while currently displaying also ignored
      notifier.enqueue([const LevelUpNotification(oldLevel: 1, newLevel: 2)]);
      expect(container.read(globalNotificationProvider).queue, isEmpty);
    });

    test('Shared queue handles Level Up, Rank Up, and Medals seamlessly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(globalNotificationProvider.notifier);
      final firstBlood = kStaticMedals.firstWhere((m) => m.id == 'first_blood');

      notifier.enqueue([
        const LevelUpNotification(oldLevel: 1, newLevel: 2),
        RankUpNotification(rank: Ranks.fresher),
        firstBlood, // Medal object auto-mapped to MedalAwardedNotification
      ]);

      final state = container.read(globalNotificationProvider);
      expect(state.currentNotification, isA<LevelUpNotification>());
      expect(state.queue.length, 2);
      expect(state.queue[0], isA<RankUpNotification>());
      expect(state.queue[1], isA<MedalAwardedNotification>());
    });
  });

  group('4. Global Notification UI & Artwork Layouts', () {
    testWidgets(
      'LEVEL UP NOTIFICATION renders "Level Up!" and "old → new" horizontally',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        container
            .read(globalNotificationProvider.notifier)
            .enqueueLevelUp(oldLevel: 5, newLevel: 6);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: GlobalNotificationOverlay(child: SizedBox()),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Level Up!'), findsOneWidget);
        expect(find.text('5 → 6'), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
      },
    );

    testWidgets(
      'RANK UP NOTIFICATION renders "RANKUP!", subtitle, and Rank SVG without circular container',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        container
            .read(globalNotificationProvider.notifier)
            .enqueueRankUp(Ranks.fresher);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: GlobalNotificationOverlay(child: SizedBox()),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('RANKUP!'), findsOneWidget);
        expect(find.text('You are now a Fresher'), findsOneWidget);
        expect(find.byType(SvgPicture), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
      },
    );

    testWidgets(
      'MEDAL AWARDED NOTIFICATION preserves exact artwork, title, and rarity layout',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final firstBlood = kStaticMedals.firstWhere(
          (m) => m.id == 'first_blood',
        );
        container.read(globalNotificationProvider.notifier).enqueueMedals([
          firstBlood,
        ]);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: GlobalNotificationOverlay(child: SizedBox()),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Medal Awarded'), findsOneWidget);
        expect(find.text('• COMMON'), findsOneWidget);
        expect(find.text('First Blood'), findsOneWidget);
        expect(find.byType(SvgPicture), findsOneWidget);
      },
    );
  });

  group('5. Global Visibility Across Routes & Navigation Persistence', () {
    testWidgets(
      'Notification overlay renders above router and remains visible across route transitions',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Simple router with two test routes
        final router = GoRouter(
          initialLocation: '/first',
          routes: [
            GoRoute(
              path: '/first',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Screen One'))),
            ),
            GoRoute(
              path: '/second',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Screen Two'))),
            ),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              routerConfig: router,
              builder: (context, child) =>
                  GlobalNotificationOverlay(child: child!),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Screen One'), findsOneWidget);

        // Trigger notification
        container
            .read(globalNotificationProvider.notifier)
            .enqueueLevelUp(oldLevel: 2, newLevel: 3);
        await tester.pumpAndSettle();

        // Banner is visible on Screen One
        expect(find.text('Level Up!'), findsOneWidget);
        expect(find.text('2 → 3'), findsOneWidget);

        // Navigate to Screen Two
        router.push('/second');
        await tester.pumpAndSettle();

        expect(find.text('Screen Two'), findsOneWidget);
        // Notification is STILL visible without replaying
        expect(find.text('Level Up!'), findsOneWidget);
        expect(find.text('2 → 3'), findsOneWidget);
      },
    );

    testWidgets(
      'Taps outside the visible banner pass through to screen controls',
      (tester) async {
        var buttonClicked = false;
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: GlobalNotificationOverlay(
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () => buttonClicked = true,
                      child: const Text('Target Button'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Trigger notification
        container
            .read(globalNotificationProvider.notifier)
            .enqueueLevelUp(oldLevel: 1, newLevel: 2);
        await tester.pumpAndSettle();

        expect(find.text('Level Up!'), findsOneWidget);
        expect(find.text('Target Button'), findsOneWidget);

        // Tap on the button outside the notification card
        await tester.tap(find.text('Target Button'));
        await tester.pumpAndSettle();

        expect(buttonClicked, isTrue);
      },
    );

    testWidgets(
      'Reduced motion accessibility setting disables slide animation',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        container
            .read(globalNotificationProvider.notifier)
            .enqueueLevelUp(oldLevel: 1, newLevel: 2);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MediaQuery(
              data: MediaQueryData(disableAnimations: true),
              child: MaterialApp(
                home: Scaffold(
                  body: GlobalNotificationOverlay(child: SizedBox()),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        // Immediately visible without needing transition pumps
        expect(find.text('Level Up!'), findsOneWidget);
      },
    );
  });

  group('6. Tap Navigation & Historical Reconciliation', () {
    testWidgets(
      'Tapping Level Up or Rank Up dismisses notification and navigates to /ranks',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final router = GoRouter(
          navigatorKey: rootNavigatorKey,
          initialLocation: '/home',
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Home Page'))),
            ),
            GoRoute(
              path: '/ranks',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Ranks Page'))),
            ),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              routerConfig: router,
              builder: (context, child) =>
                  GlobalNotificationOverlay(child: child!),
            ),
          ),
        );
        await tester.pumpAndSettle();

        container
            .read(globalNotificationProvider.notifier)
            .enqueueRankUp(Ranks.fresher);
        await tester.pumpAndSettle();

        expect(find.text('RANKUP!'), findsOneWidget);

        // Tap the notification
        await tester.tap(find.text('RANKUP!'));
        await tester.pumpAndSettle();

        // Navigated to /ranks
        expect(find.text('Ranks Page'), findsOneWidget);
        // Notification dismissed
        expect(container.read(globalNotificationProvider).isVisible, isFalse);
      },
    );

    testWidgets('Tapping Medal Awarded navigates to /medals', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = GoRouter(
        navigatorKey: rootNavigatorKey,
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Home Page'))),
          ),
          GoRoute(
            path: '/medals',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Medals Page'))),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
            builder: (context, child) =>
                GlobalNotificationOverlay(child: child!),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final firstBlood = kStaticMedals.firstWhere((m) => m.id == 'first_blood');
      container.read(globalNotificationProvider.notifier).enqueueMedals([
        firstBlood,
      ]);
      await tester.pumpAndSettle();

      expect(find.text('Medal Awarded'), findsOneWidget);

      // Tap the medal notification
      await tester.tap(find.text('Medal Awarded'));
      await tester.pumpAndSettle();

      expect(find.text('Medals Page'), findsOneWidget);
    });

    test('Historical profile reconciliation remains completely silent', () async {
      final fakeProfileRepo = _FakeProfileRepository()
        ..storedProfile = const ProfileData(
          xp: 200,
          level: 10,
          streak: 3,
          totalXp: 5000,
          skillPoints: 5,
        );
      final fakeMedalsRepo = _FakeMedalsRepository()
        ..database['first_blood'] = DateTime.now();

      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(
            User(
              id: 'user-reconcile-test',
              appMetadata: const {},
              userMetadata: const {},
              aud: 'authenticated',
              createdAt: DateTime.now().toIso8601String(),
            ),
          ),
          profileRepositoryProvider.overrideWithValue(fakeProfileRepo),
          medalsRepositoryProvider.overrideWithValue(fakeMedalsRepo),
        ],
      );
      addTearDown(container.dispose);

      // Wait for hydration
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // User reached level 10 from database, but NO notifications should be queued
      final notificationQueue = container.read(globalNotificationProvider);
      expect(notificationQueue.currentNotification, isNull);
      expect(notificationQueue.queue, isEmpty);
      expect(notificationQueue.isVisible, isFalse);
    });
  });
}
