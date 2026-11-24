import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_spacing.dart';
import 'package:stryde/core/widgets/app_surface_card.dart';
import 'package:stryde/features/social/domain/entities/social_profile.dart';
import 'package:stryde/features/social/presentation/widgets/rank_badge.dart';

class UserListTile extends StatelessWidget {
  const UserListTile({
    required this.profile,
    this.onToggleFollow,
    this.onRemoveFollower,
    this.isActionLoading = false,
    super.key,
  });

  final SocialProfile profile;
  final VoidCallback? onToggleFollow;
  final VoidCallback? onRemoveFollower;
  final bool isActionLoading;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = profile.avatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.trim().isNotEmpty;

    return AppSurfaceCard(
      onTap: () {
        context.push('/social/user/${profile.id}', extra: profile);
      },
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space12,
      ),
      child: Row(
        children: <Widget>[
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.borderStrong.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            child: hasAvatar
                ? Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    width: 44,
                    height: 44,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.person_rounded,
                      size: 24,
                      color: AppColors.onPrimary,
                    ),
                  )
                : Icon(
                    Icons.person_rounded,
                    size: 24,
                    color: AppColors.onPrimary,
                  ),
          ),
          const SizedBox(width: AppSpacing.space12),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        profile.effectiveName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    RankBadge(rankName: profile.rankTitle, size: 16),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${profile.handle} · Lv. ${profile.level}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Action Button
          if (!profile.isCurrentUser) ...<Widget>[
            const SizedBox(width: AppSpacing.space8),
            if (onRemoveFollower != null)
              OutlinedButton(
                onPressed: isActionLoading ? null : onRemoveFollower,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(72, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  foregroundColor: AppColors.error,
                  side: BorderSide(
                    color: AppColors.error.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isActionLoading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Remove', style: TextStyle(fontSize: 12)),
              )
            else if (onToggleFollow != null)
              profile.isFollowing
                  ? OutlinedButton(
                      onPressed: isActionLoading ? null : onToggleFollow,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(82, 34),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        foregroundColor: AppColors.textPrimary,
                        side: BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isActionLoading
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Following',
                              style: TextStyle(fontSize: 12),
                            ),
                    )
                  : FilledButton(
                      onPressed: isActionLoading ? null : onToggleFollow,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(72, 34),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isActionLoading
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
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
          ],
        ],
      ),
    );
  }
}
