import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stryde/core/database/local_cache_service.dart';
import 'package:stryde/core/services/location_timezone_service.dart';
import 'package:stryde/core/sync/sync_service.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/profile/data/profile_repository.dart';

class UserProfileState {
  const UserProfileState({
    this.username,
    this.displayName,
    this.avatarUrl,
    this.isLoading = false,
  });

  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final bool isLoading;

  String? get greetingName {
    if (displayName != null && displayName!.trim().isNotEmpty) {
      return displayName!.trim();
    }
    if (username != null && username!.trim().isNotEmpty) {
      return username!.trim();
    }
    return null;
  }

  String get effectiveName => greetingName ?? 'Stryder';

  UserProfileState copyWith({
    String? username,
    String? displayName,
    String? avatarUrl,
    bool? isLoading,
  }) {
    return UserProfileState(
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final userProfileProvider =
    NotifierProvider<UserProfileNotifier, UserProfileState>(
      UserProfileNotifier.new,
    );

class UserProfileNotifier extends Notifier<UserProfileState> {
  String? _activeUserId;
  ProfileRepository? get _repository => ref.read(profileRepositoryProvider);

  @override
  UserProfileState build() {
    final user = ref.watch(currentUserProvider);
    _activeUserId = user?.id;

    if (user != null) {
      final metaUsername = user.userMetadata?['username']?.toString();
      final initialUsername =
          metaUsername != null && metaUsername.trim().isNotEmpty
          ? metaUsername.trim()
          : null;

      if (_repository != null) {
        unawaited(_hydrate(user.id));
      }
      return UserProfileState(
        username: initialUsername,
        displayName: null,
        avatarUrl: null,
      );
    }

    return const UserProfileState();
  }

  Future<void> _hydrate(String userId) async {
    final repo = _repository;
    if (repo == null) return;
    try {
      final data = await repo.getOrFetchProfile(userId);
      if (_activeUserId != userId || data == null) return;
      state = state.copyWith(
        username: data.username?.trim().isNotEmpty == true
            ? data.username!.trim()
            : state.username,
        displayName: data.displayName?.trim().isNotEmpty == true
            ? data.displayName!.trim()
            : state.displayName,
        avatarUrl: data.avatarUrl?.trim().isNotEmpty == true
            ? data.avatarUrl!.trim()
            : state.avatarUrl,
      );

      if (data.timezone == null || data.timezone!.isEmpty) {
        final tzService = ref.read(locationTimezoneServiceProvider);
        final detectedTz = await tzService.resolveTimezone();
        if (_activeUserId == userId && detectedTz.isNotEmpty) {
          unawaited(repo.saveTimezone(userId: userId, timezone: detectedTz));
          final localCache = ref.read(localCacheServiceProvider);
          await localCache.updateCachedProfile(userId, timezone: detectedTz);
        }
      }
    } catch (_) {
      // Degrades gracefully
    }
  }

  Future<void> setDisplayName(String displayName) async {
    final clean = displayName.trim();
    state = state.copyWith(displayName: clean);
    final userId = _activeUserId;
    if (userId == null) return;

    final repo = _repository;
    if (repo != null) {
      try {
        await repo.saveProfileInfo(userId: userId, displayName: clean);
      } catch (_) {}
    }

    final localCache = ref.read(localCacheServiceProvider);
    final now = DateTime.now();
    await localCache.updateCachedProfile(
      userId,
      displayName: clean,
      lastUpdated: now,
    );
    await localCache.enqueue(
      entityType: 'profile',
      action: 'update',
      payload: <String, dynamic>{
        'userId': userId,
        'values': <String, dynamic>{
          'display_name': clean,
          'updated_at': now.toUtc().toIso8601String(),
        },
      },
    );
    unawaited(ref.read(syncServiceProvider.notifier).syncPending());
  }

  Future<void> setAvatarUrl(String avatarUrl) async {
    final clean = avatarUrl.trim();
    state = state.copyWith(avatarUrl: clean);
    final userId = _activeUserId;
    if (userId == null) return;

    final repo = _repository;
    if (repo != null) {
      try {
        await repo.saveProfileInfo(userId: userId, avatarUrl: clean);
      } catch (_) {}
    }

    final localCache = ref.read(localCacheServiceProvider);
    final now = DateTime.now();
    await localCache.updateCachedProfile(
      userId,
      avatarUrl: clean,
      lastUpdated: now,
    );
    await localCache.enqueue(
      entityType: 'profile',
      action: 'update',
      payload: <String, dynamic>{
        'userId': userId,
        'values': <String, dynamic>{
          'avatar_url': clean,
          'updated_at': now.toUtc().toIso8601String(),
        },
      },
    );
    unawaited(ref.read(syncServiceProvider.notifier).syncPending());
  }

  void setUsername(String? username) {
    state = state.copyWith(username: username);
  }
}

final profileUsernameProvider = Provider<String?>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile.greetingName;
});
