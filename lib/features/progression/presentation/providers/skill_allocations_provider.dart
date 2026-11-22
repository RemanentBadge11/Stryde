import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stryde/core/providers/loading_flag_notifier.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
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
      ref.read(skillAllocationsLoadingProvider.notifier).setLoading(true);
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
    final repository = _repository;
    if (repository == null) return;
    _loadingUserId = userId;

    try {
      final remote = await repository.fetch(userId);
      if (_activeUserId != userId) return;
      state = <String, int>{
        for (final muscle in skillMuscleGroups)
          muscle: (remote[muscle] ?? 0) + (_pending[muscle] ?? 0),
      };
      _hydrated = true;
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
    if (_activeUserId != null && !_hydrated) {
      _pending[muscle] = (_pending[muscle] ?? 0) + 1;
    } else {
      _queueUpsert(muscle, points);
    }
    return true;
  }

  void _queueUpsert(String muscle, int points) {
    final userId = _activeUserId;
    final repository = _repository;
    if (userId == null || repository == null) return;
    _persistenceQueue = _persistenceQueue.then((_) async {
      try {
        await repository.upsert(
          userId: userId,
          muscleGroup: muscle,
          points: points,
        );
      } catch (_) {
        // Keep the optimistic allocation while offline.
      }
    });
  }
}

Map<String, int> _emptyAllocations() => <String, int>{
  for (final muscle in skillMuscleGroups) muscle: 0,
};
