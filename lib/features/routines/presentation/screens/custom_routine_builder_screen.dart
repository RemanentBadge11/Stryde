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
import 'package:stryde/features/routines/presentation/providers/custom_routines_provider.dart';
import 'package:stryde/features/routines/presentation/widgets/exercise_target_sheet.dart';

class CustomRoutineBuilderScreen extends ConsumerStatefulWidget {
  const CustomRoutineBuilderScreen({super.key});

  @override
  ConsumerState<CustomRoutineBuilderScreen> createState() =>
      _CustomRoutineBuilderScreenState();
}

class _CustomRoutineBuilderScreenState
    extends ConsumerState<CustomRoutineBuilderScreen> {
  final _nameController = TextEditingController();
  final List<RoutineExercise> _exercises = <RoutineExercise>[];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text('Create Routine'),
        actions: <Widget>[
          TextButton(onPressed: _saveRoutine, child: const Text('Save')),
          const SizedBox(width: AppSpacing.space8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space16,
            AppSpacing.space16,
            AppSpacing.space16,
            120,
          ),
          children: <Widget>[
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              style: Theme.of(context).textTheme.titleLarge,
              decoration: InputDecoration(
                labelText: 'Routine name',
                hintText: 'e.g. Upper Strength',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space24),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Exercises',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Text(
                  '${_exercises.length}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space12),
            if (_exercises.isEmpty)
              const EmptyStateCard(
                icon: Icons.playlist_add_rounded,
                title: 'Build your routine',
                message: 'Add exercises and set a target for sets and reps.',
              )
            else
              for (var i = 0; i < _exercises.length; i++) ...<Widget>[
                _RoutineExerciseCard(
                  prescription: _exercises[i],
                  onEdit: () => _editTarget(i),
                  onRemove: () => setState(() => _exercises.removeAt(i)),
                ),
                if (i != _exercises.length - 1)
                  const SizedBox(height: AppSpacing.space8),
              ],
            const SizedBox(height: AppSpacing.space16),
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _addExercise,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Exercise'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.all(AppSpacing.space16),
        child: SizedBox(
          height: 56,
          child: FilledButton(
            onPressed: _saveRoutine,
            child: const Text('Save Routine'),
          ),
        ),
      ),
    );
  }

  Future<void> _addExercise() async {
    final selected = await showExercisePickerSheet(
      context,
      excludedExerciseIds: _exercises.map((item) => item.exercise.id).toSet(),
    );
    if (selected == null || !mounted) return;
    final prescription = await showExerciseTargetSheet(context, selected);
    if (prescription == null || !mounted) return;
    setState(() => _exercises.add(prescription));
  }

  Future<void> _editTarget(int index) async {
    final current = _exercises[index];
    final updated = await showExerciseTargetSheet(
      context,
      current.exercise,
      initialSets: current.targetSets,
      initialReps: current.targetReps,
    );
    if (updated == null || !mounted) return;
    setState(() => _exercises[index] = updated);
  }

  void _saveRoutine() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showMessage('Give this routine a name.');
      return;
    }
    if (_exercises.isEmpty) {
      _showMessage('Add at least one exercise.');
      return;
    }

    final muscles = <String>[];
    for (final item in _exercises) {
      if (!muscles.contains(item.exercise.primaryMuscle)) {
        muscles.add(item.exercise.primaryMuscle);
      }
    }
    final focus = muscles.take(3).join(' · ');
    final routine = WorkoutRoutine(
      id: 'custom-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      focus: focus,
      estimatedMinutes: _exercises.fold<int>(
        0,
        (total, item) => total + item.targetSets * 3,
      ),
      exercises: List<RoutineExercise>.unmodifiable(_exercises),
      isCustom: true,
    );
    ref.read(customRoutinesProvider.notifier).addRoutine(routine);
    context.pop();
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

class _RoutineExerciseCard extends StatelessWidget {
  const _RoutineExerciseCard({
    required this.prescription,
    required this.onEdit,
    required this.onRemove,
  });

  final RoutineExercise prescription;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final exercise = prescription.exercise;
    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.space8),
      child: Row(
        children: <Widget>[
          ExerciseImage(
            imageUrl: exercise.imageUrl,
            localImage: exercise.localImage,
            semanticLabel: exercise.name,
            width: 72,
            height: 62,
            borderRadius: 12,
          ),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  exercise.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  '${prescription.targetSets} sets × ${prescription.targetReps} reps',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          PopupMenuButton<_RoutineExerciseAction>(
            color: AppColors.surfaceElevated,
            onSelected: (action) {
              switch (action) {
                case _RoutineExerciseAction.edit:
                  onEdit();
                case _RoutineExerciseAction.remove:
                  onRemove();
              }
            },
            itemBuilder: (context) =>
                const <PopupMenuEntry<_RoutineExerciseAction>>[
                  PopupMenuItem(
                    value: _RoutineExerciseAction.edit,
                    child: Text('Edit target'),
                  ),
                  PopupMenuItem(
                    value: _RoutineExerciseAction.remove,
                    child: Text('Remove'),
                  ),
                ],
          ),
        ],
      ),
    );
  }
}

enum _RoutineExerciseAction { edit, remove }
