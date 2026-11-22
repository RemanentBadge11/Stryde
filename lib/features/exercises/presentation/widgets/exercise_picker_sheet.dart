import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_spacing.dart';
import 'package:stryde/features/exercises/presentation/widgets/exercise_library_panel.dart';
import 'package:stryde/features/routines/domain/entities/exercise.dart';

Future<Exercise?> showExercisePickerSheet(
  BuildContext context, {
  Set<String> excludedExerciseIds = const <String>{},
}) {
  return showModalBottomSheet<Exercise>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => FractionallySizedBox(
      heightFactor: 0.94,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space16,
            AppSpacing.space12,
            AppSpacing.space16,
            AppSpacing.space16,
          ),
          child: Column(
            children: <Widget>[
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderStrong,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: AppSpacing.space16),
              Expanded(
                child: ExerciseLibraryPanel(
                  excludedExerciseIds: excludedExerciseIds,
                  onExerciseSelected: (exercise) =>
                      Navigator.of(sheetContext).pop(exercise),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
