import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/home/presentation/screens/home_screen.dart';
import 'package:stryde/features/medals/data/medals_repository.dart';
import 'package:stryde/features/medals/domain/entities/medal.dart';
import 'package:stryde/features/medals/presentation/providers/medals_provider.dart';
import 'package:stryde/features/medals/presentation/screens/medals_screen.dart';
import 'package:stryde/features/profile/data/profile_repository.dart';
import 'package:stryde/features/settings/presentation/providers/theme_provider.dart';
import 'package:stryde/features/settings/presentation/screens/customize_profile_screen.dart';
import 'package:stryde/features/settings/presentation/screens/settings_screen.dart';
import 'package:stryde/features/settings/presentation/screens/theme_screen.dart';
import 'package:stryde/features/workout_logging/presentation/widgets/pr_celebration_overlay.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeProfileRepository implements ProfileRepository {
  Map<String, dynamic>? lastThemeSettings;
  Map<String, dynamic>? lastProfileInfo;

  @override
  Future<ProfileData?> getOrFetchProfile(
    String userId, {
    String? defaultUsername,
  }) async {
    return fetch(userId);
  }

  @override
  Future<ProfileData?> fetch(String userId) async {
    return const ProfileData(
      xp: 100,
      level: 1,
      streak: 3,
      skillPoints: 0,
      username: 'testuser',
      displayName: 'Test Champ',
      avatarUrl: 'https://example.com/avatar.jpg',
      themeMode: 'dark',
      accentColor: '#3B82F6',
    );
  }

  @override
  Future<void> saveTimezone({
    required String userId,
    required String timezone,
  }) async {}

  @override
  Future<void> saveGoals({
    required String userId,
    required int steps,
    required double water,
    required int protein,
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
  }) async {
    lastThemeSettings = {
      'userId': userId,
      'themeMode': themeMode,
      'accentColor': accentColor,
    };
  }

  @override
  Future<void> saveProfileInfo({
    required String userId,
    String? displayName,
    String? avatarUrl,
  }) async {
    lastProfileInfo = {
      'userId': userId,
      'displayName': ?displayName,
      'avatarUrl': ?avatarUrl,
    };
  }
}

class _FakeMedalsRepository implements MedalsRepository {
  final Map<String, DateTime> database = {};

  @override
  Future<Map<String, DateTime>> fetchUnlockedMedals(String userId) async {
    return Map<String, DateTime>.from(database);
  }

  @override
  Future<void> unlockMedal({
    required String userId,
    required String medalId,
  }) async {
    database[medalId] = DateTime.now();
  }
}

void main() {
  group('Patch 2: Themes & ThemeProvider', () {
    test('switches light and dark mode and updates AppColors', () {
      final container = ProviderContainer();
      final notifier = container.read(themeProvider.notifier);

      expect(AppColors.isDark, isTrue);
      expect(AppColors.background, const Color(0xFF000000));
      expect(AppColors.surface, const Color(0xFF121212));

      notifier.setThemeMode(ThemeMode.light);
      expect(container.read(themeProvider).isDark, isFalse);
      expect(AppColors.isDark, isFalse);
      expect(AppColors.background, const Color(0xFFFFFFFF));
      expect(AppColors.surface, const Color(0xFFF5F5F5));
      expect(AppColors.textPrimary, const Color(0xFF000000));
      expect(AppColors.textSecondary, const Color(0xFF666666));

      notifier.setThemeMode(ThemeMode.dark);
      expect(container.read(themeProvider).isDark, isTrue);
      expect(AppColors.isDark, isTrue);
      expect(AppColors.background, const Color(0xFF000000));
    });

    test('updates accent color and computes onPrimary high-contrast', () {
      final fakeRepo = _FakeProfileRepository();
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(
            User(
              id: 'user-123',
              appMetadata: const {},
              userMetadata: const {},
              aud: 'authenticated',
              createdAt: DateTime.now().toIso8601String(),
            ),
          ),
          profileRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );

      final notifier = container.read(themeProvider.notifier);

      // Select Red (#EF4444)
      final redOption = kAccentColors.firstWhere((c) => c.name == 'Red');
      notifier.setAccentColor(redOption.color, redOption.hex);

      expect(
        container.read(themeProvider).accentColor,
        const Color(0xFFEF4444),
      );
      expect(AppColors.primary, const Color(0xFFEF4444));
      // Red has luminance < 0.5, so onPrimary should be white
      expect(AppColors.onPrimary, const Color(0xFFFFFFFF));

      // Select Yellow (#EAB308)
      final yellowOption = kAccentColors.firstWhere((c) => c.name == 'Yellow');
      notifier.setAccentColor(yellowOption.color, yellowOption.hex);
      expect(
        container.read(themeProvider).accentColor,
        const Color(0xFFEAB308),
      );
      expect(AppColors.primary, const Color(0xFFEAB308));
      // Yellow has high luminance, so onPrimary should be black
      expect(AppColors.onPrimary, const Color(0xFF000000));

      expect(fakeRepo.lastThemeSettings?['accentColor'], '#EAB308');
    });
  });

  group('Patch 2: Settings & ThemeScreen UI', () {
    testWidgets('renders SettingsScreen with navigation tiles', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SettingsScreen())),
      );

      expect(find.text('Settings'), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('settings-theme-tile')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('settings-profile-tile')),
        findsOneWidget,
      );
    });

    testWidgets('ThemeScreen toggles mode and selects accent colors', (
      tester,
    ) async {
      final fakeRepo = _FakeProfileRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(
              User(
                id: 'user-123',
                appMetadata: const {},
                userMetadata: const {},
                aud: 'authenticated',
                createdAt: DateTime.now().toIso8601String(),
              ),
            ),
            profileRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(home: ThemeScreen()),
        ),
      );

      expect(find.text('Themes'), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('theme-mode-switch')),
        findsOneWidget,
      );

      // Verify all 7 color circles render
      for (final option in kAccentColors) {
        expect(
          find.byKey(
            ValueKey<String>('accent-color-${option.name.toLowerCase()}'),
          ),
          findsOneWidget,
        );
      }

      // Tap blue accent
      await tester.tap(find.byKey(const ValueKey<String>('accent-color-blue')));
      await tester.pumpAndSettle();

      expect(AppColors.primary, const Color(0xFF3B82F6));

      // Tap terracotta (#D68F71) accent
      await tester.tap(
        find.byKey(const ValueKey<String>('accent-color-terracotta')),
      );
      await tester.pumpAndSettle();

      expect(AppColors.primary, const Color(0xFFD68F71));
      expect(fakeRepo.lastThemeSettings?['accentColor'], '#D68F71');
    });
  });

  group('Patch 2: CustomizeProfileScreen & Global Avatar', () {
    testWidgets('CustomizeProfileScreen saves display name', (tester) async {
      final fakeRepo = _FakeProfileRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(
              User(
                id: 'user-123',
                appMetadata: const {},
                userMetadata: {'username': 'olduser'},
                aud: 'authenticated',
                createdAt: DateTime.now().toIso8601String(),
              ),
            ),
            profileRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(home: CustomizeProfileScreen()),
        ),
      );

      expect(find.text('Customize Profile'), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('change-avatar-button')),
        findsOneWidget,
      );

      final input = find.byKey(
        const ValueKey<String>('customize-profile-display-name-input'),
      );
      expect(input, findsOneWidget);

      await tester.enterText(input, 'Iron Warrior');
      await tester.tap(
        find.byKey(const ValueKey<String>('customize-profile-save-button')),
      );
      await tester.pumpAndSettle();

      expect(fakeRepo.lastProfileInfo?['displayName'], 'Iron Warrior');
    });

    testWidgets('HomeHeader displays display_name and circular avatar', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeHeader(
              streak: 5,
              username: 'Iron Warrior',
              avatarUrl: null,
            ),
          ),
        ),
      );

      expect(find.textContaining('Iron Warrior'), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('home-profile-button')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
    });
  });

  group('Patch 2: Medals System', () {
    test('evaluates medals based on level, streak, and PRs', () async {
      final fakeMedalsRepo = _FakeMedalsRepository();
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(
            User(
              id: 'user-123',
              appMetadata: const {},
              userMetadata: const {},
              aud: 'authenticated',
              createdAt: DateTime.now().toIso8601String(),
            ),
          ),
          medalsRepositoryProvider.overrideWithValue(fakeMedalsRepo),
        ],
      );

      final notifier = container.read(medalsProvider.notifier);

      // Reaching level 5 unlocks level_5
      await notifier.evaluateAndUnlock(level: 5);
      expect(container.read(medalsProvider).isUnlocked('level_5'), isTrue);
      expect(fakeMedalsRepo.database.containsKey('level_5'), isTrue);

      // 7-day streak unlocks streak_7
      await notifier.evaluateAndUnlock(streak: 7);
      expect(container.read(medalsProvider).isUnlocked('streak_7'), isTrue);

      // 1 PR unlocks first_pr
      await notifier.evaluateAndUnlock(totalPrs: 1);
      expect(container.read(medalsProvider).isUnlocked('first_pr'), isTrue);

      // 5 PRs unlocks five_prs
      await notifier.evaluateAndUnlock(totalPrs: 5);
      expect(container.read(medalsProvider).isUnlocked('five_prs'), isTrue);

      // Level 10 and 30-day streak remain locked
      expect(container.read(medalsProvider).isUnlocked('level_10'), isFalse);
      expect(container.read(medalsProvider).isUnlocked('streak_30'), isFalse);
    });

    testWidgets(
      'MedalsScreen renders list of medals with locked/unlocked states',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 3200));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final fakeMedalsRepo = _FakeMedalsRepository()
          ..database['first_pr'] = DateTime.now()
          ..database['level_5'] = DateTime.now();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentUserProvider.overrideWithValue(
                User(
                  id: 'user-123',
                  appMetadata: const {},
                  userMetadata: const {},
                  aud: 'authenticated',
                  createdAt: DateTime.now().toIso8601String(),
                ),
              ),
              medalsRepositoryProvider.overrideWithValue(fakeMedalsRepo),
            ],
            child: const MaterialApp(home: MedalsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Medals'), findsOneWidget);
        expect(find.textContaining('Unlocked'), findsOneWidget);

        // Check medal cards exist
        for (final medal in kStaticMedals) {
          expect(
            find.byKey(ValueKey<String>('medal-card-${medal.id}')),
            findsOneWidget,
          );
        }

        // Check UNLOCKED and LOCKED labels exist
        expect(find.text('UNLOCKED'), findsWidgets);
        expect(find.text('LOCKED'), findsWidgets);
      },
    );
  });

  group('Patch 2: PR Celebration Overlay Polish', () {
    testWidgets('uses accent color for glowing hexagon and header text', (
      tester,
    ) async {
      const customAccent = Color(0xFFEF4444); // Red accent

      await tester.pumpWidget(
        MaterialApp(
          home: PrCelebrationOverlay(
            exerciseNames: const ['Deadlift'],
            onDismiss: () {},
            accentColor: customAccent,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));

      final newPrText = tester.widget<Text>(find.text('NEW PR!'));
      expect(newPrText.style?.color, customAccent);
    });
  });
}
