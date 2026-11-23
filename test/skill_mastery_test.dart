import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stryde/features/progression/presentation/providers/skill_allocations_provider.dart';
import 'package:stryde/features/routines/data/mock_workout_data.dart';
import 'package:stryde/features/routines/domain/entities/mastery_routine_definition.dart';
import 'package:stryde/features/routines/domain/services/mastery_personalization_engine.dart';
import 'package:stryde/features/routines/presentation/providers/mastery_routines_provider.dart';
import 'package:stryde/features/workout_history/domain/entities/completed_workout.dart';
import 'package:stryde/features/workout_history/presentation/providers/workout_history_provider.dart';
import 'package:stryde/features/workout_logging/presentation/providers/active_workout_provider.dart';

void main() {
  group('Skill Mastery - 11 Unlock Conditions', () {
    test('contains exactly 11 mastery routine definitions', () {
      expect(MasteryRoutineDefinitions.all.length, 11);
      final ids = MasteryRoutineDefinitions.all.map((d) => d.id).toSet();
      expect(ids.length, 11);
    });

    test('Chest Mastery unlocks only at Chest >= 5', () {
      const def = MasteryRoutineDefinitions.chestMastery;
      expect(def.isUnlocked({'Chest': 4}), isFalse);
      expect(def.isUnlocked({'Chest': 5}), isTrue);
      expect(def.isUnlocked({'Chest': 8}), isTrue);
      expect(def.isUnlocked({'Back': 10}), isFalse);
    });

    test('Back Mastery unlocks only at Back >= 5', () {
      const def = MasteryRoutineDefinitions.backMastery;
      expect(def.isUnlocked({'Back': 4}), isFalse);
      expect(def.isUnlocked({'Back': 5}), isTrue);
      expect(def.isUnlocked({'Back': 12}), isTrue);
      expect(def.isUnlocked({'Chest': 10}), isFalse);
    });

    test('Legs Mastery unlocks only at Legs >= 5', () {
      const def = MasteryRoutineDefinitions.legsMastery;
      expect(def.isUnlocked({'Legs': 4}), isFalse);
      expect(def.isUnlocked({'Legs': 5}), isTrue);
      expect(def.isUnlocked({'Legs': 7}), isTrue);
      expect(def.isUnlocked({'Chest': 10}), isFalse);
    });

    test('Shoulders Mastery unlocks only at Shoulders >= 5', () {
      const def = MasteryRoutineDefinitions.shouldersMastery;
      expect(def.isUnlocked({'Shoulders': 4}), isFalse);
      expect(def.isUnlocked({'Shoulders': 5}), isTrue);
      expect(def.isUnlocked({'Shoulders': 6}), isTrue);
      expect(def.isUnlocked({'Legs': 10}), isFalse);
    });

    test('Biceps Mastery unlocks only at Biceps >= 5', () {
      const def = MasteryRoutineDefinitions.bicepsMastery;
      expect(def.isUnlocked({'Biceps': 4}), isFalse);
      expect(def.isUnlocked({'Biceps': 5}), isTrue);
      expect(def.isUnlocked({'Biceps': 9}), isTrue);
      expect(def.isUnlocked({'Triceps': 10}), isFalse);
    });

    test('Triceps Mastery unlocks only at Triceps >= 5', () {
      const def = MasteryRoutineDefinitions.tricepsMastery;
      expect(def.isUnlocked({'Triceps': 4}), isFalse);
      expect(def.isUnlocked({'Triceps': 5}), isTrue);
      expect(def.isUnlocked({'Triceps': 10}), isTrue);
      expect(def.isUnlocked({'Biceps': 10}), isFalse);
    });

    test('Chest + Triceps Mastery unlocks only when BOTH >= 5', () {
      const def = MasteryRoutineDefinitions.chestTricepsMastery;
      expect(def.isUnlocked({'Chest': 5, 'Triceps': 4}), isFalse);
      expect(def.isUnlocked({'Chest': 4, 'Triceps': 5}), isFalse);
      expect(def.isUnlocked({'Chest': 5, 'Triceps': 5}), isTrue);
      expect(def.isUnlocked({'Chest': 10, 'Triceps': 8}), isTrue);
    });

    test('Arms Mastery (Biceps + Triceps) unlocks only when BOTH >= 5', () {
      const def = MasteryRoutineDefinitions.armsMastery;
      expect(def.isUnlocked({'Biceps': 5, 'Triceps': 4}), isFalse);
      expect(def.isUnlocked({'Biceps': 4, 'Triceps': 5}), isFalse);
      expect(def.isUnlocked({'Biceps': 5, 'Triceps': 5}), isTrue);
      expect(def.isUnlocked({'Biceps': 7, 'Triceps': 6}), isTrue);
    });

    test('Legs + Shoulders Mastery unlocks only when BOTH >= 5', () {
      const def = MasteryRoutineDefinitions.legsShouldersMastery;
      expect(def.isUnlocked({'Legs': 5, 'Shoulders': 4}), isFalse);
      expect(def.isUnlocked({'Legs': 4, 'Shoulders': 5}), isFalse);
      expect(def.isUnlocked({'Legs': 5, 'Shoulders': 5}), isTrue);
      expect(def.isUnlocked({'Legs': 6, 'Shoulders': 6}), isTrue);
    });

    test('Back + Biceps Mastery unlocks only when BOTH >= 5', () {
      const def = MasteryRoutineDefinitions.backBicepsMastery;
      expect(def.isUnlocked({'Back': 5, 'Biceps': 4}), isFalse);
      expect(def.isUnlocked({'Back': 4, 'Biceps': 5}), isFalse);
      expect(def.isUnlocked({'Back': 5, 'Biceps': 5}), isTrue);
      expect(def.isUnlocked({'Back': 5, 'Biceps': 5}), isTrue);
    });

    test('Chest + Back Mastery unlocks only when BOTH >= 5', () {
      const def = MasteryRoutineDefinitions.chestBackMastery;
      expect(def.isUnlocked({'Chest': 5, 'Back': 4}), isFalse);
      expect(def.isUnlocked({'Chest': 4, 'Back': 5}), isFalse);
      expect(def.isUnlocked({'Chest': 5, 'Back': 5}), isTrue);
      expect(def.isUnlocked({'Chest': 8, 'Back': 8}), isTrue);
    });

    test('unlock check is read-only and does not mutate or consume points', () {
      final allocations = {'Chest': 5, 'Back': 5, 'Triceps': 3};
      final original = Map<String, int>.from(allocations);

      for (final def in MasteryRoutineDefinitions.all) {
        def.isUnlocked(allocations);
      }

      expect(allocations, equals(original));
      expect(allocations['Chest'], 5);
      expect(allocations['Back'], 5);
      expect(allocations['Triceps'], 3);
    });
  });

  group('Mastery Personalization Engine', () {
    const engine = MasteryPersonalizationEngine();

    test('falls back to default balanced exercises when history is empty', () {
      final routine = engine.personalize(
        definition: MasteryRoutineDefinitions.chestMastery,
        history: const <CompletedWorkout>[],
      );

      expect(routine.id, 'chest-mastery');
      expect(routine.name, 'Chest Mastery');
      expect(routine.exercises.length, 4);
      expect(routine.exercises[0].exercise.name, 'Bench Press');
      expect(routine.exercises[0].targetSets, 4);
      expect(routine.exercises[0].targetReps, 8);
    });

    test('prioritizes frequently performed exercises and adapts sets/reps', () {
      final history = <CompletedWorkout>[
        CompletedWorkout(
          id: 'w1',
          routineId: 'custom',
          routineName: 'Push',
          completedAt: DateTime.now().subtract(const Duration(days: 4)),
          duration: const Duration(minutes: 50),
          exercises: const <CompletedWorkoutExercise>[
            CompletedWorkoutExercise(
              exerciseId: 'incline-dumbbell-press',
              exerciseName: 'Incline Dumbbell Press',
              sets: <CompletedWorkoutSet>[
                CompletedWorkoutSet(setNumber: 1, weightKg: 24, reps: 12),
                CompletedWorkoutSet(setNumber: 2, weightKg: 24, reps: 12),
                CompletedWorkoutSet(setNumber: 3, weightKg: 24, reps: 12),
                CompletedWorkoutSet(setNumber: 4, weightKg: 24, reps: 12),
              ],
            ),
            CompletedWorkoutExercise(
              exerciseId: 'bench-press',
              exerciseName: 'Bench Press',
              sets: <CompletedWorkoutSet>[
                CompletedWorkoutSet(setNumber: 1, weightKg: 80, reps: 6),
                CompletedWorkoutSet(setNumber: 2, weightKg: 80, reps: 6),
                CompletedWorkoutSet(setNumber: 3, weightKg: 80, reps: 6),
              ],
            ),
          ],
        ),
        CompletedWorkout(
          id: 'w2',
          routineId: 'custom',
          routineName: 'Push 2',
          completedAt: DateTime.now().subtract(const Duration(days: 2)),
          duration: const Duration(minutes: 45),
          exercises: const <CompletedWorkoutExercise>[
            CompletedWorkoutExercise(
              exerciseId: 'incline-dumbbell-press',
              exerciseName: 'Incline Dumbbell Press',
              sets: <CompletedWorkoutSet>[
                CompletedWorkoutSet(setNumber: 1, weightKg: 26, reps: 10),
                CompletedWorkoutSet(setNumber: 2, weightKg: 26, reps: 10),
                CompletedWorkoutSet(setNumber: 3, weightKg: 26, reps: 10),
              ],
            ),
          ],
        ),
      ];

      final routine = engine.personalize(
        definition: MasteryRoutineDefinitions.chestMastery,
        history: history,
      );

      // Incline Dumbbell Press was performed in 2 workouts vs Bench Press in 1 workout
      expect(routine.exercises.first.exercise.id, 'incline-dumbbell-press');
      expect(routine.exercises[1].exercise.id, 'bench-press');

      // Bench press had 3 sets of 6 reps -> averageSets=3, averageReps=6
      expect(routine.exercises[1].targetSets, 3);
      expect(routine.exercises[1].targetReps, 6);

      // Total exercises is supplemented with balanced defaults without duplicates
      expect(routine.exercises.length, 4);
      final ids = routine.exercises.map((e) => e.exercise.id).toSet();
      expect(ids.length, 4);
    });

    test('balances dual-muscle routines across both target muscle groups', () {
      final history = <CompletedWorkout>[
        CompletedWorkout(
          id: 'w1',
          routineId: 'push',
          routineName: 'Push',
          completedAt: DateTime.now().subtract(const Duration(days: 1)),
          duration: const Duration(minutes: 60),
          exercises: const <CompletedWorkoutExercise>[
            CompletedWorkoutExercise(
              exerciseId: 'bench-press',
              exerciseName: 'Bench Press',
              sets: <CompletedWorkoutSet>[
                CompletedWorkoutSet(setNumber: 1, weightKg: 70, reps: 8),
                CompletedWorkoutSet(setNumber: 2, weightKg: 70, reps: 8),
                CompletedWorkoutSet(setNumber: 3, weightKg: 70, reps: 8),
              ],
            ),
            CompletedWorkoutExercise(
              exerciseId: 'triceps-pushdown',
              exerciseName: 'Triceps Pushdown',
              sets: <CompletedWorkoutSet>[
                CompletedWorkoutSet(setNumber: 1, weightKg: 25, reps: 12),
                CompletedWorkoutSet(setNumber: 2, weightKg: 25, reps: 12),
                CompletedWorkoutSet(setNumber: 3, weightKg: 25, reps: 12),
              ],
            ),
          ],
        ),
      ];

      final routine = engine.personalize(
        definition: MasteryRoutineDefinitions.chestTricepsMastery,
        history: history,
      );

      // Must contain both chest and triceps exercises
      final hasChest = routine.exercises.any(
        (e) =>
            MasteryPersonalizationEngine.detectSkillMuscleGroup(
              exerciseId: e.exercise.id,
              exerciseName: e.exercise.name,
              primaryMuscle: e.exercise.primaryMuscle,
            ) ==
            'Chest',
      );
      final hasTriceps = routine.exercises.any(
        (e) =>
            MasteryPersonalizationEngine.detectSkillMuscleGroup(
              exerciseId: e.exercise.id,
              exerciseName: e.exercise.name,
              primaryMuscle: e.exercise.primaryMuscle,
            ) ==
            'Triceps',
      );

      expect(hasChest, isTrue);
      expect(hasTriceps, isTrue);
      expect(routine.exercises.length, inInclusiveRange(4, 6));

      // Ensure no duplicate exercises
      final ids = routine.exercises.map((e) => e.exercise.id).toSet();
      expect(ids.length, routine.exercises.length);
    });

    test('clamps volume and reps to safe hypertrophic ranges', () {
      // Test extreme sets (e.g. 10 sets of 50 reps)
      final history = <CompletedWorkout>[
        CompletedWorkout(
          id: 'w-extreme',
          routineId: 'extreme',
          routineName: 'Extreme',
          completedAt: DateTime.now(),
          duration: const Duration(minutes: 90),
          exercises: <CompletedWorkoutExercise>[
            CompletedWorkoutExercise(
              exerciseId: 'squat',
              exerciseName: 'Squat',
              sets: List<CompletedWorkoutSet>.generate(
                10,
                (i) => CompletedWorkoutSet(
                  setNumber: i + 1,
                  weightKg: 100,
                  reps: 50,
                ),
              ),
            ),
          ],
        ),
      ];

      final routine = engine.personalize(
        definition: MasteryRoutineDefinitions.legsMastery,
        history: history,
      );

      final squatPrescription = routine.exercises.firstWhere(
        (e) => e.exercise.id == 'squat',
      );
      expect(squatPrescription.targetSets, lessThanOrEqualTo(4));
      expect(squatPrescription.targetReps, lessThanOrEqualTo(15));
    });
  });

  group('Mastery Routines Provider & Reactivity', () {
    test('reflects unlock status when skill allocations update', () {
      final container = ProviderContainer(
        overrides: [
          skillAllocationsProvider.overrideWith(
            () => _FakeSkillAllocationsNotifier(<String, int>{'Chest': 5}),
          ),
          workoutHistoryProvider.overrideWith(
            () => _FakeWorkoutHistoryNotifier(const <CompletedWorkout>[]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final items = container.read(masteryRoutinesProvider);
      expect(items.length, 11);

      final chest = items.firstWhere((i) => i.id == 'chest-mastery');
      final back = items.firstWhere((i) => i.id == 'back-mastery');
      final chestTriceps = items.firstWhere(
        (i) => i.id == 'chest-triceps-mastery',
      );

      expect(chest.isUnlocked, isTrue);
      expect(back.isUnlocked, isFalse);
      expect(chestTriceps.isUnlocked, isFalse);
    });

    test(
      'preserves existing presets and does not mutate active workout state',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Push/Pull/Legs presets are unchanged
        expect(MockWorkoutData.pushDay.exercises.length, 6);
        expect(MockWorkoutData.pullDay.exercises.length, 6);
        expect(MockWorkoutData.legDay.exercises.length, 6);

        // Active workout starts idle and is not altered by mastery routines evaluation
        final active = container.read(activeWorkoutProvider);
        expect(active.isOngoing, isFalse);
        expect(active.session, isNull);

        // Evaluate mastery routines
        final masteryList = container.read(masteryRoutinesProvider);
        expect(masteryList.length, 11);

        // Active workout is still idle
        expect(container.read(activeWorkoutProvider).isOngoing, isFalse);
      },
    );

    test('can start active workout with an unlocked mastery routine', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final defaultChest = MasteryRoutineDefinitions.chestMastery
          .toDefaultRoutine();
      expect(defaultChest.exercises.isNotEmpty, isTrue);

      container.read(activeWorkoutProvider.notifier).startWorkout(defaultChest);
      final active = container.read(activeWorkoutProvider);

      expect(active.isOngoing, isTrue);
      expect(active.session, isNotNull);
      expect(active.session!.routine.id, 'chest-mastery');
      expect(active.session!.routine.name, 'Chest Mastery');
    });
  });
}

class _FakeSkillAllocationsNotifier extends SkillAllocationsNotifier {
  _FakeSkillAllocationsNotifier(this._initial);
  final Map<String, int> _initial;

  @override
  Map<String, int> build() => _initial;
}

class _FakeWorkoutHistoryNotifier extends WorkoutHistoryNotifier {
  _FakeWorkoutHistoryNotifier(this._initial);
  final List<CompletedWorkout> _initial;

  @override
  List<CompletedWorkout> build() => _initial;
}
