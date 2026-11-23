import 'package:stryde/core/database/app_database.dart';

class UserQuest {
  const UserQuest({
    required this.id,
    required this.userId,
    required this.questType, // 'daily' or 'weekly'
    required this.title,
    required this.description,
    required this.xpReward,
    this.targetMetric,
    this.targetValue,
    this.exerciseName,
    required this.expiresAt,
    required this.createdAt,
    this.isCompleted = false,
    this.completedAt,
  });

  final String id;
  final String userId;
  final String questType;
  final String title;
  final String description;
  final int xpReward;
  final String? targetMetric;
  final double? targetValue;
  final String? exerciseName;
  final DateTime expiresAt;
  final DateTime createdAt;
  final bool isCompleted;
  final DateTime? completedAt;

  UserQuest copyWith({
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return UserQuest(
      id: id,
      userId: userId,
      questType: questType,
      title: title,
      description: description,
      xpReward: xpReward,
      targetMetric: targetMetric,
      targetValue: targetValue,
      exerciseName: exerciseName,
      expiresAt: expiresAt,
      createdAt: createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory UserQuest.fromSupabase(
    Map<String, dynamic> row, {
    bool isCompleted = false,
    DateTime? completedAt,
  }) {
    return UserQuest(
      id: row['id']?.toString() ?? '',
      userId: row['user_id']?.toString() ?? '',
      questType: row['quest_type']?.toString() ?? 'daily',
      title: row['title']?.toString() ?? '',
      description: row['description']?.toString() ?? '',
      xpReward: (row['xp_reward'] as num?)?.toInt() ?? 25,
      targetMetric: row['target_metric']?.toString(),
      targetValue: (row['target_value'] as num?)?.toDouble(),
      exerciseName: row['exercise_name']?.toString(),
      expiresAt:
          DateTime.tryParse(row['expires_at']?.toString() ?? '')?.toUtc() ??
          DateTime.now().toUtc(),
      createdAt:
          DateTime.tryParse(row['created_at']?.toString() ?? '')?.toUtc() ??
          DateTime.now().toUtc(),
      isCompleted: isCompleted,
      completedAt: completedAt,
    );
  }

  factory UserQuest.fromDrift(CachedQuestEntry row) {
    return UserQuest(
      id: row.id,
      userId: row.userId,
      questType: row.questType,
      title: row.title,
      description: row.description,
      xpReward: row.xpReward,
      targetMetric: row.targetMetric,
      targetValue: row.targetValue,
      exerciseName: row.exerciseName,
      expiresAt: row.expiresAt.toUtc(),
      createdAt: row.createdAt.toUtc(),
      isCompleted: row.isCompleted,
      completedAt: row.completedAt?.toUtc(),
    );
  }

  CachedQuestEntry toDrift() {
    return CachedQuestEntry(
      id: id,
      userId: userId,
      questType: questType,
      title: title,
      description: description,
      xpReward: xpReward,
      targetMetric: targetMetric,
      targetValue: targetValue,
      exerciseName: exerciseName,
      expiresAt: expiresAt,
      createdAt: createdAt,
      isCompleted: isCompleted,
      completedAt: completedAt,
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return <String, dynamic>{
      'id': id,
      'user_id': userId,
      'quest_type': questType,
      'title': title,
      'description': description,
      'xp_reward': xpReward,
      'target_metric': targetMetric,
      'target_value': targetValue,
      'exercise_name': exerciseName,
      'expires_at': expiresAt.toUtc().toIso8601String(),
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }
}
