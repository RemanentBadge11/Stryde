import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/theme_preset.dart';
import 'package:stryde/features/settings/presentation/providers/theme_provider.dart';

/// Single horizontal row selector for the eight theme presets.
/// Exactly 4 presets are visible simultaneously on a standard viewport.
/// 8 items total, swipeable, gesture-driven only (no arrows, dots, or scrollbars).
class ThemePresetSelector extends ConsumerWidget {
  const ThemePresetSelector({super.key});

  static const double _itemSpacing = 8.0;
  static const int _visibleCount = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final selectedPreset = themeState.preset;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Guarantee exactly 4 items visible simultaneously within available width
        final availableWidth = constraints.maxWidth;
        final itemWidth =
            (availableWidth - ((_visibleCount - 1) * _itemSpacing)) /
            _visibleCount;

        return SizedBox(
          height: 104,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: ListView.separated(
              key: const ValueKey<String>('theme-preset-list'),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: kThemePresets.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: _itemSpacing),
              itemBuilder: (context, index) {
                final preset = kThemePresets[index];
                final isSelected = selectedPreset?.id == preset.id;

                return _ThemePresetCard(
                  key: ValueKey<String>('theme-preset-${preset.id}'),
                  preset: preset,
                  isSelected: isSelected,
                  width: itemWidth,
                  onTap: () {
                    ref.read(themeProvider.notifier).setThemePreset(preset);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _ThemePresetCard extends StatelessWidget {
  const _ThemePresetCard({
    required this.preset,
    required this.isSelected,
    required this.width,
    required this.onTap,
    super.key,
  });

  final ThemePreset preset;
  final bool isSelected;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final neutralBorder = AppColors.isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.12);

    return Semantics(
      button: true,
      label: '${preset.name} theme preset',
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Outer container (Background)
              Container(
                width: width,
                height: 72,
                decoration: BoxDecoration(
                  color: preset.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? preset.accent : neutralBorder,
                    width: 1.5,
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          // Miniature progression card (Surface)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 3,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: preset.surface,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Flexible(
                                      child: Text(
                                        'Level 24',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: preset.text,
                                          fontSize: 6.5,
                                          fontWeight: FontWeight.bold,
                                          height: 1.0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'Ascendant',
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: preset.accent,
                                        fontSize: 5.5,
                                        fontWeight: FontWeight.w600,
                                        height: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                // Miniature XP progress bar (Track=Background, Fill=Accent, static 65%)
                                Container(
                                  height: 2.5,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: preset.background,
                                    borderRadius: BorderRadius.circular(1.5),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: 0.65,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: preset.accent,
                                        borderRadius: BorderRadius.circular(
                                          1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Miniature rounded horizontal rectangle (Accent, decorative workout button)
                          Container(
                            height: 5,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: preset.accent,
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                          // Four circular swatches (Background, Surface, Accent, Text)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              _buildSwatch(
                                preset.background,
                                borderColor: preset.text.withValues(
                                  alpha: 0.35,
                                ),
                              ),
                              const SizedBox(width: 2.5),
                              _buildSwatch(
                                preset.surface,
                                borderColor: preset.text.withValues(
                                  alpha: 0.20,
                                ),
                              ),
                              const SizedBox(width: 2.5),
                              _buildSwatch(preset.accent),
                              const SizedBox(width: 2.5),
                              _buildSwatch(preset.text),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Checkmark in upper-right corner when selected
                    if (isSelected)
                      Positioned(
                        top: 3,
                        right: 3,
                        child: Container(
                          padding: const EdgeInsets.all(1.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: preset.accent,
                          ),
                          child: Icon(
                            Icons.check,
                            size: 7,
                            color: preset.onAccent,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // Centered theme name underneath
              Text(
                preset.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? preset.accent : AppColors.textPrimary,
                  fontSize: 9.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwatch(Color color, {Color? borderColor}) {
    return Container(
      width: 6.5,
      height: 6.5,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: borderColor != null
            ? Border.all(color: borderColor, width: 0.5)
            : null,
      ),
    );
  }
}
