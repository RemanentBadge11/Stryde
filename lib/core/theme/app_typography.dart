import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';

/// Uses Flutter's platform-default sans-serif family with a restrained,
/// high-contrast weight scale.
abstract final class AppTypography {
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 40,
      height: 1.05,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.4,
    ),
    displayMedium: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 36,
      height: 1.08,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.1,
    ),
    displaySmall: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 32,
      height: 1.1,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.8,
    ),
    headlineLarge: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 28,
      height: 1.15,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
    headlineMedium: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 24,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.35,
    ),
    headlineSmall: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 20,
      height: 1.25,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
    ),
    titleLarge: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 18,
      height: 1.3,
      fontWeight: FontWeight.w700,
    ),
    titleMedium: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 16,
      height: 1.35,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 14,
      height: 1.35,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 16,
      height: 1.45,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: TextStyle(
      color: AppColors.textSecondary,
      fontSize: 14,
      height: 1.45,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: TextStyle(
      color: AppColors.textSecondary,
      fontSize: 12,
      height: 1.4,
      fontWeight: FontWeight.w400,
    ),
    labelLarge: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 14,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      color: AppColors.textSecondary,
      fontSize: 12,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    ),
    labelSmall: TextStyle(
      color: AppColors.textSecondary,
      fontSize: 10,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.35,
    ),
  );
}
