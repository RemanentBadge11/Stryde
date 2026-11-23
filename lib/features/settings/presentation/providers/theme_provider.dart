import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/database/local_cache_service.dart';
import 'package:stryde/core/sync/sync_service.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_theme.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/profile/data/profile_repository.dart';

class AccentColorOption {
  const AccentColorOption({
    required this.name,
    required this.hex,
    required this.color,
  });

  final String name;
  final String hex;
  final Color color;
}

const List<AccentColorOption> kAccentColors = [
  AccentColorOption(name: 'White', hex: '#FFFFFF', color: Color(0xFFFFFFFF)),
  AccentColorOption(name: 'Red', hex: '#EF4444', color: Color(0xFFEF4444)),
  AccentColorOption(name: 'Blue', hex: '#3B82F6', color: Color(0xFF3B82F6)),
  AccentColorOption(name: 'Green', hex: '#22C55E', color: Color(0xFF22C55E)),
  AccentColorOption(name: 'Yellow', hex: '#EAB308', color: Color(0xFFEAB308)),
  AccentColorOption(name: 'Orange', hex: '#F97316', color: Color(0xFFF97316)),
  AccentColorOption(name: 'Purple', hex: '#A855F7', color: Color(0xFFA855F7)),
  AccentColorOption(
    name: 'Terracotta',
    hex: '#D68F71',
    color: Color(0xFFD68F71),
  ),
];

Color parseHexColor(String? hex, {Color fallback = const Color(0xFFFFFFFF)}) {
  if (hex == null || hex.trim().isEmpty) return fallback;
  final clean = hex.replaceAll('#', '').trim();
  if (clean.length == 6) {
    final val = int.tryParse('FF$clean', radix: 16);
    if (val != null) return Color(val);
  } else if (clean.length == 8) {
    final val = int.tryParse(clean, radix: 16);
    if (val != null) return Color(val);
  }
  return fallback;
}

class AppThemeState {
  const AppThemeState({
    this.themeMode = ThemeMode.dark,
    this.accentColor = const Color(0xFFFFFFFF),
    this.accentColorHex = '#FFFFFF',
  });

  final ThemeMode themeMode;
  final Color accentColor;
  final String accentColorHex;

  bool get isDark => themeMode == ThemeMode.dark;

  ThemeData get themeData =>
      AppTheme.buildTheme(isDark: isDark, accentColor: accentColor);

  AppThemeState copyWith({
    ThemeMode? themeMode,
    Color? accentColor,
    String? accentColorHex,
  }) {
    return AppThemeState(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      accentColorHex: accentColorHex ?? this.accentColorHex,
    );
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, AppThemeState>(
  ThemeNotifier.new,
);

class ThemeNotifier extends Notifier<AppThemeState> {
  String? _activeUserId;
  ProfileRepository? get _repository => ref.read(profileRepositoryProvider);

  @override
  AppThemeState build() {
    final user = ref.watch(currentUserProvider);
    _activeUserId = user?.id;

    if (user != null && _repository != null) {
      unawaited(_hydrate(user.id));
    }

    const initialState = AppThemeState();
    AppColors.update(
      dark: initialState.isDark,
      accent: initialState.accentColor,
    );

    return initialState;
  }

  Future<void> _hydrate(String userId) async {
    final repo = _repository;
    if (repo == null) return;
    try {
      final data = await repo.getOrFetchProfile(userId);
      if (_activeUserId != userId || data == null) return;

      final isLight = data.themeMode?.toLowerCase() == 'light';
      final mode = isLight ? ThemeMode.light : ThemeMode.dark;
      final hex =
          (data.accentColor != null && data.accentColor!.trim().isNotEmpty)
          ? data.accentColor!.trim().toUpperCase()
          : '#FFFFFF';
      final accent = parseHexColor(hex);

      AppColors.update(dark: !isLight, accent: accent);

      state = state.copyWith(
        themeMode: mode,
        accentColor: accent,
        accentColorHex: hex,
      );
    } catch (_) {
      // Degrades gracefully
    }
  }

  void setThemeMode(ThemeMode mode) {
    final isDark = mode == ThemeMode.dark;
    AppColors.update(dark: isDark);
    state = state.copyWith(themeMode: mode);
    _persist();
  }

  void toggleThemeMode() {
    setThemeMode(state.isDark ? ThemeMode.light : ThemeMode.dark);
  }

  void setAccentColor(Color color, [String? hex]) {
    final resolvedHex =
        hex ??
        '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
    AppColors.update(accent: color);
    state = state.copyWith(accentColor: color, accentColorHex: resolvedHex);
    _persist();
  }

  void _persist() {
    final userId = _activeUserId;
    if (userId == null) return;

    final localCache = ref.read(localCacheServiceProvider);
    final now = DateTime.now();
    final themeModeStr = state.isDark ? 'dark' : 'light';
    final accentHex = state.accentColorHex;

    unawaited(() async {
      try {
        await localCache.updateCachedProfile(
          userId,
          themeMode: themeModeStr,
          accentColor: accentHex,
          lastUpdated: now,
        );
        await localCache.enqueue(
          entityType: 'profile',
          action: 'update',
          payload: <String, dynamic>{
            'userId': userId,
            'values': <String, dynamic>{
              'theme_mode': themeModeStr,
              'accent_color': accentHex,
              'updated_at': now.toUtc().toIso8601String(),
            },
          },
        );
        unawaited(ref.read(syncServiceProvider.notifier).syncPending());
      } catch (_) {
        // Degrades gracefully
      }
    }());

    final repo = _repository;
    if (repo != null) {
      unawaited(
        repo.saveThemeSettings(
          userId: userId,
          themeMode: themeModeStr,
          accentColor: accentHex,
        ),
      );
    }
  }
}
