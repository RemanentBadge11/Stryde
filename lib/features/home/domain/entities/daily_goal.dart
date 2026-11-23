import 'package:stryde/features/home/domain/entities/user_quest.dart';

class DailyGoal {
  const DailyGoal({
    required this.id,
    required this.title,
    required this.detail,
    this.xp = 25,
    this.isCompleted = false,
    this.exerciseId,
    this.targetWeight,
    this.targetReps,
  });

  factory DailyGoal.fromUserQuest(UserQuest quest) {
    double? weight = quest.targetValue;
    int? reps;
    final match = RegExp(
      r'([\d.]+)\s*kg\s*[×x*]\s*(\d+)\s*reps',
      caseSensitive: false,
    ).firstMatch(quest.title);
    if (match != null) {
      weight = double.tryParse(match.group(1)!);
      reps = int.tryParse(match.group(2)!);
    }
    return DailyGoal(
      id: quest.id,
      title: quest.title,
      detail: quest.description,
      xp: quest.xpReward,
      isCompleted: quest.isCompleted,
      exerciseId: quest.exerciseName,
      targetWeight: weight,
      targetReps: reps,
    );
  }

  final String id;
  final String title;
  final String detail;
  final int xp;
  final bool isCompleted;
  final String? exerciseId;
  final double? targetWeight;
  final int? targetReps;

  bool get hasSetTarget =>
      exerciseId != null && targetWeight != null && targetReps != null;

  DailyGoal copyWith({bool? isCompleted}) {
    return DailyGoal(
      id: id,
      title: title,
      detail: detail,
      xp: xp,
      isCompleted: isCompleted ?? this.isCompleted,
      exerciseId: exerciseId,
      targetWeight: targetWeight,
      targetReps: targetReps,
    );
  }
}

class DailyGoalState {
  const DailyGoalState({
    required this.goals,
    required this.endsAt,
    this.isEmptyOffline = false,
  });

  final List<DailyGoal> goals;
  final DateTime endsAt;
  final bool isEmptyOffline;
}
