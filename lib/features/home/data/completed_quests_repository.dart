import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/home/domain/entities/completed_quest.dart';

class CompletedQuestsRepository {
  const CompletedQuestsRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<List<CompletedQuest>> fetch(String userId) async {
    try {
      final rows = await _supabase
          .from('completed_quests')
          .select()
          .eq('user_id', userId)
          .order('completed_at', ascending: false);
      return rows
          .map<CompletedQuest>((row) => CompletedQuest.fromRow(row))
          .toList(growable: false);
    } catch (_) {
      return const <CompletedQuest>[];
    }
  }

  Future<CompletedQuest?> insert({
    required String userId,
    required String questId,
    required String questType,
    DateTime? completedAt,
  }) async {
    final timestamp = completedAt ?? DateTime.now();
    try {
      final row = await _supabase
          .from('completed_quests')
          .insert(<String, dynamic>{
            'user_id': userId,
            'quest_id': questId,
            'quest_type': questType,
            'completed_at': timestamp.toUtc().toIso8601String(),
          })
          .select()
          .single();
      return CompletedQuest.fromRow(row);
    } catch (_) {
      return null;
    }
  }
}

final completedQuestsRepositoryProvider = Provider<CompletedQuestsRepository?>((
  ref,
) {
  final supabase = ref.watch(supabaseProvider);
  return supabase == null ? null : CompletedQuestsRepository(supabase);
});
