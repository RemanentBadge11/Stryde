import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final loginStreakProvider =
    NotifierProvider<LoginStreakNotifier, LoginStreakState>(
      LoginStreakNotifier.new,
    );

class LoginStreakState {
  const LoginStreakState({required this.streak, required this.lastActivityOn});

  const LoginStreakState.empty() : streak = 0, lastActivityOn = null;

  final int streak;
  final DateTime? lastActivityOn;

  /// The visible streak can expire while the app remains open. Yesterday is
  /// still part of the current streak; a gap of two calendar days is a miss.
  int effectiveStreakAt(DateTime now) {
    final lastActivity = lastActivityOn;
    if (lastActivity == null) return 0;
    return _daysBetween(lastActivity, now) > 1 ? 0 : streak;
  }

  int get currentStreak => effectiveStreakAt(DateTime.now());

  LoginStreakState copyWith({int? streak, DateTime? lastActivityOn}) {
    return LoginStreakState(
      streak: streak ?? this.streak,
      lastActivityOn: lastActivityOn ?? this.lastActivityOn,
    );
  }
}

class LoginStreakNotifier extends Notifier<LoginStreakState> {
  Timer? _midnightTimer;

  @override
  LoginStreakState build() {
    ref.onDispose(() => _midnightTimer?.cancel());
    _scheduleMidnightRefresh();
    return const LoginStreakState.empty();
  }

  /// Records at most one qualifying activity per calendar day.
  ///
  /// A consecutive day adds one. The first activity after a missed day starts
  /// a fresh streak at one.
  bool recordActivity([DateTime? occurredAt]) {
    final activityDay = _dateOnly(occurredAt ?? DateTime.now());
    final previousDay = state.lastActivityOn;

    if (previousDay == null) {
      state = LoginStreakState(streak: 1, lastActivityOn: activityDay);
      return true;
    }

    final dayGap = _daysBetween(previousDay, activityDay);
    if (dayGap <= 0) return false;

    state = LoginStreakState(
      streak: dayGap == 1 ? state.streak + 1 : 1,
      lastActivityOn: activityDay,
    );
    return true;
  }

  void refreshIfNeeded([DateTime? now]) {
    final lastActivity = state.lastActivityOn;
    if (lastActivity == null || state.streak == 0) return;
    if (_daysBetween(lastActivity, now ?? DateTime.now()) > 1) {
      state = state.copyWith(streak: 0);
    }
  }

  void _scheduleMidnightRefresh() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer = Timer(nextMidnight.difference(now), () {
      refreshIfNeeded();
      _scheduleMidnightRefresh();
    });
  }
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

int _daysBetween(DateTime from, DateTime to) {
  final fromDay = DateTime.utc(from.year, from.month, from.day);
  final toDay = DateTime.utc(to.year, to.month, to.day);
  return toDay.difference(fromDay).inDays;
}
