import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/database/local_cache_service.dart';
import 'package:stryde/core/sync/sync_service.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_theme.dart';
import 'package:stryde/core/theme/theme_preset.dart';
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
    this.preset,
  });

  final ThemeMode themeMode;
  final Color accentColor;
  final String accentColorHex;
  final ThemePreset? preset;

  bool get isCustomPreset => preset != null;

  bool get isDark {
    if (preset != null) return preset!.isDark;
    if (themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return themeMode == ThemeMode.dark;
  }

  ThemeMode get effectiveThemeMode {
    if (preset != null) {
      return preset!.isDark ? ThemeMode.dark : ThemeMode.light;
    }
    return themeMode;
  }

  ThemeData get themeData => AppTheme.buildTheme(
    isDark: isDark,
    accentColor: preset != null ? preset!.accent : accentColor,
    preset: preset,
  );

  AppThemeState copyWith({
    ThemeMode? themeMode,
    Color? accentColor,
    String? accentColorHex,
    ThemePreset? preset,
    bool clearPreset = false,
  }) {
    return AppThemeState(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      accentColorHex: accentColorHex ?? this.accentColorHex,
      preset: clearPreset ? null : (preset ?? this.preset),
    );
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, AppThemeState>(
  ThemeNotifier.new,
);

class ThemeNotifier extends Notifier<AppThemeState> {
  String? _activeUserId;
  bool _mounted = true;
  ProfileRepository? get _repository =>
      _mounted ? ref.read(profileRepositoryProvider) : null;

  @override
  AppThemeState build() {
    _mounted = true;
    ref.onDispose(() => _mounted = false);

    final user = ref.watch(currentUserProvider);
    _activeUserId = user?.id;

    final effectiveUserId = user?.id ?? 'local_user';
    Future.microtask(() => _hydrate(effectiveUserId));

    const initialState = AppThemeState();
    AppColors.update(
      dark: initialState.isDark,
      accent: initialState.accentColor,
      preset: initialState.preset,
    );

    return initialState;
  }

  Future<void> _hydrate(String userId) async {
    if (!_mounted) return;
    final localCache = ref.read(localCacheServiceProvider);
    ProfileData? data;
    try {
      data = await localCache.getCachedProfile(userId);
    } catch (_) {}

    if (!_mounted) return;
    final repo = _repository;
    if (data == null && repo != null && userId != 'local_user') {
      try {
        data = await repo.getOrFetchProfile(userId);
      } catch (_) {}
    }

    if (!_mounted || data == null) return;
    if (_activeUserId != null && _activeUserId != userId) return;

    final modeStr = data.themeMode?.toLowerCase() ?? 'dark';
    final preset = getThemePresetById(modeStr);

    if (preset != null) {
      AppColors.update(preset: preset);
      AppTheme.updateSystemUIOverlay(preset.isDark, preset.background);
      state = state.copyWith(
        preset: preset,
        accentColor: preset.accent,
        accentColorHex:
            '#${preset.accent.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
      );
      return;
    }

    final ThemeMode mode;
    if (modeStr == 'light') {
      mode = ThemeMode.light;
    } else if (modeStr == 'system') {
      mode = ThemeMode.system;
    } else {
      mode = ThemeMode.dark;
    }

    final hex =
        (data.accentColor != null && data.accentColor!.trim().isNotEmpty)
        ? data.accentColor!.trim().toUpperCase()
        : '#FFFFFF';
    final accent = parseHexColor(hex);

    final isDark = mode == ThemeMode.system
        ? (WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark)
        : (mode == ThemeMode.dark);

    AppColors.update(dark: isDark, accent: accent, clearPreset: true);
    AppTheme.updateSystemUIOverlay(isDark, AppColors.background);

    state = state.copyWith(
      themeMode: mode,
      accentColor: accent,
      accentColorHex: hex,
      clearPreset: true,
    );
  }

  void setThemeMode(ThemeMode mode) {
    final isDark = mode == ThemeMode.system
        ? (WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark)
        : (mode == ThemeMode.dark);

    AppColors.update(dark: isDark, clearPreset: true);
    AppTheme.updateSystemUIOverlay(isDark, AppColors.background);
    state = state.copyWith(themeMode: mode, clearPreset: true);
    _persist();
  }

  void toggleThemeMode() {
    setThemeMode(state.isDark ? ThemeMode.light : ThemeMode.dark);
  }

  void setThemePreset(ThemePreset preset) {
    final hex =
        '#${preset.accent.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
    AppColors.update(preset: preset);
    AppTheme.updateSystemUIOverlay(preset.isDark, preset.background);
    state = state.copyWith(
      preset: preset,
      accentColor: preset.accent,
      accentColorHex: hex,
    );
    _persist();
  }

  void setAccentColor(Color color, [String? hex]) {
    final resolvedHex =
        hex ??
        '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
    AppColors.update(accent: color, clearPreset: true);
    state = state.copyWith(
      accentColor: color,
      accentColorHex: resolvedHex,
      clearPreset: true,
    );
    _persist();
  }

  void _persist() {
    if (!_mounted) return;
    final effectiveUserId = _activeUserId ?? 'local_user';
    final localCache = ref.read(localCacheServiceProvider);
    final now = DateTime.now();
    final themeModeStr = state.preset != null
        ? 'preset:${state.preset!.id}'
        : state.themeMode.name;
    final accentHex = state.accentColorHex;

    unawaited(() async {
      try {
        await localCache.updateCachedProfile(
          effectiveUserId,
          themeMode: themeModeStr,
          accentColor: accentHex,
          lastUpdated: now,
        );
        if (_activeUserId != null) {
          await localCache.enqueue(
            entityType: 'profile',
            action: 'update',
            payload: <String, dynamic>{
              'userId': _activeUserId,
              'values': <String, dynamic>{
                'theme_mode': themeModeStr,
                'accent_color': accentHex,
                'updated_at': now.toUtc().toIso8601String(),
              },
            },
          );
          unawaited(ref.read(syncServiceProvider.notifier).syncPending());
        }
      } catch (_) {
        // Degrades gracefully
      }
    }());

    final repo = _repository;
    if (repo != null && _activeUserId != null) {
      unawaited(
        repo.saveThemeSettings(
          userId: _activeUserId!,
          themeMode: themeModeStr,
          accentColor: accentHex,
        ),
      );
    }
  }
}
