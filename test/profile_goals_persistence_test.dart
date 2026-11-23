import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/home/data/completed_quests_repository.dart';
import 'package:stryde/features/home/domain/entities/completed_quest.dart';
import 'package:stryde/features/home/presentation/providers/habits_provider.dart';
import 'package:stryde/features/home/presentation/screens/home_screen.dart';
import 'package:stryde/features/profile/data/profile_repository.dart';
import 'package:stryde/features/profile/domain/entities/profile_goals.dart';
import 'package:stryde/features/profile/presentation/providers/profile_goals_provider.dart';
import 'package:stryde/features/progression/presentation/providers/user_progression_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockProfileRepository implements ProfileRepository {
  ProfileData? dataToReturn;
  Map<String, dynamic>? savedGoals;

  @override
  Future<ProfileData?> getOrFetchProfile(
    String userId, {
    String? defaultUsername,
  }) async {
    return fetch(userId);
  }

  @override
  Future<ProfileData?> fetch(String userId) async => dataToReturn;

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
    savedGoals = <String, dynamic>{
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

class _MockCompletedQuestsRepository implements CompletedQuestsRepository {
  final List<CompletedQuest> database = <CompletedQuest>[];

  @override
  Future<List<CompletedQuest>> fetch(String userId) async {
    return database.where((q) => q.userId == userId).toList();
  }

  @override
  Future<CompletedQuest?> insert({
    required String userId,
    required String questId,
    required String questType,
    DateTime? completedAt,
  }) async {
    final record = CompletedQuest(
      id: 'mock-${database.length + 1}',
      userId: userId,
      questId: questId,
      questType: questType,
      completedAt: completedAt ?? DateTime.now(),
    );
    database.add(record);
    return record;
  }
}

User _createTestUser() {
  return User(
    id: 'user-goals-123',
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
  );
}

void main() {
  group('Profile Goals entity', () {
    test('serializes to and from Supabase row correctly', () {
      final goals = ProfileGoals.fromRow({
        'goal_steps': 12500,
        'goal_water': 3.5,
        'goal_protein': 180,
      });

      expect(goals.steps, 12500);
      expect(goals.waterLiters, 3.5);
      expect(goals.proteinGrams, 180);

      final row = goals.toRow();
      expect(row['goal_steps'], 12500);
      expect(row['goal_water'], 3.5);
      expect(row['goal_protein'], 180);
    });

    test('falls back to defaults when row has null or missing columns', () {
      final goals = ProfileGoals.fromRow({});
      expect(goals.steps, 10000);
      expect(goals.waterLiters, 4.0);
      expect(goals.proteinGrams, 160);
    });
  });

  group('Profile Goals Provider & Repository Persistence', () {
    test('hydrates saved goals from repository on startup', () async {
      final mockRepo = _MockProfileRepository()
        ..dataToReturn = const ProfileData(
          xp: 200,
          level: 2,
          streak: 4,
          skillPoints: 1,
          goalSteps: 8500,
          goalWater: 3.0,
          goalProtein: 150,
        );

      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(_createTestUser()),
          profileRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      // Trigger read
      container.read(profileGoalsProvider);
      // Wait for hydration microtask/future
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = container.read(profileGoalsProvider);
      expect(state.steps, 8500);
      expect(state.waterLiters, 3.0);
      expect(state.proteinGrams, 150);
    });

    test(
      'immediately saves updated goals to repository on adjustments',
      () async {
        final mockRepo = _MockProfileRepository();
        final user = _createTestUser();

        final container = ProviderContainer(
          overrides: [
            currentUserProvider.overrideWithValue(user),
            profileRepositoryProvider.overrideWithValue(mockRepo),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(profileGoalsProvider.notifier);

        // Adjust water: 4.0 - 1.0 = 3.0
        notifier.adjustWater(-1.0);
        expect(container.read(profileGoalsProvider).waterLiters, 3.0);
        expect(mockRepo.savedGoals?['water'], 3.0);
        expect(mockRepo.savedGoals?['userId'], user.id);

        // Adjust steps: 10000 + 1500 = 11500
        notifier.adjustSteps(1500);
        expect(container.read(profileGoalsProvider).steps, 11500);
        expect(mockRepo.savedGoals?['steps'], 11500);

        // Adjust protein: 160 + 20 = 180
        notifier.adjustProtein(20);
        expect(container.read(profileGoalsProvider).proteinGrams, 180);
        expect(mockRepo.savedGoals?['protein'], 180);
      },
    );
  });

  group('Home Screen Habits reactivity & completion', () {
    testWidgets(
      'Home screen habits reflect updated goals immediately without manual refresh',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final mockRepo = _MockProfileRepository();
        final mockQuestsRepo = _MockCompletedQuestsRepository();
        final user = _createTestUser();

        final container = ProviderContainer(
          overrides: [
            currentUserProvider.overrideWithValue(user),
            profileRepositoryProvider.overrideWithValue(mockRepo),
            completedQuestsRepositoryProvider.overrideWithValue(mockQuestsRepo),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(home: HomeScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Verify default habit titles
        expect(find.text('Walk 10,000 steps'), findsOneWidget);
        expect(find.text('Drink 4L water'), findsOneWidget);
        expect(find.text('Hit 160g protein'), findsOneWidget);

        // Change goals via provider (simulating changing goals in Profile tab)
        container
            .read(profileGoalsProvider.notifier)
            .setGoals(steps: 12000, water: 3.0, protein: 190);

        // Pump to trigger reactive rebuild
        await tester.pumpAndSettle();

        // Home Screen immediately reflects the new text!
        expect(find.text('Walk 12,000 steps'), findsOneWidget);
        expect(find.text('Drink 3L water'), findsOneWidget);
        expect(find.text('Hit 190g protein'), findsOneWidget);

        // Tap to complete the water habit
        await tester.tap(find.text('Drink 3L water'));
        await tester.pumpAndSettle();

        // Verify XP awarded
        expect(container.read(userProgressionProvider).currentXp, 25);
        expect(container.read(habitsProvider).isCompleted('water'), isTrue);

        // Verify habit completion saved to completed_quests table
        expect(
          mockQuestsRepo.database.any(
            (q) => q.questId == 'water' && q.questType == 'habit',
          ),
          isTrue,
        );
      },
    );
  });
}
