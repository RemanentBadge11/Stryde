import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_spacing.dart';
import 'package:stryde/core/widgets/empty_state_card.dart';
import 'package:stryde/core/widgets/loading_state_card.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/social/data/social_repository.dart';
import 'package:stryde/features/social/domain/entities/social_profile.dart';
import 'package:stryde/features/social/presentation/providers/social_providers.dart';
import 'package:stryde/features/social/presentation/widgets/user_list_tile.dart';

class FollowersScreen extends ConsumerStatefulWidget {
  const FollowersScreen({
    required this.userId,
    required this.isFollowers,
    this.initialProfile,
    super.key,
  });

  final String userId;
  final bool isFollowers;
  final SocialProfile? initialProfile;

  @override
  ConsumerState<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends ConsumerState<FollowersScreen> {
  final Set<String> _loadingUserIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(currentUserProvider)?.id;
    final isMyProfile = currentUserId != null && currentUserId == widget.userId;

    final asyncList = widget.isFollowers
        ? ref.watch(followersListProvider(widget.userId))
        : ref.watch(followingListProvider(widget.userId));

    final title = widget.isFollowers ? 'Followers' : 'Following';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: asyncList.when(
          loading: () => ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.space24),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.space12),
            itemBuilder: (context, index) => const LoadingStateCard(height: 72),
          ),
          error: (err, _) => Padding(
            padding: const EdgeInsets.all(AppSpacing.space24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                EmptyStateCard(
                  icon: Icons.error_outline_rounded,
                  title: 'Could not load $title',
                  message: err.toString(),
                ),
                const SizedBox(height: AppSpacing.space16),
                FilledButton(
                  onPressed: () {
                    if (widget.isFollowers) {
                      ref.invalidate(followersListProvider(widget.userId));
                    } else {
                      ref.invalidate(followingListProvider(widget.userId));
                    }
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (profiles) {
            if (profiles.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.space24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    EmptyStateCard(
                      icon: Icons.people_outline_rounded,
                      title: widget.isFollowers
                          ? 'No followers'
                          : 'Not following anyone',
                      message: widget.isFollowers
                          ? (isMyProfile
                                ? 'When other athletes follow you, they will appear here.'
                                : 'This athlete has no followers yet.')
                          : (isMyProfile
                                ? 'Follow athletes to see their activity in your feed.'
                                : 'This athlete is not following anyone yet.'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                if (widget.isFollowers) {
                  ref.invalidate(followersListProvider(widget.userId));
                } else {
                  ref.invalidate(followingListProvider(widget.userId));
                }
              },
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.space24,
                  AppSpacing.space8,
                  AppSpacing.space24,
                  AppSpacing.space32,
                ),
                itemCount: profiles.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.space12),
                itemBuilder: (context, index) {
                  final profile = profiles[index];
                  final isActionLoading = _loadingUserIds.contains(profile.id);

                  return UserListTile(
                    profile: profile,
                    isActionLoading: isActionLoading,
                    // If viewing current user's followers list, provide remove follower action
                    onRemoveFollower: (isMyProfile && widget.isFollowers)
                        ? () => _handleRemoveFollower(currentUserId, profile.id)
                        : null,
                    // If not current user's followers list, provide toggle follow action
                    onToggleFollow: (!isMyProfile || !widget.isFollowers)
                        ? () => _handleToggleFollow(currentUserId, profile)
                        : null,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleRemoveFollower(
    String currentUserId,
    String followerId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Remove Follower?'),
        content: const Text(
          'This user will be removed from your followers and will no longer see your activity in their feed.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _loadingUserIds.add(followerId));
    try {
      final repo = ref.read(socialRepositoryProvider);
      await repo.removeFollower(currentUserId, followerId);
      ref.invalidate(followersListProvider(widget.userId));
      ref.invalidate(mySocialStatsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove follower: $e'),
            backgroundColor: AppColors.surfaceVariant,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingUserIds.remove(followerId));
      }
    }
  }

  Future<void> _handleToggleFollow(
    String? currentUserId,
    SocialProfile target,
  ) async {
    if (currentUserId == null) return;

    setState(() => _loadingUserIds.add(target.id));
    try {
      final repo = ref.read(socialRepositoryProvider);
      if (target.isFollowing) {
        await repo.unfollowUser(currentUserId, target.id);
      } else {
        await repo.followUser(currentUserId, target.id);
      }
      if (widget.isFollowers) {
        ref.invalidate(followersListProvider(widget.userId));
      } else {
        ref.invalidate(followingListProvider(widget.userId));
      }
      ref.invalidate(mySocialStatsProvider);
      ref.read(socialFeedProvider.notifier).refresh();
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _loadingUserIds.remove(target.id));
      }
    }
  }
}
