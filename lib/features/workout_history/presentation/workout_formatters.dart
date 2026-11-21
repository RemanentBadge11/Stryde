String formatWorkoutTimestamp(DateTime dateTime) {
  final hour = dateTime.hour == 0
      ? 12
      : dateTime.hour > 12
      ? dateTime.hour - 12
      : dateTime.hour;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = dateTime.hour >= 12 ? 'PM' : 'AM';
  return '${dateTime.day}/${dateTime.month}/${dateTime.year} · $hour:$minute $period';
}

String formatWorkoutDuration(Duration duration) {
  final minutes = duration.inMinutes;
  if (minutes < 1) return '< 1 min';
  return '$minutes min';
}

String formatLedgerTimestamp(DateTime dateTime) {
  final now = DateTime.now();
  final sameDay =
      now.year == dateTime.year &&
      now.month == dateTime.month &&
      now.day == dateTime.day;
  final hour = dateTime.hour == 0
      ? 12
      : dateTime.hour > 12
      ? dateTime.hour - 12
      : dateTime.hour;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = dateTime.hour >= 12 ? 'PM' : 'AM';
  return sameDay
      ? '$hour:$minute $period'
      : '${dateTime.day}/${dateTime.month} · $hour:$minute $period';
}
