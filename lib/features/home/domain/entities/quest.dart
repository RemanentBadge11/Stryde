class Quest {
  const Quest({
    required this.id,
    required this.title,
    required this.detail,
    required this.xp,
    this.isCompleted = false,
  });

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
  const WeeklyQuestState({required this.quests, required this.endsAt});

  final List<Quest> quests;
  final DateTime endsAt;
}
