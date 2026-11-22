import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_typography.dart';

abstract final class AppTheme {
  static ThemeData buildTheme({
    required bool isDark,
    required Color accentColor,
  }) {
    final background =
        isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
    final surface =
        isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
    final surfaceElevated =
        isDark ? const Color(0xFF181818) : const Color(0xFFEEEEEE);
    final surfaceVariant =
        isDark ? const Color(0xFF1F1F1F) : const Color(0xFFE8E8E8);
    final textPrimary =
        isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    final textSecondary =
        isDark ? const Color(0xFFA0A0A0) : const Color(0xFF666666);
    final textMuted =
        isDark ? const Color(0xFF6B6B6B) : const Color(0xFF888888);
    final border =
        isDark ? const Color(0xFF262626) : const Color(0xFFE0E0E0);
    final progressTrack =
        isDark ? const Color(0xFF202020) : const Color(0xFFE0E0E0);

    final onPrimary =
        (accentColor.computeLuminance() > 0.45)
            ? const Color(0xFF000000)
            : const Color(0xFFFFFFFF);

    final colorScheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: accentColor,
      onPrimary: onPrimary,
      primaryContainer: surfaceVariant,
      onPrimaryContainer: textPrimary,
      secondary: isDark ? const Color(0xFFD6D6D6) : const Color(0xFF4A4A4A),
      onSecondary: background,
      secondaryContainer: surfaceVariant,
      onSecondaryContainer: textPrimary,
      tertiary: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF616161),
      onTertiary: background,
      tertiaryContainer: surfaceElevated,
      onTertiaryContainer: textPrimary,
      error: const Color(0xFFE0E0E0),
      onError: background,
      errorContainer: surfaceVariant,
      onErrorContainer: textPrimary,
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerHighest: surfaceVariant,
      onSurfaceVariant: textSecondary,
      outline: border,
      outlineVariant: surfaceVariant,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: textPrimary,
      onInverseSurface: background,
      inversePrimary: surfaceVariant,
      surfaceTint: Colors.transparent,
    );

    final textTheme = AppTypography.getTextTheme(isDark: isDark);

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      dividerColor: border,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: IconThemeData(color: textSecondary),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accentColor,
        linearTrackColor: progressTrack,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: onPrimary,
          disabledBackgroundColor: surfaceVariant,
          disabledForegroundColor: textMuted,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: textPrimary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      splashColor: accentColor.withValues(alpha: 0.08),
      highlightColor: accentColor.withValues(alpha: 0.04),
      hoverColor: accentColor.withValues(alpha: 0.04),
    );
  }

  static ThemeData get dark => buildTheme(
        isDark: true,
        accentColor: AppColors.customPrimary,
      );

  static ThemeData get light => buildTheme(
        isDark: false,
        accentColor: AppColors.customPrimary,
      );
}
