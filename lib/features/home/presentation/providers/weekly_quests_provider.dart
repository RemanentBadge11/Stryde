import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/home/data/completed_quests_repository.dart';
import 'package:stryde/features/home/data/quest_pool.dart';
import 'package:stryde/features/home/domain/entities/quest.dart';
import 'package:stryde/features/home/presentation/providers/login_streak_provider.dart';
import 'package:stryde/features/progression/domain/entities/xp_transaction.dart';
import 'package:stryde/features/progression/presentation/providers/user_progression_provider.dart';
import 'package:stryde/features/progression/presentation/providers/xp_transactions_provider.dart';

final weeklyQuestsProvider =
    NotifierProvider<WeeklyQuestsNotifier, WeeklyQuestState>(
      WeeklyQuestsNotifier.new,
    );

class WeeklyQuestsNotifier extends Notifier<WeeklyQuestState> {
  static const Duration cycle = Duration(days: 7);

  String? _activeUserId;
  final Map<String, DateTime> _completedAt = <String, DateTime>{};

  CompletedQuestsRepository? get _repository =>
      ref.read(completedQuestsRepositoryProvider);

  @override
  WeeklyQuestState build() {
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
      state = _buildWeek();
      if (userId != null && _repository != null) {
        unawaited(_hydrate(userId));
      }
    });

    return _buildWeek();
  }

  WeeklyQuestState _buildWeek() {
    final now = DateTime.now();
    final endsAt = _nextMonday(now);
    final weekStart = endsAt.subtract(const Duration(days: 7));
    final random = Random(weekStart.millisecondsSinceEpoch);
    final pool = <Quest>[...QuestPool.all]..shuffle(random);
    final selected = pool.take(4).toList();

    return WeeklyQuestState(
      quests: <Quest>[
        for (final quest in selected)
          quest.copyWith(
            isCompleted: _isCompletedWithin(quest.id, now),
          ),
      ],
      endsAt: endsAt,
    );
  }

  bool _isCompletedWithin(String id, DateTime now) {
    final completedAt = _completedAt[id];
    if (completedAt == null) return false;
    final elapsed = now.difference(completedAt);
    return !elapsed.isNegative && elapsed < cycle;
  }

  Future<void> _hydrate(String userId) async {
    final repo = _repository;
    if (repo == null) return;
    final records = await repo.fetch(userId);
    if (_activeUserId != userId) return;

    for (final record in records) {
      if (record.questType == 'quest') {
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
    var changed = false;
    final updated = <Quest>[
      for (final quest in state.quests) ...[
        () {
          final isCompleted = _isCompletedWithin(quest.id, now);
          if (isCompleted != quest.isCompleted) changed = true;
          return quest.copyWith(isCompleted: isCompleted);
        }(),
      ],
    ];
    if (changed) {
      state = WeeklyQuestState(
        quests: updated,
        endsAt: state.endsAt,
      );
    }
  }

  bool complete(String id) {
    refreshIfNeeded();
    final index = state.quests.indexWhere((quest) => quest.id == id);
    if (index == -1 || state.quests[index].isCompleted) return false;

    final quest = state.quests[index];
    final now = DateTime.now();
    _completedAt[id] = now;
    state = WeeklyQuestState(
      quests: <Quest>[
        for (var i = 0; i < state.quests.length; i++)
          if (i == index)
            state.quests[i].copyWith(isCompleted: true)
          else
            state.quests[i],
      ],
      endsAt: state.endsAt,
    );

    final userId = _activeUserId;
    final repo = _repository;
    if (userId != null && repo != null) {
      unawaited(
        repo.insert(
          userId: userId,
          questId: id,
          questType: 'quest',
          completedAt: now,
        ),
      );
    }

    ref.read(userProgressionProvider.notifier).addXp(quest.xp);
    ref
        .read(xpTransactionsProvider.notifier)
        .log(
          description: 'Quest · ${quest.title}',
          amount: quest.xp,
          source: XpSource.quest,
        );
    ref.read(loginStreakProvider.notifier).recordActivity();
    return true;
  }

  void refreshIfNeeded() {
    final now = DateTime.now();
    if (!now.isBefore(state.endsAt)) {
      state = _buildWeek();
    } else {
      _applyActiveCompletions(now);
    }
  }
}

DateTime _nextMonday(DateTime now) {
  final daysUntilMonday = (DateTime.monday - now.weekday + 7) % 7;
  var end = DateTime(now.year, now.month, now.day + daysUntilMonday);
  if (!end.isAfter(now)) {
    end = end.add(const Duration(days: 7));
  }
  return end;
}
