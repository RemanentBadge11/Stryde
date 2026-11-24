import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_spacing.dart';
import 'package:stryde/core/widgets/app_surface_card.dart';
import 'package:stryde/core/widgets/empty_state_card.dart';
import 'package:stryde/core/widgets/loading_state_card.dart';
import 'package:stryde/features/social/domain/entities/social_post.dart';
import 'package:stryde/features/social/domain/entities/social_profile.dart';
import 'package:stryde/features/social/presentation/providers/social_providers.dart';
import 'package:stryde/features/social/presentation/widgets/rank_badge.dart';
import 'package:stryde/features/social/presentation/widgets/social_rank_up_card.dart';
import 'package:stryde/features/social/presentation/widgets/social_workout_card.dart';

class OtherUserProfileScreen extends ConsumerWidget {
  const OtherUserProfileScreen({
    required this.userId,
    this.initialProfile,
    super.key,
  });

  final String userId;
  final SocialProfile? initialProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewState = ref.watch(userProfileViewProvider(userId));
    final notifier = ref.read(userProfileViewProvider(userId).notifier);
    final profile = viewState.profile ?? initialProfile;

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
          profile?.handle ?? 'Athlete Profile',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: viewState.isLoading && profile == null
            ? const Padding(
                padding: EdgeInsets.all(AppSpacing.space24),
                child: LoadingStateCard(height: 200),
              )
            : viewState.isOffline && profile == null
            ? Padding(
                padding: const EdgeInsets.all(AppSpacing.space24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    EmptyStateCard(
                      icon: Icons.wifi_off_rounded,
                      title: "You're offline",
                      message:
                          'Social requires an internet connection to view profiles.',
                    ),
                    const SizedBox(height: AppSpacing.space16),
                    FilledButton(
                      onPressed: () => notifier.refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : profile == null
            ? const Padding(
                padding: EdgeInsets.all(AppSpacing.space24),
                child: EmptyStateCard(
                  icon: Icons.person_off_rounded,
                  title: 'Profile unavailable',
                  message: 'This athlete could not be found.',
                ),
              )
            : RefreshIndicator(
                onRefresh: () => notifier.refresh(),
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.space24,
                    AppSpacing.space16,
                    AppSpacing.space24,
                    AppSpacing.space32,
                  ),
                  children: <Widget>[
                    // Profile Header Card
                    _ProfileHeaderCard(
                      profile: profile,
                      isUpdatingFollow: viewState.isUpdatingFollow,
                      onToggleFollow: () => notifier.toggleFollow(),
                    ),
                    const SizedBox(height: AppSpacing.space28),

                    // Published Activity Section Header
                    Text(
                      'Published Activity',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space12),

                    // Posts or Empty State
                    if (viewState.posts.isEmpty)
                      const EmptyStateCard(
                        icon: Icons.fitness_center_rounded,
                        title: 'No activity published',
                        message:
                            'This athlete has not completed any workouts yet.',
                      )
                    else
                      for (final post in viewState.posts) ...<Widget>[
                        if (post.type == SocialPostType.workout)
                          SocialWorkoutCard(post: post)
                        else
                          SocialRankUpCard(post: post),
                        const SizedBox(height: AppSpacing.space16),
                      ],
                  ],
                ),
              ),
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.profile,
    required this.isUpdatingFollow,
    required this.onToggleFollow,
  });

  final SocialProfile profile;
  final bool isUpdatingFollow;
  final VoidCallback onToggleFollow;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = profile.avatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.trim().isNotEmpty;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              // Avatar
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.borderStrong.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                child: hasAvatar
                    ? Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        width: 68,
                        height: 68,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.person_rounded,
                          size: 38,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : Icon(
                        Icons.person_rounded,
                        size: 38,
                        color: AppColors.onPrimary,
                      ),
              ),
              const SizedBox(width: AppSpacing.space16),

              // Name, Handle, Rank
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      profile.effectiveName,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.handle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: <Widget>[
                        Text(
                          'Level ${profile.level}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '·',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 6),
                        RankBadge(
                          rankName: profile.rankTitle,
                          size: 16,
                          showLabel: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space20),
          const Divider(),
          const SizedBox(height: AppSpacing.space12),

          // Clickable Followers & Following Counts
          Row(
            children: <Widget>[
              InkWell(
                onTap: () {
                  context.push(
                    '/social/followers/${profile.id}',
                    extra: profile,
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      children: [
                        TextSpan(
                          text: '${profile.followersCount} ',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        TextSpan(
                          text: 'Followers',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.space16),
              InkWell(
                onTap: () {
                  context.push(
                    '/social/following/${profile.id}',
                    extra: profile,
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      children: [
                        TextSpan(
                          text: '${profile.followingCount} ',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        TextSpan(
                          text: 'Following',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),

              // Follow / Unfollow Button
              if (!profile.isCurrentUser)
                profile.isFollowing
                    ? OutlinedButton(
                        onPressed: isUpdatingFollow ? null : onToggleFollow,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(100, 38),
                          foregroundColor: AppColors.textPrimary,
                          side: BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isUpdatingFollow
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Following'),
                      )
                    : FilledButton(
                        onPressed: isUpdatingFollow ? null : onToggleFollow,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(90, 38),
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isUpdatingFollow
                            ? SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.onPrimary,
                                ),
                              )
                            : const Text(
                                'Follow',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                      ),
            ],
          ),
        ],
      ),
    );
  }
}
