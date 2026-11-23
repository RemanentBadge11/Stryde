import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stryde/core/database/local_cache_service.dart';
import 'package:stryde/core/sync/sync_service.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/profile/data/profile_repository.dart';

final loginStreakProvider =
    NotifierProvider<LoginStreakNotifier, LoginStreakState>(
      LoginStreakNotifier.new,
    );

class LoginStreakState {
  const LoginStreakState({required this.streak, required this.lastActivityOn});

  const LoginStreakState.empty() : streak = 0, lastActivityOn = null;

  final int streak;
  final DateTime? lastActivityOn;

  int effectiveStreakAt(DateTime now) {
    final lastActivity = lastActivityOn;
    if (lastActivity == null) return streak;
    return _daysBetween(lastActivity, now) > 1 ? 0 : streak;
  }

  int get currentStreak => effectiveStreakAt(DateTime.now());

  LoginStreakState copyWith({int? streak, DateTime? lastActivityOn}) {
    return LoginStreakState(
      streak: streak ?? this.streak,
      lastActivityOn: lastActivityOn ?? this.lastActivityOn,
    );
  }
}

class LoginStreakNotifier extends Notifier<LoginStreakState> {
  Timer? _midnightTimer;
  String? _activeUserId;
  bool _hydrated = false;
  final List<DateTime> _pendingActivities = <DateTime>[];
  Future<void> _persistenceQueue = Future<void>.value();

  @override
  LoginStreakState build() {
    _activeUserId = ref.read(currentUserProvider)?.id;
    _hydrated = _activeUserId == null;
    ref.listen(currentUserProvider, (_, user) {
      if (user?.id == _activeUserId) return;
      _activeUserId = user?.id;
      _hydrated = _activeUserId == null;
      _pendingActivities.clear();
      state = const LoginStreakState.empty();
    });
    ref.onDispose(() => _midnightTimer?.cancel());
    _scheduleMidnightRefresh();
    return const LoginStreakState.empty();
  }

  void hydrate({required int streak, DateTime? lastActivityOn}) {
    final pending = List<DateTime>.of(_pendingActivities)..sort();
    _pendingActivities.clear();
    final normalizedStreak = streak < 0 ? 0 : streak;
    final fallbackActivity = normalizedStreak == 0
        ? null
        : DateTime.now().subtract(const Duration(days: 1));
    final activity = lastActivityOn ?? fallbackActivity;
    state = LoginStreakState(
      streak: normalizedStreak,
      lastActivityOn: activity == null ? null : _dateOnly(activity),
    );
    _hydrated = true;
    refreshIfNeeded();
    var changed = false;
    for (final pendingActivity in pending) {
      changed = _recordActivity(pendingActivity) || changed;
    }
    if (changed) _queuePersist();
  }

  void useLocalFallback() {
    if (_hydrated) return;
    final hadPendingActivity = _pendingActivities.isNotEmpty;
    _pendingActivities.clear();
    _hydrated = true;
    if (hadPendingActivity) _queuePersist();
  }

  /// Records at most one qualifying activity per calendar day.
  bool recordActivity([DateTime? occurredAt]) {
    final activityDay = _dateOnly(occurredAt ?? DateTime.now());
    final changed = _recordActivity(activityDay);
    if (!changed) return false;

    if (_activeUserId != null && !_hydrated) {
      _pendingActivities.add(activityDay);
    } else {
      _queuePersist();
    }
    return true;
  }

  bool _recordActivity(DateTime activityDay) {
    final previousDay = state.lastActivityOn;

    if (previousDay == null) {
      state = LoginStreakState(streak: 1, lastActivityOn: activityDay);
      return true;
    }

    final dayGap = _daysBetween(previousDay, activityDay);
    if (dayGap <= 0) return false;

    state = LoginStreakState(
      streak: dayGap == 1 ? state.streak + 1 : 1,
      lastActivityOn: activityDay,
    );
    return true;
  }

  void refreshIfNeeded([DateTime? now]) {
    final lastActivity = state.lastActivityOn;
    if (lastActivity == null || state.streak == 0) return;
    if (_daysBetween(lastActivity, now ?? DateTime.now()) > 1) {
      state = state.copyWith(streak: 0);
      if (_hydrated) _queuePersist();
    }
  }

  void _queuePersist() {
    final userId = _activeUserId;
    if (userId == null) return;

    final streak = state.streak;
    final lastActivityOn = state.lastActivityOn;
    final localCache = ref.read(localCacheServiceProvider);

    _persistenceQueue = _persistenceQueue.then((_) async {
      try {
        final repo = ref.read(profileRepositoryProvider);
        if (repo != null) {
          try {
            await repo.saveStreak(
              userId: userId,
              streak: streak,
              lastActivityOn: lastActivityOn,
            );
          } catch (_) {}
        }

        final now = DateTime.now();
        await localCache.updateCachedProfile(
          userId,
          streak: streak,
          lastActivityOn: lastActivityOn,
          lastUpdated: now,
        );
        await localCache.enqueue(
          entityType: 'profile',
          action: 'update',
          payload: <String, dynamic>{
            'userId': userId,
            'values': <String, dynamic>{
              'streak': streak,
              if (lastActivityOn != null)
                'last_activity_on': lastActivityOn.toUtc().toIso8601String(),
              'updated_at': now.toUtc().toIso8601String(),
            },
          },
        );
        unawaited(ref.read(syncServiceProvider.notifier).syncPending());
      } catch (_) {
        // Keep the optimistic local streak while offline.
      }
    });
  }

  void _scheduleMidnightRefresh() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer = Timer(nextMidnight.difference(now), () {
      refreshIfNeeded();
      _scheduleMidnightRefresh();
    });
  }
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

int _daysBetween(DateTime from, DateTime to) {
  final fromDay = DateTime.utc(from.year, from.month, from.day);
  final toDay = DateTime.utc(to.year, to.month, to.day);
  return toDay.difference(fromDay).inDays;
}
