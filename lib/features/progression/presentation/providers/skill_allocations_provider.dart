import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class SkillAllocationsNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() {
    return <String, int>{for (final muscle in skillMuscleGroups) muscle: 0};
  }

  bool spend(String muscle) {
    if (!skillMuscleGroups.contains(muscle)) return false;
    final spent = ref.read(userProgressionProvider.notifier).spendSkillPoint();
    if (!spent) return false;
    state = <String, int>{...state, muscle: (state[muscle] ?? 0) + 1};
    return true;
  }
}
