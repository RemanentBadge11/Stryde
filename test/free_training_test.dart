import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/features/exercises/presentation/providers/exercise_library_provider.dart';
import 'package:stryde/features/routines/data/mock_workout_data.dart';
import 'package:stryde/main.dart';

void main() {
  testWidgets('free training adds an exercise from the JSON library', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          exerciseLibraryProvider.overrideWith(
            (ref) async => [MockWorkoutData.benchPress],
          ),
        ],
        child: const StrydeApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Train'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Empty Workout'));
    await tester.pumpAndSettle();

    expect(find.text('Empty workout'), findsOneWidget);
    await tester.tap(find.text('Add Exercise'));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Exercise Library'), findsOneWidget);
    expect(find.text('1 exercise'), findsOneWidget);
    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'Bench Press');
    tester.testTextInput.hide();
    await tester.pump();

    final benchPressTile = find
        .ancestor(of: find.text('Bench Press'), matching: find.byType(InkWell))
        .last;
    tester.widget<InkWell>(benchPressTile).onTap!();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Target'), findsOneWidget);
    expect(find.text('Add 3 × 10'), findsOneWidget);

    final addTargetButton = find.ancestor(
      of: find.text('Add 3 × 10'),
      matching: find.byType(FilledButton),
    );
    tester.widget<FilledButton>(addTargetButton).onPressed!();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.byTooltip('Complete set 1 for Bench Press'), findsOneWidget);
    expect(find.byTooltip('Complete set 3 for Bench Press'), findsOneWidget);
  });
}
