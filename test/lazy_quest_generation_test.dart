import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stryde/core/database/local_cache_service.dart';
import 'package:stryde/core/services/location_timezone_service.dart';
import 'package:stryde/core/sync/network_connectivity.dart';
import 'package:stryde/features/home/data/user_quests_repository.dart';
import 'package:stryde/features/routines/data/mock_workout_data.dart';
import 'package:stryde/features/workout_logging/presentation/providers/active_workout_provider.dart';

class _FakeOfflineConnectivity implements NetworkConnectivity {
  @override
  Future<bool> get isOnline async => false;

  @override
  Stream<bool> get onConnectivityChanged => Stream.value(false);
}

void main() {
  group('Location & Timezone Service', () {
    final tzService = LocationTimezoneService();

    test('determines timezone from coordinates', () {
      expect(
        tzService.getTimezoneFromCoordinates(28.6139, 77.2090),
        'Asia/Kolkata',
      );
      expect(
        tzService.getTimezoneFromCoordinates(40.7128, -74.0060),
        'America/New_York',
      );
      expect(
        tzService.getTimezoneFromCoordinates(51.5074, -0.1278),
        'Europe/London',
      );
      expect(
        tzService.getTimezoneFromCoordinates(35.6762, 139.6503),
        'Asia/Tokyo',
      );
      expect(
        tzService.getTimezoneFromCoordinates(-33.8688, 151.2093),
        'Australia/Sydney',
      );
    });

    test('calculates next daily midnight accurately for IST', () {
      final nowUtc = DateTime.utc(2026, 11, 23, 15, 30); // 21:00 IST
      final midnightUtc = tzService.nextDailyMidnight(
        timezone: 'Asia/Kolkata',
        now: nowUtc,
      );

      // In IST, next midnight is Nov 24 00:00:00 IST = Nov 23 18:30:00 UTC
      expect(midnightUtc, DateTime.utc(2026, 11, 23, 18, 30));
      expect(
        midnightUtc.difference(nowUtc),
        const Duration(hours: 3), // Exactly 3 hours until midnight IST
      );
    });

    test('calculates next weekly Sunday midnight accurately', () {
      // Monday Nov 23, 2026
      final monday = DateTime.utc(2026, 11, 23, 10, 0);
      final sundayMidnight = tzService.nextWeeklySundayMidnight(
        timezone: 'UTC',
        now: monday,
      );

      // Next Sunday midnight is Nov 29, 2026 00:00:00 UTC
      expect(sundayMidnight.weekday, DateTime.sunday);
      expect(sundayMidnight.hour, 0);
      expect(sundayMidnight.minute, 0);
      expect(sundayMidnight.isAfter(monday), isTrue);
    });
  });

  group('Lazy Quest Generation & Offline Handling', () {
    test('offline with empty cache yields empty state', () async {
      final offlineConn = _FakeOfflineConnectivity();
      final container = ProviderContainer(
        overrides: [networkConnectivityProvider.overrideWithValue(offlineConn)],
      );
      addTearDown(container.dispose);

      final repo = container.read(userQuestsRepositoryProvider);
      final quests = await repo.getOrGenerateQuests(
        userId: 'offline-user',
        questType: 'daily',
        timezone: 'UTC',
        history: const [],
      );

      expect(quests, isEmpty);
    });

    test('completing quest offline adds to sync_queue', () async {
      final offlineConn = _FakeOfflineConnectivity();
      final container = ProviderContainer(
        overrides: [networkConnectivityProvider.overrideWithValue(offlineConn)],
      );
      addTearDown(container.dispose);

      final repo = container.read(userQuestsRepositoryProvider);
      final localCache = container.read(localCacheServiceProvider);

      await repo.completeQuest(
        userId: 'sync-user',
        questId: 'quest-123',
        questType: 'daily',
      );

      final pending = await localCache.getPendingQueue();
      expect(
        pending.any(
          (e) =>
              e.entityType == 'quest_completion' &&
              e.payload.contains('quest-123'),
        ),
        isTrue,
      );
    });
  });

  group('Double Workout Bug Guard', () {
    test('concurrent or double finishWorkout calls are prevented by guard', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(activeWorkoutProvider.notifier);
      notifier.startWorkout(MockWorkoutData.pushDay);
      notifier.updateWeight(0, 0, '60');
      notifier.updateReps(0, 0, '10');
      notifier.toggleSetCompletion(0, 0);

      // First call succeeds
      final firstResult = notifier.finishWorkout();
      expect(firstResult, isNotNull);

      // Immediate second call returns null because session is already completed / guarded
      final secondResult = notifier.finishWorkout();
      expect(secondResult, isNull);
    });
  });
}
