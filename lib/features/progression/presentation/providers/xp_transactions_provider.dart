import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stryde/features/progression/domain/entities/xp_transaction.dart';

final xpTransactionsProvider =
    NotifierProvider<XpTransactionsNotifier, List<XpTransaction>>(
      XpTransactionsNotifier.new,
    );

class XpTransactionsNotifier extends Notifier<List<XpTransaction>> {
  var _sequence = 0;

  @override
  List<XpTransaction> build() => const <XpTransaction>[];

  void log({
    required String description,
    required int amount,
    required XpSource source,
    DateTime? occurredAt,
  }) {
    if (amount <= 0) return;
    final now = occurredAt ?? DateTime.now();
    final transaction = XpTransaction(
      id: '${now.microsecondsSinceEpoch}-${_sequence++}',
      description: description,
      amount: amount,
      occurredAt: now,
      source: source,
    );
    state = <XpTransaction>[transaction, ...state].take(100).toList();
  }
}
