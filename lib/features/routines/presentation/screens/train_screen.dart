import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_spacing.dart';
import 'package:stryde/core/widgets/app_surface_card.dart';
import 'package:stryde/features/routines/data/mock_workout_data.dart';
import 'package:stryde/features/routines/domain/entities/mastery_routine_definition.dart';
import 'package:stryde/features/routines/domain/entities/workout_routine.dart';
import 'package:stryde/features/routines/presentation/providers/custom_routines_provider.dart';
import 'package:stryde/features/routines/presentation/providers/mastery_routines_provider.dart';

class TrainScreen extends ConsumerWidget {
  const TrainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(allRoutinesProvider);
    final masteryItems = ref.watch(masteryRoutinesProvider);
    final unlockedCount = masteryItems.where((i) => i.isUnlocked).length;
    final sortedMasteryItems = List<MasteryRoutineItem>.of(masteryItems)
      ..sort((a, b) {
        if (a.isUnlocked && !b.isUnlocked) return -1;
        if (!a.isUnlocked && b.isUnlocked) return 1;
        return 0;
      });

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
            const SizedBox(height: AppSpacing.space32),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Skill Mastery',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppSpacing.space4),
                      Text(
                        'Personalized plans unlocked by skill points',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: unlockedCount > 0
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: unlockedCount > 0
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : AppColors.border,
                    ),
                  ),
                  child: Text(
                    '$unlockedCount/${masteryItems.length} unlocked',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: unlockedCount > 0
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space12),
            for (var i = 0; i < sortedMasteryItems.length; i++) ...<Widget>[
              _MasteryRoutineCard(item: sortedMasteryItems[i]),
              if (i != sortedMasteryItems.length - 1)
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
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 20),
          ),
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
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          child: Text(
                            'CUSTOM',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  letterSpacing: 0.6,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 9,
                                ),
                          ),
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

class _MasteryRoutineCard extends StatelessWidget {
  const _MasteryRoutineCard({required this.item});

  final MasteryRoutineItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnlocked = item.isUnlocked;

    return AppSurfaceCard(
      onTap: isUnlocked
          ? () => context.push(
              '/train/routine/${item.routine.id}',
              extra: item.routine,
            )
          : () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Locked · ${item.requirementsDescription}'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
      padding: const EdgeInsets.all(AppSpacing.space20),
      child: Row(
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUnlocked
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : AppColors.border,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              isUnlocked
                  ? Icons.workspace_premium_rounded
                  : Icons.lock_outline_rounded,
              color: isUnlocked ? AppColors.primary : AppColors.textSecondary,
              size: 26,
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
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isUnlocked
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space8),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: isUnlocked
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : AppColors.border,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        child: Text(
                          isUnlocked ? 'UNLOCKED' : 'LOCKED',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isUnlocked
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            letterSpacing: 0.6,
                            fontWeight: FontWeight.w700,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  item.focus,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isUnlocked
                        ? AppColors.textSecondary
                        : AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: AppSpacing.space6),
                if (isUnlocked)
                  Text(
                    '${item.routine.exercises.length} exercises  ·  ${item.routine.estimatedMinutes} min',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.info_outline_rounded,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.space4),
                      Expanded(
                        child: Text(
                          item.requirementsDescription,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.space12),
          Icon(
            isUnlocked
                ? Icons.arrow_forward_rounded
                : Icons.lock_outline_rounded,
            color: isUnlocked
                ? AppColors.textPrimary
                : AppColors.textSecondary.withValues(alpha: 0.5),
            size: 20,
          ),
        ],
      ),
    );
  }
}
