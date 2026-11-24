import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/theme_preset.dart';

/// Stryde's dynamic theme palette supporting System, Dark/Light modes,
/// custom Accent Colors, and the eight custom Theme Presets.
abstract final class AppColors {
  static bool isDark = true;
  static Color customPrimary = const Color(0xFFFFFFFF);
  static ThemePreset? currentPreset;

  static Color get background => currentPreset != null
      ? currentPreset!.background
      : (isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF));

  static Color get surface => currentPreset != null
      ? currentPreset!.surface
      : (isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5));

  static Color get surfaceElevated => currentPreset != null
      ? Color.lerp(
          currentPreset!.surface,
          currentPreset!.text,
          isDark ? 0.04 : 0.02,
        )!
      : (isDark ? const Color(0xFF181818) : const Color(0xFFEEEEEE));

  static Color get surfaceVariant => currentPreset != null
      ? Color.lerp(
          currentPreset!.surface,
          currentPreset!.text,
          isDark ? 0.07 : 0.05,
        )!
      : (isDark ? const Color(0xFF1F1F1F) : const Color(0xFFE8E8E8));

  static Color get primary =>
      currentPreset != null ? currentPreset!.accent : customPrimary;

  static Color get onPrimary => currentPreset != null
      ? currentPreset!.onAccent
      : ((primary.computeLuminance() > 0.45)
            ? const Color(0xFF000000)
            : const Color(0xFFFFFFFF));

  static Color get textPrimary => currentPreset != null
      ? currentPreset!.text
      : (isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000));

  static Color get textSecondary => currentPreset != null
      ? currentPreset!.text.withValues(alpha: 0.70)
      : (isDark ? const Color(0xFFA0A0A0) : const Color(0xFF666666));

  static Color get textMuted => currentPreset != null
      ? currentPreset!.text.withValues(alpha: 0.45)
      : (isDark ? const Color(0xFF6B6B6B) : const Color(0xFF888888));

  static Color get border => currentPreset != null
      ? currentPreset!.text.withValues(alpha: 0.12)
      : (isDark ? const Color(0xFF262626) : const Color(0xFFE0E0E0));

  static Color get borderStrong => currentPreset != null
      ? currentPreset!.text.withValues(alpha: 0.22)
      : (isDark ? const Color(0xFF3D3D3D) : const Color(0xFFCCCCCC));

  static Color get progressTrack => currentPreset != null
      ? currentPreset!.background
      : (isDark ? const Color(0xFF202020) : const Color(0xFFE0E0E0));

  static Color get error => const Color(0xFFE53935);

  static void update({
    bool? dark,
    Color? accent,
    ThemePreset? preset,
    bool clearPreset = false,
  }) {
    if (clearPreset) {
      currentPreset = null;
    } else if (preset != null) {
      currentPreset = preset;
    }

    if (currentPreset != null) {
      isDark = currentPreset!.brightness == Brightness.dark;
      customPrimary = currentPreset!.accent;
    } else {
      if (dark != null) isDark = dark;
      if (accent != null) customPrimary = accent;
    }
  }
}
