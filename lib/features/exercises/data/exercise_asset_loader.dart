import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:stryde/features/routines/domain/entities/exercise.dart';

Future<List<Exercise>> loadExerciseLibraryAsset() async {
  final jsonText = await rootBundle.loadString('assets/exercises.json');
  final decoded = jsonDecode(jsonText) as List<dynamic>;
  return List<Exercise>.unmodifiable(
    decoded.map(
      (item) => Exercise.fromJson(Map<String, dynamic>.from(item as Map)),
    ),
  );
}
