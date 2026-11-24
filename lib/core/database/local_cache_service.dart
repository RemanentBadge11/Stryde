import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stryde/core/database/app_database.dart';
import 'package:stryde/features/profile/data/profile_repository.dart';
import 'package:stryde/features/workout_history/domain/entities/completed_workout.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

class LocalCacheService {
  LocalCacheService(this._db);

  final AppDatabase _db;
  final StreamController<int> _queueCountController =
      StreamController<int>.broadcast();

  void dispose() {
    _queueCountController.close();
  }

  void _notifyQueueCount() {
    if (!_queueCountController.isClosed && _queueCountController.hasListener) {
      getPendingQueueCount().then((count) {
        if (!_queueCountController.isClosed) {
          _queueCountController.add(count);
        }
      });
    }
  }

  // PROFILE CACHE
  Future<ProfileData?> getCachedProfile(String userId) async {
    try {
      final row = await (_db.select(
        _db.cachedProfiles,
      )..where((t) => t.id.equals(userId))).getSingleOrNull();
      if (row == null) return null;

      return ProfileData(
        xp: row.xp,
        level: row.level,
        streak: row.streak,
        skillPoints: row.skillPoints,
        totalXp: row.totalXp,
        availableSkillPoints: row.availableSkillPoints,
        username: row.username,
        displayName: row.displayName,
        avatarUrl: row.avatarUrl,
        lastActivityOn: row.lastActivityOn,
        goalSteps: row.goalSteps,
        goalWater: row.goalWater,
        goalProtein: row.goalProtein,
        themeMode: row.themeMode,
        accentColor: row.accentColor,
        updatedAt: row.lastUpdated,
        timezone: row.timezone,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCachedProfile(
    String userId,
    ProfileData data, {
    DateTime? lastUpdated,
  }) async {
    try {
      await _db
          .into(_db.cachedProfiles)
          .insertOnConflictUpdate(
            CachedProfilesCompanion.insert(
              id: userId,
              xp: Value(data.xp),
              level: Value(data.level),
              streak: Value(data.streak),
              skillPoints: Value(data.skillPoints),
              totalXp: Value(data.totalXp ?? 0),
              availableSkillPoints: Value(
                data.availableSkillPoints ?? data.skillPoints,
              ),
              username: Value(data.username),
              displayName: Value(data.displayName),
              avatarUrl: Value(data.avatarUrl),
              lastActivityOn: Value(data.lastActivityOn),
              goalSteps: Value(data.goalSteps),
              goalWater: Value(data.goalWater),
              goalProtein: Value(data.goalProtein),
              themeMode: Value(data.themeMode),
              accentColor: Value(data.accentColor),
              timezone: Value(data.timezone),
              lastUpdated: Value(lastUpdated ?? DateTime.now()),
            ),
          );
    } catch (_) {}
  }

  Future<void> updateCachedProfile(
    String userId, {
    int? xp,
    int? level,
    int? streak,
    int? skillPoints,
    int? totalXp,
    int? availableSkillPoints,
    String? username,
    String? displayName,
    String? avatarUrl,
    DateTime? lastActivityOn,
    int? goalSteps,
    double? goalWater,
    int? goalProtein,
    String? themeMode,
    String? accentColor,
    String? timezone,
    DateTime? lastUpdated,
  }) async {
    final existing = await getCachedProfile(userId);
    final now = lastUpdated ?? DateTime.now();
    if (existing == null) {
      await saveCachedProfile(
        userId,
        ProfileData(
          xp: xp ?? 0,
          level: level ?? 1,
          streak: streak ?? 0,
          skillPoints: skillPoints ?? 0,
          totalXp: totalXp ?? 0,
          availableSkillPoints: availableSkillPoints ?? skillPoints ?? 0,
          username: username,
          displayName: displayName,
          avatarUrl: avatarUrl,
          lastActivityOn: lastActivityOn,
          goalSteps: goalSteps,
          goalWater: goalWater,
          goalProtein: goalProtein,
          themeMode: themeMode ?? 'dark',
          accentColor: accentColor ?? '#FFFFFF',
          timezone: timezone,
          updatedAt: now,
        ),
        lastUpdated: now,
      );
    } else {
      await saveCachedProfile(
        userId,
        existing.copyWith(
          xp: xp ?? existing.xp,
          level: level ?? existing.level,
          streak: streak ?? existing.streak,
          skillPoints: skillPoints ?? existing.skillPoints,
          totalXp: totalXp ?? existing.totalXp,
          availableSkillPoints:
              availableSkillPoints ?? existing.availableSkillPoints,
          username: username ?? existing.username,
          displayName: displayName ?? existing.displayName,
          avatarUrl: avatarUrl ?? existing.avatarUrl,
          lastActivityOn: lastActivityOn ?? existing.lastActivityOn,
          goalSteps: goalSteps ?? existing.goalSteps,
          goalWater: goalWater ?? existing.goalWater,
          goalProtein: goalProtein ?? existing.goalProtein,
          themeMode: themeMode ?? existing.themeMode,
          accentColor: accentColor ?? existing.accentColor,
          timezone: timezone ?? existing.timezone,
          updatedAt: now,
        ),
        lastUpdated: now,
      );
    }
  }

  // SYNC QUEUE
  Future<int> enqueue({
    required String entityType,
    required String action,
    required Map<String, dynamic> payload,
    DateTime? createdAt,
  }) async {
    try {
      final id = await _db
          .into(_db.syncQueue)
          .insert(
            SyncQueueCompanion.insert(
              entityType: entityType,
              action: action,
              payload: jsonEncode(payload),
              createdAt: Value(createdAt ?? DateTime.now()),
            ),
          );
      _notifyQueueCount();
      return id;
    } catch (_) {
      return -1;
    }
  }

  Future<List<SyncQueueEntry>> getPendingQueue() async {
    return (_db.select(
      _db.syncQueue,
    )..orderBy([(t) => OrderingTerm(expression: t.id)])).get();
  }

  Future<void> deleteQueueEntry(int id) async {
    await (_db.delete(_db.syncQueue)..where((t) => t.id.equals(id))).go();
    _notifyQueueCount();
  }

  Future<int> getPendingQueueCount() async {
    final countExp = _db.syncQueue.id.count();
    final query = _db.selectOnly(_db.syncQueue)..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  Stream<int> watchPendingQueueCount() {
    return _queueCountController.stream;
  }

  // CACHED MEDALS
  Future<Map<String, DateTime>> getCachedMedals(String userId) async {
    final rows = await (_db.select(
      _db.cachedMedals,
    )..where((t) => t.userId.equals(userId))).get();
    return <String, DateTime>{for (final r in rows) r.medalId: r.unlockedAt};
  }

  Future<void> saveCachedMedal(
    String userId,
    String medalId,
    DateTime unlockedAt,
  ) async {
    await _db
        .into(_db.cachedMedals)
        .insertOnConflictUpdate(
          CachedMedalsCompanion.insert(
            userId: userId,
            medalId: medalId,
            unlockedAt: unlockedAt,
          ),
        );
  }

  Future<void> setCachedMedals(
    String userId,
    Map<String, DateTime> medals,
  ) async {
    await _db.batch((batch) {
      for (final entry in medals.entries) {
        batch.insert(
          _db.cachedMedals,
          CachedMedalsCompanion.insert(
            userId: userId,
            medalId: entry.key,
            unlockedAt: entry.value,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  // CACHED SKILLS
  Future<Map<String, int>> getCachedSkills(String userId) async {
    final rows = await (_db.select(
      _db.cachedSkills,
    )..where((t) => t.userId.equals(userId))).get();
    return <String, int>{for (final r in rows) r.muscleGroup: r.points};
  }

  Future<void> saveCachedSkill(
    String userId,
    String muscleGroup,
    int points,
  ) async {
    await _db
        .into(_db.cachedSkills)
        .insertOnConflictUpdate(
          CachedSkillsCompanion.insert(
            userId: userId,
            muscleGroup: muscleGroup,
            points: Value(points),
          ),
        );
  }

  Future<void> setCachedSkills(String userId, Map<String, int> skills) async {
    await _db.batch((batch) {
      for (final entry in skills.entries) {
        batch.insert(
          _db.cachedSkills,
          CachedSkillsCompanion.insert(
            userId: userId,
            muscleGroup: entry.key,
            points: Value(entry.value),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  // CACHED WORKOUTS
  Future<List<CompletedWorkout>> getCachedWorkouts(String userId) async {
    final rows =
        await (_db.select(_db.cachedWorkouts)
              ..where((t) => t.userId.equals(userId))
              ..orderBy([
                (t) => OrderingTerm(
                  expression: t.completedAt,
                  mode: OrderingMode.desc,
                ),
              ]))
            .get();

    final workouts = <CompletedWorkout>[];
    for (final row in rows) {
      try {
        final map = jsonDecode(row.rawPayload) as Map<String, dynamic>;
        workouts.add(CompletedWorkout.fromJson(map));
      } catch (_) {
        // Skip corrupt entry
      }
    }
    return workouts;
  }

  Future<void> saveCachedWorkout(
    String userId,
    CompletedWorkout workout,
  ) async {
    await _db
        .into(_db.cachedWorkouts)
        .insertOnConflictUpdate(
          CachedWorkoutsCompanion.insert(
            id: workout.id,
            userId: userId,
            routineName: workout.routineName,
            startedAt: Value(workout.startedAt),
            completedAt: workout.completedAt,
            durationSeconds: workout.duration.inSeconds,
            totalVolumeKg: workout.totalVolume,
            rawPayload: jsonEncode(workout.toJson()),
          ),
        );
  }

  Future<void> setCachedWorkouts(
    String userId,
    List<CompletedWorkout> workouts,
  ) async {
    await _db.batch((batch) {
      for (final w in workouts) {
        batch.insert(
          _db.cachedWorkouts,
          CachedWorkoutsCompanion.insert(
            id: w.id,
            userId: userId,
            routineName: w.routineName,
            startedAt: Value(w.startedAt),
            completedAt: w.completedAt,
            durationSeconds: w.duration.inSeconds,
            totalVolumeKg: w.totalVolume,
            rawPayload: jsonEncode(w.toJson()),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  // QUESTS CACHE
  Future<List<CachedQuestEntry>> getCachedQuests(
    String userId, {
    String? questType,
    bool activeOnly = true,
    DateTime? now,
  }) async {
    try {
      final query = _db.select(_db.cachedQuests)
        ..where((t) => t.userId.equals(userId));
      if (questType != null) {
        query.where((t) => t.questType.equals(questType));
      }
      if (activeOnly) {
        final current = now ?? DateTime.now().toUtc();
        query.where((t) => t.expiresAt.isBiggerThanValue(current));
      }
      return await query.get();
    } catch (_) {
      return const <CachedQuestEntry>[];
    }
  }

  Future<void> saveCachedQuests(
    String userId,
    List<CachedQuestEntry> quests,
  ) async {
    try {
      await _db.batch((batch) {
        for (final q in quests) {
          batch.insert(
            _db.cachedQuests,
            CachedQuestsCompanion.insert(
              id: q.id,
              userId: userId,
              questType: q.questType,
              title: q.title,
              description: q.description,
              xpReward: q.xpReward,
              targetMetric: Value(q.targetMetric),
              targetValue: Value(q.targetValue),
              exerciseName: Value(q.exerciseName),
              expiresAt: q.expiresAt,
              createdAt: Value(q.createdAt),
              isCompleted: Value(q.isCompleted),
              completedAt: Value(q.completedAt),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    } catch (_) {}
  }

  Future<void> markCachedQuestCompleted(
    String userId,
    String questId,
    DateTime completedAt,
  ) async {
    try {
      await (_db.update(
        _db.cachedQuests,
      )..where((t) => t.id.equals(questId))).write(
        CachedQuestsCompanion(
          isCompleted: const Value(true),
          completedAt: Value(completedAt),
        ),
      );
    } catch (_) {}
  }

  Future<void> clearExpiredCachedQuests(DateTime now) async {
    try {
      await (_db.delete(
        _db.cachedQuests,
      )..where((t) => t.expiresAt.isSmallerOrEqualValue(now))).go();
    } catch (_) {}
  }
}

final localCacheServiceProvider = Provider<LocalCacheService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final service = LocalCacheService(db);
  ref.onDispose(() => service.dispose());
  return service;
});
