import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stryde/features/workout_history/domain/entities/completed_workout.dart';

final workoutHistoryProvider =
    NotifierProvider<WorkoutHistoryNotifier, List<CompletedWorkout>>(
      WorkoutHistoryNotifier.new,
    );

class WorkoutHistoryNotifier extends Notifier<List<CompletedWorkout>> {
  @override
  List<CompletedWorkout> build() {
    // Session-only state by design. Closing the app discards every workout.
    return const <CompletedWorkout>[];
  }

  void addWorkout(CompletedWorkout workout) {
    state = <CompletedWorkout>[workout, ...state];
  }
}
