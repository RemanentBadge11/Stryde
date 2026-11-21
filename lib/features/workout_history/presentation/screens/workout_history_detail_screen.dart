import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_spacing.dart';
import 'package:stryde/core/widgets/app_surface_card.dart';
import 'package:stryde/core/widgets/empty_state_card.dart';
import 'package:stryde/features/workout_history/domain/entities/completed_workout.dart';
import 'package:stryde/features/workout_history/presentation/providers/workout_history_provider.dart';
import 'package:stryde/features/workout_history/presentation/workout_formatters.dart';

class WorkoutHistoryDetailScreen extends ConsumerWidget {
  const WorkoutHistoryDetailScreen({required this.workoutId, super.key});

  final String workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(workoutHistoryProvider);
    CompletedWorkout? workout;
    for (final item in history) {
      if (item.id == workoutId) {
        workout = item;
        break;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text('Workout Details'),
      ),
      body: workout == null
          ? const Padding(
              padding: EdgeInsets.all(AppSpacing.space24),
              child: EmptyStateCard(
                icon: Icons.search_off_rounded,
                title: 'Workout unavailable',
                message: 'This in-memory session is no longer available.',
              ),
            )
          : _WorkoutDetails(workout: workout),
    );
  }
}

class _WorkoutDetails extends StatelessWidget {
  const _WorkoutDetails({required this.workout});

  final CompletedWorkout workout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space24,
        AppSpacing.space16,
        AppSpacing.space24,
        AppSpacing.space32,
      ),
      children: <Widget>[
        Text(
          workout.routineName,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: AppSpacing.space8),
        Text(
          formatWorkoutTimestamp(workout.completedAt),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.space24),
        Row(
          children: <Widget>[
            Expanded(
              child: _DetailMetric(
                value: '${workout.totalSets}',
                label: 'Sets',
              ),
            ),
            const SizedBox(width: AppSpacing.space8),
            Expanded(
              child: _DetailMetric(
                value: '${workout.totalReps}',
                label: 'Reps',
              ),
            ),
            const SizedBox(width: AppSpacing.space8),
            Expanded(
              child: _DetailMetric(
                value: workout.totalVolume.toStringAsFixed(0),
                label: 'kg volume',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space32),
        Text('Exercises', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.space12),
        for (var i = 0; i < workout.exercises.length; i++) ...<Widget>[
          _CompletedExerciseCard(exercise: workout.exercises[i]),
          if (i != workout.exercises.length - 1)
            const SizedBox(height: AppSpacing.space12),
        ],
      ],
    );
  }
}

class _DetailMetric extends StatelessWidget {
  const _DetailMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      radius: 14,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space12,
      ),
      child: Column(
        children: <Widget>[
          FittedBox(
            child: Text(value, style: Theme.of(context).textTheme.titleLarge),
          ),
          const SizedBox(height: AppSpacing.space4),
          FittedBox(
            child: Text(label, style: Theme.of(context).textTheme.labelSmall),
          ),
        ],
      ),
    );
  }
}

class _CompletedExerciseCard extends StatelessWidget {
  const _CompletedExerciseCard({required this.exercise});

  final CompletedWorkoutExercise exercise;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  exercise.exerciseName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '${exercise.sets.length} SETS',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textPrimary,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space12),
          const Divider(),
          for (final set in exercise.sets)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 42,
                    child: Text(
                      'SET ${set.setNumber}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${_formatWeight(set.weightKg)} kg',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${set.reps} reps',
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.titleSmall,
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

String _formatWeight(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(1);
}
