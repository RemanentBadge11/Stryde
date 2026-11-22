import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_spacing.dart';
import 'package:stryde/core/widgets/app_surface_card.dart';
import 'package:stryde/features/routines/data/mock_workout_data.dart';
import 'package:stryde/features/routines/domain/entities/workout_routine.dart';
import 'package:stryde/features/routines/presentation/providers/custom_routines_provider.dart';

class TrainScreen extends ConsumerWidget {
  const TrainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(allRoutinesProvider);

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
            Text('Train', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: AppSpacing.space8),
            Text(
              'Choose a plan or build the session live.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.space24),
            _FreeTrainingCard(
              onTap: () => context.push(
                '/workout/active/free-training',
                extra: MockWorkoutData.freeTraining,
              ),
            ),
            const SizedBox(height: AppSpacing.space12),
            Row(
              children: <Widget>[
                Expanded(
                  child: _TrainActionCard(
                    icon: Icons.menu_book_rounded,
                    label: 'Exercise Library',
                    onTap: () => context.push('/exercises'),
                  ),
                ),
                const SizedBox(width: AppSpacing.space12),
                Expanded(
                  child: _TrainActionCard(
                    icon: Icons.add_rounded,
                    label: 'Create Routine',
                    onTap: () => context.push('/routines/create'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space32),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'My Routines',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Text(
                  '${routines.length} routines',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space12),
            for (var i = 0; i < routines.length; i++) ...<Widget>[
              _RoutineCard(routine: routines[i], index: i),
              if (i != routines.length - 1)
                const SizedBox(height: AppSpacing.space12),
            ],
          ],
        ),
      ),
    );
  }
}

class _FreeTrainingCard extends StatelessWidget {
  const _FreeTrainingCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.space24),
      child: Row(
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              color: AppColors.onPrimary,
              size: 30,
            ),
          ),
          const SizedBox(width: AppSpacing.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Start Empty Workout',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  'Free training · Add exercises as you go',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_rounded, color: AppColors.textPrimary),
        ],
      ),
    );
  }
}

class _TrainActionCard extends StatelessWidget {
  const _TrainActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      radius: 16,
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: AppColors.textPrimary),
          const SizedBox(height: AppSpacing.space12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label, style: Theme.of(context).textTheme.titleSmall),
          ),
        ],
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({required this.routine, required this.index});

  final WorkoutRoutine routine;
  final int index;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      onTap: () => context.push('/train/routine/${routine.id}', extra: routine),
      padding: const EdgeInsets.all(AppSpacing.space24),
      child: Row(
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}'.padLeft(2, '0'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        routine.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    if (routine.isCustom) ...<Widget>[
                      const SizedBox(width: AppSpacing.space8),
                      Text(
                        'CUSTOM',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textPrimary,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  routine.focus,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.space8),
                Text(
                  '${routine.exercises.length} ${routine.exercises.length == 1 ? 'exercise' : 'exercises'}  ·  ${routine.estimatedMinutes} min',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.space12),
          Icon(Icons.arrow_forward_rounded, color: AppColors.textPrimary),
        ],
      ),
    );
  }
}
