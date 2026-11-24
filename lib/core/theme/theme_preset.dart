import 'package:material_ui/material_ui.dart';

/// Immutable representation of an app-wide theme preset in Stryde.
class ThemePreset {
  const ThemePreset({
    required this.id,
    required this.name,
    required this.background,
    required this.surface,
    required this.accent,
    required this.text,
    required this.onAccent,
    required this.brightness,
  });

  final String id;
  final String name;
  final Color background;
  final Color surface;
  final Color accent;
  final Color text;
  final Color onAccent;
  final Brightness brightness;

  bool get isDark => brightness == Brightness.dark;
}

const kThemePresetShadowMonarch = ThemePreset(
  id: 'shadow_monarch',
  name: 'Shadow Monarch',
  background: Color(0xFF100B1C),
  surface: Color(0xFF211631),
  accent: Color(0xFFA855F7),
  text: Color(0xFFF0E8FF),
  onAccent: Color(0xFF100B1C),
  brightness: Brightness.dark,
);

const kThemePresetBloodMoon = ThemePreset(
  id: 'blood_moon',
  name: 'Blood Moon',
  background: Color(0xFF19090D),
  surface: Color(0xFF32131B),
  accent: Color(0xFFEF4444),
  text: Color(0xFFFFE8E8),
  onAccent: Color(0xFF19090D),
  brightness: Brightness.dark,
);

const kThemePresetGlacier = ThemePreset(
  id: 'glacier',
  name: 'Glacier',
  background: Color(0xFF081725),
  surface: Color(0xFF142D40),
  accent: Color(0xFF38BDF8),
  text: Color(0xFFE1F4FF),
  onAccent: Color(0xFF081725),
  brightness: Brightness.dark,
);

const kThemePresetOlympus = ThemePreset(
  id: 'olympus',
  name: 'Olympus',
  background: Color(0xFF19160F),
  surface: Color(0xFF302718),
  accent: Color(0xFFD4AF37),
  text: Color(0xFFFFF3D6),
  onAccent: Color(0xFF19160F),
  brightness: Brightness.dark,
);

const kThemePresetToxic = ThemePreset(
  id: 'toxic',
  name: 'Toxic',
  background: Color(0xFF10170B),
  surface: Color(0xFF202D16),
  accent: Color(0xFFA3E635),
  text: Color(0xFFF0F8E5),
  onAccent: Color(0xFF10170B),
  brightness: Brightness.dark,
);

const kThemePresetAbyss = ThemePreset(
  id: 'abyss',
  name: 'Abyss',
  background: Color(0xFF050F12),
  surface: Color(0xFF102529),
  accent: Color(0xFF2DD4BF),
  text: Color(0xFFD9FFF8),
  onAccent: Color(0xFF050F12),
  brightness: Brightness.dark,
);

const kThemePresetEmber = ThemePreset(
  id: 'ember',
  name: 'Ember',
  background: Color(0xFF1C1009),
  surface: Color(0xFF382116),
  accent: Color(0xFFFB923C),
  text: Color(0xFFFFF0DF),
  onAccent: Color(0xFF1C1009),
  brightness: Brightness.dark,
);

const kThemePresetSakura = ThemePreset(
  id: 'sakura',
  name: 'Sakura',
  background: Color(0xFFFFF0F5),
  surface: Color(0xFFF9DCE7),
  accent: Color(0xFFBE185D),
  text: Color(0xFF63243F),
  onAccent: Color(0xFFFFFFFF),
  brightness: Brightness.light,
);

/// The eight official theme presets ordered exactly as specified.
const List<ThemePreset> kThemePresets = [
  kThemePresetShadowMonarch,
  kThemePresetBloodMoon,
  kThemePresetGlacier,
  kThemePresetOlympus,
  kThemePresetToxic,
  kThemePresetAbyss,
  kThemePresetEmber,
  kThemePresetSakura,
];

ThemePreset? getThemePresetById(String? id) {
  if (id == null) return null;
  final clean = id
      .trim()
      .toLowerCase()
      .replaceAll('preset:', '')
      .replaceAll('-', '_')
      .replaceAll(' ', '_');
  for (final preset in kThemePresets) {
    if (preset.id == clean ||
        preset.name.toLowerCase().replaceAll(' ', '_') == clean) {
      return preset;
    }
  }
  return null;
}
