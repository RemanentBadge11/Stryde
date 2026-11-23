import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stryde/core/database/local_cache_service.dart';
import 'package:stryde/core/services/location_timezone_service.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/home/data/completed_quests_repository.dart';
import 'package:stryde/features/home/domain/entities/habit.dart';
import 'package:stryde/features/home/presentation/providers/login_streak_provider.dart';
import 'package:stryde/features/progression/domain/entities/xp_transaction.dart';
import 'package:stryde/features/progression/presentation/providers/user_progression_provider.dart';
import 'package:stryde/features/progression/presentation/providers/xp_transactions_provider.dart';

final habitsProvider = NotifierProvider<HabitsNotifier, HabitState>(
  HabitsNotifier.new,
);

class HabitsNotifier extends Notifier<HabitState> {
  String? _activeUserId;
  final Map<String, DateTime> _completedAt = <String, DateTime>{};

  CompletedQuestsRepository? get _repository =>
      ref.read(completedQuestsRepositoryProvider);
  LocationTimezoneService get _tzService =>
      ref.read(locationTimezoneServiceProvider);

  @override
  HabitState build() {
    _completedAt.clear();
    final user = ref.read(currentUserProvider);
    _activeUserId = user?.id;

    final initialEndsAt = _tzService.nextDailyMidnight().toLocal();

    if (user != null && _repository != null) {
      unawaited(_hydrate(user.id));
    }

    ref.listen(currentUserProvider, (_, user) {
      final userId = user?.id;
      if (userId == _activeUserId) return;
      _activeUserId = userId;
      _completedAt.clear();
      state = HabitState(
        completedIds: const <String>{},
        endsAt: _tzService.nextDailyMidnight().toLocal(),
      );
      if (userId != null && _repository != null) {
        unawaited(_hydrate(userId));
      }
    });

    return HabitState(
      completedIds: const <String>{},
      endsAt: initialEndsAt,
    );
  }

  Future<void> _hydrate(String userId) async {
    final repo = _repository;
    if (repo == null) return;
    final records = await repo.fetch(userId);
    if (_activeUserId != userId) return;

    for (final record in records) {
      if (record.questType == 'habit') {
        final existing = _completedAt[record.questId];
        if (existing == null || record.completedAt.isAfter(existing)) {
          _completedAt[record.questId] = record.completedAt;
        }
      }
    }

    _applyActiveCompletions();
  }

  void _applyActiveCompletions([DateTime? at]) {
    final now = at ?? DateTime.now();
    final nextMidnight = _tzService.nextDailyMidnight(now: now).toLocal();
    final startOfToday = nextMidnight.subtract(const Duration(days: 1));

    final activeIds = <String>{};
    for (final entry in _completedAt.entries) {
      final completed = entry.value.toLocal();
      final elapsed = now.difference(entry.value);
      if (!elapsed.isNegative &&
          elapsed < const Duration(hours: 12) &&
          completed.isAfter(startOfToday) &&
          !completed.isAfter(nextMidnight)) {
        activeIds.add(entry.key);
      }
    }

    state = HabitState(completedIds: activeIds, endsAt: nextMidnight);
  }

  bool complete(String id, {required int xp, required String title}) {
    refreshIfNeeded();
    if (state.completedIds.contains(id)) return false;

    final now = DateTime.now();
    _completedAt[id] = now;
    state = HabitState(
      completedIds: <String>{...state.completedIds, id},
      endsAt: state.endsAt,
    );

    final userId = _activeUserId;
    final repo = _repository;
    if (userId != null) {
      if (repo != null) {
        unawaited(
          repo.insert(
            userId: userId,
            questId: id,
            questType: 'habit',
            completedAt: now,
          ),
        );
      }
      final localCache = ref.read(localCacheServiceProvider);
      unawaited(
        localCache.enqueue(
          entityType: 'quest_completion',
          action: 'insert',
          payload: <String, dynamic>{
            'userId': userId,
            'questId': id,
            'questType': 'habit',
            'completedAt': now.toUtc().toIso8601String(),
          },
        ),
      );
    }

    ref.read(userProgressionProvider.notifier).addXp(xp);
    ref
        .read(xpTransactionsProvider.notifier)
        .log(description: 'Habit · $title', amount: xp, source: XpSource.habit);
    ref.read(loginStreakProvider.notifier).recordActivity();
    return true;
  }

  void refreshIfNeeded() {
    final now = DateTime.now();
    if (!now.isBefore(state.endsAt)) {
      state = HabitState(
        completedIds: const <String>{},
        endsAt: _tzService.nextDailyMidnight(now: now).toLocal(),
      );
    }
    _applyActiveCompletions(now);
  }
}
