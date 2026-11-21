import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stryde/features/profile/domain/entities/profile_goals.dart';

final profileGoalsProvider =
    NotifierProvider<ProfileGoalsNotifier, ProfileGoals>(
      ProfileGoalsNotifier.new,
    );

class ProfileGoalsNotifier extends Notifier<ProfileGoals> {
  static const int stepIncrement = 500;
  static const double waterIncrement = 0.5;
  static const int proteinIncrement = 10;

  @override
  ProfileGoals build() => const ProfileGoals();

  void adjustSteps(int delta) {
    final next = (state.steps + delta).clamp(1000, 30000).toInt();
    state = state.copyWith(steps: next);
  }

  void adjustWater(double delta) {
    final next = (state.waterLiters + delta).clamp(0.5, 8.0).toDouble();
    state = state.copyWith(waterLiters: next);
  }

  void adjustProtein(int delta) {
    final next = (state.proteinGrams + delta).clamp(40, 400).toInt();
    state = state.copyWith(proteinGrams: next);
  }
}
