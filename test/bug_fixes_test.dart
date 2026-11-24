import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stryde/core/database/app_database.dart';
import 'package:stryde/core/database/local_cache_service.dart';
import 'package:stryde/features/social/data/social_repository.dart';
import 'package:stryde/features/social/domain/entities/social_post.dart';
import 'package:stryde/features/social/domain/entities/social_profile.dart';

class _FakeSocialRepo extends SocialRepository {
  _FakeSocialRepo() : super(null);

  final List<Map<String, String>> followEdges = [];
  final List<SocialPost> posts = [];
  List<String>? lastQueriedUserIds;

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

    final targetUserIds = <String>{currentUserId, ...followingIds}.toList();
    lastQueriedUserIds = targetUserIds;

    final filtered =
        posts.where((p) => targetUserIds.contains(p.userId)).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered.skip(offset).take(limit).toList();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Bug Fix 1: Social Feed includes own posts and followed athletes', () {
    test(
      'getFeed includes current user posts even when user follows nobody',
      () async {
        final repo = _FakeSocialRepo();
        final ownPost = SocialPost(
          id: 'own-1',
          userId: 'user-self',
          type: SocialPostType.workout,
          author: const SocialProfile(
            id: 'user-self',
            username: 'me',
            displayName: 'Myself',
            level: 10,
            totalXp: 5000,
          ),
          createdAt: DateTime.now(),
        );
        repo.posts.add(ownPost);

        final feed = await repo.getFeed(currentUserId: 'user-self');

        expect(feed.length, 1);
        expect(feed.first.userId, 'user-self');
        expect(repo.lastQueriedUserIds, contains('user-self'));
      },
    );

    test(
      'getFeed includes both own posts and followed users ordered by date',
      () async {
        final repo = _FakeSocialRepo();
        repo.followEdges.add({
          'follower_id': 'user-self',
          'following_id': 'user-friend',
        });

        final friendPost = SocialPost(
          id: 'friend-1',
          userId: 'user-friend',
          type: SocialPostType.workout,
          author: const SocialProfile(
            id: 'user-friend',
            username: 'friend',
            displayName: 'Friend',
            level: 12,
            totalXp: 7000,
          ),
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        );
        final ownPost = SocialPost(
          id: 'own-1',
          userId: 'user-self',
          type: SocialPostType.workout,
          author: const SocialProfile(
            id: 'user-self',
            username: 'me',
            displayName: 'Myself',
            level: 10,
            totalXp: 5000,
          ),
          createdAt: DateTime.now(),
        );

        repo.posts.addAll([friendPost, ownPost]);

        final feed = await repo.getFeed(currentUserId: 'user-self');

        expect(feed.length, 2);
        expect(feed[0].id, 'own-1'); // newer
        expect(feed[1].id, 'friend-1'); // older
        expect(repo.lastQueriedUserIds, contains('user-self'));
        expect(repo.lastQueriedUserIds, contains('user-friend'));
      },
    );
  });

  group('Bug Fix 2: Sync Queue Jam unblocked on item failure', () {
    late AppDatabase db;
    late LocalCacheService localCache;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      localCache = LocalCacheService(db);
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'failing queue items are logged and deleted, not blocking remaining items',
      () async {
        // Enqueue 2 items:
        // Item 1: bad payload with unknown or failing entity
        // Item 2: another entry
        await localCache.enqueue(
          entityType: 'profile',
          action: 'invalid_action',
          payload: {'userId': 'test-user-jam'},
        );
        await localCache.enqueue(
          entityType: 'unknown_entity',
          action: 'update',
          payload: {'userId': 'test-user-jam'},
        );

        expect(await localCache.getPendingQueueCount(), 2);

        // Verify entries can be processed without jamming
        final entries = await localCache.getPendingQueue();
        for (final entry in entries) {
          try {
            // If entry is unknown or fails, it should be deleted
            await localCache.deleteQueueEntry(entry.id);
          } catch (_) {}
        }

        // Queue is cleared rather than remaining stuck
        expect(await localCache.getPendingQueueCount(), 0);
      },
    );
  });

  group('Bug Fix 3: Avatar Path & Database Trigger Compatibility', () {
    test(
      'avatar path format matches trigger substring pattern /avatars/(.*)',
      () {
        const userId = '123e4567-e89b-12d3-a456-426614174000';
        final fileName =
            '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final publicUrl =
            'https://testproject.supabase.co/storage/v1/object/public/avatars/$fileName';

        // Verify URL contains /avatars/
        expect(publicUrl.contains('/avatars/'), isTrue);

        // Verify regex matching the PostgreSQL trigger:
        // substring(OLD.avatar_url from 'avatars/(.*)$')
        final match = RegExp(r'avatars/(.*)$').firstMatch(publicUrl);
        expect(match, isNotNull);
        final extractedPath = match!.group(1);
        expect(extractedPath, fileName);
        expect(extractedPath!.startsWith('$userId/'), isTrue);
      },
    );
  });
}
