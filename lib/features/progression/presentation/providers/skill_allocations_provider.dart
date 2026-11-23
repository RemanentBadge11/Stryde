import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stryde/core/database/local_cache_service.dart';
import 'package:stryde/core/providers/loading_flag_notifier.dart';
import 'package:stryde/core/sync/sync_service.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/medals/presentation/providers/medals_provider.dart';
import 'package:stryde/features/progression/data/skills_repository.dart';
import 'package:stryde/features/progression/presentation/providers/user_progression_provider.dart';

const List<String> skillMuscleGroups = <String>[
  'Chest',
  'Back',
  'Legs',
  'Shoulders',
  'Biceps',
  'Triceps',
];

final skillAllocationsProvider =
    NotifierProvider<SkillAllocationsNotifier, Map<String, int>>(
      SkillAllocationsNotifier.new,
    );

final skillAllocationsLoadingProvider =
    NotifierProvider<LoadingFlagNotifier, bool>(LoadingFlagNotifier.new);

class SkillAllocationsNotifier extends Notifier<Map<String, int>> {
  String? _activeUserId;
  String? _loadingUserId;
  bool _hydrated = false;
  final Map<String, int> _pending = <String, int>{};
  Future<void> _persistenceQueue = Future<void>.value();

  SkillsRepository? get _repository => ref.read(skillsRepositoryProvider);

  @override
  Map<String, int> build() {
    final user = ref.read(currentUserProvider);
    _activeUserId = user?.id;
    if (user != null && _repository != null) {
      Future.microtask(() {
        if (_activeUserId == user.id) {
          ref.read(skillAllocationsLoadingProvider.notifier).setLoading(true);
        }
      });
      unawaited(_fetch(user.id));
    }
    ref.listen(currentUserProvider, (_, user) => _handleUserChanged(user));
    return _emptyAllocations();
  }

  void _handleUserChanged(User? user) {
    final userId = user?.id;
    if (userId == _activeUserId) return;
    _activeUserId = userId;
    _loadingUserId = null;
    _hydrated = false;
    _pending.clear();
    state = _emptyAllocations();

    final loading = userId != null && _repository != null;
    ref.read(skillAllocationsLoadingProvider.notifier).setLoading(loading);
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
      final cached = await localCache.getCachedSkills(userId);
      if (_activeUserId == userId && cached.isNotEmpty) {
        state = <String, int>{
          for (final muscle in skillMuscleGroups)
            muscle: (cached[muscle] ?? 0) + (_pending[muscle] ?? 0),
        };
      }
    } catch (_) {}

    final repository = _repository;
    if (repository == null) {
      _hydrated = true;
      _loadingUserId = null;
      ref.read(skillAllocationsLoadingProvider.notifier).setLoading(false);
      return;
    }

    // 2. Fetch from remote in background
    try {
      final remote = await repository.fetch(userId);
      if (_activeUserId != userId) return;
      state = <String, int>{
        for (final muscle in skillMuscleGroups)
          muscle: (remote[muscle] ?? 0) + (_pending[muscle] ?? 0),
      };
      _hydrated = true;
      await localCache.setCachedSkills(userId, remote);

      final pendingMuscles = _pending.keys.toList(growable: false);
      _pending.clear();
      for (final muscle in pendingMuscles) {
        _queueUpsert(muscle, state[muscle] ?? 0);
      }
    } catch (_) {
      if (_activeUserId == userId) {
        _hydrated = true;
        final pendingMuscles = _pending.keys.toList(growable: false);
        _pending.clear();
        for (final muscle in pendingMuscles) {
          _queueUpsert(muscle, state[muscle] ?? 0);
        }
      }
    } finally {
      if (_loadingUserId == userId) _loadingUserId = null;
      if (_activeUserId == userId) {
        ref.read(skillAllocationsLoadingProvider.notifier).setLoading(false);
      }
    }
  }

  bool spend(String muscle) {
    if (!skillMuscleGroups.contains(muscle)) return false;
    final spent = ref.read(userProgressionProvider.notifier).spendSkillPoint();
    if (!spent) return false;

    final points = (state[muscle] ?? 0) + 1;
    state = <String, int>{...state, muscle: points};
    _queueUpsert(muscle, points);
    ref.read(medalsProvider.notifier).evaluateAndUnlock();
    return true;
  }

  void _queueUpsert(String muscle, int points) {
    final userId = _activeUserId;
    if (userId == null) return;
    final localCache = ref.read(localCacheServiceProvider);

    _persistenceQueue = _persistenceQueue.then((_) async {
      try {
        final repo = _repository;
        if (repo != null) {
          try {
            await repo.upsert(
              userId: userId,
              muscleGroup: muscle,
              points: points,
            );
          } catch (_) {}
        }
        await localCache.saveCachedSkill(userId, muscle, points);
        await localCache.enqueue(
          entityType: 'skill',
          action: 'update',
          payload: <String, dynamic>{
            'userId': userId,
            'muscleGroup': muscle,
            'points': points,
          },
        );
        unawaited(ref.read(syncServiceProvider.notifier).syncPending());
      } catch (_) {
        // Keep the optimistic allocation while offline.
      }
    });
  }
}

Map<String, int> _emptyAllocations() => <String, int>{
  for (final muscle in skillMuscleGroups) muscle: 0,
};
