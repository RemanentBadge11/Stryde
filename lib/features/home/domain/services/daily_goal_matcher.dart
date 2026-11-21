/// Applies Stryde's exact weight/repetition rules for a targeted Daily Goal.
bool setMeetsDailyGoalTarget({
  required double targetWeight,
  required int targetReps,
  required double actualWeight,
  required int actualReps,
}) {
  if (targetWeight > actualWeight) return false;
  if (targetWeight < actualWeight) return true;
  if (targetReps == actualReps) return true;

  final targetVolume = targetWeight * targetReps;
  final actualVolume = actualWeight * actualReps;
  return actualVolume >= targetVolume;
}
