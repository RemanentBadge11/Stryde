import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/home/data/completed_quests_repository.dart';
import 'package:stryde/features/home/domain/entities/completed_quest.dart';
import 'package:stryde/features/home/presentation/providers/daily_goals_provider.dart';
import 'package:stryde/features/home/presentation/providers/habits_provider.dart';
import 'package:stryde/features/home/presentation/providers/weekly_quests_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

void main() {
  test(
    'habits, quests, and daily goals persist and respect reset windows',
    () async {
      final mockRepo = _MockCompletedQuestsRepository();
      final mockUser = User(
        id: 'test-user-123',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );

      // Initial container - user completes a habit, quest, and goal
      final container1 = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(mockUser),
          completedQuestsRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container1.dispose);

      // Complete habit
      final habitsNotifier = container1.read(habitsProvider.notifier);
      expect(
        habitsNotifier.complete('water', xp: 25, title: 'Drink water'),
        isTrue,
      );
      expect(container1.read(habitsProvider).isCompleted('water'), isTrue);

      // Complete weekly quest
      final weeklyQuestsNotifier = container1.read(
        weeklyQuestsProvider.notifier,
      );
      final firstQuest = container1.read(weeklyQuestsProvider).quests.first;
      expect(weeklyQuestsNotifier.complete(firstQuest.id), isTrue);
      expect(
        container1.read(weeklyQuestsProvider).quests.first.isCompleted,
        isTrue,
      );

      // Complete daily goal
      final dailyGoalsNotifier = container1.read(dailyGoalsProvider.notifier);
      final firstGoal = container1.read(dailyGoalsProvider).goals.first;
      expect(dailyGoalsNotifier.complete(firstGoal.id), isTrue);
      expect(
        container1.read(dailyGoalsProvider).goals.first.isCompleted,
        isTrue,
      );

      // Verify all 3 were persisted in database
      expect(mockRepo.database.length, 3);
      expect(
        mockRepo.database.any(
          (q) => q.questId == 'water' && q.questType == 'habit',
        ),
        isTrue,
      );
      expect(
        mockRepo.database.any(
          (q) => q.questId == firstQuest.id && q.questType == 'quest',
        ),
        isTrue,
      );
      expect(
        mockRepo.database.any(
          (q) => q.questId == firstGoal.id && q.questType == 'goal',
        ),
        isTrue,
      );

      // Simulate app restart within reset window (e.g. 1 hour later)
      final container2 = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(mockUser),
          completedQuestsRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container2.dispose);

      // Read providers and allow hydration
      container2.read(habitsProvider);
      container2.read(weeklyQuestsProvider);
      container2.read(dailyGoalsProvider);
      await pumpEventQueue();

      // Within window: should be rendered as completed
      expect(container2.read(habitsProvider).isCompleted('water'), isTrue);
      expect(
        container2
            .read(weeklyQuestsProvider)
            .quests
            .firstWhere((q) => q.id == firstQuest.id)
            .isCompleted,
        isTrue,
      );
      expect(
        container2
            .read(dailyGoalsProvider)
            .goals
            .firstWhere((g) => g.id == firstGoal.id)
            .isCompleted,
        isTrue,
      );

      // Simulate expiration:
      // If habit completed 13 hours ago (> 12 hours window), it resets
      // If goal completed 25 hours ago (> 24 hours window), it resets
      // If quest completed 8 days ago (> 7 days window), it resets
      mockRepo.database.clear();
      mockRepo.database.add(
        CompletedQuest(
          id: 'expired-habit',
          userId: 'test-user-123',
          questId: 'water',
          questType: 'habit',
          completedAt: DateTime.now().subtract(const Duration(hours: 13)),
        ),
      );
      mockRepo.database.add(
        CompletedQuest(
          id: 'expired-goal',
          userId: 'test-user-123',
          questId: firstGoal.id,
          questType: 'goal',
          completedAt: DateTime.now().subtract(const Duration(hours: 25)),
        ),
      );
      mockRepo.database.add(
        CompletedQuest(
          id: 'expired-quest',
          userId: 'test-user-123',
          questId: firstQuest.id,
          questType: 'quest',
          completedAt: DateTime.now().subtract(const Duration(days: 8)),
        ),
      );

      final container3 = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(mockUser),
          completedQuestsRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container3.dispose);

      container3.read(habitsProvider);
      container3.read(weeklyQuestsProvider);
      container3.read(dailyGoalsProvider);
      await pumpEventQueue();

      // Expired: automatically becomes available again!
      expect(container3.read(habitsProvider).isCompleted('water'), isFalse);
      expect(
        container3
            .read(weeklyQuestsProvider)
            .quests
            .firstWhere((q) => q.id == firstQuest.id)
            .isCompleted,
        isFalse,
      );
      expect(
        container3
            .read(dailyGoalsProvider)
            .goals
            .firstWhere((g) => g.id == firstGoal.id)
            .isCompleted,
        isFalse,
      );
    },
  );
}
