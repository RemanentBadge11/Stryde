import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';

class MedalsRepository {
  MedalsRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<Map<String, DateTime>> fetchUnlockedMedals(String userId) async {
    try {
      final rows = await _supabase
          .from('user_medals')
          .select('medal_id, unlocked_at')
          .eq('user_id', userId);

      final result = <String, DateTime>{};
      for (final row in rows) {
        final id = row['medal_id']?.toString();
        if (id != null) {
          final timestamp =
              DateTime.tryParse(row['unlocked_at']?.toString() ?? '') ??
              DateTime.now();
          result[id] = timestamp;
        }
      }
      return result;
    } catch (_) {
      return <String, DateTime>{};
    }
  }

  Future<void> unlockMedal({
    required String userId,
    required String medalId,
  }) async {
    try {
      await _supabase.from('user_medals').upsert(<String, dynamic>{
        'user_id': userId,
        'medal_id': medalId,
        'unlocked_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'user_id, medal_id');
    } catch (_) {
      // Degrades gracefully
    }
  }
}

final medalsRepositoryProvider = Provider<MedalsRepository?>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase == null ? null : MedalsRepository(supabase);
});
