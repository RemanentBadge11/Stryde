import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/medals/data/medals_repository.dart';
import 'package:stryde/features/medals/domain/entities/medal.dart';
import 'package:stryde/features/workout_history/domain/entities/completed_workout.dart';

int calculateTotalPrsFromHistory(List<CompletedWorkout> history) {
  final sorted = List<CompletedWorkout>.from(history)
    ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

  final exerciseMaxVolumes = <String, double>{};
  int prCount = 0;

  for (final workout in sorted) {
    for (final exercise in workout.exercises) {
      final prevMax = exerciseMaxVolumes[exercise.exerciseId] ?? 0;
      double sessionMax = 0;
      for (final s in exercise.sets) {
        if (s.volume > sessionMax) {
          sessionMax = s.volume;
        }
      }
      if (sessionMax > 0 && sessionMax > prevMax) {
        prCount++;
        exerciseMaxVolumes[exercise.exerciseId] = sessionMax;
      }
    }
  }

  return prCount;
}

class MedalsState {
  const MedalsState({
    this.unlockedMedals = const <String, DateTime>{},
    this.isLoading = false,
  });

  final Map<String, DateTime> unlockedMedals;
  final bool isLoading;

  bool isUnlocked(String medalId) => unlockedMedals.containsKey(medalId);
  int get unlockedCount => unlockedMedals.length;

  MedalsState copyWith({
    Map<String, DateTime>? unlockedMedals,
    bool? isLoading,
  }) {
    return MedalsState(
      unlockedMedals: unlockedMedals ?? this.unlockedMedals,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final medalsProvider =
    NotifierProvider<MedalsNotifier, MedalsState>(MedalsNotifier.new);

class MedalsNotifier extends Notifier<MedalsState> {
  String? _activeUserId;
  MedalsRepository? get _repository => ref.read(medalsRepositoryProvider);

  @override
  MedalsState build() {
    final user = ref.watch(currentUserProvider);
    _activeUserId = user?.id;

    if (user != null && _repository != null) {
      unawaited(_hydrate(user.id));
    }

    return const MedalsState();
  }

  Future<void> _hydrate(String userId) async {
    final repo = _repository;
    if (repo == null) return;
    try {
      final medals = await repo.fetchUnlockedMedals(userId);
      if (_activeUserId != userId) return;
      final merged = <String, DateTime>{
        ...medals,
        ...state.unlockedMedals,
      };
      state = state.copyWith(unlockedMedals: merged);
    } catch (_) {
      // Degrades gracefully
    }
  }

  Future<void> evaluateAndUnlock({
    int? level,
    int? streak,
    int? totalPrs,
    bool? hasNewPr,
  }) async {
    final userId = _activeUserId;
    final repo = _repository;
    if (userId == null) return;

    final updated = Map<String, DateTime>.from(state.unlockedMedals);
    final newlyUnlocked = <String>[];

    for (final medal in kStaticMedals) {
      if (updated.containsKey(medal.id)) continue;

      bool shouldUnlock = false;
      switch (medal.id) {
        case 'first_pr':
          shouldUnlock = hasNewPr == true || (totalPrs != null && totalPrs >= 1);
        case 'five_prs':
          shouldUnlock = totalPrs != null && totalPrs >= 5;
        case 'level_5':
          shouldUnlock = level != null && level >= 5;
        case 'level_10':
          shouldUnlock = level != null && level >= 10;
        case 'streak_7':
          shouldUnlock = streak != null && streak >= 7;
        case 'streak_30':
          shouldUnlock = streak != null && streak >= 30;
      }

      if (shouldUnlock) {
        final now = DateTime.now();
        updated[medal.id] = now;
        newlyUnlocked.add(medal.id);
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      state = state.copyWith(unlockedMedals: updated);
      if (repo != null) {
        for (final medalId in newlyUnlocked) {
          unawaited(repo.unlockMedal(userId: userId, medalId: medalId));
        }
      }
    }
  }
}
