import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stryde/features/progression/presentation/providers/skill_allocations_provider.dart';
import 'package:stryde/features/routines/domain/entities/mastery_routine_definition.dart';
import 'package:stryde/features/routines/domain/entities/workout_routine.dart';
import 'package:stryde/features/routines/domain/services/mastery_personalization_engine.dart';
import 'package:stryde/features/workout_history/presentation/providers/workout_history_provider.dart';

const masteryPersonalizationEngine = MasteryPersonalizationEngine();

final masteryRoutinesProvider = Provider<List<MasteryRoutineItem>>((ref) {
  final allocations = ref.watch(skillAllocationsProvider);
  final history = ref.watch(workoutHistoryProvider);

  return MasteryRoutineDefinitions.all
      .map((def) {
        final unlocked = def.isUnlocked(allocations);
        final personalized = masteryPersonalizationEngine.personalize(
          definition: def,
          history: history,
        );
        return MasteryRoutineItem(
          definition: def,
          routine: personalized,
          isUnlocked: unlocked,
          allocations: allocations,
        );
      })
      .toList(growable: false);
});

final singleMasteryRoutineProvider = Provider.family<WorkoutRoutine?, String>((
  ref,
  routineId,
) {
  final items = ref.watch(masteryRoutinesProvider);
  for (final item in items) {
    if (item.id == routineId) return item.routine;
  }
  return MasteryRoutineDefinitions.findDefaultRoutineById(routineId);
});
