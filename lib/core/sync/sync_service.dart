import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stryde/core/database/app_database.dart';
import 'package:stryde/core/database/local_cache_service.dart';
import 'package:stryde/core/sync/network_connectivity.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/medals/data/medals_repository.dart';
import 'package:stryde/features/profile/data/profile_repository.dart';
import 'package:stryde/features/progression/data/skills_repository.dart';
import 'package:stryde/features/workout_history/data/workout_history_repository.dart';
import 'package:stryde/features/workout_history/domain/entities/completed_workout.dart';

class SyncState {
  const SyncState({
    this.isOnline = true,
    this.isSyncing = false,
    this.pendingCount = 0,
    this.lastSyncedAt,
  });

  final bool isOnline;
  final bool isSyncing;
  final int pendingCount;
  final DateTime? lastSyncedAt;

  bool get hasPendingSync => pendingCount > 0;

  SyncState copyWith({
    bool? isOnline,
    bool? isSyncing,
    int? pendingCount,
    DateTime? lastSyncedAt,
  }) {
    return SyncState(
      isOnline: isOnline ?? this.isOnline,
      isSyncing: isSyncing ?? this.isSyncing,
      pendingCount: pendingCount ?? this.pendingCount,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}

class SyncNotifier extends Notifier<SyncState> {
  StreamSubscription<bool>? _connectivitySub;
  StreamSubscription<int>? _queueCountSub;
  bool _isProcessing = false;
  bool _mounted = true;

  late LocalCacheService _localCache;
  late NetworkConnectivity _connectivity;
  SupabaseClient? _supabase;
  WorkoutHistoryRepository? _workoutHistoryRepo;
  MedalsRepository? _medalsRepo;
  SkillsRepository? _skillsRepo;
  ProfileRepository? _profileRepo;

  @override
  SyncState build() {
    _mounted = true;
    _localCache = ref.read(localCacheServiceProvider);
    _connectivity = ref.read(networkConnectivityProvider);
    _supabase = ref.read(supabaseProvider);
    _workoutHistoryRepo = ref.read(workoutHistoryRepositoryProvider);
    _medalsRepo = ref.read(medalsRepositoryProvider);
    _skillsRepo = ref.read(skillsRepositoryProvider);
    _profileRepo = ref.read(profileRepositoryProvider);

    ref.onDispose(() {
      _mounted = false;
      _connectivitySub?.cancel();
      _queueCountSub?.cancel();
    });

    _initListeners();

    return const SyncState();
  }

  Future<void> _initListeners() async {
    final initialOnline = await _connectivity.isOnline;
    if (!_mounted) return;
    final initialCount = await _localCache.getPendingQueueCount();
    if (!_mounted) return;

    state = state.copyWith(isOnline: initialOnline, pendingCount: initialCount);

    _connectivitySub = _connectivity.onConnectivityChanged.listen((online) {
      if (!_mounted) return;
      final wasOffline = !state.isOnline;
      state = state.copyWith(isOnline: online);
      if (wasOffline && online) {
        unawaited(syncPending());
      }
    });

    _queueCountSub = _localCache.watchPendingQueueCount().listen((count) {
      if (!_mounted) return;
      state = state.copyWith(pendingCount: count);
    });

    if (initialOnline && _mounted) {
      unawaited(syncPending());
    }
  }

  Future<void> syncPending() async {
    if (_isProcessing || !_mounted) return;
    final online = await _connectivity.isOnline;
    if (!_mounted) return;
    if (!online) {
      state = state.copyWith(isOnline: false);
      return;
    }

    _isProcessing = true;
    if (_mounted) {
      state = state.copyWith(isSyncing: true, isOnline: true);
    }

    try {
      final entries = await _localCache.getPendingQueue();
      for (final entry in entries) {
        if (!_mounted) break;
        final stillOnline = await _connectivity.isOnline;
        if (!_mounted) break;
        if (!stillOnline) {
          state = state.copyWith(isOnline: false);
          break;
        }

        final success = await _processQueueEntry(entry);
        if (!_mounted) break;
        if (success) {
          await _localCache.deleteQueueEntry(entry.id);
        } else {
          // Network error or push failure: stop sync and retry later
          break;
        }
      }
    } catch (_) {
      // Degrades gracefully, retry later
    } finally {
      _isProcessing = false;
      if (_mounted) {
        final remaining = await _localCache.getPendingQueueCount();
        if (_mounted) {
          state = state.copyWith(
            isSyncing: false,
            pendingCount: remaining,
            lastSyncedAt: DateTime.now(),
          );
        }
      }
    }
  }

  Future<bool> _processQueueEntry(SyncQueueEntry entry) async {
    final client = _supabase;
    if (client == null) return false;

    try {
      final payload = jsonDecode(entry.payload) as Map<String, dynamic>;

      switch (entry.entityType) {
        case 'profile':
          return await _syncProfileEntry(entry.action, payload, client);

        case 'workout':
          return await _syncWorkoutEntry(entry.action, payload);

        case 'medal':
          return await _syncMedalEntry(entry.action, payload);

        case 'skill':
          return await _syncSkillEntry(entry.action, payload);

        case 'quest_completion':
          return await _syncQuestCompletionEntry(entry.action, payload, client);

        default:
          return true; // Unknown entry type, dismiss to prevent blocking queue
      }
    } catch (_) {
      return false;
    }
  }

  Future<bool> _syncProfileEntry(
    String action,
    Map<String, dynamic> payload,
    SupabaseClient client,
  ) async {
    final userId = payload['userId']?.toString();
    if (userId == null) return true;

    try {
      if (action == 'create_profile') {
        final username = payload['username']?.toString();
        final values = <String, dynamic>{
          'id': userId,
          'level': 1,
          'xp': 0,
          'skill_points': 0,
          'total_xp': 0,
          'available_skill_points': 0,
          'streak': 0,
        };
        if (username != null) {
          values['username'] = username;
        }
        await client.from('profiles').upsert(values);
        return true;
      }

      if (action == 'update') {
        final values = Map<String, dynamic>.from(
          payload['values'] as Map? ?? <String, dynamic>{},
        );
        if (values.isNotEmpty) {
          await client.from('profiles').update(values).eq('id', userId);
        }
        return true;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _syncWorkoutEntry(
    String action,
    Map<String, dynamic> payload,
  ) async {
    final userId = payload['userId']?.toString();
    final repo = _workoutHistoryRepo;
    if (userId == null || repo == null) return false;

    try {
      final workoutMap = payload['workout'] as Map<String, dynamic>?;
      if (workoutMap == null) return true;
      final workout = CompletedWorkout.fromJson(workoutMap);
      await repo.insert(userId: userId, workout: workout);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _syncMedalEntry(
    String action,
    Map<String, dynamic> payload,
  ) async {
    final userId = payload['userId']?.toString();
    final medalId = payload['medalId']?.toString();
    final repo = _medalsRepo;
    if (userId == null || medalId == null || repo == null) return false;

    try {
      await repo.unlockMedal(userId: userId, medalId: medalId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _syncSkillEntry(
    String action,
    Map<String, dynamic> payload,
  ) async {
    final userId = payload['userId']?.toString();
    final muscleGroup = payload['muscleGroup']?.toString();
    final points = payload['points'] as int? ?? 0;
    final repo = _skillsRepo;
    if (userId == null || muscleGroup == null || repo == null) return false;

    try {
      await repo.upsert(
        userId: userId,
        muscleGroup: muscleGroup,
        points: points,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _syncQuestCompletionEntry(
    String action,
    Map<String, dynamic> payload,
    SupabaseClient client,
  ) async {
    final userId = payload['userId']?.toString();
    final questId = payload['questId']?.toString();
    final questType = payload['questType']?.toString() ?? 'goal';
    final completedAt = payload['completedAt']?.toString() ??
        DateTime.now().toUtc().toIso8601String();
    if (userId == null || questId == null) return true;

    try {
      await client.from('completed_quests').insert(<String, dynamic>{
        'user_id': userId,
        'quest_id': questId,
        'quest_type': questType,
        'completed_at': completedAt,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> reconcileProfile(String userId) async {
    if (!_mounted) return;
    final online = await _connectivity.isOnline;
    if (!online || !_mounted) return;

    final local = await _localCache.getCachedProfile(userId);
    final repo = _profileRepo;
    if (local == null || repo == null || !_mounted) return;

    try {
      final remote = await repo.fetch(userId);
      if (remote == null || !_mounted) return;

      final localUpdated =
          local.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final remoteUpdated =
          remote.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

      if (localUpdated.isAfter(remoteUpdated)) {
        // Local is newer: push local update to server
        await repo.saveProgression(
          userId: userId,
          xp: local.xp,
          level: local.level,
          skillPoints: local.skillPoints,
          totalXp: local.totalXp,
          availableSkillPoints: local.availableSkillPoints,
        );
        if (!_mounted) return;
        if (local.streak > 0) {
          await repo.saveStreak(
            userId: userId,
            streak: local.streak,
            lastActivityOn: local.lastActivityOn,
          );
        }
        if (!_mounted) return;
        if (local.displayName != null || local.avatarUrl != null) {
          await repo.saveProfileInfo(
            userId: userId,
            displayName: local.displayName,
            avatarUrl: local.avatarUrl,
          );
        }
        if (!_mounted) return;
        if (local.themeMode != null && local.accentColor != null) {
          await repo.saveThemeSettings(
            userId: userId,
            themeMode: local.themeMode!,
            accentColor: local.accentColor!,
          );
        }
      } else if (remoteUpdated.isAfter(localUpdated)) {
        // Server is newer: pull down and overwrite local cache
        await _localCache.saveCachedProfile(
          userId,
          remote,
          lastUpdated: remoteUpdated,
        );
      }
    } catch (_) {
      // Degrades gracefully
    }
  }
}

final syncServiceProvider = NotifierProvider<SyncNotifier, SyncState>(
  SyncNotifier.new,
);
