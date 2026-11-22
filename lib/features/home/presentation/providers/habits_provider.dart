import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  static const Duration cycle = Duration(hours: 12);

  String? _activeUserId;
  final Map<String, DateTime> _completedAt = <String, DateTime>{};

  CompletedQuestsRepository? get _repository =>
      ref.read(completedQuestsRepositoryProvider);

  @override
  HabitState build() {
    _completedAt.clear();
    final user = ref.read(currentUserProvider);
    _activeUserId = user?.id;
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
        endsAt: DateTime.now().add(cycle),
      );
      if (userId != null && _repository != null) {
        unawaited(_hydrate(userId));
      }
    });

    return HabitState(
      completedIds: const <String>{},
      endsAt: DateTime.now().add(cycle),
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
    final activeIds = <String>{};
    for (final entry in _completedAt.entries) {
      final elapsed = now.difference(entry.value);
      if (!elapsed.isNegative && elapsed < cycle) {
        activeIds.add(entry.key);
      }
    }
    if (activeIds.length != state.completedIds.length ||
        !activeIds.containsAll(state.completedIds)) {
      state = HabitState(
        completedIds: activeIds,
        endsAt: state.endsAt,
      );
    }
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
    if (userId != null && repo != null) {
      unawaited(
        repo.insert(
          userId: userId,
          questId: id,
          questType: 'habit',
          completedAt: now,
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
        completedIds: state.completedIds,
        endsAt: now.add(cycle),
      );
    }
    _applyActiveCompletions(now);
  }
}
