import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/features/progression/domain/entities/xp_transaction.dart';
import 'package:stryde/features/progression/presentation/providers/xp_transactions_provider.dart';
import 'package:stryde/features/workout_history/domain/entities/completed_workout.dart';
import 'package:stryde/features/workout_history/presentation/providers/workout_history_provider.dart';
import 'package:stryde/main.dart';

void main() {
  testWidgets('Stats limits previews and opens complete history pages', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final xpNotifier = container.read(xpTransactionsProvider.notifier);
    final workoutNotifier = container.read(workoutHistoryProvider.notifier);
    for (var i = 0; i < 6; i++) {
      xpNotifier.log(
        description: 'XP entry $i',
        amount: i + 1,
        source: XpSource.habit,
        occurredAt: DateTime(2026, 1, i + 1),
      );
    }
    for (var i = 0; i < 5; i++) {
      workoutNotifier.addWorkout(
        CompletedWorkout(
          id: 'workout-$i',
          routineId: 'routine-$i',
          routineName: 'Workout $i',
          completedAt: DateTime(2026, 2, i + 1),
          duration: Duration(minutes: 20 + i),
          exercises: const <CompletedWorkoutExercise>[],
        ),
      );
    }

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const StrydeApp()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('bottom-nav-stats')));
    await tester.pumpAndSettle();

    for (final index in <int>[5, 4, 3, 2]) {
      expect(find.text('XP entry $index'), findsOneWidget);
    }
    expect(find.text('XP entry 1'), findsNothing);
    expect(find.text('XP entry 0'), findsNothing);

    await tester.tap(find.byKey(const ValueKey<String>('view-all-xp')));
    await tester.pumpAndSettle();
    expect(find.text('XP History'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('bottom-nav-home')), findsNothing);
    await tester.scrollUntilVisible(
      find.text('XP entry 0'),
      250,
      scrollable: find.descendant(
        of: find.byKey(const ValueKey<String>('complete-xp-history')),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('XP entry 0'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Recent Workouts'), 300);
    await tester.scrollUntilVisible(find.text('Workout 2'), 300);
    for (final index in <int>[4, 3, 2]) {
      expect(find.text('Workout $index'), findsOneWidget);
    }
    expect(find.text('Workout 1'), findsNothing);
    expect(find.text('Workout 0'), findsNothing);

    await tester.tap(find.byKey(const ValueKey<String>('view-all-workouts')));
    await tester.pumpAndSettle();
    expect(find.text('Workout History'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('bottom-nav-home')), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Workout 0'),
      250,
      scrollable: find.descendant(
        of: find.byKey(const ValueKey<String>('complete-workout-history')),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('Workout 0'), findsOneWidget);
  });
}
