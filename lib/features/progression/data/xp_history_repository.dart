import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/progression/domain/entities/xp_transaction.dart';

class XpHistoryRepository {
  const XpHistoryRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<List<XpTransaction>> fetch(String userId) async {
    final rows = await _supabase
        .from('xp_history')
        .select()
        .eq('user_id', userId);

    final transactions =
        rows.map<XpTransaction>(_fromRow).toList(growable: false)
          ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return transactions;
  }

  Future<XpTransaction> insert({
    required String userId,
    required XpTransaction transaction,
  }) async {
    final row = await _supabase
        .from('xp_history')
        .insert(<String, dynamic>{
          'description': transaction.description,
          'amount': transaction.amount,
          'user_id': userId,
        })
        .select()
        .single();
    return _fromRow(row, fallback: transaction);
  }

  XpTransaction _fromRow(Map<String, dynamic> row, {XpTransaction? fallback}) {
    final description =
        row['description']?.toString() ?? fallback?.description ?? 'XP Award';
    return XpTransaction(
      id: row['id']?.toString() ?? fallback?.id ?? '',
      description: description,
      amount: _asInt(row['amount'], fallback: fallback?.amount ?? 0),
      occurredAt:
          _asDateTime(row['created_at']) ??
          _asDateTime(row['occurred_at']) ??
          fallback?.occurredAt ??
          DateTime.now(),
      source: _sourceFromDescription(description, fallback?.source),
    );
  }
}

final xpHistoryRepositoryProvider = Provider<XpHistoryRepository?>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase == null ? null : XpHistoryRepository(supabase);
});

XpSource _sourceFromDescription(String description, XpSource? fallback) {
  if (fallback != null) return fallback;
  final normalized = description.toLowerCase();
  if (normalized.startsWith('habit')) return XpSource.habit;
  if (normalized.startsWith('quest')) return XpSource.quest;
  if (normalized.startsWith('daily goal')) return XpSource.goal;
  return XpSource.workout;
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

DateTime? _asDateTime(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString())?.toLocal();
}
