import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      final data = await repo.fetch(userId);
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
    } catch (_) {
      // Degrades gracefully
    }
  }

  Future<void> setDisplayName(String displayName) async {
    final clean = displayName.trim();
    state = state.copyWith(displayName: clean);
    final userId = _activeUserId;
    final repo = _repository;
    if (userId != null && repo != null) {
      await repo.saveProfileInfo(userId: userId, displayName: clean);
    }
  }

  Future<void> setAvatarUrl(String avatarUrl) async {
    final clean = avatarUrl.trim();
    state = state.copyWith(avatarUrl: clean);
    final userId = _activeUserId;
    final repo = _repository;
    if (userId != null && repo != null) {
      await repo.saveProfileInfo(userId: userId, avatarUrl: clean);
    }
  }

  void setUsername(String? username) {
    state = state.copyWith(username: username);
  }
}

final profileUsernameProvider = Provider<String?>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile.greetingName;
});
