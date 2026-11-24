import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/features/exercises/presentation/widgets/exercise_image.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExerciseImage color rendering', () {
    testWidgets(
      'renders image without ColorFiltered or grayscale filter in light and dark mode',
      (tester) async {
        // Test dark theme
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: const Scaffold(
              body: ExerciseImage(
                imageUrl: 'asset:assets/images/generic.png',
                localImage: 'assets/Visuals/images/bench_press.jpg',
                semanticLabel: 'Bench Press',
                width: 100,
                height: 100,
              ),
            ),
          ),
        );

        // Verify no ColorFiltered widget is present
        expect(find.byType(ColorFiltered), findsNothing);
        expect(find.byType(Image), findsOneWidget);

        // Test light theme
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: const Scaffold(
              body: ExerciseImage(
                imageUrl: 'asset:assets/images/generic.png',
                localImage: 'assets/Visuals/images/Pec Deck.jpg',
                semanticLabel: 'Pec Deck',
                width: 100,
                height: 100,
              ),
            ),
          ),
        );

        expect(find.byType(ColorFiltered), findsNothing);
        expect(find.byType(Image), findsOneWidget);
      },
    );

    testWidgets(
      'renders newly acquired openGym webp illustrations in light and dark themes',
      (tester) async {
        // Dark theme test with WebP illustration
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: const Scaffold(
              body: ExerciseImage(
                imageUrl: 'asset:assets/images/generic.png',
                localImage: 'assets/Visuals/images/Pike Push Up.webp',
                semanticLabel: 'Pike Push Up',
                width: 100,
                height: 100,
              ),
            ),
          ),
        );

        expect(find.byType(ColorFiltered), findsNothing);
        expect(find.byType(Image), findsOneWidget);

        // Light theme test with WebP illustration
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: const Scaffold(
              body: ExerciseImage(
                imageUrl: 'asset:assets/images/generic.png',
                localImage: 'assets/Visuals/images/Devil Press.webp',
                semanticLabel: 'Devil Press',
                width: 100,
                height: 100,
              ),
            ),
          ),
        );

        expect(find.byType(ColorFiltered), findsNothing);
        expect(find.byType(Image), findsOneWidget);
      },
    );

    testWidgets(
      'renders newly acquired illustrations with spaces in filenames',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ExerciseImage(
                imageUrl: 'asset:assets/images/generic.png',
                localImage: 'assets/Visuals/images/Renegade Row.jpg',
                semanticLabel: 'Renegade Row',
                width: 100,
                height: 100,
              ),
            ),
          ),
        );

        expect(find.byType(ColorFiltered), findsNothing);
        expect(find.byType(Image), findsOneWidget);
      },
    );

    test('all mapped local illustrations in exercises.json exist on disk', () {
      final jsonFile = File('assets/exercises.json');
      expect(jsonFile.existsSync(), isTrue);
      final jsonText = jsonFile.readAsStringSync();
      final List<dynamic> decoded = jsonDecode(jsonText) as List<dynamic>;

      var localCount = 0;
      for (final item in decoded) {
        final map = item as Map<String, dynamic>;
        final localImage = map['local_image'] as String?;
        if (localImage != null && localImage.isNotEmpty) {
          localCount++;
          final file = File(localImage);
          expect(
            file.existsSync(),
            isTrue,
            reason: 'File not found on disk: $localImage',
          );
        }
      }

      // 286 previously existing + 6 newly finalized = 292 total local illustrations (100% coverage)
      expect(localCount, 292);
    });
  });
}
