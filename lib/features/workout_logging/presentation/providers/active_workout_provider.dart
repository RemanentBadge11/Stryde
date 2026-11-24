import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stryde/core/database/local_cache_service.dart';
import 'package:stryde/core/services/audio_service.dart';
import 'package:stryde/core/sync/sync_service.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/home/presentation/providers/daily_goals_provider.dart';
import 'package:stryde/features/home/presentation/providers/login_streak_provider.dart';
import 'package:stryde/features/medals/presentation/providers/medals_provider.dart';
import 'package:stryde/features/progression/domain/entities/rank.dart';
import 'package:stryde/features/progression/domain/entities/xp_transaction.dart';
import 'package:stryde/features/progression/presentation/providers/user_progression_provider.dart';
import 'package:stryde/features/progression/presentation/providers/xp_transactions_provider.dart';
import 'package:stryde/features/routines/domain/entities/exercise.dart';
import 'package:stryde/features/routines/domain/entities/workout_routine.dart';
import 'package:stryde/features/workout_history/domain/entities/completed_workout.dart';
import 'package:stryde/features/workout_history/presentation/providers/workout_history_provider.dart';

final activeWorkoutProvider =
    NotifierProvider<ActiveWorkoutNotifier, ActiveWorkoutState>(
      ActiveWorkoutNotifier.new,
    );

class ActiveWorkoutState {
  const ActiveWorkoutState({
    required this.session,
    required this.now,
    required this.isMinimized,
  });

  factory ActiveWorkoutState.idle([DateTime? now]) => ActiveWorkoutState(
    session: null,
    now: now ?? DateTime.now(),
    isMinimized: false,
  );

  final ActiveWorkoutSession? session;

  /// Updated once per second while a workout is active so timer consumers
  /// rebuild without owning their own timers.
  final DateTime now;

  /// True only after the workout route is popped. This makes the navbar morph
  /// while it is being revealed instead of animating behind the active route.
  final bool isMinimized;

  bool get isOngoing => session != null;

  bool get isPaused => session?.pausedAt != null;

  Duration get elapsed {
    final activeSession = session;
    if (activeSession == null) return Duration.zero;
    return activeSession.elapsedAt(now);
  }

  int? get restSecondsRemaining {
    final endsAt = session?.restEndsAt;
    if (endsAt == null) return null;
    final milliseconds = endsAt.difference(now).inMilliseconds;
    if (milliseconds <= 0) return null;
    return (milliseconds + 999) ~/ 1000;
  }
}

class ActiveWorkoutSession {
  ActiveWorkoutSession({
    required this.routine,
    required this.startedAt,
    required List<ActiveWorkoutExercise> exercises,
    required this.nextSetId,
    this.restEndsAt,
    this.accumulatedPausedDuration = Duration.zero,
    this.pausedAt,
  }) : exercises = List<ActiveWorkoutExercise>.unmodifiable(exercises);

  final WorkoutRoutine routine;
  final DateTime startedAt;
  final List<ActiveWorkoutExercise> exercises;
  final int nextSetId;
  final DateTime? restEndsAt;
  final Duration accumulatedPausedDuration;
  final DateTime? pausedAt;

  bool get hasCompletedSets =>
      exercises.any((exercise) => exercise.sets.any((set) => set.isCompleted));

  Duration elapsedAt(DateTime at) {
    final effectiveEnd = pausedAt ?? at;
    final elapsed =
        effectiveEnd.difference(startedAt) - accumulatedPausedDuration;
    return elapsed.isNegative ? Duration.zero : elapsed;
  }

  ActiveWorkoutSession copyWith({
    List<ActiveWorkoutExercise>? exercises,
    int? nextSetId,
    DateTime? restEndsAt,
    bool clearRestTimer = false,
    Duration? accumulatedPausedDuration,
    DateTime? pausedAt,
    bool clearPausedAt = false,
  }) {
    return ActiveWorkoutSession(
      routine: routine,
      startedAt: startedAt,
      exercises: exercises ?? this.exercises,
      nextSetId: nextSetId ?? this.nextSetId,
      restEndsAt: clearRestTimer ? null : restEndsAt ?? this.restEndsAt,
      accumulatedPausedDuration:
          accumulatedPausedDuration ?? this.accumulatedPausedDuration,
      pausedAt: clearPausedAt ? null : pausedAt ?? this.pausedAt,
    );
  }
}

class ActiveWorkoutExercise {
  ActiveWorkoutExercise({
    required this.exercise,
    required List<ActiveWorkoutSet> sets,
  }) : sets = List<ActiveWorkoutSet>.unmodifiable(sets);

  final Exercise exercise;
  final List<ActiveWorkoutSet> sets;

  ActiveWorkoutExercise copyWith({List<ActiveWorkoutSet>? sets}) {
    return ActiveWorkoutExercise(exercise: exercise, sets: sets ?? this.sets);
  }
}

class ActiveWorkoutSet {
  const ActiveWorkoutSet({
    required this.id,
    this.weightText = '',
    this.repsText = '',
    this.timeText = '',
    this.distanceText = '',
    this.inclineText = '',
    this.resistanceText = '',
    this.stepsText = '',
    this.isCompleted = false,
  });

  final int id;
  final String weightText;
  final String repsText;
  final String timeText;
  final String distanceText;
  final String inclineText;
  final String resistanceText;
  final String stepsText;
  final bool isCompleted;

  ActiveWorkoutSet copyWith({
    String? weightText,
    String? repsText,
    String? timeText,
    String? distanceText,
    String? inclineText,
    String? resistanceText,
    String? stepsText,
    bool? isCompleted,
  }) {
    return ActiveWorkoutSet(
      id: id,
      weightText: weightText ?? this.weightText,
      repsText: repsText ?? this.repsText,
      timeText: timeText ?? this.timeText,
      distanceText: distanceText ?? this.distanceText,
      inclineText: inclineText ?? this.inclineText,
      resistanceText: resistanceText ?? this.resistanceText,
      stepsText: stepsText ?? this.stepsText,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

enum SetCompletionResult { completed, uncompleted, invalid, unavailable }

class WorkoutFinishResult {
  const WorkoutFinishResult({
    required this.workout,
    required this.previousLevel,
    required this.newLevel,
    required this.completedDailyGoals,
    required this.xpAwarded,
    this.prExercises = const <String>[],
  });

  final CompletedWorkout workout;
  final int previousLevel;
  final int newLevel;
  final int completedDailyGoals;
  final int xpAwarded;
  final List<String> prExercises;

  bool get hasPr => prExercises.isNotEmpty;
}

class ActiveWorkoutNotifier extends Notifier<ActiveWorkoutState> {
  static const int workoutXp = 100;
  static const Duration defaultRestDuration = Duration(seconds: 90);

  Timer? _ticker;
  bool _isFinishing = false;

  @override
  ActiveWorkoutState build() {
    ref.onDispose(() => _ticker?.cancel());
    return ActiveWorkoutState.idle();
  }

  bool startWorkout(WorkoutRoutine routine, {DateTime? startedAt}) {
    if (state.isOngoing) return false;
    _isFinishing = false;

    final now = startedAt ?? DateTime.now();
    var nextSetId = 0;
    final exercises = <ActiveWorkoutExercise>[
      for (final prescription in routine.exercises)
        ActiveWorkoutExercise(
          exercise: prescription.exercise,
          sets: <ActiveWorkoutSet>[
            for (var i = 0; i < prescription.targetSets; i++)
              ActiveWorkoutSet(
                id: nextSetId++,
                weightText:
                    (prescription.targetSetDetails != null &&
                        i < prescription.targetSetDetails!.length &&
                        prescription.targetSetDetails![i].weightKg != null &&
                        prescription.targetSetDetails![i].weightKg! > 0)
                    ? (prescription.targetSetDetails![i].weightKg! ==
                              prescription.targetSetDetails![i].weightKg!
                                  .roundToDouble()
                          ? prescription.targetSetDetails![i].weightKg!
                                .toInt()
                                .toString()
                          : prescription.targetSetDetails![i].weightKg!
                                .toString())
                    : '',
                repsText:
                    (prescription.targetSetDetails != null &&
                        i < prescription.targetSetDetails!.length &&
                        prescription.targetSetDetails![i].reps != null &&
                        prescription.targetSetDetails![i].reps! > 0)
                    ? prescription.targetSetDetails![i].reps!.toString()
                    : ((prescription.targetReps != null &&
                              !prescription.exercise.isCardioExercise)
                          ? prescription.targetReps.toString()
                          : ''),
              ),
          ],
        ),
    ];

    state = ActiveWorkoutState(
      session: ActiveWorkoutSession(
        routine: routine,
        startedAt: now,
        exercises: exercises,
        nextSetId: nextSetId,
      ),
      now: now,
      isMinimized: false,
    );
    _startTicker();
    return true;
  }

  void addExercise(RoutineExercise prescription) {
    final session = state.session;
    if (session == null) return;

    var nextSetId = session.nextSetId;
    final draft = ActiveWorkoutExercise(
      exercise: prescription.exercise,
      sets: <ActiveWorkoutSet>[
        for (var i = 0; i < prescription.targetSets; i++)
          ActiveWorkoutSet(
            id: nextSetId++,
            weightText:
                (prescription.targetSetDetails != null &&
                    i < prescription.targetSetDetails!.length &&
                    prescription.targetSetDetails![i].weightKg != null &&
                    prescription.targetSetDetails![i].weightKg! > 0)
                ? (prescription.targetSetDetails![i].weightKg! ==
                          prescription.targetSetDetails![i].weightKg!
                              .roundToDouble()
                      ? prescription.targetSetDetails![i].weightKg!
                            .toInt()
                            .toString()
                      : prescription.targetSetDetails![i].weightKg!.toString())
                : '',
            repsText:
                (prescription.targetSetDetails != null &&
                    i < prescription.targetSetDetails!.length &&
                    prescription.targetSetDetails![i].reps != null &&
                    prescription.targetSetDetails![i].reps! > 0)
                ? prescription.targetSetDetails![i].reps!.toString()
                : ((prescription.targetReps != null &&
                          !prescription.exercise.isCardioExercise)
                      ? prescription.targetReps.toString()
                      : ''),
          ),
      ],
    );
    _setSession(
      session.copyWith(
        exercises: <ActiveWorkoutExercise>[...session.exercises, draft],
        nextSetId: nextSetId,
      ),
    );
  }

  void removeExercise(int exerciseIndex) {
    final session = state.session;
    if (!_validExerciseIndex(session, exerciseIndex)) return;
    final exercises = <ActiveWorkoutExercise>[...session!.exercises]
      ..removeAt(exerciseIndex);
    _setSession(session.copyWith(exercises: exercises));
  }

  void addSet(int exerciseIndex) {
    final session = state.session;
    if (!_validExerciseIndex(session, exerciseIndex)) return;
    final exercise = session!.exercises[exerciseIndex];
    final previous = exercise.sets.isEmpty ? null : exercise.sets.last;
    final set = ActiveWorkoutSet(
      id: session.nextSetId,
      weightText: previous?.weightText ?? '',
      repsText: previous?.repsText ?? '',
      timeText: previous?.timeText ?? '',
      distanceText: previous?.distanceText ?? '',
      inclineText: previous?.inclineText ?? '',
      resistanceText: previous?.resistanceText ?? '',
      stepsText: previous?.stepsText ?? '',
    );
    _replaceExercise(
      session,
      exerciseIndex,
      exercise.copyWith(sets: <ActiveWorkoutSet>[...exercise.sets, set]),
      nextSetId: session.nextSetId + 1,
    );
  }

  void clearSets(int exerciseIndex) {
    final session = state.session;
    if (!_validExerciseIndex(session, exerciseIndex)) return;
    final exercise = session!.exercises[exerciseIndex];
    final set = ActiveWorkoutSet(id: session.nextSetId);
    _replaceExercise(
      session,
      exerciseIndex,
      exercise.copyWith(sets: <ActiveWorkoutSet>[set]),
      nextSetId: session.nextSetId + 1,
    );
  }

  void duplicateSet(int exerciseIndex, int setIndex) {
    final session = state.session;
    if (!_validSetIndex(session, exerciseIndex, setIndex)) return;
    final exercise = session!.exercises[exerciseIndex];
    final source = exercise.sets[setIndex];
    final duplicate = ActiveWorkoutSet(
      id: session.nextSetId,
      weightText: source.weightText,
      repsText: source.repsText,
      timeText: source.timeText,
      distanceText: source.distanceText,
      inclineText: source.inclineText,
      resistanceText: source.resistanceText,
      stepsText: source.stepsText,
    );
    final sets = <ActiveWorkoutSet>[...exercise.sets]
      ..insert(setIndex + 1, duplicate);
    _replaceExercise(
      session,
      exerciseIndex,
      exercise.copyWith(sets: sets),
      nextSetId: session.nextSetId + 1,
    );
  }

  void deleteSet(int exerciseIndex, int setIndex) {
    final session = state.session;
    if (!_validSetIndex(session, exerciseIndex, setIndex)) return;
    final exercise = session!.exercises[exerciseIndex];
    final sets = <ActiveWorkoutSet>[...exercise.sets];
    var nextSetId = session.nextSetId;
    if (sets.length == 1) {
      sets[0] = ActiveWorkoutSet(id: nextSetId++);
    } else {
      sets.removeAt(setIndex);
    }
    _replaceExercise(
      session,
      exerciseIndex,
      exercise.copyWith(sets: sets),
      nextSetId: nextSetId,
    );
  }

  void updateWeight(int exerciseIndex, int setIndex, String value) {
    _updateSet(
      exerciseIndex,
      setIndex,
      (set) => set.copyWith(weightText: value),
    );
  }

  void updateReps(int exerciseIndex, int setIndex, String value) {
    _updateSet(exerciseIndex, setIndex, (set) => set.copyWith(repsText: value));
  }

  void updateTime(int exerciseIndex, int setIndex, String value) {
    _updateSet(exerciseIndex, setIndex, (set) => set.copyWith(timeText: value));
  }

  void updateDistance(int exerciseIndex, int setIndex, String value) {
    _updateSet(
      exerciseIndex,
      setIndex,
      (set) => set.copyWith(distanceText: value),
    );
  }

  void updateIncline(int exerciseIndex, int setIndex, String value) {
    _updateSet(
      exerciseIndex,
      setIndex,
      (set) => set.copyWith(inclineText: value),
    );
  }

  void updateResistance(int exerciseIndex, int setIndex, String value) {
    _updateSet(
      exerciseIndex,
      setIndex,
      (set) => set.copyWith(resistanceText: value),
    );
  }

  void updateSteps(int exerciseIndex, int setIndex, String value) {
    _updateSet(
      exerciseIndex,
      setIndex,
      (set) => set.copyWith(stepsText: value),
    );
  }

  SetCompletionResult toggleSetCompletion(int exerciseIndex, int setIndex) {
    final session = state.session;
    if (!_validSetIndex(session, exerciseIndex, setIndex)) {
      return SetCompletionResult.unavailable;
    }
    final targetExercise = session!.exercises[exerciseIndex];
    final set = targetExercise.sets[setIndex];
    if (set.isCompleted) {
      _updateSet(
        exerciseIndex,
        setIndex,
        (current) => current.copyWith(isCompleted: false),
      );
      return SetCompletionResult.uncompleted;
    }

    if (!_validateSet(targetExercise.exercise.type, set)) {
      return SetCompletionResult.invalid;
    }

    _updateSet(
      exerciseIndex,
      setIndex,
      (current) => current.copyWith(isCompleted: true),
    );
    startRestTimer();
    return SetCompletionResult.completed;
  }

  bool _validateSet(String type, ActiveWorkoutSet set) {
    switch (type) {
      case 'strength':
      case 'weighted':
        final weight = double.tryParse(set.weightText.replaceAll(',', '.'));
        final reps = int.tryParse(set.repsText);
        return weight != null && weight >= 0 && reps != null && reps > 0;
      case 'bodyweight':
      case 'reps_only_cardio':
        final reps = int.tryParse(set.repsText);
        return reps != null && reps > 0;
      case 'time':
      case 'time_only_cardio':
      case 'distance_cardio':
        final seconds = _parseDurationSeconds(set.timeText);
        return seconds > 0;
      case 'resistance':
        final reps = int.tryParse(set.repsText);
        return set.resistanceText.trim().isNotEmpty && reps != null && reps > 0;
      case 'cardio':
        final seconds = _parseDurationSeconds(set.timeText);
        final distance = double.tryParse(set.distanceText.replaceAll(',', '.'));
        return seconds > 0 && distance != null && distance > 0;
      case 'incline_cardio':
        final incline = double.tryParse(set.inclineText.replaceAll(',', '.'));
        final distance = double.tryParse(set.distanceText.replaceAll(',', '.'));
        final seconds = _parseDurationSeconds(set.timeText);
        return incline != null &&
            incline >= 0 &&
            distance != null &&
            distance > 0 &&
            seconds > 0;
      case 'steps_cardio':
        final steps = int.tryParse(set.stepsText);
        final seconds = _parseDurationSeconds(set.timeText);
        return steps != null && steps > 0 && seconds > 0;
      default:
        final weight = double.tryParse(set.weightText.replaceAll(',', '.'));
        final reps = int.tryParse(set.repsText);
        return weight != null && weight >= 0 && reps != null && reps > 0;
    }
  }

  void startRestTimer({Duration duration = defaultRestDuration}) {
    final session = state.session;
    if (session == null) return;
    final now = DateTime.now();
    _setSession(session.copyWith(restEndsAt: now.add(duration)), now: now);
  }

  void skipRestTimer() {
    final session = state.session;
    if (session == null) return;
    _setSession(session.copyWith(clearRestTimer: true));
  }

  void addRestTime([Duration duration = const Duration(seconds: 15)]) {
    final session = state.session;
    final currentEnd = session?.restEndsAt;
    if (session == null || currentEnd == null) return;
    _setSession(session.copyWith(restEndsAt: currentEnd.add(duration)));
  }

  void minimizeWorkout() {
    final session = state.session;
    if (session == null || state.isMinimized) return;
    state = ActiveWorkoutState(
      session: session,
      now: state.now,
      isMinimized: true,
    );
  }

  void resumeWorkout() {
    final session = state.session;
    if (session == null || !state.isMinimized) return;
    state = ActiveWorkoutState(
      session: session,
      now: state.now,
      isMinimized: false,
    );
  }

  void toggleTimer([DateTime? changedAt]) {
    final session = state.session;
    if (session == null) return;
    final now = changedAt ?? DateTime.now();
    final pausedAt = session.pausedAt;
    if (pausedAt == null) {
      _setSession(session.copyWith(pausedAt: now), now: now);
      return;
    }

    final rawPauseDuration = now.difference(pausedAt);
    final pauseDuration = rawPauseDuration.isNegative
        ? Duration.zero
        : rawPauseDuration;
    _setSession(
      session.copyWith(
        accumulatedPausedDuration:
            session.accumulatedPausedDuration + pauseDuration,
        clearPausedAt: true,
      ),
      now: now,
    );
  }

  bool discardWorkout() {
    _isFinishing = false;
    if (state.session == null) return false;
    _ticker?.cancel();
    _ticker = null;
    state = ActiveWorkoutState.idle();
    return true;
  }

  WorkoutFinishResult? finishWorkout({DateTime? completedAt}) {
    if (_isFinishing) return null;
    final session = state.session;
    if (session == null) return null;

    _isFinishing = true;
    try {
      final now = completedAt ?? DateTime.now();
      final exercises = <CompletedWorkoutExercise>[];
      for (final exercise in session.exercises) {
        final sets = <CompletedWorkoutSet>[];
        final type = exercise.exercise.type;
        for (var i = 0; i < exercise.sets.length; i++) {
          final set = exercise.sets[i];
          if (!set.isCompleted) continue;

          double weight = 0;
          int reps = 0;
          int? durationSeconds;
          String? resistanceLevel;
          double? distance;
          double? incline;
          int? steps;

          switch (type) {
            case 'strength':
            case 'weighted':
              weight =
                  double.tryParse(set.weightText.replaceAll(',', '.')) ?? 0;
              reps = int.tryParse(set.repsText) ?? 0;
            case 'bodyweight':
            case 'reps_only_cardio':
              reps = int.tryParse(set.repsText) ?? 0;
            case 'time':
            case 'time_only_cardio':
            case 'distance_cardio':
              durationSeconds = _parseDurationSeconds(set.timeText);
            case 'resistance':
              resistanceLevel = set.resistanceText.trim();
              reps = int.tryParse(set.repsText) ?? 0;
            case 'cardio':
              durationSeconds = _parseDurationSeconds(set.timeText);
              distance = double.tryParse(set.distanceText.replaceAll(',', '.'));
            case 'incline_cardio':
              incline = double.tryParse(set.inclineText.replaceAll(',', '.'));
              distance = double.tryParse(set.distanceText.replaceAll(',', '.'));
              durationSeconds = _parseDurationSeconds(set.timeText);
            case 'steps_cardio':
              steps = int.tryParse(set.stepsText);
              durationSeconds = _parseDurationSeconds(set.timeText);
            default:
              weight =
                  double.tryParse(set.weightText.replaceAll(',', '.')) ?? 0;
              reps = int.tryParse(set.repsText) ?? 0;
          }

          sets.add(
            CompletedWorkoutSet(
              setNumber: i + 1,
              weightKg: weight,
              reps: reps,
              durationSeconds: durationSeconds,
              resistanceLevel: resistanceLevel,
              distance: distance,
              incline: incline,
              steps: steps,
            ),
          );
        }
        if (sets.isNotEmpty) {
          exercises.add(
            CompletedWorkoutExercise(
              exerciseId: exercise.exercise.id,
              exerciseName: exercise.exercise.name,
              sets: List<CompletedWorkoutSet>.unmodifiable(sets),
              exerciseType: exercise.exercise.type,
            ),
          );
        }
      }

      final hasCompletedSets = exercises.isNotEmpty;
      final workout = CompletedWorkout(
        id: now.microsecondsSinceEpoch.toString(),
        routineId: session.routine.id,
        routineName: session.routine.name,
        startedAt: session.startedAt,
        completedAt: now,
        duration: session.elapsedAt(now),
        exercises: List<CompletedWorkoutExercise>.unmodifiable(exercises),
      );

      // Evaluate PRs against prior history (beat previous max volume: weight * reps)
      final priorHistory = ref.read(workoutHistoryProvider);
      final prExercises = <String>[];
      for (final exercise in exercises) {
        double previousMaxVol = 0;
        for (final pastWorkout in priorHistory) {
          for (final pastEx in pastWorkout.exercises) {
            if (pastEx.exerciseId == exercise.exerciseId) {
              for (final pastSet in pastEx.sets) {
                if (pastSet.volume > previousMaxVol) {
                  previousMaxVol = pastSet.volume;
                }
              }
            }
          }
        }
        final hasPr = exercise.sets.any(
          (s) => s.volume > 0 && s.volume > previousMaxVol,
        );
        if (hasPr) {
          prExercises.add(exercise.exerciseName);
        }
      }

      // Initialize today's goals before inserting this workout, so a direct
      // deep-link still evaluates goals generated from genuinely prior history.
      ref.read(dailyGoalsProvider);
      final previousLevel = ref.read(userProgressionProvider).currentLevel;
      ref
          .read(workoutHistoryProvider.notifier)
          .addWorkout(workout, prExercises: prExercises);
      final dailyGoals = ref.read(dailyGoalsProvider.notifier);
      final completedDailyGoals = dailyGoals.evaluateWorkout(workout);
      dailyGoals.generateFromHistoryIfNeeded();
      ref.read(loginStreakProvider.notifier).recordActivity(now);
      final xpAwarded = hasCompletedSets ? workoutXp : 0;
      if (xpAwarded > 0) {
        ref.read(userProgressionProvider.notifier).addXp(xpAwarded);
        ref
            .read(xpTransactionsProvider.notifier)
            .log(
              description: 'Completed ${workout.routineName}',
              amount: xpAwarded,
              source: XpSource.workout,
            );
      }
      final newLevel = ref.read(userProgressionProvider).currentLevel;
      final currentStreak = ref.read(loginStreakProvider).currentStreak;
      final allWorkouts = ref.read(workoutHistoryProvider);
      final totalPrs = calculateTotalPrsFromHistory(allWorkouts);

      ref
          .read(medalsProvider.notifier)
          .evaluateAndUnlock(
            level: newLevel,
            streak: currentStreak,
            totalPrs: totalPrs,
            totalWorkouts: allWorkouts.length,
            hasNewPr: prExercises.isNotEmpty,
          );

      // Check for rank promotion and automatically queue social post
      final previousRank = Ranks.forLevel(previousLevel);
      final newRank = Ranks.forLevel(newLevel);
      if (previousRank.name != newRank.name) {
        final userId = ref.read(currentUserProvider)?.id;
        if (userId != null) {
          unawaited(
            ref
                .read(localCacheServiceProvider)
                .enqueue(
                  entityType: 'rank_up',
                  action: 'insert',
                  payload: <String, dynamic>{
                    'userId': userId,
                    'rankName': newRank.name,
                    'level': newLevel,
                  },
                ),
          );
          unawaited(ref.read(syncServiceProvider.notifier).syncPending());
        }
      }

      _ticker?.cancel();
      _ticker = null;
      state = ActiveWorkoutState.idle(now);
      return WorkoutFinishResult(
        workout: workout,
        previousLevel: previousLevel,
        newLevel: newLevel,
        completedDailyGoals: completedDailyGoals,
        xpAwarded: xpAwarded,
        prExercises: List<String>.unmodifiable(prExercises),
      );
    } finally {
      _isFinishing = false;
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final session = state.session;
      if (session == null) {
        _ticker?.cancel();
        _ticker = null;
        return;
      }
      final now = DateTime.now();
      final restEnded =
          session.restEndsAt != null && !session.restEndsAt!.isAfter(now);
      if (restEnded) {
        ref.read(audioServiceProvider).playDing();
      }
      state = ActiveWorkoutState(
        session: restEnded ? session.copyWith(clearRestTimer: true) : session,
        now: now,
        isMinimized: state.isMinimized,
      );
    });
  }

  void _setSession(ActiveWorkoutSession session, {DateTime? now}) {
    state = ActiveWorkoutState(
      session: session,
      now: now ?? state.now,
      isMinimized: state.isMinimized,
    );
  }

  void _updateSet(
    int exerciseIndex,
    int setIndex,
    ActiveWorkoutSet Function(ActiveWorkoutSet set) update,
  ) {
    final session = state.session;
    if (!_validSetIndex(session, exerciseIndex, setIndex)) return;
    final exercise = session!.exercises[exerciseIndex];
    final sets = <ActiveWorkoutSet>[...exercise.sets];
    sets[setIndex] = update(sets[setIndex]);
    _replaceExercise(session, exerciseIndex, exercise.copyWith(sets: sets));
  }

  void _replaceExercise(
    ActiveWorkoutSession session,
    int exerciseIndex,
    ActiveWorkoutExercise exercise, {
    int? nextSetId,
  }) {
    final exercises = <ActiveWorkoutExercise>[...session.exercises];
    exercises[exerciseIndex] = exercise;
    _setSession(
      session.copyWith(
        exercises: exercises,
        nextSetId: nextSetId ?? session.nextSetId,
      ),
    );
  }

  bool _validExerciseIndex(ActiveWorkoutSession? session, int index) {
    return session != null && index >= 0 && index < session.exercises.length;
  }

  bool _validSetIndex(
    ActiveWorkoutSession? session,
    int exerciseIndex,
    int setIndex,
  ) {
    if (!_validExerciseIndex(session, exerciseIndex)) return false;
    final sets = session!.exercises[exerciseIndex].sets;
    return setIndex >= 0 && setIndex < sets.length;
  }
}

int _parseDurationSeconds(String text) {
  final clean = text.trim();
  if (clean.isEmpty) return 0;
  if (clean.contains(':')) {
    final parts = clean.split(':');
    if (parts.length == 2) {
      final mins = int.tryParse(parts[0]) ?? 0;
      final secs = int.tryParse(parts[1]) ?? 0;
      return mins * 60 + secs;
    }
  }
  return int.tryParse(clean) ?? 0;
}
