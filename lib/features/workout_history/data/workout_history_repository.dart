import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/workout_history/domain/entities/completed_workout.dart';

class WorkoutHistoryRepository {
  const WorkoutHistoryRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<List<CompletedWorkout>> fetch(String userId) async {
    final workoutRows = await _supabase
        .from('workouts')
        .select()
        .eq('user_id', userId)
        .order('start_time', ascending: false);
    if (workoutRows.isEmpty) return const <CompletedWorkout>[];

    final workoutIds = workoutRows
        .map<dynamic>((row) => row['id'])
        .where((id) => id != null)
        .toList(growable: false);
    final setRows = workoutIds.isEmpty
        ? const <Map<String, dynamic>>[]
        : await _supabase
              .from('workout_sets')
              .select()
              .inFilter('workout_id', workoutIds);

    final setsByWorkout = <String, List<Map<String, dynamic>>>{};
    for (final row in setRows) {
      final workoutId = row['workout_id']?.toString();
      if (workoutId == null) continue;
      setsByWorkout
          .putIfAbsent(workoutId, () => <Map<String, dynamic>>[])
          .add(row);
    }

    return workoutRows
        .map(
          (row) => _workoutFromRows(
            row,
            setsByWorkout[row['id']?.toString()] ??
                const <Map<String, dynamic>>[],
          ),
        )
        .toList(growable: false);
  }

  Future<String> insert({
    required String userId,
    required CompletedWorkout workout,
  }) async {
    final startTime =
        workout.startedAt ?? workout.completedAt.subtract(workout.duration);
    final row = await _supabase
        .from('workouts')
        .insert(<String, dynamic>{
          'name': workout.routineName,
          'start_time': startTime.toUtc().toIso8601String(),
          'end_time': workout.completedAt.toUtc().toIso8601String(),
          'user_id': userId,
        })
        .select('id')
        .single();
    final workoutId = row['id'].toString();

    final sets = <Map<String, dynamic>>[
      for (final exercise in workout.exercises)
        for (final set in exercise.sets)
          <String, dynamic>{
            'workout_id': workoutId,
            'exercise_name': exercise.exerciseName,
            'set_number': set.setNumber,
            ..._setFieldsForType(exercise.exerciseType, set),
          },
    ];
    if (sets.isNotEmpty) {
      await _supabase.from('workout_sets').insert(sets);
    }
    return workoutId;
  }

  static Map<String, dynamic> _setFieldsForType(
    String type,
    CompletedWorkoutSet set,
  ) {
    switch (type) {
      case 'strength':
      case 'weighted':
        return <String, dynamic>{
          'weight': set.weightKg,
          'reps': set.reps,
        };
      case 'bodyweight':
      case 'reps_only_cardio':
        return <String, dynamic>{
          'reps': set.reps,
        };
      case 'time':
      case 'time_only_cardio':
      case 'distance_cardio':
        return <String, dynamic>{
          'duration_seconds': set.durationSeconds ?? 0,
        };
      case 'resistance':
        return <String, dynamic>{
          'resistance_level': set.resistanceLevel ?? '',
          'reps': set.reps,
        };
      case 'cardio':
        return <String, dynamic>{
          'duration_seconds': set.durationSeconds ?? 0,
          'distance': set.distance ?? 0,
        };
      case 'incline_cardio':
        return <String, dynamic>{
          'incline': set.incline ?? 0,
          'duration_seconds': set.durationSeconds ?? 0,
          'distance': set.distance ?? 0,
        };
      case 'steps_cardio':
        return <String, dynamic>{
          'steps': set.steps ?? 0,
          'duration_seconds': set.durationSeconds ?? 0,
        };
      default:
        return <String, dynamic>{
          'weight': set.weightKg,
          'reps': set.reps,
          if (set.durationSeconds != null)
            'duration_seconds': set.durationSeconds,
          if (set.resistanceLevel != null && set.resistanceLevel!.isNotEmpty)
            'resistance_level': set.resistanceLevel,
          if (set.distance != null) 'distance': set.distance,
          if (set.incline != null) 'incline': set.incline,
          if (set.steps != null) 'steps': set.steps,
        };
    }
  }

  CompletedWorkout _workoutFromRows(
    Map<String, dynamic> workoutRow,
    List<Map<String, dynamic>> setRows,
  ) {
    final id = workoutRow['id']?.toString() ?? '';
    final name = workoutRow['name']?.toString() ?? 'Workout';
    final start = _asDateTime(workoutRow['start_time']) ?? DateTime.now();
    final end = _asDateTime(workoutRow['end_time']) ?? start;
    final rowsByExercise = <String, List<Map<String, dynamic>>>{};
    for (final row in setRows) {
      final exerciseName = row['exercise_name']?.toString() ?? 'Exercise';
      rowsByExercise
          .putIfAbsent(exerciseName, () => <Map<String, dynamic>>[])
          .add(row);
    }

    final exercises = <CompletedWorkoutExercise>[
      for (final entry in rowsByExercise.entries)
        CompletedWorkoutExercise(
          exerciseId: _slug(entry.key),
          exerciseName: entry.key,
          sets:
              (entry.value..sort(
                    (a, b) => _asInt(
                      a['set_number'],
                    ).compareTo(_asInt(b['set_number'])),
                  ))
                  .map(
                    (row) => CompletedWorkoutSet(
                      setNumber: _asInt(row['set_number'], fallback: 1),
                      weightKg: _asDouble(row['weight']),
                      reps: _asInt(row['reps']),
                      durationSeconds: row['duration_seconds'] != null
                          ? _asInt(row['duration_seconds'])
                          : null,
                      resistanceLevel: row['resistance_level']?.toString(),
                      distance: row['distance'] != null
                          ? _asDouble(row['distance'])
                          : null,
                      incline: row['incline'] != null
                          ? _asDouble(row['incline'])
                          : null,
                      steps: row['steps'] != null ? _asInt(row['steps']) : null,
                    ),
                  )
                  .toList(growable: false),
        ),
    ];

    return CompletedWorkout(
      id: id,
      routineId: id,
      routineName: name,
      startedAt: start,
      completedAt: end,
      duration: end.difference(start).isNegative
          ? Duration.zero
          : end.difference(start),
      exercises: exercises,
    );
  }
}

final workoutHistoryRepositoryProvider = Provider<WorkoutHistoryRepository?>((
  ref,
) {
  final supabase = ref.watch(supabaseProvider);
  return supabase == null ? null : WorkoutHistoryRepository(supabase);
});

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _asDateTime(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString())?.toLocal();
}

String _slug(String value) => value
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-|-$'), '');
