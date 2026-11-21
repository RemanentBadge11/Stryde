import 'package:material_ui/material_ui.dart';

/// Stryde's deliberately monochrome palette.
///
/// True black canvas, layered charcoal surfaces, and a strict white-to-gray
/// type scale. No accent hue is permitted anywhere in the app.
abstract final class AppColors {
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF121212);
  static const Color surfaceElevated = Color(0xFF181818);
  static const Color surfaceVariant = Color(0xFF1F1F1F);

  static const Color primary = Color(0xFFFFFFFF);
  static const Color onPrimary = Color(0xFF000000);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color textMuted = Color(0xFF6B6B6B);

  static const Color border = Color(0xFF262626);
  static const Color borderStrong = Color(0xFF3D3D3D);
  static const Color progressTrack = Color(0xFF202020);
}
