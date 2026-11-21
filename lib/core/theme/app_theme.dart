import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_typography.dart';

abstract final class AppTheme {
  static const ColorScheme _colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.surfaceVariant,
    onPrimaryContainer: AppColors.textPrimary,
    secondary: Color(0xFFD6D6D6),
    onSecondary: AppColors.background,
    secondaryContainer: AppColors.surfaceVariant,
    onSecondaryContainer: AppColors.textPrimary,
    tertiary: Color(0xFFBDBDBD),
    onTertiary: AppColors.background,
    tertiaryContainer: AppColors.surfaceElevated,
    onTertiaryContainer: AppColors.textPrimary,
    error: Color(0xFFE0E0E0),
    onError: AppColors.background,
    errorContainer: AppColors.surfaceVariant,
    onErrorContainer: AppColors.textPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    outlineVariant: AppColors.surfaceVariant,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: AppColors.textPrimary,
    onInverseSurface: AppColors.background,
    inversePrimary: AppColors.surfaceVariant,
    surfaceTint: Colors.transparent,
  );

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      dividerColor: AppColors.border,
      textTheme: AppTypography.textTheme,
      primaryTextTheme: AppTypography.textTheme,
      iconTheme: const IconThemeData(color: AppColors.textSecondary),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.progressTrack,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.surfaceVariant,
          disabledForegroundColor: AppColors.textMuted,
          textStyle: AppTypography.textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      splashColor: AppColors.primary.withValues(alpha: 0.08),
      highlightColor: AppColors.primary.withValues(alpha: 0.04),
      hoverColor: AppColors.primary.withValues(alpha: 0.04),
    );
  }
}
