import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/database/app_database.dart';
import 'package:stryde/core/database/local_cache_service.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/theme_preset.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/profile/data/profile_repository.dart';
import 'package:stryde/features/routines/data/mock_workout_data.dart';
import 'package:stryde/features/settings/presentation/providers/theme_provider.dart';
import 'package:stryde/features/settings/presentation/screens/theme_screen.dart';
import 'package:stryde/features/settings/presentation/widgets/theme_preset_selector.dart';
import 'package:stryde/features/workout_logging/presentation/providers/active_workout_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeProfileRepository implements ProfileRepository {
  Map<String, dynamic>? lastThemeSettings;

  @override
  Future<void> saveThemeSettings({
    required String userId,
    required String themeMode,
    required String accentColor,
  }) async {
    lastThemeSettings = <String, dynamic>{
      'userId': userId,
      'themeMode': themeMode,
      'accentColor': accentColor,
    };
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Theme Presets: Exact Palettes & Brightness', () {
    test(
      'all 8 theme presets match exact hexadecimal values and brightness',
      () {
        expect(kThemePresets.length, 8);

        // 1. Shadow Monarch
        final shadowMonarch = kThemePresetShadowMonarch;
        expect(shadowMonarch.id, 'shadow_monarch');
        expect(shadowMonarch.background, const Color(0xFF100B1C));
        expect(shadowMonarch.surface, const Color(0xFF211631));
        expect(shadowMonarch.accent, const Color(0xFFA855F7));
        expect(shadowMonarch.text, const Color(0xFFF0E8FF));
        expect(shadowMonarch.onAccent, const Color(0xFF100B1C));
        expect(shadowMonarch.brightness, Brightness.dark);
        expect(shadowMonarch.isDark, isTrue);

        // 2. Blood Moon
        final bloodMoon = kThemePresetBloodMoon;
        expect(bloodMoon.id, 'blood_moon');
        expect(bloodMoon.background, const Color(0xFF19090D));
        expect(bloodMoon.surface, const Color(0xFF32131B));
        expect(bloodMoon.accent, const Color(0xFFEF4444));
        expect(bloodMoon.text, const Color(0xFFFFE8E8));
        expect(bloodMoon.onAccent, const Color(0xFF19090D));
        expect(bloodMoon.brightness, Brightness.dark);
        expect(bloodMoon.isDark, isTrue);

        // 3. Glacier
        final glacier = kThemePresetGlacier;
        expect(glacier.id, 'glacier');
        expect(glacier.background, const Color(0xFF081725));
        expect(glacier.surface, const Color(0xFF142D40));
        expect(glacier.accent, const Color(0xFF38BDF8));
        expect(glacier.text, const Color(0xFFE1F4FF));
        expect(glacier.onAccent, const Color(0xFF081725));
        expect(glacier.brightness, Brightness.dark);
        expect(glacier.isDark, isTrue);

        // 4. Olympus
        final olympus = kThemePresetOlympus;
        expect(olympus.id, 'olympus');
        expect(olympus.background, const Color(0xFF19160F));
        expect(olympus.surface, const Color(0xFF302718));
        expect(olympus.accent, const Color(0xFFD4AF37));
        expect(olympus.text, const Color(0xFFFFF3D6));
        expect(olympus.onAccent, const Color(0xFF19160F));
        expect(olympus.brightness, Brightness.dark);
        expect(olympus.isDark, isTrue);

        // 5. Toxic
        final toxic = kThemePresetToxic;
        expect(toxic.id, 'toxic');
        expect(toxic.background, const Color(0xFF10170B));
        expect(toxic.surface, const Color(0xFF202D16));
        expect(toxic.accent, const Color(0xFFA3E635));
        expect(toxic.text, const Color(0xFFF0F8E5));
        expect(toxic.onAccent, const Color(0xFF10170B));
        expect(toxic.brightness, Brightness.dark);
        expect(toxic.isDark, isTrue);

        // 6. Abyss
        final abyss = kThemePresetAbyss;
        expect(abyss.id, 'abyss');
        expect(abyss.background, const Color(0xFF050F12));
        expect(abyss.surface, const Color(0xFF102529));
        expect(abyss.accent, const Color(0xFF2DD4BF));
        expect(abyss.text, const Color(0xFFD9FFF8));
        expect(abyss.onAccent, const Color(0xFF050F12));
        expect(abyss.brightness, Brightness.dark);
        expect(abyss.isDark, isTrue);

        // 7. Ember
        final ember = kThemePresetEmber;
        expect(ember.id, 'ember');
        expect(ember.background, const Color(0xFF1C1009));
        expect(ember.surface, const Color(0xFF382116));
        expect(ember.accent, const Color(0xFFFB923C));
        expect(ember.text, const Color(0xFFFFF0DF));
        expect(ember.onAccent, const Color(0xFF1C1009));
        expect(ember.brightness, Brightness.dark);
        expect(ember.isDark, isTrue);

        // 8. Sakura (Light)
        final sakura = kThemePresetSakura;
        expect(sakura.id, 'sakura');
        expect(sakura.background, const Color(0xFFFFF0F5));
        expect(sakura.surface, const Color(0xFFF9DCE7));
        expect(sakura.accent, const Color(0xFFBE185D));
        expect(sakura.text, const Color(0xFF63243F));
        expect(sakura.onAccent, const Color(0xFFFFFFFF));
        expect(sakura.brightness, Brightness.light);
        expect(sakura.isDark, isFalse);
      },
    );

    test('getThemePresetById resolves identifiers with and without prefix', () {
      expect(getThemePresetById('shadow_monarch'), kThemePresetShadowMonarch);
      expect(
        getThemePresetById('preset:shadow_monarch'),
        kThemePresetShadowMonarch,
      );
      expect(getThemePresetById('preset:blood_moon'), kThemePresetBloodMoon);
      expect(getThemePresetById('sakura'), kThemePresetSakura);
      expect(getThemePresetById('unknown_id'), isNull);
      expect(getThemePresetById(null), isNull);
    });
  });

  group('Theme Presets: AppColors and Token Mapping', () {
    test(
      'AppColors updates tokens correctly when preset is set and cleared',
      () {
        AppColors.update(preset: kThemePresetGlacier);
        expect(AppColors.currentPreset, kThemePresetGlacier);
        expect(AppColors.background, const Color(0xFF081725));
        expect(AppColors.surface, const Color(0xFF142D40));
        expect(AppColors.primary, const Color(0xFF38BDF8));
        expect(AppColors.textPrimary, const Color(0xFFE1F4FF));
        expect(AppColors.onPrimary, const Color(0xFF081725));
        expect(AppColors.progressTrack, const Color(0xFF081725));
        expect(AppColors.isDark, isTrue);

        // Sakura (Light preset)
        AppColors.update(preset: kThemePresetSakura);
        expect(AppColors.currentPreset, kThemePresetSakura);
        expect(AppColors.background, const Color(0xFFFFF0F5));
        expect(AppColors.surface, const Color(0xFFF9DCE7));
        expect(AppColors.primary, const Color(0xFFBE185D));
        expect(AppColors.textPrimary, const Color(0xFF63243F));
        expect(AppColors.onPrimary, const Color(0xFFFFFFFF));
        expect(AppColors.progressTrack, const Color(0xFFFFF0F5));
        expect(AppColors.isDark, isFalse);

        // Clear preset back to standard dark
        AppColors.update(clearPreset: true, dark: true);
        expect(AppColors.currentPreset, isNull);
        expect(AppColors.background, const Color(0xFF000000));
        expect(AppColors.surface, const Color(0xFF121212));
      },
    );
  });

  group('Theme Presets: UI & ThemeScreen Integration', () {
    testWidgets(
      'ThemePresetSelector renders first 4 visible and scrolls remaining presets into view',
      (tester) async {
        final fakeRepo = _FakeProfileRepository();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentUserProvider.overrideWith(
                (ref) => const User(
                  id: 'test-user-theme',
                  appMetadata: {},
                  userMetadata: {},
                  aud: 'authenticated',
                  createdAt: '2026-01-01',
                ),
              ),
              profileRepositoryProvider.overrideWithValue(fakeRepo),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ThemePresetSelector(),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Exactly the first 4 are rendered on standard viewport
        expect(
          find.byKey(const ValueKey<String>('theme-preset-shadow_monarch')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey<String>('theme-preset-blood_moon')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey<String>('theme-preset-glacier')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey<String>('theme-preset-olympus')),
          findsOneWidget,
        );

        // Check miniature preview elements for visible cards
        expect(find.text('Level 24'), findsWidgets);
        expect(find.text('Ascendant'), findsWidgets);

        // Scroll horizontally to reveal the remaining 4 presets
        await tester.drag(
          find.byKey(const ValueKey<String>('theme-preset-list')),
          const Offset(-900, 0),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey<String>('theme-preset-toxic')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey<String>('theme-preset-abyss')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey<String>('theme-preset-ember')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey<String>('theme-preset-sakura')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Selecting a preset updates theme and overrides System/Light/Dark',
      (tester) async {
        final fakeRepo = _FakeProfileRepository();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentUserProvider.overrideWith(
                (ref) => const User(
                  id: 'test-user-theme-select',
                  appMetadata: {},
                  userMetadata: {},
                  aud: 'authenticated',
                  createdAt: '2026-01-01',
                ),
              ),
              profileRepositoryProvider.overrideWithValue(fakeRepo),
            ],
            child: const MaterialApp(home: ThemeScreen()),
          ),
        );

        await tester.pumpAndSettle();

        // Initially, no preset is active (default is dark mode)
        expect(AppColors.currentPreset, isNull);

        // Tap Shadow Monarch preset (visible in first 4)
        await tester.tap(
          find.byKey(const ValueKey<String>('theme-preset-shadow_monarch')),
        );
        await tester.pumpAndSettle();

        expect(AppColors.currentPreset, kThemePresetShadowMonarch);
        expect(AppColors.background, const Color(0xFF100B1C));
        expect(AppColors.surface, const Color(0xFF211631));
        expect(AppColors.primary, const Color(0xFFA855F7));
        expect(AppColors.textPrimary, const Color(0xFFF0E8FF));
        expect(AppColors.onPrimary, const Color(0xFF100B1C));

        // Verify persistence call was made with preset prefix
        expect(
          fakeRepo.lastThemeSettings?['themeMode'],
          'preset:shadow_monarch',
        );

        // Tap Light mode segment in Appearance - should clear the preset
        await tester.tap(find.text('Light'));
        await tester.pumpAndSettle();

        expect(AppColors.currentPreset, isNull);
        expect(AppColors.isDark, isFalse);
        expect(fakeRepo.lastThemeSettings?['themeMode'], 'light');

        // Tap Glacier preset
        await tester.tap(
          find.byKey(const ValueKey<String>('theme-preset-glacier')),
        );
        await tester.pumpAndSettle();

        expect(AppColors.currentPreset, kThemePresetGlacier);
        expect(AppColors.background, const Color(0xFF081725));
        expect(AppColors.primary, const Color(0xFF38BDF8));
      },
    );

    test('active workout state is preserved across theme preset switches', () {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);
      final workoutNotifier = container.read(activeWorkoutProvider.notifier);
      final themeNotifier = container.read(themeProvider.notifier);

      expect(workoutNotifier.startWorkout(MockWorkoutData.pushDay), isTrue);
      workoutNotifier.updateWeight(0, 0, '85.0');
      workoutNotifier.updateReps(0, 0, '10');

      final before = container.read(activeWorkoutProvider);
      expect(before.isOngoing, isTrue);
      expect(before.session!.exercises.first.sets.first.weightText, '85.0');

      // Switch to multiple presets
      themeNotifier.setThemePreset(kThemePresetShadowMonarch);
      expect(AppColors.currentPreset, kThemePresetShadowMonarch);

      themeNotifier.setThemePreset(kThemePresetSakura);
      expect(AppColors.currentPreset, kThemePresetSakura);

      themeNotifier.setThemeMode(ThemeMode.light);
      expect(AppColors.currentPreset, isNull);

      // Workout state is completely intact
      final after = container.read(activeWorkoutProvider);
      expect(after.isOngoing, isTrue);
      expect(after.session!.exercises.first.sets.first.weightText, '85.0');
      expect(after.session!.routine.id, MockWorkoutData.pushDay.id);
    });
  });
}
