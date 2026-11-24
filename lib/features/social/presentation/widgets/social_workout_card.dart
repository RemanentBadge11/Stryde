import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_spacing.dart';
import 'package:stryde/core/theme/app_typography.dart';
import 'package:stryde/core/widgets/app_surface_card.dart';
import 'package:stryde/features/social/domain/entities/social_post.dart';
import 'package:stryde/features/social/presentation/widgets/social_author_header.dart';
import 'package:stryde/features/workout_history/presentation/workout_formatters.dart';

class SocialWorkoutCard extends StatelessWidget {
  const SocialWorkoutCard({required this.post, super.key});

  final SocialPost post;

  @override
  Widget build(BuildContext context) {
    final workout = post.workoutData;
    if (workout == null) return const SizedBox.shrink();

    final exercises = workout.exercisesSummary;
    final prs = workout.prExercises;

    return AppSurfaceCard(
      onTap: () {
        context.push('/social/workout/${post.id}', extra: post);
      },
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Author Header: [Username] [Level] [Rank SVG]
          SocialAuthorHeader(
            author: post.author,
            subtitle: Text(
              formatWorkoutTimestamp(workout.completedAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space12),

          // Workout Name
          Text(
            workout.routineName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.space12),

          // Metric Chips (Only display stats that actually exist)
          Wrap(
            spacing: AppSpacing.space8,
            runSpacing: AppSpacing.space8,
            children: <Widget>[
              if (workout.durationSeconds > 0)
                _StatChip(
                  icon: Icons.timer_outlined,
                  label: _formatDuration(workout.duration),
                ),
              if (workout.totalVolumeKg > 0)
                _StatChip(
                  icon: Icons.fitness_center_rounded,
                  label:
                      '${workout.totalVolumeKg.toStringAsFixed(0)} kg volume',
                ),
              if (workout.totalSets > 0)
                _StatChip(
                  icon: Icons.layers_outlined,
                  label:
                      '${workout.totalSets} ${workout.totalSets == 1 ? 'set' : 'sets'}',
                ),
              if (workout.totalReps > 0)
                _StatChip(
                  icon: Icons.repeat_rounded,
                  label: '${workout.totalReps} reps',
                ),
            ],
          ),

          // PR Achievements (if applicable)
          if (prs.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.space12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space12,
                vertical: AppSpacing.space8,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.emoji_events_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.space8),
                  Expanded(
                    child: Text(
                      'PR Achieved: ${prs.join(', ')}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Exercise Summary Preview
          if (exercises.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.space12),
            Text(
              exercises.join(' · '),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${duration.inMinutes}m';
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontFeatures: AppTypography.tabularFontFeatures,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
