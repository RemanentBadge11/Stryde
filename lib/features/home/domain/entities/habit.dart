import 'package:stryde/features/profile/domain/entities/profile_goals.dart';

class HabitDefinition {
  const HabitDefinition({
    required this.id,
    required this.title,
    required this.detail,
    required this.xp,
  });

  final String id;
  final String title;
  final String detail;
  final int xp;
}

class HabitState {
  HabitState({required Set<String> completedIds, required this.endsAt})
    : completedIds = Set<String>.unmodifiable(completedIds);

  final Set<String> completedIds;
  final DateTime endsAt;

  bool isCompleted(String id) => completedIds.contains(id);
}

List<HabitDefinition> habitDefinitionsFor(ProfileGoals goals) {
  return <HabitDefinition>[
    HabitDefinition(
      id: 'steps',
      title: 'Walk ${_formatNumber(goals.steps)} steps',
      detail: 'Daily movement target',
      xp: 30,
    ),
    HabitDefinition(
      id: 'water',
      title: 'Drink ${_formatWater(goals.waterLiters)}L water',
      detail: 'Hydration target',
      xp: 25,
    ),
    HabitDefinition(
      id: 'protein',
      title: 'Hit ${goals.proteinGrams}g protein',
      detail: 'Nutrition target',
      xp: 30,
    ),
    const HabitDefinition(
      id: 'gym',
      title: 'Go to the gym',
      detail: 'Complete a session today',
      xp: 50,
    ),
  ];
}

String _formatNumber(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

String _formatWater(double value) => value == value.roundToDouble()
    ? value.toStringAsFixed(0)
    : value.toStringAsFixed(1);
