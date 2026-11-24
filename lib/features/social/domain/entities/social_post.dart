import 'package:stryde/features/progression/domain/entities/rank.dart';
import 'package:stryde/features/social/domain/entities/social_profile.dart';
import 'package:stryde/features/workout_history/domain/entities/completed_workout.dart';

enum SocialPostType {
  workout,
  rankUp;

  static SocialPostType fromString(String val) {
    if (val == 'rank_up' || val == 'rankUp') return SocialPostType.rankUp;
    return SocialPostType.workout;
  }

  String toDbString() {
    switch (this) {
      case SocialPostType.workout:
        return 'workout';
      case SocialPostType.rankUp:
        return 'rank_up';
    }
  }
}

class WorkoutPostData {
  const WorkoutPostData({
    required this.workoutId,
    required this.routineName,
    required this.completedAt,
    required this.durationSeconds,
    required this.totalVolumeKg,
    required this.totalSets,
    required this.totalReps,
    required this.exercisesSummary,
    required this.snapshot,
    this.prExercises = const <String>[],
  });

  final String workoutId;
  final String routineName;
  final DateTime completedAt;
  final int durationSeconds;
  final double totalVolumeKg;
  final int totalSets;
  final int totalReps;
  final List<String> exercisesSummary;
  final List<String> prExercises;
  final CompletedWorkout snapshot;

  Duration get duration => Duration(seconds: durationSeconds);

  factory WorkoutPostData.fromJson(Map<String, dynamic> json) {
    final rawSnapshot = json['snapshot'] as Map<String, dynamic>?;
    final snapshot = rawSnapshot != null
        ? CompletedWorkout.fromJson(rawSnapshot)
        : CompletedWorkout(
            id: json['workout_id']?.toString() ?? '',
            routineId: json['routine_id']?.toString() ?? '',
            routineName: json['routine_name']?.toString() ?? 'Workout',
            completedAt:
                DateTime.tryParse(json['completed_at']?.toString() ?? '') ??
                DateTime.now(),
            duration: Duration(seconds: json['duration_seconds'] as int? ?? 0),
            exercises: const <CompletedWorkoutExercise>[],
          );

    return WorkoutPostData(
      workoutId: json['workout_id']?.toString() ?? snapshot.id,
      routineName: json['routine_name']?.toString() ?? snapshot.routineName,
      completedAt:
          DateTime.tryParse(json['completed_at']?.toString() ?? '') ??
          snapshot.completedAt,
      durationSeconds:
          json['duration_seconds'] as int? ?? snapshot.duration.inSeconds,
      totalVolumeKg:
          (json['total_volume_kg'] as num?)?.toDouble() ?? snapshot.totalVolume,
      totalSets: json['total_sets'] as int? ?? snapshot.totalSets,
      totalReps: json['total_reps'] as int? ?? snapshot.totalReps,
      exercisesSummary:
          (json['exercises_summary'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          snapshot.exercises.map((e) => e.exerciseName).toList(),
      prExercises:
          (json['pr_exercises'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>[],
      snapshot: snapshot,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'workout_id': workoutId,
    'routine_name': routineName,
    'completed_at': completedAt.toUtc().toIso8601String(),
    'duration_seconds': durationSeconds,
    'total_volume_kg': totalVolumeKg,
    'total_sets': totalSets,
    'total_reps': totalReps,
    'exercises_summary': exercisesSummary,
    'pr_exercises': prExercises,
    'snapshot': snapshot.toJson(),
  };
}

class RankUpPostData {
  const RankUpPostData({
    required this.rankName,
    required this.level,
    this.rankSvgPath,
  });

  final String rankName;
  final int level;
  final String? rankSvgPath;

  String get effectiveSvgPath =>
      rankSvgPath ?? RankAssetResolver.getSvgAssetPath(rankName);

  factory RankUpPostData.fromJson(Map<String, dynamic> json) {
    final rankName = json['rank_name']?.toString() ?? 'Initiate';
    return RankUpPostData(
      rankName: rankName,
      level: json['level'] as int? ?? 1,
      rankSvgPath: json['rank_svg_path']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'rank_name': rankName,
    'level': level,
    'rank_svg_path': effectiveSvgPath,
  };
}

class SocialPost {
  const SocialPost({
    required this.id,
    required this.userId,
    required this.type,
    required this.author,
    required this.createdAt,
    this.workoutData,
    this.rankUpData,
  });

  final String id;
  final String userId;
  final SocialPostType type;
  final SocialProfile author;
  final DateTime createdAt;
  final WorkoutPostData? workoutData;
  final RankUpPostData? rankUpData;

  factory SocialPost.fromJson(
    Map<String, dynamic> json, {
    SocialProfile? authorProfile,
    String? currentUserId,
  }) {
    final type = SocialPostType.fromString(json['type']?.toString() ?? '');
    final data = json['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

    final author =
        authorProfile ??
        (json['profiles'] is Map<String, dynamic>
            ? SocialProfile.fromJson(
                json['profiles'] as Map<String, dynamic>,
                currentUserId: currentUserId,
              )
            : SocialProfile(id: json['user_id']?.toString() ?? ''));

    return SocialPost(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      type: type,
      author: author,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      workoutData: type == SocialPostType.workout
          ? WorkoutPostData.fromJson(data)
          : null,
      rankUpData: type == SocialPostType.rankUp
          ? RankUpPostData.fromJson(data)
          : null,
    );
  }
}
