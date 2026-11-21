import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  @override
  WeeklyQuestState build() => _buildWeek();

  WeeklyQuestState _buildWeek() {
    final now = DateTime.now();
    final shuffled = <Quest>[...QuestPool.all]..shuffle();
    return WeeklyQuestState(
      quests: shuffled
          .take(4)
          .map((quest) => quest.copyWith(isCompleted: false))
          .toList(growable: false),
      endsAt: _nextMonday(now),
    );
  }

  bool complete(String id) {
    refreshIfNeeded();
    final index = state.quests.indexWhere((quest) => quest.id == id);
    if (index == -1 || state.quests[index].isCompleted) return false;

    final quest = state.quests[index];
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
    if (!DateTime.now().isBefore(state.endsAt)) {
      state = _buildWeek();
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
