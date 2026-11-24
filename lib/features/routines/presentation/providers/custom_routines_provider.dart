import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stryde/features/routines/data/mock_workout_data.dart';
import 'package:stryde/features/routines/domain/entities/workout_routine.dart';

final customRoutinesProvider =
    NotifierProvider<CustomRoutinesNotifier, List<WorkoutRoutine>>(
      CustomRoutinesNotifier.new,
    );

final allRoutinesProvider = Provider<List<WorkoutRoutine>>((ref) {
  return List<WorkoutRoutine>.unmodifiable(<WorkoutRoutine>[
    ...MockWorkoutData.routines,
    ...ref.watch(customRoutinesProvider),
  ]);
});

class CustomRoutinesNotifier extends Notifier<List<WorkoutRoutine>> {
  @override
  List<WorkoutRoutine> build() {
    return const <WorkoutRoutine>[];
  }

  void addRoutine(WorkoutRoutine routine) {
    state = <WorkoutRoutine>[...state, routine];
  }

  void removeRoutine(String routineId) {
    state = state.where((r) => r.id != routineId).toList();
  }
}
