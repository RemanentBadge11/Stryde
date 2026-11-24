import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_typography.dart';
import 'package:stryde/core/theme/theme_preset.dart';

abstract final class AppTheme {
  static void updateSystemUIOverlay(bool isDark, Color backgroundColor) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: backgroundColor,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarDividerColor: backgroundColor,
      ),
    );
  }

  static ThemeData buildTheme({
    required bool isDark,
    required Color accentColor,
    ThemePreset? preset,
  }) {
    final effectiveIsDark = preset != null
        ? preset.brightness == Brightness.dark
        : isDark;
    final background = preset != null
        ? preset.background
        : (effectiveIsDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF));
    final surface = preset != null
        ? preset.surface
        : (effectiveIsDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5));
    final surfaceElevated = preset != null
        ? Color.lerp(
            preset.surface,
            preset.text,
            effectiveIsDark ? 0.04 : 0.02,
          )!
        : (effectiveIsDark ? const Color(0xFF181818) : const Color(0xFFEEEEEE));
    final surfaceVariant = preset != null
        ? Color.lerp(
            preset.surface,
            preset.text,
            effectiveIsDark ? 0.07 : 0.05,
          )!
        : (effectiveIsDark ? const Color(0xFF1F1F1F) : const Color(0xFFE8E8E8));
    final textPrimary = preset != null
        ? preset.text
        : (effectiveIsDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000));
    final textSecondary = preset != null
        ? preset.text.withValues(alpha: 0.70)
        : (effectiveIsDark ? const Color(0xFFA0A0A0) : const Color(0xFF666666));
    final textMuted = preset != null
        ? preset.text.withValues(alpha: 0.45)
        : (effectiveIsDark ? const Color(0xFF6B6B6B) : const Color(0xFF888888));
    final border = preset != null
        ? preset.text.withValues(alpha: 0.12)
        : (effectiveIsDark ? const Color(0xFF262626) : const Color(0xFFE0E0E0));
    final progressTrack = preset != null
        ? preset.background
        : (effectiveIsDark ? const Color(0xFF202020) : const Color(0xFFE0E0E0));

    final effectiveAccent = preset != null ? preset.accent : accentColor;
    final onPrimary = preset != null
        ? preset.onAccent
        : ((effectiveAccent.computeLuminance() > 0.45)
              ? const Color(0xFF000000)
              : const Color(0xFFFFFFFF));

    final colorScheme = ColorScheme(
      brightness: effectiveIsDark ? Brightness.dark : Brightness.light,
      primary: effectiveAccent,
      onPrimary: onPrimary,
      primaryContainer: surfaceVariant,
      onPrimaryContainer: textPrimary,
      secondary: effectiveIsDark
          ? const Color(0xFFD6D6D6)
          : const Color(0xFF4A4A4A),
      onSecondary: background,
      secondaryContainer: surfaceVariant,
      onSecondaryContainer: textPrimary,
      tertiary: effectiveIsDark
          ? const Color(0xFFBDBDBD)
          : const Color(0xFF616161),
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

    final textTheme = AppTypography.getTextTheme(isDark: effectiveIsDark);

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      brightness: effectiveIsDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      dividerColor: border,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: IconThemeData(color: textSecondary),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: effectiveAccent),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: textMuted),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceVariant,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: effectiveAccent,
        linearTrackColor: progressTrack,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: effectiveAccent,
          foregroundColor: onPrimary,
          disabledBackgroundColor: surfaceVariant,
          disabledForegroundColor: textMuted,
          textStyle: textTheme.labelLarge,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: textPrimary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      splashColor: effectiveAccent.withValues(alpha: 0.08),
      highlightColor: effectiveAccent.withValues(alpha: 0.04),
      hoverColor: effectiveAccent.withValues(alpha: 0.04),
    );
  }

  static ThemeData get dark =>
      buildTheme(isDark: true, accentColor: AppColors.customPrimary);

  static ThemeData get light =>
      buildTheme(isDark: false, accentColor: AppColors.customPrimary);
}
