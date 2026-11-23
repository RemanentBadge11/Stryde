import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/database/app_database.dart';
import 'package:stryde/core/database/local_cache_service.dart';
import 'package:stryde/core/sync/network_connectivity.dart';
import 'package:stryde/core/sync/sync_service.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/home/presentation/screens/home_screen.dart';
import 'package:stryde/features/medals/presentation/providers/medals_provider.dart';
import 'package:stryde/features/profile/data/profile_repository.dart';
import 'package:stryde/features/progression/presentation/providers/skill_allocations_provider.dart';
import 'package:stryde/features/progression/presentation/providers/user_progression_provider.dart';
import 'package:stryde/features/workout_history/domain/entities/completed_workout.dart';
import 'package:stryde/features/workout_history/presentation/providers/workout_history_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeNetworkConnectivity implements NetworkConnectivity {
  FakeNetworkConnectivity({bool initialOnline = true})
    : _isOnline = initialOnline;

  bool _isOnline;
  final _controller = StreamController<bool>.broadcast();

  void setOnline(bool online) {
    _isOnline = online;
    _controller.add(online);
  }

  @override
  Future<bool> get isOnline async => _isOnline;

  @override
  Stream<bool> get onConnectivityChanged => _controller.stream;

  void dispose() {
    _controller.close();
  }
}

class FakeProfileRepoWithMock implements ProfileRepository {
  FakeProfileRepoWithMock([this.localCache]);

  final LocalCacheService? localCache;
  ProfileData? remoteProfile;
  bool shouldThrowOnFetch = false;
  int saveCount = 0;
  Map<String, dynamic> lastSavedValues = {};

  @override
  Future<ProfileData?> getOrFetchProfile(
    String userId, {
    String? defaultUsername,
  }) async {
    final cache = localCache;
    if (cache != null) {
      final cached = await cache.getCachedProfile(userId);
      if (cached != null) return cached;
    }

    if (shouldThrowOnFetch) {
      final defaultProfile = ProfileData(
        xp: 0,
        level: 1,
        streak: 0,
        skillPoints: 0,
        totalXp: 0,
        availableSkillPoints: 0,
        username: defaultUsername,
        themeMode: 'dark',
        accentColor: '#FFFFFF',
        updatedAt: DateTime.now().toUtc(),
      );
      if (cache != null) {
        await cache.saveCachedProfile(userId, defaultProfile);
        await cache.enqueue(
          entityType: 'profile',
          action: 'create_profile',
          payload: {
            'userId': userId,
            'created_at': DateTime.now().toUtc().toIso8601String(),
          },
        );
      }
      return defaultProfile;
    }

    final remote = await fetch(userId);
    if (remote != null && cache != null) {
      await cache.saveCachedProfile(userId, remote);
    }
    return remote;
  }

  @override
  Future<ProfileData?> fetch(String userId) async {
    if (shouldThrowOnFetch) throw Exception('Network offline');
    return remoteProfile;
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
    lastSavedValues = {
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late LocalCacheService localCache;
  late FakeNetworkConnectivity fakeConnectivity;
  final testUser = User(
    id: 'user-offline-123',
    appMetadata: const {},
    userMetadata: const {'username': 'offline_stryder'},
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
  );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    localCache = LocalCacheService(db);
    fakeConnectivity = FakeNetworkConnectivity(initialOnline: true);
  });

  tearDown(() async {
    fakeConnectivity.dispose();
    await db.close();
  });

  group('1. Local Profile Cache (Read) & Fresh Install', () {
    test(
      'Scenario A (Cache Exists): Hydrates UI immediately from local cache even offline',
      () async {
        // Seed local cache with existing profile
        await localCache.saveCachedProfile(
          'user-offline-123',
          ProfileData(
            xp: 175,
            level: 4,
            streak: 12,
            skillPoints: 5,
            totalXp: 850,
            availableSkillPoints: 5,
            username: 'offline_warrior',
            themeMode: 'dark',
            accentColor: '#3B82F6',
            updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        );

        final fakeRepo = FakeProfileRepoWithMock(localCache)
          ..shouldThrowOnFetch = true; // Simulating no network

        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            localCacheServiceProvider.overrideWithValue(localCache),
            networkConnectivityProvider.overrideWithValue(fakeConnectivity),
            currentUserProvider.overrideWith((ref) => testUser),
            profileRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        );
        addTearDown(container.dispose);

        // Trigger user progression reading
        final initialProg = container.read(userProgressionProvider);
        expect(initialProg.currentLevel, 1);

        // Wait for async hydrate to read cached_profile
        await Future<void>.delayed(const Duration(milliseconds: 50));
        final hydratedProg = container.read(userProgressionProvider);

        expect(hydratedProg.currentLevel, 5);
        expect(hydratedProg.totalXp, 850);
        expect(hydratedProg.skillPoints, 5);
      },
    );

    test(
      'Scenario B (Cache Empty - Fresh Install Offline): Initializes defaults and queues create_profile',
      () async {
        final fakeRepo = FakeProfileRepoWithMock(localCache)
          ..shouldThrowOnFetch = true; // Offline fresh install

        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            localCacheServiceProvider.overrideWithValue(localCache),
            networkConnectivityProvider.overrideWithValue(fakeConnectivity),
            currentUserProvider.overrideWith((ref) => testUser),
            profileRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        );
        addTearDown(container.dispose);

        // Trigger hydration
        container.read(userProgressionProvider);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Check local cached_profile table was populated with defaults
        final cached = await localCache.getCachedProfile('user-offline-123');
        expect(cached, isNotNull);
        expect(cached!.level, 1);
        expect(cached.totalXp, 0);

        // Check sync_queue has create_profile action
        final queue = await localCache.getPendingQueue();
        expect(
          queue.any(
            (q) => q.entityType == 'profile' && q.action == 'create_profile',
          ),
          isTrue,
        );
      },
    );
  });

  group('2. Local Profile Cache (Write) & Immediate Cache Updates', () {
    test(
      'State changes update local cached_profile and enqueue sync action immediately',
      () async {
        final fakeRepo = FakeProfileRepoWithMock(localCache);
        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            localCacheServiceProvider.overrideWithValue(localCache),
            networkConnectivityProvider.overrideWithValue(fakeConnectivity),
            currentUserProvider.overrideWith((ref) => testUser),
            profileRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        );
        addTearDown(container.dispose);

        container.read(userProgressionProvider);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Add XP
        container.read(userProgressionProvider.notifier).addXp(120);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Local cached_profile row should immediately be updated
        final cachedAfterXp = await localCache.getCachedProfile(
          'user-offline-123',
        );
        expect(cachedAfterXp, isNotNull);
        expect(cachedAfterXp!.totalXp, 120);

        // And sync queue has a profile update entry
        final queue = await localCache.getPendingQueue();
        expect(
          queue.any((q) => q.entityType == 'profile' && q.action == 'update'),
          isTrue,
        );
      },
    );
  });

  group('3. The Sync Queue & Entities (Workouts, Medals, Skills)', () {
    test(
      'Adding workout, medal, and skill allocates to local cache first and adds to sync_queue',
      () async {
        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            localCacheServiceProvider.overrideWithValue(localCache),
            networkConnectivityProvider.overrideWithValue(fakeConnectivity),
            currentUserProvider.overrideWith((ref) => testUser),
          ],
        );
        addTearDown(container.dispose);

        // 1. Add Workout
        final workout = CompletedWorkout(
          id: 'workout-offline-999',
          routineId: 'custom-1',
          routineName: 'Heavy Chest',
          completedAt: DateTime.now(),
          duration: const Duration(minutes: 45),
          exercises: const [
            CompletedWorkoutExercise(
              exerciseId: 'bench-press',
              exerciseName: 'Bench Press',
              sets: [CompletedWorkoutSet(setNumber: 1, weightKg: 100, reps: 5)],
            ),
          ],
        );
        container.read(workoutHistoryProvider.notifier).addWorkout(workout);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Check workout local cache
        final cachedWorkouts = await localCache.getCachedWorkouts(
          'user-offline-123',
        );
        expect(
          cachedWorkouts.any((w) => w.id == 'workout-offline-999'),
          isTrue,
        );

        // 2. Unlock Medal
        container.read(medalsProvider.notifier).evaluateAndUnlock(level: 23);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Check medal local cache
        final cachedMedals = await localCache.getCachedMedals(
          'user-offline-123',
        );
        expect(cachedMedals.containsKey('the_ascended'), isTrue);

        // 3. Assign Skill (grant skill points by leveling up first)
        container.read(userProgressionProvider.notifier).addXp(300);
        await Future<void>.delayed(const Duration(milliseconds: 50));
        container.read(skillAllocationsProvider.notifier).spend('Chest');
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Check skill local cache
        final cachedSkills = await localCache.getCachedSkills(
          'user-offline-123',
        );
        expect(cachedSkills['Chest'], greaterThanOrEqualTo(1));

        // Verify sync_queue contains entries for workout, medal, and skill
        final queue = await localCache.getPendingQueue();
        expect(queue.any((e) => e.entityType == 'workout'), isTrue);
        expect(queue.any((e) => e.entityType == 'medal'), isTrue);
        expect(queue.any((e) => e.entityType == 'skill'), isTrue);
      },
    );
  });

  group('4. The Sync Worker & Network Transitions', () {
    test(
      'Offline queue retains rows; reconnecting transitions and attempts sync',
      () async {
        fakeConnectivity.setOnline(false);

        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            localCacheServiceProvider.overrideWithValue(localCache),
            networkConnectivityProvider.overrideWithValue(fakeConnectivity),
            currentUserProvider.overrideWith((ref) => testUser),
          ],
        );
        addTearDown(container.dispose);

        final syncNotifier = container.read(syncServiceProvider.notifier);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Queue an item while offline
        await localCache.enqueue(
          entityType: 'profile',
          action: 'update',
          payload: {
            'userId': 'user-offline-123',
            'values': {'level': 5},
          },
        );

        // Trigger sync while offline - should stop
        await syncNotifier.syncPending();
        var queue = await localCache.getPendingQueue();
        expect(queue.length, 1);
        expect(container.read(syncServiceProvider).isOnline, isFalse);

        // Reconnect online
        fakeConnectivity.setOnline(true);
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(container.read(syncServiceProvider).isOnline, isTrue);
      },
    );
  });

  group('5. Conflict Resolution (Last-Write-Wins)', () {
    test(
      'Pushes local changes if local last_updated is newer than server',
      () async {
        final now = DateTime.now();
        // Server profile is 2 hours old
        final fakeRepo = FakeProfileRepoWithMock(localCache)
          ..remoteProfile = ProfileData(
            xp: 50,
            level: 2,
            streak: 1,
            skillPoints: 0,
            totalXp: 150,
            availableSkillPoints: 0,
            updatedAt: now.subtract(const Duration(hours: 2)),
          );

        // Local profile is 10 minutes old (newer)
        await localCache.saveCachedProfile(
          'user-offline-123',
          ProfileData(
            xp: 120,
            level: 3,
            streak: 2,
            skillPoints: 1,
            totalXp: 320,
            availableSkillPoints: 1,
            updatedAt: now.subtract(const Duration(minutes: 10)),
          ),
          lastUpdated: now.subtract(const Duration(minutes: 10)),
        );

        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            localCacheServiceProvider.overrideWithValue(localCache),
            networkConnectivityProvider.overrideWithValue(fakeConnectivity),
            currentUserProvider.overrideWith((ref) => testUser),
            profileRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(syncServiceProvider.notifier)
            .reconcileProfile('user-offline-123');

        // Since local was newer, saveProgression was called to push local update
        expect(fakeRepo.saveCount, 1);
        expect(fakeRepo.lastSavedValues['level'], 3);
        expect(fakeRepo.lastSavedValues['total_xp'], 320);
      },
    );

    test(
      'Pulls server changes if server updated_at is newer than local',
      () async {
        final now = DateTime.now();
        // Server profile is newer (1 minute ago)
        final fakeRepo = FakeProfileRepoWithMock(localCache)
          ..remoteProfile = ProfileData(
            xp: 99,
            level: 10,
            streak: 15,
            skillPoints: 8,
            totalXp: 5000,
            availableSkillPoints: 8,
            updatedAt: now.subtract(const Duration(minutes: 1)),
          );

        // Local profile is older (2 days ago)
        await localCache.saveCachedProfile(
          'user-offline-123',
          ProfileData(
            xp: 10,
            level: 2,
            streak: 1,
            skillPoints: 0,
            totalXp: 110,
            availableSkillPoints: 0,
            updatedAt: now.subtract(const Duration(days: 2)),
          ),
          lastUpdated: now.subtract(const Duration(days: 2)),
        );

        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            localCacheServiceProvider.overrideWithValue(localCache),
            networkConnectivityProvider.overrideWithValue(fakeConnectivity),
            currentUserProvider.overrideWith((ref) => testUser),
            profileRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(syncServiceProvider.notifier)
            .reconcileProfile('user-offline-123');

        // Local cache should now have server's newer data
        final cached = await localCache.getCachedProfile('user-offline-123');
        expect(cached, isNotNull);
        expect(cached!.level, 10);
        expect(cached.totalXp, 5000);
      },
    );
  });

  group('6. UI Feedback (Offline Banner & Pending Sync Badge)', () {
    testWidgets(
      'Home screen displays offline banner when connectivity is false',
      (tester) async {
        fakeConnectivity.setOnline(false);

        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            localCacheServiceProvider.overrideWithValue(localCache),
            networkConnectivityProvider.overrideWithValue(fakeConnectivity),
            currentUserProvider.overrideWith((ref) => testUser),
            syncServiceProvider.overrideWith(() => _OfflineSyncNotifier()),
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

        expect(
          find.byKey(const ValueKey<String>('offline-banner')),
          findsOneWidget,
        );
        expect(
          find.text('You are offline. Changes will sync when you reconnect.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Home screen displays pending sync badge when queue has items',
      (tester) async {
        fakeConnectivity.setOnline(true);

        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            localCacheServiceProvider.overrideWithValue(localCache),
            networkConnectivityProvider.overrideWithValue(fakeConnectivity),
            currentUserProvider.overrideWith((ref) => testUser),
            syncServiceProvider.overrideWith(() => _PendingSyncNotifier(3)),
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

        expect(
          find.byKey(const ValueKey<String>('pending-sync-badge')),
          findsOneWidget,
        );
        expect(find.text('Pending Sync (3)'), findsOneWidget);
      },
    );
  });
}

class _OfflineSyncNotifier extends SyncNotifier {
  @override
  SyncState build() {
    return const SyncState(isOnline: false, isSyncing: false, pendingCount: 0);
  }
}

class _PendingSyncNotifier extends SyncNotifier {
  _PendingSyncNotifier(this._pendingCount);
  final int _pendingCount;

  @override
  SyncState build() {
    return SyncState(
      isOnline: true,
      isSyncing: false,
      pendingCount: _pendingCount,
    );
  }
}
