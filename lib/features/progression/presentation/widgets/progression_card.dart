import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_spacing.dart';
import 'package:stryde/core/widgets/app_surface_card.dart';
import 'package:stryde/features/progression/domain/entities/user_progression.dart';

class ProgressionCard extends StatelessWidget {
  const ProgressionCard({
    required this.progression,
    this.onRankTap,
    this.onAssignSkills,
    super.key,
  });

  final UserProgression progression;
  final VoidCallback? onRankTap;
  final VoidCallback? onAssignSkills;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -16,
            top: 8,
            child: Transform.rotate(
              angle: -0.12,
              child: Icon(
                Icons.shield_outlined,
                size: 118,
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, animation) => ScaleTransition(
                        scale: Tween<double>(begin: 0.78, end: 1).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutBack,
                          ),
                        ),
                        child: FadeTransition(opacity: animation, child: child),
                      ),
                      child: _LevelPill(
                        key: ValueKey<String>(
                          '${progression.currentLevel}-${progression.levelUpRevision}',
                        ),
                        level: progression.currentLevel,
                      ),
                    ),
                    const Spacer(),
                    _SkillPointPill(points: progression.skillPoints),
                  ],
                ),
                const SizedBox(height: AppSpacing.space16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 360),
                  child: Text(
                    progression.rankTitle,
                    key: ValueKey<String>(progression.rankTitle),
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                const SizedBox(height: AppSpacing.space8),
                Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(
                        text: _formatNumber(progression.currentXp),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      TextSpan(
                        text:
                            ' / ${_formatNumber(progression.xpToNextLevel)} XP',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.space16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(end: progression.progress),
                    duration: const Duration(milliseconds: 720),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) => LinearProgressIndicator(
                      value: value,
                      minHeight: 8,
                      color: AppColors.primary,
                      backgroundColor: AppColors.progressTrack,
                      semanticsLabel: 'Level progress',
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.space16),
                _SkillPointRow(
                  points: progression.skillPoints,
                  onAssignSkills: onAssignSkills,
                ),
                const SizedBox(height: AppSpacing.space16),
                const Divider(),
                const SizedBox(height: AppSpacing.space8),
                InkWell(
                  onTap: onRankTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.space8,
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.military_tech_outlined,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.space8),
                        Expanded(
                          child: Text(
                            'Rank Progression',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        Text(
                          progression.currentLevel >= UserProgression.maxLevel
                              ? 'MAX LEVEL'
                              : '${_formatNumber(progression.xpRemaining)} XP to go',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: AppColors.textPrimary),
                        ),
                        const SizedBox(width: AppSpacing.space4),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelPill extends StatelessWidget {
  const _LevelPill({required this.level, super.key});

  final int level;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space12,
          vertical: AppSpacing.space8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.star_rounded, size: 18, color: AppColors.primary),
            const SizedBox(width: AppSpacing.space8),
            Text(
              'LEVEL $level',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(letterSpacing: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillPointPill extends StatelessWidget {
  const _SkillPointPill({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: points > 0 ? AppColors.primary : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: points > 0 ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space12,
          vertical: AppSpacing.space8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bolt_rounded,
              size: 16,
              color: points > 0 ? AppColors.onPrimary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.space4),
            Text(
              '$points',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: points > 0 ? AppColors.onPrimary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillPointRow extends StatelessWidget {
  const _SkillPointRow({required this.points, this.onAssignSkills});

  final int points;
  final VoidCallback? onAssignSkills;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space12,
        vertical: AppSpacing.space12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.auto_awesome_outlined,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.space8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'SKILL POINTS AVAILABLE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 0.6,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  points == 1 ? '1 point' : '$points points',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
          if (onAssignSkills != null)
            TextButton(onPressed: onAssignSkills, child: const Text('Assign')),
        ],
      ),
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
