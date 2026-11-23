import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/medals/data/medals_repository.dart';
import 'package:stryde/features/medals/presentation/providers/medal_notification_provider.dart';
import 'package:stryde/features/medals/presentation/providers/medals_provider.dart';
import 'package:stryde/features/profile/data/profile_repository.dart';
import 'package:stryde/features/progression/data/skills_repository.dart';
import 'package:stryde/features/progression/presentation/providers/skill_allocations_provider.dart';
import 'package:stryde/features/progression/presentation/providers/user_progression_provider.dart';
import 'package:stryde/features/routines/data/mock_workout_data.dart';
import 'package:stryde/features/routines/domain/entities/mastery_routine_definition.dart';
import 'package:stryde/features/workout_history/data/workout_history_repository.dart';
import 'package:stryde/features/workout_history/domain/entities/completed_workout.dart';
import 'package:stryde/features/workout_logging/presentation/providers/active_workout_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeProfileRepository implements ProfileRepository {
  ProfileData? currentProfile;
  Map<String, dynamic> lastSavedValues = <String, dynamic>{};
  int saveCount = 0;

  @override
  Future<ProfileData?> getOrFetchProfile(
    String userId, {
    String? defaultUsername,
  }) async {
    return fetch(userId);
  }

  @override
  Future<ProfileData?> fetch(String userId) async {
    return currentProfile;
  }

  @override
  Future<void> saveProgression({
    required String userId,
    required int xp,
    required int level,
    required int skillPoints,
    int? totalXp,
    int? availableSkillPoints,
  }) async {
    saveCount++;
    lastSavedValues = <String, dynamic>{
      'user_id': userId,
      'xp': xp,
      'level': level,
      'skill_points': skillPoints,
      'total_xp': totalXp,
      'available_skill_points': availableSkillPoints,
    };
  }

  @override
  Future<void> saveTimezone({
    required String userId,
    required String timezone,
  }) async {}

  @override
  Future<void> saveStreak({
    required String userId,
    required int streak,
    required DateTime? lastActivityOn,
  }) async {}

  @override
  Future<void> saveGoals({
    required String userId,
    required int steps,
    required double water,
    required int protein,
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

class _FakeSkillsRepository implements SkillsRepository {
  final Map<String, int> database = <String, int>{};
  int upsertCount = 0;

  @override
  Future<Map<String, int>> fetch(String userId) async {
    return Map<String, int>.from(database);
  }

  @override
  Future<void> upsert({
    required String userId,
    required String muscleGroup,
    required int points,
  }) async {
    upsertCount++;
    database[muscleGroup] = points;
  }
}

class _FakeMedalsRepository implements MedalsRepository {
  final Map<String, DateTime> database = <String, DateTime>{};
  int unlockCount = 0;

  @override
  Future<Map<String, DateTime>> fetchUnlockedMedals(String userId) async {
    return Map<String, DateTime>.from(database);
  }

  @override
  Future<void> unlockMedal({
    required String userId,
    required String medalId,
  }) async {
    unlockCount++;
    database[medalId] = DateTime.now();
  }
}

class _FakeWorkoutHistoryRepository implements WorkoutHistoryRepository {
  final List<CompletedWorkout> insertedWorkouts = <CompletedWorkout>[];

  @override
  Future<List<CompletedWorkout>> fetch(String userId) async {
    return List<CompletedWorkout>.from(insertedWorkouts);
  }

  @override
  Future<String> insert({
    required String userId,
    required CompletedWorkout workout,
  }) async {
    insertedWorkouts.add(workout);
    return 'fake-workout-id-${insertedWorkouts.length}';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('1. XP & Rank Syncing to Supabase (profiles.total_xp)', () {
    test(
      'UserProgressionNotifier saves cumulative total_xp whenever XP is gained',
      () async {
        final fakeProfileRepo = _FakeProfileRepository();
        final container = ProviderContainer(
          overrides: [
            currentUserProvider.overrideWithValue(
              User(
                id: 'user-sync-test',
                appMetadata: const {},
                userMetadata: const {},
                aud: 'authenticated',
                createdAt: DateTime.now().toIso8601String(),
              ),
            ),
            profileRepositoryProvider.overrideWithValue(fakeProfileRepo),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(userProgressionProvider.notifier);

        // Award 250 XP:
        // Level 1->2 (100) + Level 2->3 (150) = 250 cumulative XP, reaches Level 3 with 0 currentXp
        notifier.addXp(250);

        // Allow async persistence queue to run
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final state = container.read(userProgressionProvider);
        expect(state.currentLevel, 3);
        expect(state.currentXp, 0);
        expect(state.totalXp, 250);

        expect(fakeProfileRepo.lastSavedValues['total_xp'], 250);
        expect(fakeProfileRepo.lastSavedValues['level'], 3);
        expect(fakeProfileRepo.lastSavedValues['xp'], 0);
      },
    );

    test(
      'On app load, reads total_xp and recalculates correct progressive level rather than trusting level column',
      () async {
        final fakeProfileRepo = _FakeProfileRepository();
        // Suppose the database stale 'level' says 1, but 'total_xp' is 450 (which corresponds to Level 4 Fresher)
        fakeProfileRepo.currentProfile = const ProfileData(
          xp: 0,
          level: 1, // Stale level in database
          totalXp: 450, // True total XP (100 + 150 + 200 = Level 4)
          streak: 5,
          skillPoints: 6,
          availableSkillPoints: 6,
        );

        final container = ProviderContainer(
          overrides: [
            currentUserProvider.overrideWithValue(
              User(
                id: 'user-hydrate-test',
                appMetadata: const {},
                userMetadata: const {},
                aud: 'authenticated',
                createdAt: DateTime.now().toIso8601String(),
              ),
            ),
            profileRepositoryProvider.overrideWithValue(fakeProfileRepo),
          ],
        );
        addTearDown(container.dispose);

        // Trigger build and hydration
        container.read(userProgressionProvider);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final state = container.read(userProgressionProvider);
        // XpProgressionEngine correctly recalculated Level 4 Fresher with 0 current XP
        expect(state.currentLevel, 4);
        expect(state.currentXp, 0);
        expect(state.totalXp, 450);
        expect(state.rank.name, 'Fresher');
        expect(state.skillPoints, 6);
      },
    );
  });

  group('2. Skill Point Syncing (available_skill_points & skills table)', () {
    test(
      'Level-up / rank promotion increments available_skill_points and saves to profiles',
      () async {
        final fakeProfileRepo = _FakeProfileRepository();
        final container = ProviderContainer(
          overrides: [
            currentUserProvider.overrideWithValue(
              User(
                id: 'user-sp-test',
                appMetadata: const {},
                userMetadata: const {},
                aud: 'authenticated',
                createdAt: DateTime.now().toIso8601String(),
              ),
            ),
            profileRepositoryProvider.overrideWithValue(fakeProfileRepo),
          ],
        );
        addTearDown(container.dispose);

        // 450 XP = Levels 1->2 (1), 2->3 (1), 3->4 (1 + 3 rank bonus) = 6 skill points earned
        container.read(userProgressionProvider.notifier).addXp(450);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(container.read(userProgressionProvider).skillPoints, 6);
        expect(fakeProfileRepo.lastSavedValues['available_skill_points'], 6);
        expect(fakeProfileRepo.lastSavedValues['skill_points'], 6);
      },
    );

    test(
      'Allocating a skill point decrements available_skill_points and upserts skills table',
      () async {
        final fakeProfileRepo = _FakeProfileRepository();
        final fakeSkillsRepo = _FakeSkillsRepository();

        final container = ProviderContainer(
          overrides: [
            currentUserProvider.overrideWithValue(
              User(
                id: 'user-spend-test',
                appMetadata: const {},
                userMetadata: const {},
                aud: 'authenticated',
                createdAt: DateTime.now().toIso8601String(),
              ),
            ),
            profileRepositoryProvider.overrideWithValue(fakeProfileRepo),
            skillsRepositoryProvider.overrideWithValue(fakeSkillsRepo),
          ],
        );
        addTearDown(container.dispose);

        // Gain 100 XP -> 1 skill point
        container.read(userProgressionProvider.notifier).addXp(100);
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(container.read(userProgressionProvider).skillPoints, 1);

        // Allocate point to Chest
        final spent = container
            .read(skillAllocationsProvider.notifier)
            .spend('Chest');
        expect(spent, isTrue);

        await Future<void>.delayed(const Duration(milliseconds: 50));

        // 1. available_skill_points in profiles decremented to 0
        expect(container.read(userProgressionProvider).skillPoints, 0);
        expect(fakeProfileRepo.lastSavedValues['available_skill_points'], 0);

        // 2. skills table upserted with points: 1 for 'Chest'
        expect(fakeSkillsRepo.database['Chest'], 1);
        expect(fakeSkillsRepo.upsertCount, 1);
      },
    );
  });

  group('3. Medals Syncing (20-Medal Update & user_medals table)', () {
    test('Newly unlocked medal inserts into user_medals table', () async {
      final fakeMedalsRepo = _FakeMedalsRepository();
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(
            User(
              id: 'user-medal-sync',
              appMetadata: const {},
              userMetadata: const {},
              aud: 'authenticated',
              createdAt: DateTime.now().toIso8601String(),
            ),
          ),
          medalsRepositoryProvider.overrideWithValue(fakeMedalsRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(medalsProvider.notifier);

      // Unlock First Blood (1 PR) during runtime
      await notifier.evaluateAndUnlock(totalPrs: 1, isReconciling: false);

      expect(container.read(medalsProvider).isUnlocked('first_blood'), isTrue);
      expect(fakeMedalsRepo.database.containsKey('first_blood'), isTrue);
      expect(fakeMedalsRepo.unlockCount, 1);

      // Notification is queued for this newly unlocked medal
      final notif = container.read(medalNotificationProvider);
      expect(notif.currentMedal?.id, 'first_blood');
      expect(notif.isVisible, isTrue);
    });

    test(
      'On app load, fetches unlocked medals from user_medals and does not trigger notification',
      () async {
        final fakeMedalsRepo = _FakeMedalsRepository()
          ..database['record_breaker'] = DateTime.now()
          ..database['first_flame'] = DateTime.now();

        final container = ProviderContainer(
          overrides: [
            currentUserProvider.overrideWithValue(
              User(
                id: 'user-medal-hydrate',
                appMetadata: const {},
                userMetadata: const {},
                aud: 'authenticated',
                createdAt: DateTime.now().toIso8601String(),
              ),
            ),
            medalsRepositoryProvider.overrideWithValue(fakeMedalsRepo),
          ],
        );
        addTearDown(container.dispose);

        // Trigger build and hydration
        container.read(medalsProvider);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final state = container.read(medalsProvider);
        expect(state.isUnlocked('record_breaker'), isTrue);
        expect(state.isUnlocked('first_flame'), isTrue);

        // Notification banner is NOT triggered for medals already in database
        final notif = container.read(medalNotificationProvider);
        expect(notif.currentMedal, isNull);
        expect(notif.isVisible, isFalse);
      },
    );
  });

  group(
    '4. Mastery & Preset Workout Syncing (workouts and workout_sets tables)',
    () {
      test(
        'Finishing a Mastery Routine saves completed workout and sets to repository',
        () async {
          final fakeHistoryRepo = _FakeWorkoutHistoryRepository();
          final container = ProviderContainer(
            overrides: [
              currentUserProvider.overrideWithValue(
                User(
                  id: 'user-workout-sync',
                  appMetadata: const {},
                  userMetadata: const {},
                  aud: 'authenticated',
                  createdAt: DateTime.now().toIso8601String(),
                ),
              ),
              workoutHistoryRepositoryProvider.overrideWithValue(
                fakeHistoryRepo,
              ),
            ],
          );
          addTearDown(container.dispose);

          // Start Chest Mastery routine
          final chestMastery = MasteryRoutineDefinitions.chestMastery
              .toDefaultRoutine();
          final activeNotifier = container.read(activeWorkoutProvider.notifier);
          activeNotifier.startWorkout(chestMastery);

          // Complete a set
          activeNotifier.updateWeight(0, 0, '90.0');
          activeNotifier.updateReps(0, 0, '8');
          activeNotifier.toggleSetCompletion(0, 0);

          final result = activeNotifier.finishWorkout();
          expect(result, isNotNull);

          await Future<void>.delayed(const Duration(milliseconds: 50));

          // Verify workout was inserted into repository
          expect(fakeHistoryRepo.insertedWorkouts, hasLength(1));
          final savedWorkout = fakeHistoryRepo.insertedWorkouts.first;
          expect(savedWorkout.routineName, 'Chest Mastery');
          expect(savedWorkout.exercises.first.sets.first.weightKg, 90.0);
          expect(savedWorkout.exercises.first.sets.first.reps, 8);
        },
      );

      test(
        'Finishing a Push/Pull/Legs preset routine saves completed workout and sets to repository',
        () async {
          final fakeHistoryRepo = _FakeWorkoutHistoryRepository();
          final container = ProviderContainer(
            overrides: [
              currentUserProvider.overrideWithValue(
                User(
                  id: 'user-ppl-sync',
                  appMetadata: const {},
                  userMetadata: const {},
                  aud: 'authenticated',
                  createdAt: DateTime.now().toIso8601String(),
                ),
              ),
              workoutHistoryRepositoryProvider.overrideWithValue(
                fakeHistoryRepo,
              ),
            ],
          );
          addTearDown(container.dispose);

          // Start Push Day preset
          final activeNotifier = container.read(activeWorkoutProvider.notifier);
          activeNotifier.startWorkout(MockWorkoutData.pushDay);

          // Complete Bench Press set
          activeNotifier.updateWeight(0, 0, '85.0');
          activeNotifier.updateReps(0, 0, '10');
          activeNotifier.toggleSetCompletion(0, 0);

          final result = activeNotifier.finishWorkout();
          expect(result, isNotNull);

          await Future<void>.delayed(const Duration(milliseconds: 50));

          expect(fakeHistoryRepo.insertedWorkouts, hasLength(1));
          final savedWorkout = fakeHistoryRepo.insertedWorkouts.first;
          expect(savedWorkout.routineName, 'Push Day');
          expect(savedWorkout.exercises.first.sets.first.weightKg, 85.0);
          expect(savedWorkout.exercises.first.sets.first.reps, 10);
        },
      );
    },
  );
}
