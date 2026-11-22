import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';

class ProfileData {
  const ProfileData({
    required this.xp,
    required this.level,
    required this.streak,
    required this.skillPoints,
    this.username,
    this.lastActivityOn,
    this.goalSteps,
    this.goalWater,
    this.goalProtein,
    this.displayName,
    this.avatarUrl,
    this.themeMode,
    this.accentColor,
  });

  final int xp;
  final int level;
  final int streak;
  final int skillPoints;
  final String? username;
  final DateTime? lastActivityOn;
  final int? goalSteps;
  final double? goalWater;
  final int? goalProtein;
  final String? displayName;
  final String? avatarUrl;
  final String? themeMode;
  final String? accentColor;
}

class ProfileRepository {
  ProfileRepository(this._supabase);

  final SupabaseClient _supabase;
  bool _supportsLastActivityOn = false;
  bool _supportsUpdatedAt = false;

  Future<ProfileData?> fetch(String userId) async {
    final row = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (row == null) return null;

    _supportsLastActivityOn = row.containsKey('last_activity_on');
    _supportsUpdatedAt = row.containsKey('updated_at');
    return ProfileData(
      xp: _asInt(row['xp']),
      level: _asInt(row['level'], fallback: 1),
      streak: _asInt(row['streak']),
      skillPoints: _asInt(row['skill_points']),
      username: row['username']?.toString(),
      lastActivityOn:
          _asDateTime(row['last_activity_on']) ??
          _asDateTime(row['updated_at']),
      goalSteps: row['goal_steps'] != null ? _asInt(row['goal_steps']) : null,
      goalWater: row['goal_water'] != null ? _asDouble(row['goal_water']) : null,
      goalProtein:
          row['goal_protein'] != null ? _asInt(row['goal_protein']) : null,
      displayName: row['display_name']?.toString(),
      avatarUrl: row['avatar_url']?.toString(),
      themeMode: row['theme_mode']?.toString(),
      accentColor: row['accent_color']?.toString(),
    );
  }

  Future<void> saveProgression({
    required String userId,
    required int xp,
    required int level,
    required int skillPoints,
  }) async {
    await _supabase
        .from('profiles')
        .update(<String, dynamic>{
          'xp': xp,
          'level': level,
          'skill_points': skillPoints,
        })
        .eq('id', userId);
  }

  Future<void> saveStreak({
    required String userId,
    required int streak,
    required DateTime? lastActivityOn,
  }) async {
    final values = <String, dynamic>{'streak': streak};
    if (_supportsLastActivityOn) {
      values['last_activity_on'] = lastActivityOn?.toIso8601String();
    } else if (_supportsUpdatedAt) {
      values['updated_at'] = lastActivityOn?.toUtc().toIso8601String();
    }
    await _supabase.from('profiles').update(values).eq('id', userId);
  }

  Future<void> saveGoals({
    required String userId,
    required int steps,
    required double water,
    required int protein,
  }) async {
    try {
      await _supabase
          .from('profiles')
          .update(<String, dynamic>{
            'goal_steps': steps,
            'goal_water': water,
            'goal_protein': protein,
          })
          .eq('id', userId);
    } catch (_) {
      // Degrades gracefully
    }
  }

  Future<void> saveThemeSettings({
    required String userId,
    required String themeMode,
    required String accentColor,
  }) async {
    try {
      await _supabase
          .from('profiles')
          .update(<String, dynamic>{
            'theme_mode': themeMode,
            'accent_color': accentColor,
          })
          .eq('id', userId);
    } catch (_) {
      // Degrades gracefully
    }
  }

  Future<void> saveProfileInfo({
    required String userId,
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
      final values = <String, dynamic>{};
      if (displayName != null) values['display_name'] = displayName;
      if (avatarUrl != null) values['avatar_url'] = avatarUrl;
      if (values.isNotEmpty) {
        await _supabase.from('profiles').update(values).eq('id', userId);
      }
    } catch (_) {
      // Degrades gracefully
    }
  }
}

final profileRepositoryProvider = Provider<ProfileRepository?>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase == null ? null : ProfileRepository(supabase);
});

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _asDouble(dynamic value, {double fallback = 0.0}) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

DateTime? _asDateTime(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString())?.toLocal();
}
