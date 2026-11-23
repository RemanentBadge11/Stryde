import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_spacing.dart';
import 'package:stryde/core/theme/app_typography.dart';
import 'package:stryde/core/widgets/app_surface_card.dart';
import 'package:stryde/features/workout_history/domain/entities/completed_workout.dart';
import 'package:stryde/features/workout_history/presentation/workout_formatters.dart';

class WorkoutHistoryCard extends StatelessWidget {
  const WorkoutHistoryCard({required this.workout, this.onTap, super.key});

  final CompletedWorkout workout;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(
                  Icons.fitness_center_rounded,
                  size: 19,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      workout.routineName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatWorkoutTimestamp(workout.completedAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.space12),
          Row(
            children: <Widget>[
              _Metric(
                icon: Icons.check_rounded,
                label: '${workout.totalSets} sets',
              ),
              const SizedBox(width: AppSpacing.space16),
              _Metric(
                icon: Icons.schedule_rounded,
                label: formatWorkoutDuration(workout.duration),
              ),
              const SizedBox(width: AppSpacing.space16),
              _Metric(
                icon: Icons.monitor_weight_outlined,
                label: '${workout.totalVolume.toStringAsFixed(0)} kg',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontFeatures: AppTypography.tabularFontFeatures,
          ),
        ),
      ],
    );
  }
}
