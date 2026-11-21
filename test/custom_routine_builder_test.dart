import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/features/exercises/presentation/providers/exercise_library_provider.dart';
import 'package:stryde/features/routines/data/mock_workout_data.dart';
import 'package:stryde/main.dart';

void main() {
  testWidgets('creates an in-memory custom routine from the library', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          exerciseLibraryProvider.overrideWith(
            (ref) async => [MockWorkoutData.squat],
          ),
        ],
        child: const StrydeApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Train'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create Routine'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Power Builder');
    await tester.tap(find.text('Add Exercise'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('1 exercise'), findsOneWidget);

    final squatTile = find
        .ancestor(of: find.text('Squat'), matching: find.byType(InkWell))
        .last;
    tester.widget<InkWell>(squatTile).onTap!();
    await tester.pump(const Duration(milliseconds: 500));

    final addTargetButton = find.ancestor(
      of: find.text('Add 3 × 10'),
      matching: find.byType(FilledButton),
    );
    tester.widget<FilledButton>(addTargetButton).onPressed!();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Squat'), findsOneWidget);
    await tester.tap(find.text('Save').first);
    await tester.pumpAndSettle();

    expect(find.text('4 routines'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Power Builder'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Power Builder'), findsOneWidget);
    expect(find.text('CUSTOM'), findsOneWidget);
  });
}
