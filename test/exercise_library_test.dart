import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stryde/features/exercises/data/exercise_asset_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('exercise JSON parses a comprehensive unique collection', () async {
    final exercises = await loadExerciseLibraryAsset();
    final ids = exercises.map((exercise) => exercise.id).toSet();
    final muscles = exercises.map((exercise) => exercise.primaryMuscle).toSet();
    final equipment = exercises.map((exercise) => exercise.equipment).toSet();

    expect(exercises.length, greaterThanOrEqualTo(200));
    expect(ids.length, exercises.length);
    expect(muscles, containsAll(<String>['Chest', 'Back', 'Shoulders']));
    expect(
      equipment,
      containsAll(<String>['Barbell', 'Dumbbell', 'Cable', 'Bodyweight']),
    );
    expect(
      exercises.every(
        (exercise) =>
            exercise.imageUrl.startsWith('asset:assets/images/') &&
            exercise.hasBundledImage,
      ),
      isTrue,
    );
  });

  test('every referenced exercise image is bundled with the app', () async {
    final exercises = await loadExerciseLibraryAsset();
    final assetPaths = exercises
        .map((exercise) => exercise.imageAssetPath)
        .toSet();

    expect(assetPaths, isNotEmpty);
    for (final assetPath in assetPaths) {
      final data = await rootBundle.load(assetPath);
      expect(data.lengthInBytes, greaterThan(0), reason: assetPath);
    }
  });
}
