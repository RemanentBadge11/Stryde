import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';

class SkillsRepository {
  const SkillsRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<Map<String, int>> fetch(String userId) async {
    final rows = await _supabase
        .from('skills')
        .select('muscle_group, points')
        .eq('user_id', userId);
    return <String, int>{
      for (final row in rows)
        if (row['muscle_group'] != null)
          row['muscle_group'].toString(): _asInt(row['points']),
    };
  }

  Future<void> upsert({
    required String userId,
    required String muscleGroup,
    required int points,
  }) async {
    await _supabase.from('skills').upsert(<String, dynamic>{
      'user_id': userId,
      'muscle_group': muscleGroup,
      'points': points,
    }, onConflict: 'user_id,muscle_group');
  }
}

final skillsRepositoryProvider = Provider<SkillsRepository?>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase == null ? null : SkillsRepository(supabase);
});

int _asInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
