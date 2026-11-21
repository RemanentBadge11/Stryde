enum XpSource { habit, quest, goal, workout }

class XpTransaction {
  const XpTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.occurredAt,
    required this.source,
  });

  final String id;
  final String description;
  final int amount;
  final DateTime occurredAt;
  final XpSource source;
}
