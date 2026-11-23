class CompletedQuest {
  const CompletedQuest({
    required this.id,
    required this.userId,
    required this.questId,
    required this.questType,
    required this.completedAt,
  });

  final String id;
  final String userId;
  final String questId;
  final String questType;
  final DateTime completedAt;

  bool isWithinWindow(Duration window, [DateTime? now]) {
    final current = now ?? DateTime.now();
    final elapsed = current.difference(completedAt);
    return !elapsed.isNegative && elapsed < window;
  }

  factory CompletedQuest.fromRow(Map<String, dynamic> row) {
    return CompletedQuest(
      id: row['id']?.toString() ?? '',
      userId: row['user_id']?.toString() ?? '',
      questId: row['quest_id']?.toString() ?? '',
      questType: row['quest_type']?.toString() ?? '',
      completedAt:
          DateTime.tryParse(row['completed_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toInsertRow() {
    return <String, dynamic>{
      'user_id': userId,
      'quest_id': questId,
      'quest_type': questType,
      'completed_at': completedAt.toUtc().toIso8601String(),
    };
  }
}
