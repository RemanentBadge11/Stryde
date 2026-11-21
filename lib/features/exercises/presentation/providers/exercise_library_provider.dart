import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stryde/features/exercises/data/exercise_asset_loader.dart';
import 'package:stryde/features/routines/domain/entities/exercise.dart';

final exerciseLibraryProvider = FutureProvider<List<Exercise>>((ref) {
  return loadExerciseLibraryAsset();
});
