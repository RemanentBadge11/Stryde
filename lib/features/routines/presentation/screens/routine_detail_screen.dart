import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_spacing.dart';
import 'package:stryde/core/widgets/app_surface_card.dart';
import 'package:stryde/features/exercises/presentation/widgets/exercise_image.dart';
import 'package:stryde/features/routines/domain/entities/workout_routine.dart';

class RoutineDetailScreen extends StatelessWidget {
  const RoutineDetailScreen({required this.routine, super.key});

  final WorkoutRoutine routine;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text('Routine'),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space24,
            AppSpacing.space16,
            AppSpacing.space24,
            120,
          ),
          children: <Widget>[
            Text(routine.name, style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: AppSpacing.space8),
            Text(
              routine.focus,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.space16),
            Wrap(
              spacing: AppSpacing.space8,
              runSpacing: AppSpacing.space8,
              children: <Widget>[
                _MetaPill(
                  icon: Icons.fitness_center_rounded,
                  label:
                      '${routine.exercises.length} ${routine.exercises.length == 1 ? 'exercise' : 'exercises'}',
                ),
                _MetaPill(
                  icon: Icons.schedule_rounded,
                  label: '${routine.estimatedMinutes} min',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space32),
            Text(
              'Exercise Order',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.space12),
            for (var i = 0; i < routine.exercises.length; i++) ...<Widget>[
              _ExercisePreview(prescription: routine.exercises[i], index: i),
              if (i != routine.exercises.length - 1)
                const SizedBox(height: AppSpacing.space12),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.all(AppSpacing.space24),
        child: SizedBox(
          height: 56,
          child: FilledButton.icon(
            onPressed: () =>
                context.push('/workout/active/${routine.id}', extra: routine),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start This Routine'),
          ),
        ),
      ),
    );
  }
}

class _ExercisePreview extends StatelessWidget {
  const _ExercisePreview({required this.prescription, required this.index});

  final RoutineExercise prescription;
  final int index;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Row(
        children: <Widget>[
          ExerciseImage(
            imageUrl: prescription.exercise.imageUrl,
            semanticLabel: prescription.exercise.name,
            width: 68,
            height: 58,
            borderRadius: 12,
          ),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${index + 1}. ${prescription.exercise.name}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  '${prescription.exercise.primaryMuscle} · ${prescription.targetSets} × ${prescription.targetReps}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.drag_handle_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

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
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.space8),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}
