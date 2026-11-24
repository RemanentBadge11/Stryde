import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_spacing.dart';
import 'package:stryde/core/widgets/app_surface_card.dart';
import 'package:stryde/features/settings/presentation/providers/theme_provider.dart';
import 'package:stryde/features/settings/presentation/widgets/theme_preset_selector.dart';

class ThemeScreen extends ConsumerWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final isDark = themeState.isDark;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Themes',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space24,
            vertical: AppSpacing.space16,
          ),
          children: <Widget>[
            Text(
              'APPEARANCE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: AppSpacing.space12),
            AppSurfaceCard(
              padding: const EdgeInsets.all(AppSpacing.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      _AppearanceSegment(
                        title: 'System',
                        icon: Icons.brightness_auto_outlined,
                        isSelected:
                            themeState.preset == null &&
                            themeState.themeMode == ThemeMode.system,
                        onTap: () =>
                            themeNotifier.setThemeMode(ThemeMode.system),
                      ),
                      const SizedBox(width: 8),
                      _AppearanceSegment(
                        title: 'Light',
                        icon: Icons.light_mode_outlined,
                        isSelected:
                            themeState.preset == null &&
                            themeState.themeMode == ThemeMode.light,
                        onTap: () =>
                            themeNotifier.setThemeMode(ThemeMode.light),
                      ),
                      const SizedBox(width: 8),
                      _AppearanceSegment(
                        title: 'Dark',
                        icon: Icons.dark_mode_outlined,
                        isSelected:
                            themeState.preset == null &&
                            themeState.themeMode == ThemeMode.dark,
                        onTap: () => themeNotifier.setThemeMode(ThemeMode.dark),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: AppSpacing.space12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              isDark ? 'Dark Mode' : 'Light Mode',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isDark
                                  ? 'Monochrome true-black'
                                  : 'Clean high-contrast light',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        key: const ValueKey<String>('theme-mode-switch'),
                        value: isDark,
                        activeThumbColor: themeState.accentColor,
                        activeTrackColor: themeState.accentColor.withValues(
                          alpha: 0.35,
                        ),
                        inactiveThumbColor: AppColors.textSecondary,
                        inactiveTrackColor: AppColors.surfaceVariant,
                        onChanged: (val) {
                          themeNotifier.setThemeMode(
                            val ? ThemeMode.dark : ThemeMode.light,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space20),
            Text(
              'THEME PRESETS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: AppSpacing.space12),
            const ThemePresetSelector(),
            const SizedBox(height: AppSpacing.space20),
            Text(
              'ACCENT COLOR',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: AppSpacing.space12),
            AppSurfaceCard(
              padding: const EdgeInsets.all(AppSpacing.space20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Color Accent',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Customizes buttons, progress indicators, and checkmarks.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space20),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: <Widget>[
                      for (final option in kAccentColors)
                        _ColorCircle(
                          key: ValueKey<String>(
                            'accent-color-${option.name.toLowerCase()}',
                          ),
                          option: option,
                          isSelected:
                              themeState.accentColorHex.toUpperCase() ==
                                  option.hex.toUpperCase() ||
                              themeState.accentColor.toARGB32() ==
                                  option.color.toARGB32(),
                          onTap: () {
                            themeNotifier.setAccentColor(
                              option.color,
                              option.hex,
                            );
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space32),
            Text(
              'PREVIEW',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: AppSpacing.space12),
            AppSurfaceCard(
              padding: const EdgeInsets.all(AppSpacing.space20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 20,
                          color: AppColors.onPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space12),
                      Expanded(
                        child: Text(
                          'Checkmark & Buttons Active',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: 0.72,
                      minHeight: 8,
                      color: AppColors.primary,
                      backgroundColor: AppColors.progressTrack,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space20),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Primary Button Preview'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorCircle extends StatelessWidget {
  const _ColorCircle({
    required this.option,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final AccentColorOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isWhite =
        option.color.toARGB32() == const Color(0xFFFFFFFF).toARGB32();
    final checkColor = (option.color.computeLuminance() > 0.5)
        ? Colors.black
        : Colors.white;

    return Semantics(
      button: true,
      label: '${option.name} accent color',
      selected: isSelected,
      child: Tooltip(
        message: option.name,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: option.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? (isWhite && !AppColors.isDark
                          ? Colors.black
                          : AppColors.textPrimary)
                    : (isWhite ? AppColors.borderStrong : Colors.transparent),
                width: isSelected ? 3.0 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: option.color.withValues(alpha: 0.45),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: isSelected
                  ? Icon(
                      Icons.check_rounded,
                      key: const ValueKey<bool>(true),
                      size: 22,
                      color: checkColor,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppearanceSegment extends StatelessWidget {
  const _AppearanceSegment({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: '$title appearance mode',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
