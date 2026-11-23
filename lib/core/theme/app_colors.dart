import 'package:material_ui/material_ui.dart';

/// Stryde's dynamic theme palette supporting Dark/Light modes and Accent Colors.
abstract final class AppColors {
  static bool isDark = true;
  static Color customPrimary = const Color(0xFFFFFFFF);

  static Color get background =>
      isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  static Color get surface =>
      isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
  static Color get surfaceElevated =>
      isDark ? const Color(0xFF181818) : const Color(0xFFEEEEEE);
  static Color get surfaceVariant =>
      isDark ? const Color(0xFF1F1F1F) : const Color(0xFFE8E8E8);

  static Color get primary => customPrimary;
  static Color get onPrimary => (primary.computeLuminance() > 0.45)
      ? const Color(0xFF000000)
      : const Color(0xFFFFFFFF);

  static Color get textPrimary =>
      isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
  static Color get textSecondary =>
      isDark ? const Color(0xFFA0A0A0) : const Color(0xFF666666);
  static Color get textMuted =>
      isDark ? const Color(0xFF6B6B6B) : const Color(0xFF888888);

  static Color get border =>
      isDark ? const Color(0xFF262626) : const Color(0xFFE0E0E0);
  static Color get borderStrong =>
      isDark ? const Color(0xFF3D3D3D) : const Color(0xFFCCCCCC);
  static Color get progressTrack =>
      isDark ? const Color(0xFF202020) : const Color(0xFFE0E0E0);

  static void update({bool? dark, Color? accent}) {
    if (dark != null) isDark = dark;
    if (accent != null) customPrimary = accent;
  }
}
