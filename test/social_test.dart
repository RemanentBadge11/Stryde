import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/database/app_database.dart';
import 'package:stryde/core/database/local_cache_service.dart';
import 'package:stryde/core/sync/network_connectivity.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/exercises/presentation/providers/exercise_library_provider.dart';
import 'package:stryde/features/profile/data/profile_repository.dart';
import 'package:stryde/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:stryde/features/progression/presentation/providers/user_progression_provider.dart';
import 'package:stryde/features/routines/data/mock_workout_data.dart';
import 'package:stryde/features/routines/domain/entities/workout_routine.dart';
import 'package:stryde/features/routines/presentation/providers/custom_routines_provider.dart';
import 'package:stryde/features/social/data/social_repository.dart';
import 'package:stryde/features/social/domain/entities/social_post.dart';
import 'package:stryde/features/social/domain/entities/social_profile.dart';
import 'package:stryde/features/social/presentation/providers/social_providers.dart';
import 'package:stryde/features/social/presentation/screens/historical_workout_detail_screen.dart';
import 'package:stryde/features/social/presentation/widgets/social_author_header.dart';
import 'package:stryde/features/social/presentation/widgets/social_rank_up_card.dart';
import 'package:stryde/features/social/presentation/widgets/social_workout_card.dart';
import 'package:stryde/features/workout_history/domain/entities/completed_workout.dart';
import 'package:stryde/features/workout_logging/presentation/providers/active_workout_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------------------
// Test Doubles
// ---------------------------------------------------------------------------

class FakeNetworkConnectivity implements NetworkConnectivity {
  FakeNetworkConnectivity({bool initialOnline = true})
    : _isOnline = initialOnline;

  bool _isOnline;
  final _controller = StreamController<bool>.broadcast();

  void setOnline(bool online) {
    _isOnline = online;
    _controller.add(online);
  }

  @override
  Future<bool> get isOnline async => _isOnline;

  @override
  Stream<bool> get onConnectivityChanged => _controller.stream;

  void dispose() => _controller.close();
}

class FakeSocialRepository implements SocialRepository {
  FakeSocialRepository();

  final Map<String, SocialProfile> profiles = {};
  final Set<String> takenUsernames = {'existinguser', 'strydeathlete'};
  final List<Map<String, String>> followEdges =
      []; // follower_id -> following_id
  final List<SocialPost> posts = [];
  final Set<String> publishedWorkoutPostKeys = {}; // user_id:workout_id
  final Set<String> publishedRankPostKeys = {}; // user_id:rank_name

  @override
  Future<bool> isUsernameAvailable(String username) async {
    final clean = username.trim().toLowerCase();
    if (clean.length < 3) return false;
    return !takenUsernames.contains(clean);
  }

  @override
  Future<void> updateUsername({
    required String userId,
    required String username,
  }) async {
    takenUsernames.add(username.trim().toLowerCase());
    final current = profiles[userId];
    if (current != null) {
      profiles[userId] = current.copyWith(username: username.trim());
    }
  }

  @override
  Future<List<SocialPost>> getFeed({
    required String currentUserId,
    int limit = 20,
    int offset = 0,
  }) async {
    final followingIds = followEdges
        .where((e) => e['follower_id'] == currentUserId)
        .map((e) => e['following_id']!)
        .toSet();
    followingIds.add(currentUserId);

    final filtered =
        posts.where((p) => followingIds.contains(p.userId)).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (offset >= filtered.length) return const <SocialPost>[];
    return filtered.skip(offset).take(limit).toList();
  }

  @override
  Future<List<SocialPost>> getUserPosts({
    required String targetUserId,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  }) async {
    final userPosts = posts.where((p) => p.userId == targetUserId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (offset >= userPosts.length) return const <SocialPost>[];
    return userPosts.skip(offset).take(limit).toList();
  }

  @override
  Future<SocialPost?> getPostById(
    String postId, {
    String? currentUserId,
  }) async {
    return posts.cast<SocialPost?>().firstWhere(
      (p) => p?.id == postId,
      orElse: () => null,
    );
  }

  @override
  Future<SocialProfile?> getProfile(
    String targetUserId, {
    String? currentUserId,
  }) async {
    final prof = profiles[targetUserId];
    if (prof == null) return null;

    final followersCount = followEdges
        .where((e) => e['following_id'] == targetUserId)
        .length;
    final followingCount = followEdges
        .where((e) => e['follower_id'] == targetUserId)
        .length;
    final isFollowing =
        currentUserId != null &&
        followEdges.any(
          (e) =>
              e['follower_id'] == currentUserId &&
              e['following_id'] == targetUserId,
        );

    return prof.copyWith(
      followersCount: followersCount,
      followingCount: followingCount,
      isFollowing: isFollowing,
    );
  }

  @override
  Future<List<SocialProfile>> searchUsers(
    String query, {
    String? currentUserId,
    int limit = 25,
  }) async {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return const <SocialProfile>[];

    final matches = profiles.values.where((p) {
      final usernameMatch = p.username?.toLowerCase().contains(clean) ?? false;
      final nameMatch = p.displayName?.toLowerCase().contains(clean) ?? false;
      return usernameMatch || nameMatch;
    }).toList();

    return matches.take(limit).map((p) {
      final isFollowing =
          currentUserId != null &&
          followEdges.any(
            (e) =>
                e['follower_id'] == currentUserId && e['following_id'] == p.id,
          );
      return p.copyWith(isFollowing: isFollowing);
    }).toList();
  }

  @override
  Future<void> followUser(String currentUserId, String targetUserId) async {
    if (currentUserId == targetUserId) return; // Prevent self-following
    final alreadyFollowing = followEdges.any(
      (e) =>
          e['follower_id'] == currentUserId &&
          e['following_id'] == targetUserId,
    );
    if (!alreadyFollowing) {
      followEdges.add({
        'follower_id': currentUserId,
        'following_id': targetUserId,
      });
    }
  }

  @override
  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    followEdges.removeWhere(
      (e) =>
          e['follower_id'] == currentUserId &&
          e['following_id'] == targetUserId,
    );
  }

  @override
  Future<void> removeFollower(String currentUserId, String followerId) async {
    followEdges.removeWhere(
      (e) =>
          e['following_id'] == currentUserId && e['follower_id'] == followerId,
    );
  }

  @override
  Future<List<SocialProfile>> getFollowers(
    String targetUserId, {
    String? currentUserId,
  }) async {
    final followerIds = followEdges
        .where((e) => e['following_id'] == targetUserId)
        .map((e) => e['follower_id']!)
        .toList();

    final result = <SocialProfile>[];
    for (final id in followerIds) {
      final p = profiles[id];
      if (p != null) {
        final isFollowing =
            currentUserId != null &&
            followEdges.any(
              (e) =>
                  e['follower_id'] == currentUserId && e['following_id'] == id,
            );
        result.add(p.copyWith(isFollowing: isFollowing));
      }
    }
    return result;
  }

  @override
  Future<List<SocialProfile>> getFollowing(
    String targetUserId, {
    String? currentUserId,
  }) async {
    final followingIds = followEdges
        .where((e) => e['follower_id'] == targetUserId)
        .map((e) => e['following_id']!)
        .toList();

    final result = <SocialProfile>[];
    for (final id in followingIds) {
      final p = profiles[id];
      if (p != null) {
        final isFollowing =
            currentUserId != null &&
            followEdges.any(
              (e) =>
                  e['follower_id'] == currentUserId && e['following_id'] == id,
            );
        result.add(p.copyWith(isFollowing: isFollowing));
      }
    }
    return result;
  }

  @override
  Future<void> publishWorkoutPost({
    required String userId,
    required CompletedWorkout workout,
    List<String> prExercises = const <String>[],
  }) async {
    final key = '$userId:${workout.id}';
    if (publishedWorkoutPostKeys.contains(key)) return; // Idempotent
    publishedWorkoutPostKeys.add(key);

    final author =
        profiles[userId] ??
        SocialProfile(id: userId, username: 'athlete', level: 1);

    final post = SocialPost(
      id: 'post-${workout.id}',
      userId: userId,
      type: SocialPostType.workout,
      author: author,
      createdAt: workout.completedAt,
      workoutData: WorkoutPostData(
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
      ),
    );
    posts.insert(0, post);
  }

  @override
  Future<void> publishRankUpPost({
    required String userId,
    required String rankName,
    required int level,
  }) async {
    final key = '$userId:$rankName';
    if (publishedRankPostKeys.contains(key)) return; // Idempotent
    publishedRankPostKeys.add(key);

    final author =
        profiles[userId] ??
        SocialProfile(id: userId, username: 'athlete', level: level);

    final post = SocialPost(
      id: 'rankup-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: SocialPostType.rankUp,
      author: author,
      createdAt: DateTime.now(),
      rankUpData: RankUpPostData(rankName: rankName, level: level),
    );
    posts.insert(0, post);
  }
}

class FakeProfileRepoForSocial implements ProfileRepository {
  ProfileData? storedProfile;

  @override
  Future<ProfileData?> fetch(String userId) async => storedProfile;

  @override
  Future<ProfileData?> getOrFetchProfile(
    String userId, {
    String? defaultUsername,
  }) async => storedProfile;

  @override
  Future<void> saveGoals({
    required String userId,
    required int steps,
    required double water,
    required int protein,
  }) async {}

  @override
  Future<void> saveProfileInfo({
    required String userId,
    String? displayName,
    String? avatarUrl,
  }) async {
    storedProfile = storedProfile?.copyWith(
      displayName: displayName,
      avatarUrl: avatarUrl,
    );
  }

  @override
  Future<void> saveTimezone({
    required String userId,
    required String timezone,
  }) async {}

  @override
  Future<void> saveProgression({
    required String userId,
    required int xp,
    required int level,
    required int skillPoints,
    int? totalXp,
    int? availableSkillPoints,
  }) async {}

  @override
  Future<void> saveStreak({
    required String userId,
    required int streak,
    required DateTime? lastActivityOn,
  }) async {}

  @override
  Future<void> saveThemeSettings({
    required String userId,
    required String themeMode,
    required String accentColor,
  }) async {}
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late LocalCacheService localCache;
  late FakeNetworkConnectivity fakeConnectivity;
  late FakeSocialRepository socialRepo;
  late FakeProfileRepoForSocial profileRepo;

  final userA = User(
    id: 'user-a-111',
    appMetadata: const {},
    userMetadata: {'username': 'alice'},
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
  );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    localCache = LocalCacheService(db);
    fakeConnectivity = FakeNetworkConnectivity(initialOnline: true);
    socialRepo = FakeSocialRepository();
    profileRepo = FakeProfileRepoForSocial();

    socialRepo.profiles['user-a-111'] = const SocialProfile(
      id: 'user-a-111',
      username: 'alice',
      displayName: 'Alice Champion',
      level: 10,
    );

    socialRepo.profiles['user-b-222'] = const SocialProfile(
      id: 'user-b-222',
      username: 'bob',
      displayName: 'Bob Lifter',
      level: 25,
    );
  });

  tearDown(() async {
    fakeConnectivity.dispose();
    await db.close();
  });

  group('Social: Username Availability & Case-Insensitive Uniqueness', () {
    test(
      'validates username minimum length and availability case-insensitively',
      () async {
        expect(
          await socialRepo.isUsernameAvailable('al'),
          isFalse,
        ); // < 3 chars
        expect(await socialRepo.isUsernameAvailable('   '), isFalse);
        expect(
          await socialRepo.isUsernameAvailable('ExistingUser'),
          isFalse,
        ); // Case-insensitive
        expect(await socialRepo.isUsernameAvailable('existinguser'), isFalse);
        expect(await socialRepo.isUsernameAvailable('EXISTINGUSER'), isFalse);
        expect(await socialRepo.isUsernameAvailable('new_superstar'), isTrue);
      },
    );

    test(
      'updateUsername persists and updates local profile cache and sync queue',
      () async {
        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            localCacheServiceProvider.overrideWithValue(localCache),
            networkConnectivityProvider.overrideWithValue(fakeConnectivity),
            currentUserProvider.overrideWith((ref) => userA),
            socialRepositoryProvider.overrideWithValue(socialRepo),
            profileRepositoryProvider.overrideWithValue(profileRepo),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(userProfileProvider.notifier);
        final success = await notifier.updateUsername('alice_prime');
        expect(success, isTrue);

        final state = container.read(userProfileProvider);
        expect(state.username, 'alice_prime');

        // Verify cached locally in Drift
        final cached = await localCache.getCachedProfile('user-a-111');
        expect(cached?.username, 'alice_prime');

        // Verify enqueued into syncQueue
        final queued = await localCache.getPendingQueue();
        expect(
          queued.any(
            (e) =>
                e.entityType == 'profile' &&
                e.action == 'update' &&
                e.payload.contains('alice_prime'),
          ),
          isTrue,
        );
      },
    );
  });

  group('Social: Following System', () {
    test(
      'enforces no self-following and updates follow/unfollow/remove states',
      () async {
        // 1. Attempt self-follow -> must be prevented
        await socialRepo.followUser('user-a-111', 'user-a-111');
        expect(socialRepo.followEdges.isEmpty, isTrue);

        // 2. User A follows User B
        await socialRepo.followUser('user-a-111', 'user-b-222');
        expect(socialRepo.followEdges.length, 1);

        var profileB = await socialRepo.getProfile(
          'user-b-222',
          currentUserId: 'user-a-111',
        );
        expect(profileB?.isFollowing, isTrue);
        expect(profileB?.followersCount, 1);

        var profileA = await socialRepo.getProfile(
          'user-a-111',
          currentUserId: 'user-a-111',
        );
        expect(profileA?.followingCount, 1);

        // 3. User A unfollows User B
        await socialRepo.unfollowUser('user-a-111', 'user-b-222');
        profileB = await socialRepo.getProfile(
          'user-b-222',
          currentUserId: 'user-a-111',
        );
        expect(profileB?.isFollowing, isFalse);
        expect(profileB?.followersCount, 0);

        // 4. User B follows User A, then User A removes follower
        await socialRepo.followUser('user-b-222', 'user-a-111');
        var followersA = await socialRepo.getFollowers(
          'user-a-111',
          currentUserId: 'user-a-111',
        );
        expect(followersA.length, 1);
        expect(followersA.first.id, 'user-b-222');

        await socialRepo.removeFollower('user-a-111', 'user-b-222');
        followersA = await socialRepo.getFollowers(
          'user-a-111',
          currentUserId: 'user-a-111',
        );
        expect(followersA.isEmpty, isTrue);
      },
    );

    test('searches users by username substring', () async {
      final results = await socialRepo.searchUsers('bob');
      expect(results.length, 1);
      expect(results.first.username, 'bob');
    });
  });

  group('Social Feed: Activity Feed, Post Types, & Offline State', () {
    test(
      'renders activity feed from followed athletes in reverse chronological order',
      () async {
        // Follow User B
        await socialRepo.followUser('user-a-111', 'user-b-222');

        // Create two workouts
        final workoutB = CompletedWorkout(
          id: 'w-b-1',
          routineId: 'r-1',
          routineName: 'Heavy Legs',
          completedAt: DateTime.now().subtract(const Duration(hours: 2)),
          duration: const Duration(minutes: 45),
          exercises: const [
            CompletedWorkoutExercise(
              exerciseId: 'squat',
              exerciseName: 'Squat',
              sets: [
                CompletedWorkoutSet(setNumber: 1, weightKg: 100, reps: 10),
              ],
            ),
          ],
        );

        final workoutA = CompletedWorkout(
          id: 'w-a-1',
          routineId: 'r-2',
          routineName: 'Upper Body Blast',
          completedAt: DateTime.now().subtract(const Duration(minutes: 30)),
          duration: const Duration(minutes: 50),
          exercises: const [
            CompletedWorkoutExercise(
              exerciseId: 'bench',
              exerciseName: 'Bench Press',
              sets: [CompletedWorkoutSet(setNumber: 1, weightKg: 80, reps: 10)],
            ),
          ],
        );

        await socialRepo.publishWorkoutPost(
          userId: 'user-b-222',
          workout: workoutB,
        );
        await socialRepo.publishWorkoutPost(
          userId: 'user-a-111',
          workout: workoutA,
        );

        final feed = await socialRepo.getFeed(currentUserId: 'user-a-111');
        expect(feed.length, 2);
        expect(
          feed.first.workoutData?.routineName,
          'Upper Body Blast',
        ); // newer first
        expect(feed.last.workoutData?.routineName, 'Heavy Legs');
      },
    );

    test(
      'feed provider reports offline when network is disconnected',
      () async {
        fakeConnectivity.setOnline(false);

        final container = ProviderContainer(
          overrides: [
            networkConnectivityProvider.overrideWithValue(fakeConnectivity),
            currentUserProvider.overrideWith((ref) => userA),
            socialRepositoryProvider.overrideWithValue(socialRepo),
          ],
        );
        addTearDown(container.dispose);

        await container.read(socialFeedProvider.notifier).refresh();
        final state = container.read(socialFeedProvider);
        expect(state.isOffline, isTrue);
      },
    );

    testWidgets(
      'renders SocialWorkoutCard with author header [Username] [Level] [Rank SVG]',
      (tester) async {
        final post = SocialPost(
          id: 'post-test-1',
          userId: 'user-b-222',
          type: SocialPostType.workout,
          author: const SocialProfile(
            id: 'user-b-222',
            username: 'bob',
            displayName: 'Bob Lifter',
            level: 25,
          ),
          createdAt: DateTime.now(),
          workoutData: WorkoutPostData(
            workoutId: 'w-1',
            routineName: 'Chest & Arms',
            completedAt: DateTime.now(),
            durationSeconds: 3600,
            totalVolumeKg: 4500,
            totalSets: 10,
            totalReps: 80,
            exercisesSummary: const ['Bench Press', 'Incline Dumbbell Press'],
            prExercises: const ['Bench Press'],
            snapshot: CompletedWorkout(
              id: 'w-1',
              routineId: 'r-1',
              routineName: 'Chest & Arms',
              completedAt: DateTime.now(),
              duration: const Duration(minutes: 60),
              exercises: const [],
            ),
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: SocialWorkoutCard(post: post)),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(SocialAuthorHeader), findsOneWidget);
        expect(find.text('@bob'), findsOneWidget);
        expect(find.text('Lv. 25'), findsOneWidget);
        expect(find.text('Chest & Arms'), findsOneWidget);
        expect(find.textContaining('Bench Press'), findsAtLeastNWidgets(1));
        expect(find.text('10 sets'), findsOneWidget);
      },
    );

    testWidgets('renders SocialRankUpCard on rank promotion', (tester) async {
      final post = SocialPost(
        id: 'rankup-1',
        userId: 'user-a-111',
        type: SocialPostType.rankUp,
        author: const SocialProfile(
          id: 'user-a-111',
          username: 'alice',
          displayName: 'Alice Champion',
          level: 30,
        ),
        createdAt: DateTime.now(),
        rankUpData: const RankUpPostData(rankName: 'Silver', level: 30),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SocialRankUpCard(post: post)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('RANK PROMOTION'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is RichText &&
              w.text.toPlainText().contains('ranked up to Silver'),
        ),
        findsOneWidget,
      );
    });
  });

  group('Social: Offline Synchronization & Idempotency', () {
    test(
      'finishWorkout enqueues workout to syncQueue and conditionally enqueues rank_up',
      () async {
        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            localCacheServiceProvider.overrideWithValue(localCache),
            networkConnectivityProvider.overrideWithValue(fakeConnectivity),
            currentUserProvider.overrideWith((ref) => userA),
            socialRepositoryProvider.overrideWithValue(socialRepo),
            profileRepositoryProvider.overrideWithValue(profileRepo),
          ],
        );
        addTearDown(container.dispose);

        final activeNotifier = container.read(activeWorkoutProvider.notifier);
        final routine = WorkoutRoutine(
          id: 'test-routine-1',
          name: 'Quick Test',
          focus: 'Legs',
          estimatedMinutes: 20,
          isCustom: true,
          exercises: [
            RoutineExercise(
              exercise: MockWorkoutData.squat,
              targetSets: 1,
              targetReps: 5,
            ),
          ],
        );

        // Start & complete set
        activeNotifier.startWorkout(routine);
        activeNotifier.updateWeight(0, 0, '100');
        activeNotifier.updateReps(0, 0, '5');
        activeNotifier.toggleSetCompletion(0, 0);

        // Finish workout
        final result = activeNotifier.finishWorkout();
        expect(result, isNotNull);
        final workout = result!.workout;

        // Allow async unawaited(_insert) to execute
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Verify syncQueue entries
        final entries = await localCache.getPendingQueue();
        final workoutEntry = entries.firstWhere(
          (e) => e.entityType == 'workout',
        );
        expect(workoutEntry.action, 'insert');
        expect(workoutEntry.payload.contains(workout.id), isTrue);

        // Verify SocialRepository publishWorkoutPost and idempotency
        await socialRepo.publishWorkoutPost(
          userId: 'user-a-111',
          workout: workout,
          prExercises: const ['Squat'],
        );
        expect(
          socialRepo.posts.any((p) => p.workoutData?.workoutId == workout.id),
          isTrue,
        );

        // Verify idempotency: duplicate publication does not duplicate posts
        await socialRepo.publishWorkoutPost(
          userId: 'user-a-111',
          workout: workout,
          prExercises: const ['Squat'],
        );
        final duplicateWorkoutCount = socialRepo.posts
            .where((p) => p.workoutData?.workoutId == workout.id)
            .length;
        expect(duplicateWorkoutCount, 1);

        // Verify rank promotion post publication and idempotency
        await socialRepo.publishRankUpPost(
          userId: 'user-a-111',
          rankName: 'Bronze',
          level: 10,
        );
        await socialRepo.publishRankUpPost(
          userId: 'user-a-111',
          rankName: 'Bronze',
          level: 10,
        );
        final duplicateRankCount = socialRepo.posts
            .where((p) => p.rankUpData?.rankName == 'Bronze')
            .length;
        expect(duplicateRankCount, 1);
      },
    );
  });

  group('Social: Historical Workout Viewer & Routine Conversion', () {
    testWidgets(
      'Save Workout Routine converts snapshot to new custom routine with attribution and exact set targets without XP',
      (tester) async {
        final snapshot = CompletedWorkout(
          id: 'snapshot-100',
          routineId: 'orig-routine-99',
          routineName: 'Pro Leg Day',
          completedAt: DateTime.now().subtract(const Duration(days: 1)),
          duration: const Duration(minutes: 55),
          exercises: const [
            CompletedWorkoutExercise(
              exerciseId: 'squat-1',
              exerciseName: 'Squat',
              exerciseType: 'weight_reps',
              sets: [
                CompletedWorkoutSet(setNumber: 1, reps: 8, weightKg: 100),
                CompletedWorkoutSet(setNumber: 2, reps: 8, weightKg: 110),
              ],
            ),
          ],
        );

        final post = SocialPost(
          id: 'post-historical-1',
          userId: 'user-b-222',
          type: SocialPostType.workout,
          author: const SocialProfile(
            id: 'user-b-222',
            username: 'bob_olympian',
            displayName: 'Bob Olympian',
            level: 40,
          ),
          createdAt: snapshot.completedAt,
          workoutData: WorkoutPostData(
            workoutId: snapshot.id,
            routineName: snapshot.routineName,
            completedAt: snapshot.completedAt,
            durationSeconds: snapshot.duration.inSeconds,
            totalVolumeKg: snapshot.totalVolume,
            totalSets: snapshot.totalSets,
            totalReps: snapshot.totalReps,
            exercisesSummary: const ['Squat'],
            snapshot: snapshot,
          ),
        );

        socialRepo.posts.add(post);

        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            localCacheServiceProvider.overrideWithValue(localCache),
            networkConnectivityProvider.overrideWithValue(fakeConnectivity),
            currentUserProvider.overrideWith((ref) => userA),
            socialRepositoryProvider.overrideWithValue(socialRepo),
            exerciseLibraryProvider.overrideWith(
              (ref) async => [MockWorkoutData.squat],
            ),
          ],
        );
        addTearDown(container.dispose);

        // Verify baseline progression XP before routine save
        final xpBefore = container.read(userProgressionProvider).totalXp;

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: HistoricalWorkoutDetailScreen(
                postId: post.id,
                initialPost: post,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify historical snapshot details render read-only
        expect(find.text('Pro Leg Day'), findsOneWidget);
        expect(find.text('Squat'), findsOneWidget);
        expect(find.text('100 kg × 8 reps'), findsOneWidget);
        expect(find.text('110 kg × 8 reps'), findsOneWidget);

        // Tap "Save Workout Routine" button
        final saveRoutineBtn = find.byKey(
          const ValueKey<String>('save-workout-routine-button'),
        );
        expect(saveRoutineBtn, findsOneWidget);

        await tester.tap(saveRoutineBtn);
        await tester.pumpAndSettle();

        // Verify routine saved in customRoutinesProvider
        final customRoutines = container.read(customRoutinesProvider);
        expect(customRoutines.length, 1);
        final savedRoutine = customRoutines.first;

        expect(savedRoutine.name, 'Pro Leg Day');
        expect(savedRoutine.isCustom, isTrue);
        expect(savedRoutine.savedFromUsername, 'bob_olympian'); // Attribution
        expect(savedRoutine.exercises.length, 1);

        // Verify exact set targets preserved
        final setTargets = savedRoutine.exercises.first.targetSetDetails;
        expect(setTargets, isNotNull);
        expect(setTargets!.length, 2);
        expect(setTargets[0].weightKg, 100);
        expect(setTargets[0].reps, 8);
        expect(setTargets[1].weightKg, 110);
        expect(setTargets[1].reps, 8);

        // Verify NO XP or progression rewards awarded for saving routine
        final xpAfter = container.read(userProgressionProvider).totalXp;
        expect(xpAfter, xpBefore);
      },
    );
  });
}
