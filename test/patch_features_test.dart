import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stryde/core/services/audio_service.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/home/presentation/screens/home_screen.dart';
import 'package:stryde/features/profile/data/profile_repository.dart';
import 'package:stryde/features/profile/presentation/providers/profile_goals_provider.dart';
import 'package:stryde/features/profile/presentation/screens/profile_screen.dart';
import 'package:stryde/features/progression/domain/entities/rank.dart';
import 'package:stryde/features/routines/data/mock_workout_data.dart';
import 'package:stryde/features/workout_history/domain/entities/completed_workout.dart';
import 'package:stryde/features/workout_history/presentation/providers/workout_history_provider.dart';
import 'package:stryde/features/workout_logging/presentation/providers/active_workout_provider.dart';
import 'package:stryde/features/workout_logging/presentation/widgets/pr_celebration_overlay.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockAudioService extends AudioService {
  int dingCount = 0;

  @override
  Future<void> playDing() async {
    dingCount++;
  }
}

class _MockProfileRepository implements ProfileRepository {
  Map<String, dynamic>? savedGoals;

  @override
  Future<ProfileData?> getOrFetchProfile(
    String userId, {
    String? defaultUsername,
  }) async {
    return fetch(userId);
  }

  @override
  Future<ProfileData?> fetch(String userId) async => null;

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
  }) async {
    savedGoals = {
      'userId': userId,
      'steps': steps,
      'water': water,
      'protein': protein,
    };
  }

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

  @override
  Future<void> saveProfileInfo({
    required String userId,
    String? displayName,
    String? avatarUrl,
  }) async {}
}

void main() {
  group('1. Rest Timer Ding Sound', () {
    test('plays ding sound when rest timer reaches 0', () async {
      final mockAudio = _MockAudioService();
      final container = ProviderContainer(
        overrides: [audioServiceProvider.overrideWithValue(mockAudio)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(activeWorkoutProvider.notifier);
      notifier.startWorkout(MockWorkoutData.pushDay);

      // Start rest timer with a duration of 1 second
      notifier.startRestTimer(duration: const Duration(seconds: 1));
      expect(
        container.read(activeWorkoutProvider).session?.restEndsAt,
        isNotNull,
      );
      expect(mockAudio.dingCount, 0);

      // Advance clock past rest duration
      await Future<void>.delayed(const Duration(milliseconds: 1100));

      // Active workout ticker runs once per second
      expect(mockAudio.dingCount, greaterThanOrEqualTo(1));
    });

    test('does not play ding sound if rest timer is skipped', () {
      final mockAudio = _MockAudioService();
      final container = ProviderContainer(
        overrides: [audioServiceProvider.overrideWithValue(mockAudio)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(activeWorkoutProvider.notifier);
      notifier.startWorkout(MockWorkoutData.pushDay);

      notifier.startRestTimer(duration: const Duration(seconds: 90));
      expect(
        container.read(activeWorkoutProvider).session?.restEndsAt,
        isNotNull,
      );

      notifier.skipRestTimer();
      expect(container.read(activeWorkoutProvider).session?.restEndsAt, isNull);
      expect(mockAudio.dingCount, 0);
    });
  });

  group('2. Manual Text Input for Goals (Profile Tab)', () {
    testWidgets('typing a number and submitting updates goals and repository', (
      tester,
    ) async {
      final mockRepo = _MockProfileRepository();
      final testUser = User(
        id: 'user-input-test',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );

      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(testUser),
          profileRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: ProfileScreen())),
        ),
      );
      await tester.pumpAndSettle();

      // Find the text input for Daily Steps
      final stepsInputFinder = find.byKey(
        const ValueKey<String>('goal-input-Daily Steps'),
      );
      expect(stepsInputFinder, findsOneWidget);

      // Enter 12500 steps and submit
      await tester.enterText(stepsInputFinder, '12500');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(container.read(profileGoalsProvider).steps, 12500);
      expect(mockRepo.savedGoals?['steps'], 12500);

      // Enter 3.5 water and submit
      final waterInputFinder = find.byKey(
        const ValueKey<String>('goal-input-Daily Water'),
      );
      await tester.enterText(waterInputFinder, '3.5');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(container.read(profileGoalsProvider).waterLiters, 3.5);
      expect(mockRepo.savedGoals?['water'], 3.5);

      // Enter 180 protein and submit
      final proteinInputFinder = find.byKey(
        const ValueKey<String>('goal-input-Daily Protein'),
      );
      await tester.enterText(proteinInputFinder, '180');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(container.read(profileGoalsProvider).proteinGrams, 180);
      expect(mockRepo.savedGoals?['protein'], 180);
    });
  });

  group('3. Rename the Ranks', () {
    test('evaluates ranks according to the new hierarchy', () {
      expect(Ranks.forLevel(1).name, 'Initiate');
      expect(Ranks.forLevel(3).name, 'Initiate');
      expect(Ranks.forLevel(4).name, 'Fresher');
      expect(Ranks.forLevel(6).name, 'Fresher');
      expect(Ranks.forLevel(7).name, 'Rising Star');
      expect(Ranks.forLevel(10).name, 'Rising Star');
      expect(Ranks.forLevel(11).name, 'Locked In');
      expect(Ranks.forLevel(15).name, 'Locked In');
      expect(Ranks.forLevel(16).name, 'Vanguard');
      expect(Ranks.forLevel(22).name, 'Vanguard');
      expect(Ranks.forLevel(23).name, 'Ascendant');
      expect(Ranks.forLevel(30).name, 'Ascendant');
      expect(Ranks.forLevel(31).name, 'Sovereign');
      expect(Ranks.forLevel(40).name, 'Sovereign');
      expect(Ranks.forLevel(41).name, 'Olympian');
      expect(Ranks.forLevel(50).name, 'Olympian');
      expect(Ranks.forLevel(51).name, 'Titan');
      expect(Ranks.forLevel(65).name, 'Titan');
      expect(Ranks.forLevel(66).name, 'Demigod');
      expect(Ranks.forLevel(80).name, 'Demigod');
      expect(Ranks.forLevel(81).name, 'Celestial');
      expect(Ranks.forLevel(99).name, 'Celestial');
      expect(Ranks.forLevel(100).name, 'Godslayer');
      expect(Ranks.forLevel(120).name, 'Godslayer');
    });
  });

  group('4. Custom Greeting with Username', () {
    test(
      'formats greeting with username based on time of day and handles null',
      () {
        final morning = DateTime(2026, 11, 22, 9, 0);
        final afternoon = DateTime(2026, 11, 22, 14, 0);
        final evening = DateTime(2026, 11, 22, 20, 0);

        // With username
        expect(HomeHeader.greeting(morning, 'Alex'), 'Good Morning, Alex');
        expect(HomeHeader.greeting(afternoon, 'Alex'), 'Good Afternoon, Alex');
        expect(HomeHeader.greeting(evening, 'Alex'), 'Good Evening, Alex');

        // Without username (null or empty)
        expect(HomeHeader.greeting(morning, null), 'Good Morning');
        expect(HomeHeader.greeting(afternoon, null), 'Good Morning');
        expect(HomeHeader.greeting(evening, null), 'Good Morning');
        expect(HomeHeader.greeting(morning, ''), 'Good Morning');
      },
    );
  });

  group('5. PR Celebration Overlay Foundation', () {
    test(
      'detects PR when a set beats previous max volume for that exercise',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Seed historical workout with Bench Press: 80kg x 10 reps = 800 volume
        container
            .read(workoutHistoryProvider.notifier)
            .addWorkout(
              CompletedWorkout(
                id: 'past-1',
                routineId: MockWorkoutData.pushDay.id,
                routineName: MockWorkoutData.pushDay.name,
                completedAt: DateTime.now().subtract(const Duration(days: 3)),
                duration: const Duration(minutes: 30),
                exercises: [
                  CompletedWorkoutExercise(
                    exerciseId: MockWorkoutData.benchPress.id,
                    exerciseName: MockWorkoutData.benchPress.name,
                    sets: const [
                      CompletedWorkoutSet(setNumber: 1, weightKg: 80, reps: 10),
                    ],
                  ),
                ],
              ),
            );

        // Start a new workout
        final notifier = container.read(activeWorkoutProvider.notifier);
        notifier.startWorkout(MockWorkoutData.pushDay);

        // Log Bench Press with 85kg x 10 reps = 850 volume (> 800 volume)
        notifier.updateWeight(0, 0, '85');
        notifier.updateReps(0, 0, '10');
        notifier.toggleSetCompletion(0, 0);

        // Finish workout
        final result = notifier.finishWorkout();
        expect(result, isNotNull);
        expect(result!.hasPr, isTrue);
        expect(result.prExercises, contains(MockWorkoutData.benchPress.name));
      },
    );

    testWidgets(
      'renders PR celebration overlay with glowing hexagon and exercise name',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: PrCelebrationOverlay(
              exerciseNames: const ['Bench Press'],
              onDismiss: () {},
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 900));

        expect(find.text('NEW PR!'), findsOneWidget);
        expect(find.text('Bench Press'), findsOneWidget);
        expect(find.text('TAP ANYWHERE TO CONTINUE'), findsOneWidget);
      },
    );
  });
}
