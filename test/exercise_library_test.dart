import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stryde/features/exercises/data/exercise_asset_loader.dart';
import 'package:stryde/features/routines/domain/entities/exercise.dart';

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

  test('exercise library has exact types and removes forbidden exercises', () async {
    final exercises = await loadExerciseLibraryAsset();
    final byName = {for (final e in exercises) e.name.toLowerCase(): e};

    // Removed exercises
    expect(byName.containsKey('jump rope calf bounce'), isFalse);
    expect(byName.containsKey('good morning'), isFalse);
    expect(byName.containsKey('seated good morning'), isFalse);
    expect(byName.containsKey('cable good morning'), isFalse);

    // Bodyweight
    expect(byName['push up']?.type, ExerciseType.bodyweight);
    expect(byName['pull up']?.type, ExerciseType.bodyweight);
    expect(byName['chin up']?.type, ExerciseType.bodyweight);
    expect(byName['pike push up']?.type, ExerciseType.bodyweight);
    expect(byName['jump rope']?.type, ExerciseType.bodyweight);
    expect(byName['burpee']?.type, ExerciseType.bodyweight);
    expect(byName['neck flexion']?.type, ExerciseType.bodyweight);

    // Time
    expect(byName['dead hang']?.type, ExerciseType.time);
    expect(byName['plank']?.type, ExerciseType.time);
    expect(byName['side plank']?.type, ExerciseType.time);

    // Resistance
    expect(byName['resistance band lateral raise']?.type, ExerciseType.resistance);
    expect(byName['banded clamshell']?.type, ExerciseType.resistance);

    // Cardio
    expect(byName['treadmill run']?.type, ExerciseType.cardio);
    expect(byName['treadmill walk']?.type, ExerciseType.cardio);

    // Incline Cardio
    expect(byName['incline treadmill walk']?.type, ExerciseType.inclineCardio);

    // Time Only Cardio
    expect(byName['stationary bike']?.type, ExerciseType.timeOnlyCardio);
    expect(byName['swimming']?.type, ExerciseType.timeOnlyCardio);

    // Steps Cardio
    expect(byName['stair climber']?.type, ExerciseType.stepsCardio);

    // Distance Cardio
    expect(byName['shuttle run']?.type, ExerciseType.distanceCardio);

    // Weighted variants
    expect(byName['pull up (weighted)']?.type, ExerciseType.weighted);
    expect(byName['chin up (weighted)']?.type, ExerciseType.weighted);
    expect(byName['push up (weighted)']?.type, ExerciseType.weighted);
    expect(byName['chest dip (weighted)']?.type, ExerciseType.weighted);

    // Bundled Visuals
    final pushUp = byName['push up'];
    expect(pushUp?.localImage, 'assets/Visuals/images/push_up.jpg');
    expect(pushUp?.hasBundledImage, isTrue);
    expect(exercises.where((e) => e.localImage != null).length, greaterThanOrEqualTo(190));
  });
}
