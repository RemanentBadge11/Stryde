import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_spacing.dart';
import 'package:stryde/features/exercises/presentation/providers/exercise_library_provider.dart';
import 'package:stryde/features/exercises/presentation/widgets/exercise_image.dart';
import 'package:stryde/features/routines/domain/entities/exercise.dart';

class ExerciseLibraryPanel extends ConsumerStatefulWidget {
  const ExerciseLibraryPanel({
    this.onExerciseSelected,
    this.excludedExerciseIds = const <String>{},
    this.showHeader = true,
    super.key,
  });

  final ValueChanged<Exercise>? onExerciseSelected;
  final Set<String> excludedExerciseIds;
  final bool showHeader;

  @override
  ConsumerState<ExerciseLibraryPanel> createState() =>
      _ExerciseLibraryPanelState();
}

class _ExerciseLibraryPanelState extends ConsumerState<ExerciseLibraryPanel> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _selectedMuscle;
  String? _selectedEquipment;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final library = ref.watch(exerciseLibraryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (widget.showHeader) ...<Widget>[
          Text(
            'Exercise Library',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.space4),
          Text(
            'Search the in-memory openGym collection.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.space16),
        ],
        _SearchField(
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value.trim()),
          onClear: () {
            _searchController.clear();
            setState(() => _query = '');
          },
        ),
        const SizedBox(height: AppSpacing.space12),
        library.when(
          loading: () => const Expanded(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
          error: (error, stackTrace) => Expanded(
            child: _LoadError(
              onRetry: () => ref.invalidate(exerciseLibraryProvider),
            ),
          ),
          data: (exercises) => _buildLibrary(context, exercises),
        ),
      ],
    );
  }

  Widget _buildLibrary(BuildContext context, List<Exercise> exercises) {
    final muscles = exercises.map((item) => item.primaryMuscle).toSet().toList()
      ..sort();
    final equipment = exercises.map((item) => item.equipment).toSet().toList()
      ..sort();
    final normalizedQuery = _query.toLowerCase();
    final filtered = exercises.where((exercise) {
      final matchesQuery =
          normalizedQuery.isEmpty ||
          exercise.name.toLowerCase().contains(normalizedQuery);
      final matchesMuscle =
          _selectedMuscle == null || exercise.primaryMuscle == _selectedMuscle;
      final matchesEquipment =
          _selectedEquipment == null ||
          exercise.equipment == _selectedEquipment;
      return matchesQuery && matchesMuscle && matchesEquipment;
    }).toList();

    return Expanded(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _FilterDropdown(
                  label: 'Muscle',
                  value: _selectedMuscle,
                  values: muscles,
                  onChanged: (value) => setState(() => _selectedMuscle = value),
                ),
              ),
              const SizedBox(width: AppSpacing.space8),
              Expanded(
                child: _FilterDropdown(
                  label: 'Equipment',
                  value: _selectedEquipment,
                  values: equipment,
                  onChanged: (value) =>
                      setState(() => _selectedEquipment = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space12),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${filtered.length} ${filtered.length == 1 ? 'exercise' : 'exercises'}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              if (_selectedMuscle != null ||
                  _selectedEquipment != null ||
                  _query.isNotEmpty)
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Reset'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.space4),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No exercises match these filters.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.space8),
                    itemBuilder: (context, index) {
                      final exercise = filtered[index];
                      final isExcluded = widget.excludedExerciseIds.contains(
                        exercise.id,
                      );
                      return _ExerciseListTile(
                        exercise: exercise,
                        isExcluded: isExcluded,
                        isSelectionMode: widget.onExerciseSelected != null,
                        onTap: isExcluded
                            ? null
                            : () {
                                final callback = widget.onExerciseSelected;
                                if (callback != null) {
                                  callback(exercise);
                                } else {
                                  _showExerciseDetails(context, exercise);
                                }
                              },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _selectedMuscle = null;
      _selectedEquipment = null;
    });
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search exercises',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: AppColors.surfaceElevated,
            hint: Text(label),
            items: <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(value: null, child: Text('All $label')),
              for (final item in values)
                DropdownMenuItem<String>(value: item, child: Text(item)),
            ],
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

class _ExerciseListTile extends StatelessWidget {
  const _ExerciseListTile({
    required this.exercise,
    required this.isExcluded,
    required this.isSelectionMode,
    required this.onTap,
  });

  final Exercise exercise;
  final bool isExcluded;
  final bool isSelectionMode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space8),
          child: Row(
            children: <Widget>[
              ExerciseImage(
                imageUrl: exercise.imageUrl,
                semanticLabel: exercise.name,
                width: 76,
                height: 58,
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
                      '${exercise.primaryMuscle} · ${exercise.equipment}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.space8),
              if (isExcluded)
                Text('ADDED', style: Theme.of(context).textTheme.labelSmall)
              else
                Icon(
                  isSelectionMode
                      ? Icons.add_circle_outline_rounded
                      : Icons.arrow_forward_rounded,
                  color: AppColors.textPrimary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.textSecondary,
            size: 36,
          ),
          const SizedBox(height: AppSpacing.space12),
          Text(
            'Could not load the exercise asset.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.space8),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

void _showExerciseDetails(BuildContext context, Exercise exercise) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.space24,
        AppSpacing.space24,
        AppSpacing.space24,
        MediaQuery.paddingOf(context).bottom + AppSpacing.space24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ExerciseImage(
            imageUrl: exercise.imageUrl,
            semanticLabel: exercise.name,
            height: 190,
            borderRadius: 18,
          ),
          const SizedBox(height: AppSpacing.space16),
          Text(
            exercise.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.space8),
          Text(
            '${exercise.primaryMuscle} · ${exercise.equipment}',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    ),
  );
}
