import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stryde/core/database/local_cache_service.dart';
import 'package:stryde/core/services/location_timezone_service.dart';
import 'package:stryde/core/sync/network_connectivity.dart';
import 'package:stryde/core/utils/uuid.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/home/data/quest_pool.dart';
import 'package:stryde/features/home/domain/entities/quest.dart';
import 'package:stryde/features/home/domain/entities/user_quest.dart';
import 'package:stryde/features/workout_history/domain/entities/completed_workout.dart';

class UserQuestsRepository {
  UserQuestsRepository({
    this.supabase,
    required this.localCache,
    required this.timezoneService,
    required this.connectivity,
  });

  final SupabaseClient? supabase;
  final LocalCacheService localCache;
  final LocationTimezoneService timezoneService;
  final NetworkConnectivity connectivity;

  Future<List<UserQuest>> getOrGenerateQuests({
    required String userId,
    required String questType, // 'daily' or 'weekly'
    required String timezone,
    required List<CompletedWorkout> history,
    DateTime? now,
  }) async {
    final current = (now ?? DateTime.now()).toUtc();
    final expectedCount = questType == 'daily' ? 3 : 4;

    // 1. Check if offline
    final isOnline = await connectivity.isOnline;
    if (!isOnline) {
      final cached = await localCache.getCachedQuests(
        userId,
        questType: questType,
        activeOnly: true,
        now: current,
      );

      if (cached.isNotEmpty) {
        return cached.map(UserQuest.fromDrift).toList();
      }

      // Offline and cache is empty or expired:
      // Do not try to delete them locally; queue a cleanup_quests action in the sync_queue.
      await enqueueCleanupQuests(userId);
      return const <UserQuest>[];
    }

    final client = supabase;
    if (client == null) {
      // Offline / guest mode without Supabase client
      final cached = await localCache.getCachedQuests(
        userId,
        questType: questType,
        activeOnly: true,
        now: current,
      );
      if (cached.length >= expectedCount) {
        return cached.map(UserQuest.fromDrift).toList();
      }
      final generated = questType == 'daily'
          ? generateDailyGoals(
              userId: userId,
              timezone: timezone,
              history: history,
              now: current,
            )
          : generateWeeklyQuests(
              userId: userId,
              timezone: timezone,
              now: current,
            );
      await localCache.clearExpiredCachedQuests(current);
      await localCache.saveCachedQuests(
        userId,
        generated.map((q) => q.toDrift()).toList(),
      );
      return generated;
    }

    // 2. Online: Query user_quests for active quests (expires_at > now())
    try {
      final remote = await fetchActiveQuests(
        userId,
        questType: questType,
        now: current,
      );

      if (remote.length >= expectedCount) {
        await localCache.clearExpiredCachedQuests(current);
        await localCache.saveCachedQuests(
          userId,
          remote.map((q) => q.toDrift()).toList(),
        );
        return remote;
      }
    } catch (_) {
      // Remote fetch failed, fall back to cached if active
      final cached = await localCache.getCachedQuests(
        userId,
        questType: questType,
        activeOnly: true,
        now: current,
      );
      if (cached.isNotEmpty) {
        return cached.map(UserQuest.fromDrift).toList();
      }
      await enqueueCleanupQuests(userId);
      return const <UserQuest>[];
    }

    // 3. If there are NO active quests (all expired or none exist):
    // Step 1: Delete all expired quests for this user from user_quests.
    try {
      await deleteExpiredQuests(userId, now: current);
    } catch (_) {
      // Degrades gracefully if remote delete fails
    }

    // Step 2: Generate the new quests (3 Daily Goals, 4 Weekly Quests) using the existing logic.
    final generated = questType == 'daily'
        ? generateDailyGoals(
            userId: userId,
            timezone: timezone,
            history: history,
            now: current,
          )
        : generateWeeklyQuests(
            userId: userId,
            timezone: timezone,
            now: current,
          );

    // Step 3: Insert the new quests into user_quests with the correct expires_at.
    try {
      await insertQuests(generated);
    } catch (_) {
      // If remote insert fails, still keep local
    }

    // Step 4: Update the local Drift cached_quests table.
    await localCache.clearExpiredCachedQuests(current);
    await localCache.saveCachedQuests(
      userId,
      generated.map((q) => q.toDrift()).toList(),
    );

    return generated;
  }

  Future<void> deleteExpiredQuests(
    String userId, {
    String? questType,
    DateTime? now,
  }) async {
    final client = supabase;
    if (client == null) return;

    final current = (now ?? DateTime.now()).toUtc();
    var query = client
        .from('user_quests')
        .delete()
        .eq('user_id', userId)
        .lte('expires_at', current.toIso8601String());

    if (questType != null) {
      query = query.eq('quest_type', questType);
    }

    await query;
  }

  Future<void> enqueueCleanupQuests(String userId) async {
    try {
      final pending = await localCache.getPendingQueue();
      final alreadyQueued = pending.any((e) {
        if (e.entityType != 'quests' || e.action != 'cleanup_quests') {
          return false;
        }
        try {
          final payload = jsonDecode(e.payload) as Map<String, dynamic>;
          return payload['userId'] == userId;
        } catch (_) {
          return true;
        }
      });
      if (!alreadyQueued) {
        await localCache.enqueue(
          entityType: 'quests',
          action: 'cleanup_quests',
          payload: <String, dynamic>{'userId': userId},
        );
      }
    } catch (_) {
      // Degrades gracefully
    }
  }

  Future<List<UserQuest>> fetchActiveQuests(
    String userId, {
    String? questType,
    DateTime? now,
  }) async {
    final client = supabase;
    if (client == null) return const <UserQuest>[];

    final current = (now ?? DateTime.now()).toUtc();
    var query = client
        .from('user_quests')
        .select()
        .eq('user_id', userId)
        .gt('expires_at', current.toIso8601String());

    if (questType != null) {
      query = query.eq('quest_type', questType);
    }

    final rows = await query.order('created_at', ascending: false);

    // Fetch user completions to mark isCompleted
    final completedRows = await client
        .from('completed_quests')
        .select()
        .eq('user_id', userId);

    final completedMap = <String, DateTime>{};
    for (final c in completedRows) {
      final qId = c['quest_id']?.toString();
      if (qId != null) {
        final parsed = DateTime.tryParse(c['completed_at']?.toString() ?? '');
        if (parsed != null) {
          completedMap[qId] = parsed.toUtc();
        }
      }
    }

    return rows.map<UserQuest>((row) {
      final id = row['id']?.toString() ?? '';
      final isCompleted = completedMap.containsKey(id);
      final completedAt = completedMap[id];
      return UserQuest.fromSupabase(
        row,
        isCompleted: isCompleted,
        completedAt: completedAt,
      );
    }).toList();
  }

  Future<void> insertQuests(List<UserQuest> quests) async {
    final client = supabase;
    if (client == null || quests.isEmpty) return;

    final maps = quests.map((q) => q.toSupabaseMap()).toList();
    await client.from('user_quests').upsert(maps);
  }

  Future<void> completeQuest({
    required String userId,
    required String questId,
    required String questType,
    DateTime? completedAt,
  }) async {
    final timestamp = (completedAt ?? DateTime.now()).toUtc();

    try {
      // 1. Mark in local Drift cache
      await localCache.markCachedQuestCompleted(userId, questId, timestamp);

      // 2. Enqueue for offline sync
      await localCache.enqueue(
        entityType: 'quest_completion',
        action: 'insert',
        payload: <String, dynamic>{
          'userId': userId,
          'questId': questId,
          'questType': questType,
          'completedAt': timestamp.toIso8601String(),
        },
      );
    } catch (_) {
      // Degrades gracefully if database is closed or shutting down
    }

    // 3. If online, insert to Supabase
    final client = supabase;
    if (client != null) {
      final online = await connectivity.isOnline;
      if (online) {
        try {
          await client.from('completed_quests').insert(<String, dynamic>{
            'user_id': userId,
            'quest_id': questId,
            'quest_type': questType,
            'completed_at': timestamp.toIso8601String(),
          });
        } catch (_) {
          // Sync queue will retry on reconnect
        }
      }
    }
  }

  List<UserQuest> generateDailyGoals({
    required String userId,
    required String timezone,
    required List<CompletedWorkout> history,
    DateTime? now,
  }) {
    final current = (now ?? DateTime.now()).toUtc();
    final expiresAt = timezoneService.nextDailyMidnight(
      timezone: timezone,
      now: current,
    );

    final goals = <UserQuest>[];
    final usedExerciseIds = <String>{};

    for (final workout in history) {
      for (final exercise in workout.exercises) {
        if (exercise.sets.isEmpty || goals.length == 3) continue;
        if (!usedExerciseIds.add(exercise.exerciseId)) continue;

        final bestSet = exercise.sets.reduce(
          (best, set) => set.weightKg >= best.weightKg ? set : best,
        );
        final targetWeight = bestSet.weightKg + 2.5;
        final targetReps = (bestSet.reps - 2).clamp(1, 999).toInt();

        goals.add(
          UserQuest(
            id: deterministicUuid(
              'daily-$userId-${expiresAt.toIso8601String()}-${exercise.exerciseId}',
            ),
            userId: userId,
            questType: 'daily',
            title: '${_formatWeight(targetWeight)} kg × $targetReps reps',
            description: exercise.exerciseName,
            xpReward: 25,
            targetMetric: 'weight_reps',
            targetValue: targetWeight,
            exerciseName: exercise.exerciseId,
            expiresAt: expiresAt,
            createdAt: current,
          ),
        );
      }
      if (goals.length == 3) break;
    }

    final fallbackDefaults = [
      (
        title: '50 Push-ups',
        desc: 'Chest PR challenge',
        val: 50.0,
        name: 'Push-up',
      ),
      (
        title: '50 Bodyweight Squats',
        desc: 'Legs PR challenge',
        val: 50.0,
        name: 'Squat',
      ),
      (
        title: '10 Pull-ups',
        desc: 'Back PR challenge',
        val: 10.0,
        name: 'Pull-up',
      ),
    ];

    for (final fb in fallbackDefaults) {
      if (goals.length == 3) break;
      goals.add(
        UserQuest(
          id: deterministicUuid(
            'daily-$userId-${expiresAt.toIso8601String()}-${fb.name}',
          ),
          userId: userId,
          questType: 'daily',
          title: fb.title,
          description: fb.desc,
          xpReward: 25,
          targetMetric: 'reps',
          targetValue: fb.val,
          exerciseName: fb.name,
          expiresAt: expiresAt,
          createdAt: current,
        ),
      );
    }

    return goals;
  }

  List<UserQuest> generateWeeklyQuests({
    required String userId,
    required String timezone,
    DateTime? now,
  }) {
    final current = (now ?? DateTime.now()).toUtc();
    final expiresAt = timezoneService.nextWeeklySundayMidnight(
      timezone: timezone,
      now: current,
    );

    final weekSeed = expiresAt.millisecondsSinceEpoch;
    final pool = <Quest>[...QuestPool.all]..shuffle(Random(weekSeed));
    final selected = pool.take(4).toList();

    return [
      for (final q in selected)
        UserQuest(
          id: deterministicUuid(
            'weekly-$userId-${expiresAt.toIso8601String()}-${q.id}',
          ),
          userId: userId,
          questType: 'weekly',
          title: q.title,
          description: q.detail,
          xpReward: q.xp,
          targetMetric: 'reps',
          targetValue: null,
          exerciseName: null,
          expiresAt: expiresAt,
          createdAt: current,
        ),
    ];
  }

  String _formatWeight(double weight) {
    return weight.truncateToDouble() == weight
        ? weight.toStringAsFixed(0)
        : weight.toStringAsFixed(1);
  }
}

final userQuestsRepositoryProvider = Provider<UserQuestsRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  final localCache = ref.watch(localCacheServiceProvider);
  final tzService = ref.watch(locationTimezoneServiceProvider);
  final connectivity = ref.watch(networkConnectivityProvider);

  return UserQuestsRepository(
    supabase: supabase,
    localCache: localCache,
    timezoneService: tzService,
    connectivity: connectivity,
  );
});
