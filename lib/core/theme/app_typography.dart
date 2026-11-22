import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';

/// Uses Flutter's platform-default sans-serif family with a restrained,
/// high-contrast weight scale.
abstract final class AppTypography {
  static TextTheme getTextTheme({bool? isDark}) {
    final dark = isDark ?? AppColors.isDark;
    final textPrimary = dark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    final textSecondary = dark ? const Color(0xFFA0A0A0) : const Color(0xFF666666);

    return TextTheme(
      displayLarge: TextStyle(
        color: textPrimary,
        fontSize: 40,
        height: 1.05,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.4,
      ),
      displayMedium: TextStyle(
        color: textPrimary,
        fontSize: 36,
        height: 1.08,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.1,
      ),
      displaySmall: TextStyle(
        color: textPrimary,
        fontSize: 32,
        height: 1.1,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
      ),
      headlineLarge: TextStyle(
        color: textPrimary,
        fontSize: 28,
        height: 1.15,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        color: textPrimary,
        fontSize: 24,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.35,
      ),
      headlineSmall: TextStyle(
        color: textPrimary,
        fontSize: 20,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleLarge: TextStyle(
        color: textPrimary,
        fontSize: 18,
        height: 1.3,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: textPrimary,
        fontSize: 16,
        height: 1.35,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: textPrimary,
        fontSize: 14,
        height: 1.35,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: textPrimary,
        fontSize: 16,
        height: 1.45,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        color: textSecondary,
        fontSize: 14,
        height: 1.45,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        color: textSecondary,
        fontSize: 12,
        height: 1.4,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        color: textPrimary,
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        color: textSecondary,
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      labelSmall: TextStyle(
        color: textSecondary,
        fontSize: 10,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.35,
      ),
    );
  }

  static TextTheme get textTheme => getTextTheme();
}
