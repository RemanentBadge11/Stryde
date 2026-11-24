import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stryde/core/database/local_cache_service.dart';
import 'package:stryde/core/providers/loading_flag_notifier.dart';
import 'package:stryde/core/sync/sync_service.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/social/data/social_repository.dart';
import 'package:stryde/features/workout_history/data/workout_history_repository.dart';
import 'package:stryde/features/workout_history/domain/entities/completed_workout.dart';

final workoutHistoryProvider =
    NotifierProvider<WorkoutHistoryNotifier, List<CompletedWorkout>>(
      WorkoutHistoryNotifier.new,
    );

final workoutHistoryLoadingProvider =
    NotifierProvider<LoadingFlagNotifier, bool>(LoadingFlagNotifier.new);

class WorkoutHistoryNotifier extends Notifier<List<CompletedWorkout>> {
  String? _activeUserId;
  String? _loadingUserId;
  bool _hydrated = false;
  final List<CompletedWorkout> _pending = <CompletedWorkout>[];

  WorkoutHistoryRepository? get _repository =>
      ref.read(workoutHistoryRepositoryProvider);

  @override
  List<CompletedWorkout> build() {
    final user = ref.read(currentUserProvider);
    _activeUserId = user?.id;
    if (user != null && _repository != null) {
      Future.microtask(() {
        if (_activeUserId == user.id) {
          ref.read(workoutHistoryLoadingProvider.notifier).setLoading(true);
        }
      });
      unawaited(_fetch(user.id));
    }
    ref.listen(currentUserProvider, (_, user) => _handleUserChanged(user));
    return const <CompletedWorkout>[];
  }

  void _handleUserChanged(User? user) {
    final userId = user?.id;
    if (userId == _activeUserId) return;
    _activeUserId = userId;
    _loadingUserId = null;
    _hydrated = false;
    _pending.clear();
    state = const <CompletedWorkout>[];

    final loading = userId != null && _repository != null;
    ref.read(workoutHistoryLoadingProvider.notifier).setLoading(loading);
    if (loading) unawaited(_fetch(userId));
  }

  Future<void> _fetch(String userId) async {
    if (_activeUserId != userId || _hydrated || _loadingUserId == userId) {
      return;
    }
    _loadingUserId = userId;
    final localCache = ref.read(localCacheServiceProvider);

    // 1. Read from local cache first
    try {
      final cached = await localCache.getCachedWorkouts(userId);
      if (_activeUserId == userId && cached.isNotEmpty) {
        final pending = List<CompletedWorkout>.of(_pending);
        state = _merge(pending, cached);
      }
    } catch (_) {}

    final repository = _repository;
    if (repository == null) {
      _hydrated = true;
      _loadingUserId = null;
      ref.read(workoutHistoryLoadingProvider.notifier).setLoading(false);
      return;
    }

    // 2. Fetch from remote in background
    try {
      final remote = await repository.fetch(userId);
      if (_activeUserId != userId) return;
      final pending = List<CompletedWorkout>.of(_pending);
      state = _merge(pending, remote);
      _pending.clear();
      _hydrated = true;
      await localCache.setCachedWorkouts(userId, state);

      for (final workout in pending) {
        unawaited(_insert(userId, workout));
      }
    } catch (_) {
      if (_activeUserId == userId) {
        final pending = List<CompletedWorkout>.of(_pending);
        _pending.clear();
        _hydrated = true;
        for (final workout in pending) {
          unawaited(_insert(userId, workout));
        }
      }
    } finally {
      if (_loadingUserId == userId) _loadingUserId = null;
      if (_activeUserId == userId) {
        ref.read(workoutHistoryLoadingProvider.notifier).setLoading(false);
      }
    }
  }

  void addWorkout(
    CompletedWorkout workout, {
    List<String> prExercises = const <String>[],
  }) {
    state = <CompletedWorkout>[workout, ...state];
    final userId = _activeUserId;
    if (userId == null) return;

    unawaited(_insert(userId, workout, prExercises: prExercises));
  }

  Future<void> _insert(
    String userId,
    CompletedWorkout workout, {
    List<String> prExercises = const <String>[],
  }) async {
    final localCache = ref.read(localCacheServiceProvider);
    try {
      final repo = _repository;
      if (repo != null) {
        try {
          await repo.insert(userId: userId, workout: workout);
        } catch (_) {}
      }
      try {
        final socialRepo = ref.read(socialRepositoryProvider);
        await socialRepo.publishWorkoutPost(
          userId: userId,
          workout: workout,
          prExercises: prExercises,
        );
      } catch (_) {}
      // 1. Save to local cache first
      await localCache.saveCachedWorkout(userId, workout);
      // 2. Add to sync queue
      await localCache.enqueue(
        entityType: 'workout',
        action: 'insert',
        payload: <String, dynamic>{
          'userId': userId,
          'workout': workout.toJson(),
          'prExercises': prExercises,
        },
      );
      // 3. Trigger sync worker
      unawaited(ref.read(syncServiceProvider.notifier).syncPending());
    } catch (_) {
      // Keep optimistic workout in memory
    }
  }

  List<CompletedWorkout> _merge(
    List<CompletedWorkout> pending,
    List<CompletedWorkout> remote,
  ) {
    final seen = <String>{};
    final merged = <CompletedWorkout>[
      ...pending,
      ...remote,
    ].where((workout) => seen.add(workout.id)).toList();
    merged.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return merged;
  }
}
