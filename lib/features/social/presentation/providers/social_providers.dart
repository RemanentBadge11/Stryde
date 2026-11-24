import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stryde/core/sync/network_connectivity.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/social/data/social_repository.dart';
import 'package:stryde/features/social/domain/entities/social_post.dart';
import 'package:stryde/features/social/domain/entities/social_profile.dart';

// ---------------------------------------------------------------------------
// Feed State & Notifier
// ---------------------------------------------------------------------------

class SocialFeedState {
  const SocialFeedState({
    this.posts = const <SocialPost>[],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
    this.isOffline = false,
  });

  final List<SocialPost> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;
  final bool isOffline;

  SocialFeedState copyWith({
    List<SocialPost>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
    bool clearError = false,
    bool? isOffline,
  }) {
    return SocialFeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

final socialFeedProvider =
    NotifierProvider<SocialFeedNotifier, SocialFeedState>(
      SocialFeedNotifier.new,
    );

class SocialFeedNotifier extends Notifier<SocialFeedState> {
  static const int _pageSize = 20;

  @override
  SocialFeedState build() {
    ref.listen(currentUserProvider, (_, next) {
      if (next != null) refresh();
    });

    final connectivity = ref.watch(networkConnectivityProvider);
    connectivity.isOnline.then((online) {
      if (!online) {
        state = state.copyWith(isOffline: true);
      } else {
        refresh();
      }
    });

    return const SocialFeedState(isLoading: true);
  }

  Future<void> refresh() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = state.copyWith(isLoading: false, posts: const <SocialPost>[]);
      return;
    }

    final isOnline = await ref.read(networkConnectivityProvider).isOnline;
    if (!isOnline) {
      state = state.copyWith(
        isLoading: false,
        isOffline: true,
        errorMessage: 'Social requires an internet connection',
      );
      return;
    }

    state = state.copyWith(isLoading: true, isOffline: false, clearError: true);

    try {
      final repo = ref.read(socialRepositoryProvider);
      final posts = await repo.getFeed(
        currentUserId: user.id,
        limit: _pageSize,
        offset: 0,
      );

      state = state.copyWith(
        posts: posts,
        isLoading: false,
        hasMore: posts.length >= _pageSize,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load activity feed: $e',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final repo = ref.read(socialRepositoryProvider);
      final nextPosts = await repo.getFeed(
        currentUserId: user.id,
        limit: _pageSize,
        offset: state.posts.length,
      );

      final combined = <SocialPost>[...state.posts, ...nextPosts];
      state = state.copyWith(
        posts: combined,
        isLoadingMore: false,
        hasMore: nextPosts.length >= _pageSize,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

// ---------------------------------------------------------------------------
// Other User Profile Notifier (Profile + Activity + Follow Toggle)
// ---------------------------------------------------------------------------

class UserProfileViewState {
  const UserProfileViewState({
    this.profile,
    this.posts = const <SocialPost>[],
    this.isLoading = true,
    this.isUpdatingFollow = false,
    this.errorMessage,
    this.isOffline = false,
  });

  final SocialProfile? profile;
  final List<SocialPost> posts;
  final bool isLoading;
  final bool isUpdatingFollow;
  final String? errorMessage;
  final bool isOffline;

  UserProfileViewState copyWith({
    SocialProfile? profile,
    List<SocialPost>? posts,
    bool? isLoading,
    bool? isUpdatingFollow,
    String? errorMessage,
    bool clearError = false,
    bool? isOffline,
  }) {
    return UserProfileViewState(
      profile: profile ?? this.profile,
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isUpdatingFollow: isUpdatingFollow ?? this.isUpdatingFollow,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

final userProfileViewProvider = NotifierProvider.autoDispose
    .family<UserProfileViewNotifier, UserProfileViewState, String>(
      UserProfileViewNotifier.new,
    );

class UserProfileViewNotifier extends Notifier<UserProfileViewState> {
  UserProfileViewNotifier(this.targetUserId);

  final String targetUserId;

  @override
  UserProfileViewState build() {
    _load(targetUserId);
    return const UserProfileViewState(isLoading: true);
  }

  Future<void> _load(String targetUserId) async {
    final currentUserId = ref.read(currentUserProvider)?.id;
    final isOnline = await ref.read(networkConnectivityProvider).isOnline;
    if (!isOnline) {
      state = state.copyWith(
        isLoading: false,
        isOffline: true,
        errorMessage: 'Social requires an internet connection',
      );
      return;
    }

    try {
      final repo = ref.read(socialRepositoryProvider);
      final profile = await repo.getProfile(
        targetUserId,
        currentUserId: currentUserId,
      );
      final posts = await repo.getUserPosts(
        targetUserId: targetUserId,
        currentUserId: currentUserId,
      );

      state = state.copyWith(
        profile: profile,
        posts: posts,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load profile: $e',
      );
    }
  }

  Future<void> toggleFollow() async {
    final profile = state.profile;
    final currentUserId = ref.read(currentUserProvider)?.id;
    if (profile == null || currentUserId == null || state.isUpdatingFollow) {
      return;
    }

    final currentlyFollowing = profile.isFollowing;
    final newFollowState = !currentlyFollowing;
    final updatedFollowersCount = currentlyFollowing
        ? (profile.followersCount > 0 ? profile.followersCount - 1 : 0)
        : profile.followersCount + 1;

    // Optimistic UI update
    state = state.copyWith(
      isUpdatingFollow: true,
      profile: profile.copyWith(
        isFollowing: newFollowState,
        followersCount: updatedFollowersCount,
      ),
    );

    try {
      final repo = ref.read(socialRepositoryProvider);
      if (currentlyFollowing) {
        await repo.unfollowUser(currentUserId, profile.id);
      } else {
        await repo.followUser(currentUserId, profile.id);
      }
      // Invalidate current user's following list and feed
      ref.invalidate(mySocialStatsProvider);
      ref.read(socialFeedProvider.notifier).refresh();
    } catch (e) {
      // Revert on error
      state = state.copyWith(profile: profile);
    } finally {
      state = state.copyWith(isUpdatingFollow: false);
    }
  }

  Future<void> refresh() => _load(targetUserId);
}

// ---------------------------------------------------------------------------
// Current User Social Stats Provider (Followers & Following counts)
// ---------------------------------------------------------------------------

final mySocialStatsProvider = FutureProvider<SocialProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final repo = ref.watch(socialRepositoryProvider);
  try {
    return await repo.getProfile(user.id, currentUserId: user.id);
  } catch (_) {
    return null;
  }
});

// ---------------------------------------------------------------------------
// User Search Provider
// ---------------------------------------------------------------------------

class UserSearchState {
  const UserSearchState({
    this.query = '',
    this.results = const <SocialProfile>[],
    this.isLoading = false,
    this.errorMessage,
  });

  final String query;
  final List<SocialProfile> results;
  final bool isLoading;
  final String? errorMessage;

  UserSearchState copyWith({
    String? query,
    List<SocialProfile>? results,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return UserSearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final userSearchProvider =
    NotifierProvider.autoDispose<UserSearchNotifier, UserSearchState>(
      UserSearchNotifier.new,
    );

class UserSearchNotifier extends Notifier<UserSearchState> {
  Timer? _debounce;

  @override
  UserSearchState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const UserSearchState();
  }

  void onQueryChanged(String query) {
    state = state.copyWith(query: query);
    _debounce?.cancel();

    final clean = query.trim();
    if (clean.isEmpty) {
      state = state.copyWith(
        results: const <SocialProfile>[],
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(clean));
  }

  Future<void> _search(String query) async {
    final currentUserId = ref.read(currentUserProvider)?.id;
    try {
      final repo = ref.read(socialRepositoryProvider);
      final results = await repo.searchUsers(
        query,
        currentUserId: currentUserId,
      );
      state = state.copyWith(results: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Search failed: $e',
      );
    }
  }

  Future<void> toggleFollowUser(SocialProfile target) async {
    final currentUserId = ref.read(currentUserProvider)?.id;
    if (currentUserId == null) return;

    final updatedResults = state.results.map((p) {
      if (p.id == target.id) {
        return p.copyWith(isFollowing: !p.isFollowing);
      }
      return p;
    }).toList();

    state = state.copyWith(results: updatedResults);

    try {
      final repo = ref.read(socialRepositoryProvider);
      if (target.isFollowing) {
        await repo.unfollowUser(currentUserId, target.id);
      } else {
        await repo.followUser(currentUserId, target.id);
      }
      ref.invalidate(mySocialStatsProvider);
      ref.read(socialFeedProvider.notifier).refresh();
    } catch (_) {
      // Revert
      state = state.copyWith(results: state.results);
    }
  }
}

// ---------------------------------------------------------------------------
// Followers & Following Lists Provider
// ---------------------------------------------------------------------------

final followersListProvider = FutureProvider.autoDispose
    .family<List<SocialProfile>, String>((ref, targetUserId) async {
      final currentUserId = ref.watch(currentUserProvider)?.id;
      final repo = ref.watch(socialRepositoryProvider);
      return repo.getFollowers(targetUserId, currentUserId: currentUserId);
    });

final followingListProvider = FutureProvider.autoDispose
    .family<List<SocialProfile>, String>((ref, targetUserId) async {
      final currentUserId = ref.watch(currentUserProvider)?.id;
      final repo = ref.watch(socialRepositoryProvider);
      return repo.getFollowing(targetUserId, currentUserId: currentUserId);
    });
