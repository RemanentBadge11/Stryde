import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_spacing.dart';
import 'package:stryde/features/exercises/presentation/widgets/exercise_image.dart';
import 'package:stryde/features/routines/domain/entities/exercise.dart';
import 'package:stryde/features/routines/domain/entities/workout_routine.dart';

Future<RoutineExercise?> showExerciseTargetSheet(
  BuildContext context,
  Exercise exercise, {
  int initialSets = 3,
  int initialReps = 10,
}) {
  return showModalBottomSheet<RoutineExercise>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ExerciseTargetSheet(
      exercise: exercise,
      initialSets: initialSets,
      initialReps: initialReps,
    ),
  );
}

class _ExerciseTargetSheet extends StatefulWidget {
  const _ExerciseTargetSheet({
    required this.exercise,
    required this.initialSets,
    required this.initialReps,
  });

  final Exercise exercise;
  final int initialSets;
  final int initialReps;

  @override
  State<_ExerciseTargetSheet> createState() => _ExerciseTargetSheetState();
}

class _ExerciseTargetSheetState extends State<_ExerciseTargetSheet> {
  late int _sets;
  late int _reps;

  @override
  void initState() {
    super.initState();
    _sets = widget.initialSets;
    _reps = widget.initialReps;
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.space24,
          AppSpacing.space16,
          AppSpacing.space24,
          MediaQuery.viewInsetsOf(context).bottom +
              MediaQuery.paddingOf(context).bottom +
              AppSpacing.space24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Align(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderStrong,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space24),
            Row(
              children: <Widget>[
                ExerciseImage(
                  imageUrl: widget.exercise.imageUrl,
                  localImage: widget.exercise.localImage,
                  semanticLabel: widget.exercise.name,
                  width: 84,
                  height: 68,
                ),
                const SizedBox(width: AppSpacing.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.exercise.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.space4),
                      Text(
                        '${widget.exercise.primaryMuscle} · ${widget.exercise.equipment}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space24),
            Text('Target', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.space12),
            _CounterRow(
              label: 'Sets',
              value: _sets,
              onDecrease: _sets > 1 ? () => setState(() => _sets -= 1) : null,
              onIncrease: _sets < 12 ? () => setState(() => _sets += 1) : null,
            ),
            const SizedBox(height: AppSpacing.space8),
            _CounterRow(
              label: 'Reps',
              value: _reps,
              onDecrease: _reps > 1 ? () => setState(() => _reps -= 1) : null,
              onIncrease: _reps < 50 ? () => setState(() => _reps += 1) : null,
            ),
            const SizedBox(height: AppSpacing.space24),
            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(
                  RoutineExercise(
                    exercise: widget.exercise,
                    targetSets: _sets,
                    targetReps: _reps,
                  ),
                ),
                child: Text('Add $_sets × $_reps'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterRow extends StatelessWidget {
  const _CounterRow({
    required this.label,
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String label;
  final int value;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space8,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: 'Decrease $label',
              onPressed: onDecrease,
              icon: const Icon(Icons.remove_rounded),
            ),
            SizedBox(
              width: 48,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            IconButton(
              tooltip: 'Increase $label',
              onPressed: onIncrease,
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
