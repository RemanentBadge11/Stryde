import 'package:stryde/features/home/domain/entities/user_quest.dart';

class Quest {
  const Quest({
    required this.id,
    required this.title,
    required this.detail,
    required this.xp,
    this.isCompleted = false,
  });

  factory Quest.fromUserQuest(UserQuest quest) {
    return Quest(
      id: quest.id,
      title: quest.title,
      detail: quest.description,
      xp: quest.xpReward,
      isCompleted: quest.isCompleted,
    );
  }

  final String id;
  final String title;
  final String detail;
  final int xp;
  final bool isCompleted;

  Quest copyWith({bool? isCompleted}) {
    return Quest(
      id: id,
      title: title,
      detail: detail,
      xp: xp,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class WeeklyQuestState {
  const WeeklyQuestState({
    required this.quests,
    required this.endsAt,
    this.isEmptyOffline = false,
  });

  final List<Quest> quests;
  final DateTime endsAt;
  final bool isEmptyOffline;
}
