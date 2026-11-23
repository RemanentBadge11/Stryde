import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stryde/core/database/local_cache_service.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';

class ProfileData {
  const ProfileData({
    required this.xp,
    required this.level,
    required this.streak,
    required this.skillPoints,
    this.totalXp,
    this.availableSkillPoints,
    this.username,
    this.lastActivityOn,
    this.goalSteps,
    this.goalWater,
    this.goalProtein,
    this.displayName,
    this.avatarUrl,
    this.themeMode,
    this.accentColor,
    this.updatedAt,
    this.timezone,
  });

  final int xp;
  final int level;
  final int streak;
  final int skillPoints;
  final int? totalXp;
  final int? availableSkillPoints;
  final String? username;
  final DateTime? lastActivityOn;
  final int? goalSteps;
  final double? goalWater;
  final int? goalProtein;
  final String? displayName;
  final String? avatarUrl;
  final String? themeMode;
  final String? accentColor;
  final DateTime? updatedAt;
  final String? timezone;

  ProfileData copyWith({
    int? xp,
    int? level,
    int? streak,
    int? skillPoints,
    int? totalXp,
    int? availableSkillPoints,
    String? username,
    DateTime? lastActivityOn,
    int? goalSteps,
    double? goalWater,
    int? goalProtein,
    String? displayName,
    String? avatarUrl,
    String? themeMode,
    String? accentColor,
    DateTime? updatedAt,
    String? timezone,
  }) {
    return ProfileData(
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      skillPoints: skillPoints ?? this.skillPoints,
      totalXp: totalXp ?? this.totalXp,
      availableSkillPoints: availableSkillPoints ?? this.availableSkillPoints,
      username: username ?? this.username,
      lastActivityOn: lastActivityOn ?? this.lastActivityOn,
      goalSteps: goalSteps ?? this.goalSteps,
      goalWater: goalWater ?? this.goalWater,
      goalProtein: goalProtein ?? this.goalProtein,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      updatedAt: updatedAt ?? this.updatedAt,
      timezone: timezone ?? this.timezone,
    );
  }
}

class ProfileRepository {
  ProfileRepository(this._supabase, [this._localCache]);

  final SupabaseClient _supabase;
  final LocalCacheService? _localCache;
  bool _supportsLastActivityOn = false;
  bool _supportsUpdatedAt = false;

  Future<ProfileData?> getOrFetchProfile(
    String userId, {
    String? defaultUsername,
  }) async {
    final cache = _localCache;

    // 1. Check local cache first
    if (cache != null) {
      try {
        final cached = await cache.getCachedProfile(userId);
        if (cached != null) {
          return cached;
        }
      } catch (_) {
        // Fall back to direct fetch
      }
    }

    // 2. Scenario B: Cache is Empty - Fresh Install
    try {
      final remote = await fetch(userId);
      if (remote != null) {
        if (cache != null) {
          await cache.saveCachedProfile(
            userId,
            remote,
            lastUpdated: remote.updatedAt ?? DateTime.now(),
          );
        }
        return remote;
      }
    } catch (_) {
      // Offline / network failure on fresh install
    }

    // Initialize new profile locally with defaults
    final defaultProfile = ProfileData(
      xp: 0,
      level: 1,
      streak: 0,
      skillPoints: 0,
      totalXp: 0,
      availableSkillPoints: 0,
      username: defaultUsername,
      themeMode: 'dark',
      accentColor: '#FFFFFF',
      updatedAt: DateTime.now().toUtc(),
    );

    if (cache != null) {
      await cache.saveCachedProfile(userId, defaultProfile);
      final payload = <String, dynamic>{
        'userId': userId,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      };
      if (defaultUsername != null) {
        payload['username'] = defaultUsername;
      }
      await cache.enqueue(
        entityType: 'profile',
        action: 'create_profile',
        payload: payload,
      );
    }

    return defaultProfile;
  }

  Future<ProfileData?> fetch(String userId) async {
    final row = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (row == null) return null;

    _supportsLastActivityOn = row.containsKey('last_activity_on');
    _supportsUpdatedAt = row.containsKey('updated_at');
    final profile = ProfileData(
      xp: _asInt(row['xp']),
      level: _asInt(row['level'], fallback: 1),
      streak: _asInt(row['streak']),
      skillPoints: _asInt(row['skill_points']),
      totalXp: row['total_xp'] != null ? _asInt(row['total_xp']) : null,
      availableSkillPoints: row['available_skill_points'] != null
          ? _asInt(row['available_skill_points'])
          : null,
      username: row['username']?.toString(),
      lastActivityOn:
          _asDateTime(row['last_activity_on']) ??
          _asDateTime(row['updated_at']),
      goalSteps: row['goal_steps'] != null ? _asInt(row['goal_steps']) : null,
      goalWater: row['goal_water'] != null
          ? _asDouble(row['goal_water'])
          : null,
      goalProtein: row['goal_protein'] != null
          ? _asInt(row['goal_protein'])
          : null,
      displayName: row['display_name']?.toString(),
      avatarUrl: row['avatar_url']?.toString(),
      themeMode: row['theme_mode']?.toString(),
      accentColor: row['accent_color']?.toString(),
      updatedAt: _asDateTime(row['updated_at']),
      timezone: row['timezone']?.toString(),
    );

    final cache = _localCache;
    if (cache != null) {
      try {
        await cache.saveCachedProfile(
          userId,
          profile,
          lastUpdated: profile.updatedAt ?? DateTime.now(),
        );
      } catch (_) {
        // Cache write degrades gracefully
      }
    }

    return profile;
  }

  Future<void> saveProgression({
    required String userId,
    required int xp,
    required int level,
    required int skillPoints,
    int? totalXp,
    int? availableSkillPoints,
  }) async {
    final values = <String, dynamic>{
      'xp': xp,
      'level': level,
      'skill_points': skillPoints,
      'available_skill_points': availableSkillPoints ?? skillPoints,
    };
    if (totalXp != null) {
      values['total_xp'] = totalXp;
    }
    await _supabase.from('profiles').update(values).eq('id', userId);
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

  Future<void> saveTimezone({
    required String userId,
    required String timezone,
  }) async {
    try {
      await _supabase
          .from('profiles')
          .update(<String, dynamic>{'timezone': timezone})
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
  final localCache = ref.watch(localCacheServiceProvider);
  return supabase == null ? null : ProfileRepository(supabase, localCache);
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
