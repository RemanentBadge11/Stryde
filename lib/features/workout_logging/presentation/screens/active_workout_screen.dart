import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_spacing.dart';
import 'package:stryde/core/widgets/app_surface_card.dart';
import 'package:stryde/core/widgets/empty_state_card.dart';
import 'package:stryde/features/exercises/presentation/widgets/exercise_image.dart';
import 'package:stryde/features/exercises/presentation/widgets/exercise_picker_sheet.dart';
import 'package:stryde/features/routines/domain/entities/workout_routine.dart';
import 'package:stryde/features/routines/presentation/widgets/exercise_target_sheet.dart';
import 'package:stryde/features/workout_logging/presentation/providers/active_workout_provider.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({required this.routine, super.key});

  final WorkoutRoutine routine;

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  var _isFinishing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = ref.read(activeWorkoutProvider.notifier);
      if (ref.read(activeWorkoutProvider).isOngoing) {
        notifier.resumeWorkout();
      } else {
        notifier.startWorkout(widget.routine);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final workoutState = ref.watch(activeWorkoutProvider);
    final session = workoutState.session;
    if (session == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: SizedBox.shrink(),
      );
    }

    final exerciseDrafts = session.exercises;
    final restSecondsRemaining = workoutState.restSecondsRemaining;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          ref.read(activeWorkoutProvider.notifier).minimizeWorkout();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          titleSpacing: 4,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Active Workout'),
              Text(
                session.routine.name,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
          actions: <Widget>[
            _WorkoutAppBarAction(
              tooltip: 'Finish workout',
              icon: Icons.check_rounded,
              backgroundColor: Colors.green,
              foregroundColor: Colors.black,
              onPressed: _isFinishing ? null : _finishWorkout,
            ),
            const SizedBox(width: AppSpacing.space8),
            _WorkoutAppBarAction(
              tooltip: 'Discard workout',
              icon: Icons.delete_outline_rounded,
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              onPressed: _isFinishing ? null : _discardWorkout,
            ),
            const SizedBox(width: AppSpacing.space12),
          ],
        ),
        body: Stack(
          children: <Widget>[
            ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space16,
                AppSpacing.space16,
                AppSpacing.space16,
                164,
              ),
              children: <Widget>[
                _WorkoutElapsedCard(
                  elapsed: workoutState.elapsed,
                  isPaused: workoutState.isPaused,
                  onToggleTimer: () =>
                      ref.read(activeWorkoutProvider.notifier).toggleTimer(),
                ),
                const SizedBox(height: AppSpacing.space16),
                _WorkoutHeader(
                  routine: session.routine,
                  exerciseCount: exerciseDrafts.length,
                ),
                const SizedBox(height: AppSpacing.space16),
                if (exerciseDrafts.isEmpty) ...<Widget>[
                  const EmptyStateCard(
                    icon: Icons.add_circle_outline_rounded,
                    title: 'Empty workout',
                    message:
                        'Add an exercise from the library to begin free training.',
                  ),
                  const SizedBox(height: AppSpacing.space16),
                ],
                for (var i = 0; i < exerciseDrafts.length; i++) ...<Widget>[
                  _ExerciseLoggerCard(
                    draft: exerciseDrafts[i],
                    exerciseIndex: i,
                    onAddSet: () =>
                        ref.read(activeWorkoutProvider.notifier).addSet(i),
                    onClearSets: () =>
                        ref.read(activeWorkoutProvider.notifier).clearSets(i),
                    onRemoveExercise: () => _removeExercise(i),
                    onDuplicateSet: (setIndex) => ref
                        .read(activeWorkoutProvider.notifier)
                        .duplicateSet(i, setIndex),
                    onDeleteSet: (setIndex) => ref
                        .read(activeWorkoutProvider.notifier)
                        .deleteSet(i, setIndex),
                    onCompleteSet: (setIndex) => _completeSet(i, setIndex),
                    onWeightChanged: (setIndex, value) {
                      ref
                          .read(activeWorkoutProvider.notifier)
                          .updateWeight(i, setIndex, value);
                    },
                    onRepsChanged: (setIndex, value) {
                      ref
                          .read(activeWorkoutProvider.notifier)
                          .updateReps(i, setIndex, value);
                    },
                  ),
                  if (i != exerciseDrafts.length - 1)
                    const SizedBox(height: AppSpacing.space16),
                ],
                if (exerciseDrafts.isNotEmpty)
                  const SizedBox(height: AppSpacing.space16),
                SizedBox(
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: _addExercise,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Exercise'),
                  ),
                ),
              ],
            ),
            Positioned(
              left: AppSpacing.space16,
              right: AppSpacing.space16,
              bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.space16,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                transitionBuilder: (child, animation) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.35),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: restSecondsRemaining == null
                    ? const SizedBox.shrink(key: ValueKey<String>('no-timer'))
                    : _RestTimerCard(
                        key: const ValueKey<String>('rest-timer'),
                        secondsRemaining: restSecondsRemaining,
                        onSkip: _skipRest,
                        onAddTime: _addRestTime,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addExercise() async {
    final session = ref.read(activeWorkoutProvider).session;
    if (session == null) return;
    final selected = await showExercisePickerSheet(
      context,
      excludedExerciseIds: session.exercises
          .map((draft) => draft.exercise.id)
          .toSet(),
    );
    if (selected == null || !mounted) return;
    final prescription = await showExerciseTargetSheet(context, selected);
    if (prescription == null || !mounted) return;
    ref.read(activeWorkoutProvider.notifier).addExercise(prescription);
  }

  void _removeExercise(int index) {
    ref.read(activeWorkoutProvider.notifier).removeExercise(index);
  }

  void _completeSet(int exerciseIndex, int setIndex) {
    final result = ref
        .read(activeWorkoutProvider.notifier)
        .toggleSetCompletion(exerciseIndex, setIndex);
    if (result == SetCompletionResult.invalid) {
      _showMessage('Enter a valid weight and rep count first.');
    } else if (result == SetCompletionResult.completed) {
      FocusScope.of(context).unfocus();
    }
  }

  void _skipRest() {
    ref.read(activeWorkoutProvider.notifier).skipRestTimer();
  }

  void _addRestTime() {
    ref.read(activeWorkoutProvider.notifier).addRestTime();
  }

  Future<void> _finishWorkout() async {
    final session = ref.read(activeWorkoutProvider).session;
    if (session == null) return;

    setState(() => _isFinishing = true);
    final result = ref.read(activeWorkoutProvider.notifier).finishWorkout();
    if (result == null) return;

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          title: Text(
            result.newLevel > result.previousLevel
                ? 'Level Up'
                : result.xpAwarded > 0
                ? 'Workout Complete'
                : 'Workout Saved',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  result.newLevel > result.previousLevel
                      ? Icons.arrow_upward_rounded
                      : Icons.check_rounded,
                  color: AppColors.onPrimary,
                  size: 34,
                ),
              ),
              const SizedBox(height: AppSpacing.space16),
              Text(
                result.newLevel > result.previousLevel
                    ? 'Level ${result.newLevel} reached. +${result.xpAwarded} XP earned.'
                    : result.completedDailyGoals > 0
                    ? '+${result.xpAwarded} workout XP earned, ${result.completedDailyGoals} Daily Goal${result.completedDailyGoals == 1 ? '' : 's'} completed, and the session was added to Stats.'
                    : result.xpAwarded > 0
                    ? '+${result.xpAwarded} XP earned and session added to Stats.'
                    : 'Session saved with 0 XP. Complete at least one set to earn workout XP.',
                textAlign: TextAlign.center,
                style: Theme.of(dialogContext).textTheme.bodyMedium,
              ),
            ],
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Back Home'),
            ),
          ],
        ),
      ),
    );

    if (mounted) context.go('/');
  }

  void _discardWorkout() {
    setState(() => _isFinishing = true);
    final discarded = ref.read(activeWorkoutProvider.notifier).discardWorkout();
    if (!discarded) return;
    context.go('/');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.surfaceVariant,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _WorkoutAppBarAction extends StatelessWidget {
  const _WorkoutAppBarAction({
    required this.tooltip,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        style: IconButton.styleFrom(
          fixedSize: const Size(40, 40),
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: AppColors.surface,
          disabledForegroundColor: AppColors.textMuted,
          side: BorderSide(color: backgroundColor),
          shape: const CircleBorder(),
        ),
        icon: Icon(icon, size: 21),
      ),
    );
  }
}

class _WorkoutElapsedCard extends StatelessWidget {
  const _WorkoutElapsedCard({
    required this.elapsed,
    required this.isPaused,
    required this.onToggleTimer,
  });

  final Duration elapsed;
  final bool isPaused;
  final VoidCallback onToggleTimer;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space12,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(
              isPaused ? Icons.pause_rounded : Icons.timer_outlined,
              color: AppColors.textPrimary,
              size: 21,
            ),
          ),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  isPaused ? 'WORKOUT PAUSED' : 'WORKOUT TIME',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(letterSpacing: 0.6),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatElapsed(elapsed),
                  key: const ValueKey<String>('active-screen-workout-elapsed'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Tooltip(
            message: isPaused ? 'Resume workout timer' : 'Pause workout timer',
            child: IconButton(
              onPressed: onToggleTimer,
              style: IconButton.styleFrom(
                fixedSize: const Size(42, 42),
                backgroundColor: AppColors.surfaceVariant,
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.borderStrong),
                shape: const CircleBorder(),
              ),
              icon: Icon(
                isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                size: 21,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatElapsed(Duration elapsed) {
  final totalSeconds = elapsed.inSeconds < 0 ? 0 : elapsed.inSeconds;
  final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
  final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}

class _WorkoutHeader extends StatelessWidget {
  const _WorkoutHeader({required this.routine, required this.exerciseCount});

  final WorkoutRoutine routine;
  final int exerciseCount;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  routine.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  routine.focus,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '$exerciseCount ${exerciseCount == 1 ? 'EXERCISE' : 'EXERCISES'}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseLoggerCard extends StatelessWidget {
  const _ExerciseLoggerCard({
    required this.draft,
    required this.exerciseIndex,
    required this.onAddSet,
    required this.onClearSets,
    required this.onRemoveExercise,
    required this.onDuplicateSet,
    required this.onDeleteSet,
    required this.onCompleteSet,
    required this.onWeightChanged,
    required this.onRepsChanged,
  });

  final ActiveWorkoutExercise draft;
  final int exerciseIndex;
  final VoidCallback onAddSet;
  final VoidCallback onClearSets;
  final VoidCallback onRemoveExercise;
  final ValueChanged<int> onDuplicateSet;
  final ValueChanged<int> onDeleteSet;
  final ValueChanged<int> onCompleteSet;
  final void Function(int index, String value) onWeightChanged;
  final void Function(int index, String value) onRepsChanged;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                ExerciseImage(
                  imageUrl: draft.exercise.imageUrl,
                  semanticLabel: draft.exercise.name,
                  width: 52,
                  height: 44,
                  borderRadius: 12,
                ),
                const SizedBox(width: AppSpacing.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        draft.exercise.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${exerciseIndex + 1}. ${draft.exercise.primaryMuscle}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<_ExerciseMenuAction>(
                  color: AppColors.surfaceElevated,
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    color: AppColors.textPrimary,
                  ),
                  onSelected: (action) {
                    switch (action) {
                      case _ExerciseMenuAction.addSet:
                        onAddSet();
                      case _ExerciseMenuAction.clearSets:
                        onClearSets();
                      case _ExerciseMenuAction.removeExercise:
                        onRemoveExercise();
                    }
                  },
                  itemBuilder: (context) =>
                      const <PopupMenuEntry<_ExerciseMenuAction>>[
                        PopupMenuItem(
                          value: _ExerciseMenuAction.addSet,
                          child: Text('Add set'),
                        ),
                        PopupMenuItem(
                          value: _ExerciseMenuAction.clearSets,
                          child: Text('Reset exercise'),
                        ),
                        PopupMenuItem(
                          value: _ExerciseMenuAction.removeExercise,
                          child: Text('Remove exercise'),
                        ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space16),
            const Divider(),
            const SizedBox(height: AppSpacing.space12),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 42,
                  child: Text(
                    'SET',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                const SizedBox(width: AppSpacing.space8),
                Expanded(
                  child: Text(
                    'WEIGHT (KG)',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                const SizedBox(width: AppSpacing.space8),
                Expanded(
                  child: Text(
                    'REPS',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                const SizedBox(width: AppSpacing.space8),
                const SizedBox(width: 42),
              ],
            ),
            const SizedBox(height: AppSpacing.space8),
            for (var i = 0; i < draft.sets.length; i++) ...<Widget>[
              _SetRow(
                key: ValueKey<int>(draft.sets[i].id),
                set: draft.sets[i],
                displayNumber: i + 1,
                exerciseName: draft.exercise.name,
                onDuplicate: () => onDuplicateSet(i),
                onDelete: () => onDeleteSet(i),
                onComplete: () => onCompleteSet(i),
                onWeightChanged: (value) => onWeightChanged(i, value),
                onRepsChanged: (value) => onRepsChanged(i, value),
              ),
              if (i != draft.sets.length - 1)
                const SizedBox(height: AppSpacing.space8),
            ],
            const SizedBox(height: AppSpacing.space12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onAddSet,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Set'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({
    required this.set,
    required this.displayNumber,
    required this.exerciseName,
    required this.onDuplicate,
    required this.onDelete,
    required this.onComplete,
    required this.onWeightChanged,
    required this.onRepsChanged,
    super.key,
  });

  final ActiveWorkoutSet set;
  final int displayNumber;
  final String exerciseName;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final VoidCallback onComplete;
  final ValueChanged<String> onWeightChanged;
  final ValueChanged<String> onRepsChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 42,
          height: 42,
          child: PopupMenuButton<_SetMenuAction>(
            color: AppColors.surfaceElevated,
            tooltip: 'Set $displayNumber menu',
            onSelected: (action) {
              switch (action) {
                case _SetMenuAction.duplicate:
                  onDuplicate();
                case _SetMenuAction.delete:
                  onDelete();
              }
            },
            itemBuilder: (context) => const <PopupMenuEntry<_SetMenuAction>>[
              PopupMenuItem(
                value: _SetMenuAction.duplicate,
                child: Text('Duplicate set'),
              ),
              PopupMenuItem(
                value: _SetMenuAction.delete,
                child: Text('Delete set'),
              ),
            ],
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: set.isCompleted
                    ? AppColors.primary
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: set.isCompleted ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Center(
                child: Text(
                  '$displayNumber',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: set.isCompleted
                        ? AppColors.onPrimary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.space8),
        Expanded(
          child: _SetInput(
            initialValue: set.weightText,
            hintText: '0',
            readOnly: set.isCompleted,
            decimal: true,
            onChanged: onWeightChanged,
          ),
        ),
        const SizedBox(width: AppSpacing.space8),
        Expanded(
          child: _SetInput(
            initialValue: set.repsText,
            hintText: '0',
            readOnly: set.isCompleted,
            onChanged: onRepsChanged,
          ),
        ),
        const SizedBox(width: AppSpacing.space8),
        Tooltip(
          message: set.isCompleted
              ? 'Uncheck set $displayNumber for $exerciseName'
              : 'Complete set $displayNumber for $exerciseName',
          child: IconButton(
            onPressed: onComplete,
            style: IconButton.styleFrom(
              minimumSize: const Size(42, 42),
              maximumSize: const Size(42, 42),
              backgroundColor: set.isCompleted
                  ? AppColors.primary
                  : AppColors.surfaceVariant,
              foregroundColor: set.isCompleted
                  ? AppColors.onPrimary
                  : AppColors.textSecondary,
              side: BorderSide(
                color: set.isCompleted ? AppColors.primary : AppColors.border,
              ),
            ),
            icon: const Icon(Icons.check_rounded, size: 20),
          ),
        ),
      ],
    );
  }
}

class _SetInput extends StatelessWidget {
  const _SetInput({
    required this.initialValue,
    required this.hintText,
    required this.readOnly,
    required this.onChanged,
    this.decimal = false,
  });

  final String initialValue;
  final String hintText;
  final bool readOnly;
  final ValueChanged<String> onChanged;
  final bool decimal;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: TextFormField(
        initialValue: initialValue,
        readOnly: readOnly,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.numberWithOptions(decimal: decimal),
        style: Theme.of(context).textTheme.titleSmall,
        onChanged: onChanged,
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: readOnly
              ? AppColors.surfaceVariant.withValues(alpha: 0.65)
              : AppColors.surfaceVariant,
          hintText: hintText,
          hintStyle: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space8,
            vertical: AppSpacing.space12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _RestTimerCard extends StatelessWidget {
  const _RestTimerCard({
    required this.secondsRemaining,
    required this.onSkip,
    required this.onAddTime,
    super.key,
  });

  final int secondsRemaining;
  final VoidCallback onSkip;
  final VoidCallback onAddTime;

  @override
  Widget build(BuildContext context) {
    final minutes = secondsRemaining ~/ 60;
    final seconds = (secondsRemaining % 60).toString().padLeft(2, '0');

    return AppSurfaceCard(
      radius: 18,
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.timer_outlined, color: AppColors.onPrimary),
          ),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'REST TIMER',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  '$minutes:$seconds',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
          TextButton(onPressed: onSkip, child: const Text('Skip')),
          const SizedBox(width: AppSpacing.space4),
          FilledButton(onPressed: onAddTime, child: const Text('+15s')),
        ],
      ),
    );
  }
}

enum _ExerciseMenuAction { addSet, clearSets, removeExercise }

enum _SetMenuAction { duplicate, delete }
