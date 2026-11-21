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
  const DailyGoalState({required this.goals, required this.endsAt});

  final List<DailyGoal> goals;
  final DateTime endsAt;
}
