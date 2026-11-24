import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/social/domain/entities/social_post.dart';
import 'package:stryde/features/social/domain/entities/social_profile.dart';
import 'package:stryde/features/workout_history/domain/entities/completed_workout.dart';

final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return SocialRepository(supabase);
});

class SocialRepository {
  const SocialRepository(this._supabase);

  final SupabaseClient? _supabase;

  SupabaseClient? get _client => _supabase;

  /// Verifies if a username is available (case-insensitive).
  Future<bool> isUsernameAvailable(String username) async {
    final client = _client;
    if (client == null) return true;
    final clean = username.trim();
    if (clean.length < 3) return false;
    try {
      final res = await client.rpc(
        'check_username_available',
        params: {'check_username': clean},
      );
      return res == true;
    } catch (_) {
      // Fallback query if RPC unavailable
      final row = await client
          .from('profiles')
          .select('id')
          .ilike('username', clean)
          .maybeSingle();
      return row == null;
    }
  }

  /// Updates the username for the given user ID.
  Future<void> updateUsername({
    required String userId,
    required String username,
  }) async {
    final client = _client;
    if (client == null) return;
    await client
        .from('profiles')
        .update(<String, dynamic>{'username': username})
        .eq('id', userId);
  }

  /// Fetches the social activity feed for the current user.
  /// Includes activity from followed athletes and the current user's own published posts:
  /// SELECT * FROM social_posts WHERE user_id = auth.uid() OR user_id IN (SELECT following_id FROM follows WHERE follower_id = auth.uid()) ORDER BY created_at DESC
  Future<List<SocialPost>> getFeed({
    required String currentUserId,
    int limit = 20,
    int offset = 0,
  }) async {
    final client = _client;
    if (client == null) return const <SocialPost>[];

    final authUid = client.auth.currentUser?.id;
    final effectiveUserId = (authUid != null && authUid.isNotEmpty)
        ? authUid
        : currentUserId;

    // 1. Get the list of IDs followed by the current user:
    // (SELECT following_id FROM follows WHERE follower_id = auth.uid())
    final followRows = await client
        .from('follows')
        .select('following_id')
        .eq('follower_id', effectiveUserId);

    // Combine user_id = auth.uid() OR user_id IN (followed IDs)
    final targetUserIds = <String>{
      effectiveUserId,
      if (currentUserId.isNotEmpty) currentUserId,
      for (final r in followRows)
        if (r['following_id'] != null) r['following_id'].toString(),
    }.toList();

    // 2. Fetch posts from current user OR followed users, ordered by created_at DESC
    final postRows = await client
        .from('social_posts')
        .select(
          '*, profiles:user_id(id, username, display_name, avatar_url, level, total_xp)',
        )
        .inFilter('user_id', targetUserIds)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return _parsePosts(postRows, currentUserId: effectiveUserId);
  }

  /// Fetches published activity posts for a specific user profile.
  Future<List<SocialPost>> getUserPosts({
    required String targetUserId,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  }) async {
    final client = _client;
    if (client == null) return const <SocialPost>[];

    final postRows = await client
        .from('social_posts')
        .select(
          '*, profiles:user_id(id, username, display_name, avatar_url, level, total_xp)',
        )
        .eq('user_id', targetUserId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return _parsePosts(postRows, currentUserId: currentUserId);
  }

  /// Fetches a single post by its ID.
  Future<SocialPost?> getPostById(
    String postId, {
    String? currentUserId,
  }) async {
    final client = _client;
    if (client == null) return null;

    final row = await client
        .from('social_posts')
        .select(
          '*, profiles:user_id(id, username, display_name, avatar_url, level, total_xp)',
        )
        .eq('id', postId)
        .maybeSingle();

    if (row == null) return null;
    final posts = _parsePosts([row], currentUserId: currentUserId);
    return posts.isNotEmpty ? posts.first : null;
  }

  /// Fetches the public profile information and social stats for a user.
  Future<SocialProfile?> getProfile(
    String targetUserId, {
    String? currentUserId,
  }) async {
    final client = _client;
    if (client == null) return null;

    final profileRow = await client
        .from('profiles')
        .select('id, username, display_name, avatar_url, level, total_xp, xp')
        .eq('id', targetUserId)
        .maybeSingle();

    if (profileRow == null) return null;

    int followersCount = 0;
    int followingCount = 0;

    try {
      final stats = await client.rpc(
        'get_profile_social_stats',
        params: {'target_user_id': targetUserId},
      );
      if (stats is Map) {
        followersCount = (stats['followers_count'] as num?)?.toInt() ?? 0;
        followingCount = (stats['following_count'] as num?)?.toInt() ?? 0;
      }
    } catch (_) {
      // Fallback count query
      final followers = await client
          .from('follows')
          .select('follower_id')
          .eq('following_id', targetUserId);
      final following = await client
          .from('follows')
          .select('following_id')
          .eq('follower_id', targetUserId);
      followersCount = followers.length;
      followingCount = following.length;
    }

    bool isFollowing = false;
    if (currentUserId != null && currentUserId != targetUserId) {
      final followCheck = await client
          .from('follows')
          .select('follower_id')
          .eq('follower_id', currentUserId)
          .eq('following_id', targetUserId)
          .maybeSingle();
      isFollowing = followCheck != null;
    }

    return SocialProfile.fromJson(
      profileRow,
      currentUserId: currentUserId,
      isFollowing: isFollowing,
      followersCount: followersCount,
      followingCount: followingCount,
    );
  }

  /// Searches users by username or display name (case-insensitive substring).
  Future<List<SocialProfile>> searchUsers(
    String query, {
    String? currentUserId,
    int limit = 25,
  }) async {
    final client = _client;
    if (client == null) return const <SocialProfile>[];

    final clean = query.trim();
    if (clean.isEmpty) return const <SocialProfile>[];

    final rows = await client
        .from('profiles')
        .select('id, username, display_name, avatar_url, level, total_xp, xp')
        .or('username.ilike.%$clean%,display_name.ilike.%$clean%')
        .limit(limit);

    if (rows.isEmpty) return const <SocialProfile>[];

    // Check which ones are followed by current user
    final followedIds = <String>{};
    if (currentUserId != null) {
      final targetIds = rows.map((r) => r['id'].toString()).toList();
      final followRows = await client
          .from('follows')
          .select('following_id')
          .eq('follower_id', currentUserId)
          .inFilter('following_id', targetIds);
      for (final r in followRows) {
        followedIds.add(r['following_id'].toString());
      }
    }

    return rows.map((r) {
      final id = r['id'].toString();
      return SocialProfile.fromJson(
        r,
        currentUserId: currentUserId,
        isFollowing: followedIds.contains(id),
      );
    }).toList();
  }

  /// Follows another user.
  Future<void> followUser(String currentUserId, String targetUserId) async {
    final client = _client;
    if (client == null || currentUserId == targetUserId) return;
    await client.from('follows').upsert({
      'follower_id': currentUserId,
      'following_id': targetUserId,
    });
  }

  /// Unfollows another user.
  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    final client = _client;
    if (client == null) return;
    await client
        .from('follows')
        .delete()
        .eq('follower_id', currentUserId)
        .eq('following_id', targetUserId);
  }

  /// Removes a follower (a user who is following the current user).
  Future<void> removeFollower(String currentUserId, String followerId) async {
    final client = _client;
    if (client == null) return;
    await client
        .from('follows')
        .delete()
        .eq('following_id', currentUserId)
        .eq('follower_id', followerId);
  }

  /// Fetches the list of followers for a user.
  Future<List<SocialProfile>> getFollowers(
    String targetUserId, {
    String? currentUserId,
  }) async {
    final client = _client;
    if (client == null) return const <SocialProfile>[];

    final rows = await client
        .from('follows')
        .select(
          'follower_id, profiles:follower_id(id, username, display_name, avatar_url, level, total_xp, xp)',
        )
        .eq('following_id', targetUserId);

    if (rows.isEmpty) return const <SocialProfile>[];

    final profileRows = <Map<String, dynamic>>[];
    for (final r in rows) {
      final p = r['profiles'];
      if (p is Map<String, dynamic>) {
        profileRows.add(p);
      }
    }

    return _buildProfilesWithFollowState(
      profileRows,
      currentUserId: currentUserId,
    );
  }

  /// Fetches the list of athletes followed by a user.
  Future<List<SocialProfile>> getFollowing(
    String targetUserId, {
    String? currentUserId,
  }) async {
    final client = _client;
    if (client == null) return const <SocialProfile>[];

    final rows = await client
        .from('follows')
        .select(
          'following_id, profiles:following_id(id, username, display_name, avatar_url, level, total_xp, xp)',
        )
        .eq('follower_id', targetUserId);

    if (rows.isEmpty) return const <SocialProfile>[];

    final profileRows = <Map<String, dynamic>>[];
    for (final r in rows) {
      final p = r['profiles'];
      if (p is Map<String, dynamic>) {
        profileRows.add(p);
      }
    }

    return _buildProfilesWithFollowState(
      profileRows,
      currentUserId: currentUserId,
    );
  }

  /// Automatically publishes a workout completion event post.
  /// Idempotent via (user_id, workout_id) unique constraint.
  Future<void> publishWorkoutPost({
    required String userId,
    required CompletedWorkout workout,
    List<String> prExercises = const <String>[],
  }) async {
    final client = _client;
    if (client == null) return;

    final postData = WorkoutPostData(
      workoutId: workout.id,
      routineName: workout.routineName,
      completedAt: workout.completedAt,
      durationSeconds: workout.duration.inSeconds,
      totalVolumeKg: workout.totalVolume,
      totalSets: workout.totalSets,
      totalReps: workout.totalReps,
      exercisesSummary: workout.exercises.map((e) => e.exerciseName).toList(),
      prExercises: prExercises,
      snapshot: workout,
    );

    try {
      await client.from('social_posts').upsert({
        'user_id': userId,
        'type': 'workout',
        'workout_id': workout.id,
        'data': postData.toJson(),
        'created_at': workout.completedAt.toUtc().toIso8601String(),
      }, onConflict: 'user_id, workout_id');
    } catch (e) {
      // ignore: avoid_print
      print('Supabase insert error: $e');
    }
  }

  /// Automatically publishes a rank promotion event post.
  /// Idempotent via (user_id, rank_name) unique constraint.
  Future<void> publishRankUpPost({
    required String userId,
    required String rankName,
    required int level,
  }) async {
    final client = _client;
    if (client == null) return;

    final postData = RankUpPostData(rankName: rankName, level: level);

    await client.from('social_posts').upsert({
      'user_id': userId,
      'type': 'rank_up',
      'rank_name': rankName,
      'data': postData.toJson(),
    }, onConflict: 'user_id, rank_name');
  }

  List<SocialPost> _parsePosts(List<dynamic> rows, {String? currentUserId}) {
    final posts = <SocialPost>[];
    for (final row in rows) {
      if (row is! Map<String, dynamic>) continue;
      try {
        posts.add(SocialPost.fromJson(row, currentUserId: currentUserId));
      } catch (_) {
        // Skip malformed post to protect feed stability
      }
    }
    return posts;
  }

  Future<List<SocialProfile>> _buildProfilesWithFollowState(
    List<Map<String, dynamic>> profiles, {
    String? currentUserId,
  }) async {
    final followedIds = <String>{};
    final client = _client;
    if (currentUserId != null && profiles.isNotEmpty && client != null) {
      final targetIds = profiles.map((p) => p['id'].toString()).toList();
      final followRows = await client
          .from('follows')
          .select('following_id')
          .eq('follower_id', currentUserId)
          .inFilter('following_id', targetIds);
      for (final r in followRows) {
        followedIds.add(r['following_id'].toString());
      }
    }

    return profiles.map((p) {
      final id = p['id'].toString();
      return SocialProfile.fromJson(
        p,
        currentUserId: currentUserId,
        isFollowing: followedIds.contains(id),
      );
    }).toList();
  }
}
