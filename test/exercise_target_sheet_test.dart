import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_theme.dart';
import 'package:stryde/features/routines/domain/entities/exercise.dart';
import 'package:stryde/features/routines/domain/entities/workout_routine.dart';
import 'package:stryde/features/routines/presentation/widgets/exercise_target_sheet.dart';
import 'package:stryde/features/workout_logging/presentation/providers/active_workout_provider.dart';

void main() {
  const treadmillWalk = Exercise(
    id: 'treadmill-walk',
    name: 'Treadmill Walk',
    primaryMuscle: 'Cardio',
    equipment: 'Other',
    imageUrl: 'asset:assets/images/generic.png',
    type: ExerciseType.cardio,
  );

  const benchPress = Exercise(
    id: 'bench-press',
    name: 'Bench Press',
    primaryMuscle: 'Chest',
    equipment: 'Barbell',
    imageUrl: 'asset:assets/images/bench_press.png',
    type: ExerciseType.strength,
  );

  group('ExerciseTargetSheet', () {
    testWidgets(
      'Cardio exercise shows only Sets selector, removes Reps, and uses singular/plural CTA',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 932));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        RoutineExercise? result;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () async {
                    result = await showExerciseTargetSheet(
                      context,
                      treadmillWalk,
                    );
                  },
                  child: const Text('Open Sheet'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        // Sets selector must be present
        expect(find.text('Sets'), findsOneWidget);

        // Reps selector must be completely absent
        expect(find.text('Reps'), findsNothing);

        // Dynamic CTA with default 3 sets
        expect(find.text('Add 3 Sets'), findsOneWidget);

        // Tap decrease sets twice: 3 -> 2 -> 1
        final decreaseSets = find.byTooltip('Decrease Sets');
        await tester.tap(decreaseSets);
        await tester.pumpAndSettle();
        expect(find.text('Add 2 Sets'), findsOneWidget);

        await tester.tap(decreaseSets);
        await tester.pumpAndSettle();
        // Dynamic CTA with 1 set should be singular
        expect(find.text('Add 1 Set'), findsOneWidget);

        // Tap Add 1 Set button
        await tester.tap(find.text('Add 1 Set'));
        await tester.pumpAndSettle();

        expect(result, isNotNull);
        expect(result!.exercise.id, 'treadmill-walk');
        expect(result!.targetSets, 1);
        expect(result!.targetReps, isNull);

        // Verify that adding this cardio exercise to an active workout session does not assign artificial reps
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(activeWorkoutProvider.notifier);

        notifier.startWorkout(
          const WorkoutRoutine(
            id: 'empty-test',
            name: 'Empty Test',
            focus: 'Test',
            estimatedMinutes: 30,
            exercises: <RoutineExercise>[],
          ),
        );

        notifier.addExercise(result!);
        final session = container.read(activeWorkoutProvider).session!;
        expect(session.exercises.length, 1);
        expect(session.exercises.first.sets.length, 1);
        expect(session.exercises.first.sets.first.repsText, '');
      },
    );

    testWidgets(
      'Non-cardio exercise retains both Sets and Reps selectors with target multiplier CTA',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 932));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        RoutineExercise? result;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () async {
                    result = await showExerciseTargetSheet(context, benchPress);
                  },
                  child: const Text('Open Sheet'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        // Both Sets and Reps selectors must be present
        expect(find.text('Sets'), findsOneWidget);
        expect(find.text('Reps'), findsOneWidget);

        // Default CTA
        expect(find.text('Add 3 × 10'), findsOneWidget);

        // Tap Add 3 × 10
        await tester.tap(find.text('Add 3 × 10'));
        await tester.pumpAndSettle();

        expect(result, isNotNull);
        expect(result!.exercise.id, 'bench-press');
        expect(result!.targetSets, 3);
        expect(result!.targetReps, 10);

        // Verify that adding non-cardio retains reps target in active workout session
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(activeWorkoutProvider.notifier);

        notifier.startWorkout(
          const WorkoutRoutine(
            id: 'empty-test',
            name: 'Empty Test',
            focus: 'Test',
            estimatedMinutes: 30,
            exercises: <RoutineExercise>[],
          ),
        );

        notifier.addExercise(result!);
        final session = container.read(activeWorkoutProvider).session!;
        expect(session.exercises.length, 1);
        expect(session.exercises.first.sets.length, 3);
        expect(session.exercises.first.sets.first.repsText, '10');
      },
    );
  });
}
