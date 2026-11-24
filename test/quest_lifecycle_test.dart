import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stryde/core/database/app_database.dart';
import 'package:stryde/core/database/local_cache_service.dart';
import 'package:stryde/core/services/location_timezone_service.dart';
import 'package:stryde/core/sync/network_connectivity.dart';
import 'package:stryde/core/sync/sync_service.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/home/data/user_quests_repository.dart';
import 'package:stryde/features/home/domain/entities/user_quest.dart';
import 'package:stryde/features/home/presentation/providers/daily_goals_provider.dart';
import 'package:stryde/features/home/presentation/providers/weekly_quests_provider.dart';
import 'package:stryde/features/workout_history/domain/entities/completed_workout.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeConnectivity implements NetworkConnectivity {
  _FakeConnectivity({this.online = true});

  bool online;

  @override
  Future<bool> get isOnline async => online;

  @override
  Stream<bool> get onConnectivityChanged => Stream.value(online);
}

class _TestUserQuestsRepository extends UserQuestsRepository {
  _TestUserQuestsRepository({
    required super.localCache,
    required super.timezoneService,
    required super.connectivity,
  });

  bool deleteExpiredQuestsCalled = false;
  String? deletedUserId;
  int generateQuestsCalled = 0;

  @override
  Future<void> deleteExpiredQuests(
    String userId, {
    String? questType,
    DateTime? now,
  }) async {
    deleteExpiredQuestsCalled = true;
    deletedUserId = userId;
  }

  @override
  Future<List<UserQuest>> getOrGenerateQuests({
    required String userId,
    required String questType,
    required String timezone,
    required List<CompletedWorkout> history,
    DateTime? now,
  }) async {
    generateQuestsCalled++;
    return [
      UserQuest(
        id: 'new-$questType-1',
        userId: userId,
        questType: questType,
        title: 'New Quest',
        description: 'New Desc',
        xpReward: 25,
        expiresAt: DateTime.now().add(const Duration(days: 1)),
        createdAt: DateTime.now(),
      ),
    ];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late LocalCacheService localCache;
  late LocationTimezoneService tzService;
  late _FakeConnectivity connectivity;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    localCache = LocalCacheService(db);
    tzService = LocationTimezoneService();
    connectivity = _FakeConnectivity(online: true);
  });

  tearDown(() async {
    localCache.dispose();
    await db.close();
  });

  group('Quest Lifecycle - Offline Behavior & Sync Queue', () {
    test('offline with active cached quests returns cached quests', () async {
      connectivity.online = false;
      final now = DateTime.utc(2026, 11, 24, 12, 0);

      // Pre-populate active quests in local cache
      final activeQuests = [
        UserQuest(
          id: 'quest-active-1',
          userId: 'user-1',
          questType: 'daily',
          title: 'Push-up 50',
          description: 'Chest',
          xpReward: 25,
          expiresAt: DateTime.utc(2026, 11, 24, 18, 30), // future
          createdAt: now,
        ),
        UserQuest(
          id: 'quest-active-2',
          userId: 'user-1',
          questType: 'daily',
          title: 'Squat 50',
          description: 'Legs',
          xpReward: 25,
          expiresAt: DateTime.utc(2026, 11, 24, 18, 30),
          createdAt: now,
        ),
        UserQuest(
          id: 'quest-active-3',
          userId: 'user-1',
          questType: 'daily',
          title: 'Pull-up 10',
          description: 'Back',
          xpReward: 25,
          expiresAt: DateTime.utc(2026, 11, 24, 18, 30),
          createdAt: now,
        ),
      ];

      await localCache.saveCachedQuests(
        'user-1',
        activeQuests.map((q) => q.toDrift()).toList(),
      );

      final repo = UserQuestsRepository(
        localCache: localCache,
        timezoneService: tzService,
        connectivity: connectivity,
      );

      final result = await repo.getOrGenerateQuests(
        userId: 'user-1',
        questType: 'daily',
        timezone: 'UTC',
        history: const [],
        now: now,
      );

      expect(result.length, 3);
      expect(result.first.id, 'quest-active-1');

      // Sync queue should NOT have cleanup_quests
      final pending = await localCache.getPendingQueue();
      expect(pending.any((e) => e.action == 'cleanup_quests'), isFalse);
    });

    test(
      'offline with expired cached quests does NOT delete locally and queues cleanup_quests',
      () async {
        connectivity.online = false;
        final expiredAt = DateTime.utc(2026, 11, 23, 18, 30);
        final now = DateTime.utc(2026, 11, 24, 12, 0); // now is after expiredAt

        // Pre-populate expired quests in local cache
        final expiredQuests = [
          UserQuest(
            id: 'quest-expired-1',
            userId: 'user-offline',
            questType: 'daily',
            title: 'Old Goal',
            description: 'Chest',
            xpReward: 25,
            expiresAt: expiredAt,
            createdAt: expiredAt.subtract(const Duration(hours: 24)),
          ),
        ];

        await localCache.saveCachedQuests(
          'user-offline',
          expiredQuests.map((q) => q.toDrift()).toList(),
        );

        final repo = UserQuestsRepository(
          localCache: localCache,
          timezoneService: tzService,
          connectivity: connectivity,
        );

        final result = await repo.getOrGenerateQuests(
          userId: 'user-offline',
          questType: 'daily',
          timezone: 'UTC',
          history: const [],
          now: now,
        );

        // Result should be empty to trigger empty offline state
        expect(result, isEmpty);

        // Local cache must NOT delete expired quests locally while offline
        final rawCached = await localCache.getCachedQuests(
          'user-offline',
          questType: 'daily',
          activeOnly: false,
        );
        expect(rawCached.length, 1);
        expect(rawCached.first.id, 'quest-expired-1');

        // cleanup_quests must be enqueued in sync_queue
        final pending = await localCache.getPendingQueue();
        expect(
          pending.any(
            (e) =>
                e.entityType == 'quests' &&
                e.action == 'cleanup_quests' &&
                jsonDecode(e.payload)['userId'] == 'user-offline',
          ),
          isTrue,
        );

        // Calling again does not insert duplicate queue entry
        await repo.getOrGenerateQuests(
          userId: 'user-offline',
          questType: 'daily',
          timezone: 'UTC',
          history: const [],
          now: now,
        );

        final pendingAfter = await localCache.getPendingQueue();
        final cleanupEntries = pendingAfter
            .where(
              (e) => e.entityType == 'quests' && e.action == 'cleanup_quests',
            )
            .toList();
        expect(cleanupEntries.length, 1);
      },
    );
  });

  group(
    'DailyGoalsNotifier & WeeklyQuestsNotifier - Live Updates & Empty State',
    () {
      test(
        'DailyGoalsNotifier displays isEmptyOffline when quests are empty',
        () async {
          connectivity.online = false;

          final container = ProviderContainer(
            overrides: [
              localCacheServiceProvider.overrideWithValue(localCache),
              networkConnectivityProvider.overrideWithValue(connectivity),
              locationTimezoneServiceProvider.overrideWithValue(tzService),
            ],
          );
          addTearDown(container.dispose);

          // Allow microtask hydration to run
          container.read(dailyGoalsProvider);
          await pumpEventQueue();

          final state = container.read(dailyGoalsProvider);
          expect(state.isEmptyOffline, isTrue);
          expect(state.goals, isEmpty);
        },
      );

      test(
        'WeeklyQuestsNotifier displays isEmptyOffline when quests are empty',
        () async {
          connectivity.online = false;

          final container = ProviderContainer(
            overrides: [
              localCacheServiceProvider.overrideWithValue(localCache),
              networkConnectivityProvider.overrideWithValue(connectivity),
              locationTimezoneServiceProvider.overrideWithValue(tzService),
            ],
          );
          addTearDown(container.dispose);

          container.read(weeklyQuestsProvider);
          await pumpEventQueue();

          final state = container.read(weeklyQuestsProvider);
          expect(state.isEmptyOffline, isTrue);
          expect(state.quests, isEmpty);
        },
      );

      test(
        'refreshIfNeeded(force: true) triggers hydration immediately',
        () async {
          connectivity.online = false;

          final container = ProviderContainer(
            overrides: [
              localCacheServiceProvider.overrideWithValue(localCache),
              networkConnectivityProvider.overrideWithValue(connectivity),
              locationTimezoneServiceProvider.overrideWithValue(tzService),
            ],
          );
          addTearDown(container.dispose);

          final notifier = container.read(dailyGoalsProvider.notifier);
          await pumpEventQueue();

          expect(container.read(dailyGoalsProvider).isEmptyOffline, isTrue);

          // Now switch online and force refresh
          connectivity.online = true;
          notifier.refreshIfNeeded(force: true);
          await pumpEventQueue();

          final updatedState = container.read(dailyGoalsProvider);
          expect(updatedState.isEmptyOffline, isFalse);
          expect(updatedState.goals.length, 3);
        },
      );
    },
  );

  group('Online Guest / Mock Quest Generation', () {
    test(
      'clears expired local cache and inserts newly generated quests',
      () async {
        connectivity.online = true;
        final expiredAt = DateTime.utc(2026, 11, 23, 18, 30);
        final now = DateTime.utc(2026, 11, 24, 12, 0);

        // Pre-populate expired quests
        await localCache.saveCachedQuests('user-online', [
          UserQuest(
            id: 'old-q1',
            userId: 'user-online',
            questType: 'daily',
            title: 'Old Title',
            description: 'Old Desc',
            xpReward: 25,
            expiresAt: expiredAt,
            createdAt: expiredAt.subtract(const Duration(hours: 24)),
          ).toDrift(),
        ]);

        final repo = UserQuestsRepository(
          localCache: localCache,
          timezoneService: tzService,
          connectivity: connectivity,
        );

        final generated = await repo.getOrGenerateQuests(
          userId: 'user-online',
          questType: 'daily',
          timezone: 'UTC',
          history: const [],
          now: now,
        );

        expect(generated.length, 3);

        // Verify that expired quests were cleared from local Drift table
        final cached = await localCache.getCachedQuests(
          'user-online',
          questType: 'daily',
          activeOnly: false,
        );
        expect(cached.length, 3);
        expect(cached.any((q) => q.id == 'old-q1'), isFalse);
      },
    );
  });

  group('SyncService - cleanup_quests action processing', () {
    test(
      'processes cleanup_quests by calling deleteExpiredQuests and re-generating quests',
      () async {
        final mockRepo = _TestUserQuestsRepository(
          localCache: localCache,
          timezoneService: tzService,
          connectivity: connectivity,
        );

        // Pre-enqueue cleanup_quests
        await localCache.enqueue(
          entityType: 'quests',
          action: 'cleanup_quests',
          payload: <String, dynamic>{'userId': 'sync-user-99'},
        );

        final pendingBefore = await localCache.getPendingQueue();
        expect(pendingBefore.length, 1);

        final fakeSupabase = SupabaseClient(
          'https://mock.supabase.co',
          'fake-key',
        );

        final container = ProviderContainer(
          overrides: [
            localCacheServiceProvider.overrideWithValue(localCache),
            networkConnectivityProvider.overrideWithValue(connectivity),
            locationTimezoneServiceProvider.overrideWithValue(tzService),
            userQuestsRepositoryProvider.overrideWithValue(mockRepo),
            supabaseProvider.overrideWithValue(fakeSupabase),
          ],
        );
        addTearDown(container.dispose);

        // Trigger sync
        await container.read(syncServiceProvider.notifier).syncPending();

        expect(mockRepo.deleteExpiredQuestsCalled, isTrue);
        expect(mockRepo.deletedUserId, 'sync-user-99');
        expect(
          mockRepo.generateQuestsCalled,
          greaterThanOrEqualTo(2),
        ); // daily and weekly

        // Queue entry should be removed after successful sync
        final pendingAfter = await localCache.getPendingQueue();
        expect(pendingAfter, isEmpty);
      },
    );
  });
}
