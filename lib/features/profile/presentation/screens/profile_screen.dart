import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_spacing.dart';
import 'package:stryde/core/widgets/app_surface_card.dart';
import 'package:stryde/core/widgets/section_header.dart';
import 'package:stryde/features/profile/presentation/providers/profile_goals_provider.dart';
import 'package:stryde/features/progression/presentation/providers/user_progression_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(profileGoalsProvider);
    final progression = ref.watch(userProgressionProvider);
    final notifier = ref.read(profileGoalsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space24,
            AppSpacing.space24,
            AppSpacing.space24,
            AppSpacing.space32,
          ),
          children: <Widget>[
            Text('Profile', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: AppSpacing.space8),
            Text(
              'Set the targets that shape your habits.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.space24),
            _IdentityCard(
              level: progression.currentLevel,
              rank: progression.rankTitle,
              skillPoints: progression.skillPoints,
            ),
            const SizedBox(height: AppSpacing.space32),
            SectionHeader(
              title: 'Goals',
              subtitle: 'These values feed your Habits on Home.',
            ),
            const SizedBox(height: AppSpacing.space12),
            AppSurfaceCard(
              padding: const EdgeInsets.all(AppSpacing.space16),
              child: Column(
                children: <Widget>[
                  _GoalStepper(
                    icon: Icons.directions_walk_rounded,
                    label: 'Daily Steps',
                    value: _formatNumber(goals.steps),
                    unit: 'steps',
                    onDecrease: () => notifier.adjustSteps(
                      -ProfileGoalsNotifier.stepIncrement,
                    ),
                    onIncrease: () => notifier.adjustSteps(
                      ProfileGoalsNotifier.stepIncrement,
                    ),
                  ),
                  const Divider(),
                  _GoalStepper(
                    icon: Icons.water_drop_outlined,
                    label: 'Daily Water',
                    value: _formatWater(goals.waterLiters),
                    unit: 'liters',
                    onDecrease: () => notifier.adjustWater(
                      -ProfileGoalsNotifier.waterIncrement,
                    ),
                    onIncrease: () => notifier.adjustWater(
                      ProfileGoalsNotifier.waterIncrement,
                    ),
                  ),
                  const Divider(),
                  _GoalStepper(
                    icon: Icons.restaurant_outlined,
                    label: 'Daily Protein',
                    value: '${goals.proteinGrams}',
                    unit: 'grams',
                    onDecrease: () => notifier.adjustProtein(
                      -ProfileGoalsNotifier.proteinIncrement,
                    ),
                    onIncrease: () => notifier.adjustProtein(
                      ProfileGoalsNotifier.proteinIncrement,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space24),
            AppSurfaceCard(
              radius: 16,
              padding: const EdgeInsets.all(AppSpacing.space16),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.space12),
                  Expanded(
                    child: Text(
                      'Everything is in memory. Closing Stryde resets your goals, XP, and history.',
                      style: Theme.of(context).textTheme.bodySmall,
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

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.level,
    required this.rank,
    required this.skillPoints,
  });

  final int level;
  final String rank;
  final int skillPoints;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.space24),
      child: Row(
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.person_rounded,
              size: 34,
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Stryder',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  'Level $level · $rank',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.space8),
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.bolt_rounded,
                      size: 15,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      skillPoints == 1
                          ? '1 skill point'
                          : '$skillPoints skill points',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalStepper extends StatelessWidget {
  const _GoalStepper({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.onDecrease,
    required this.onIncrease,
  });

  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space12),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, size: 19, color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  '$value $unit',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          _StepButton(
            icon: Icons.remove_rounded,
            tooltip: 'Decrease $label',
            onPressed: onDecrease,
          ),
          const SizedBox(width: AppSpacing.space8),
          _StepButton(
            icon: Icons.add_rounded,
            tooltip: 'Increase $label',
            onPressed: onIncrease,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        minimumSize: const Size(38, 38),
        maximumSize: const Size(38, 38),
        backgroundColor: AppColors.surfaceVariant,
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border),
      ),
      icon: Icon(icon, size: 19),
    );
  }
}

String _formatNumber(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

String _formatWater(double value) => value == value.roundToDouble()
    ? value.toStringAsFixed(0)
    : value.toStringAsFixed(1);
