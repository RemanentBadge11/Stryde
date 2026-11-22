import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/profile/data/profile_repository.dart';
import 'package:stryde/features/profile/domain/entities/profile_goals.dart';

final profileGoalsProvider =
    NotifierProvider<ProfileGoalsNotifier, ProfileGoals>(
      ProfileGoalsNotifier.new,
    );

class ProfileGoalsNotifier extends Notifier<ProfileGoals> {
  static const int stepIncrement = 500;
  static const double waterIncrement = 0.5;
  static const int proteinIncrement = 10;

  String? _activeUserId;
  ProfileRepository? get _repository => ref.read(profileRepositoryProvider);

  @override
  ProfileGoals build() {
    final user = ref.read(currentUserProvider);
    _activeUserId = user?.id;
    if (user != null && _repository != null) {
      unawaited(_hydrate(user.id));
    }

    ref.listen(currentUserProvider, (_, user) {
      final userId = user?.id;
      if (userId == _activeUserId) return;
      _activeUserId = userId;
      state = const ProfileGoals();
      if (userId != null && _repository != null) {
        unawaited(_hydrate(userId));
      }
    });

    return const ProfileGoals();
  }

  Future<void> _hydrate(String userId) async {
    final repo = _repository;
    if (repo == null) return;
    try {
      final data = await repo.fetch(userId);
      if (_activeUserId != userId || data == null) return;
      state = ProfileGoals(
        steps: data.goalSteps ?? state.steps,
        waterLiters: data.goalWater ?? state.waterLiters,
        proteinGrams: data.goalProtein ?? state.proteinGrams,
      );
    } catch (_) {
      // Degrades gracefully
    }
  }

  void adjustSteps(int delta) {
    final next = (state.steps + delta).clamp(1000, 30000).toInt();
    state = state.copyWith(steps: next);
    _persist();
  }

  void adjustWater(double delta) {
    final next = (state.waterLiters + delta).clamp(0.5, 8.0).toDouble();
    state = state.copyWith(waterLiters: next);
    _persist();
  }

  void adjustProtein(int delta) {
    final next = (state.proteinGrams + delta).clamp(40, 400).toInt();
    state = state.copyWith(proteinGrams: next);
    _persist();
  }

  void setGoals({int? steps, double? water, int? protein}) {
    state = state.copyWith(
      steps: steps,
      waterLiters: water,
      proteinGrams: protein,
    );
    _persist();
  }

  void _persist() {
    final userId = _activeUserId;
    final repo = _repository;
    if (userId != null && repo != null) {
      unawaited(
        repo.saveGoals(
          userId: userId,
          steps: state.steps,
          water: state.waterLiters,
          protein: state.proteinGrams,
        ),
      );
    }
  }
}
