import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_spacing.dart';
import 'package:stryde/features/social/domain/entities/social_profile.dart';
import 'package:stryde/features/social/presentation/widgets/rank_badge.dart';

class SocialAuthorHeader extends StatelessWidget {
  const SocialAuthorHeader({
    required this.author,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final SocialProfile author;
  final Widget? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = author.avatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.trim().isNotEmpty;

    return InkWell(
      onTap: () {
        if (author.id.isNotEmpty) {
          context.push('/social/user/${author.id}', extra: author);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Avatar
            Container(
              width: 42,
              height: 42,
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
                      width: 42,
                      height: 42,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person_rounded,
                        size: 22,
                        color: AppColors.onPrimary,
                      ),
                    )
                  : Icon(
                      Icons.person_rounded,
                      size: 22,
                      color: AppColors.onPrimary,
                    ),
            ),
            const SizedBox(width: AppSpacing.space12),

            // [Username] [Level] [Rank SVG]
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          author.username != null &&
                                  author.username!.trim().isNotEmpty
                              ? '@${author.username!.trim()}'
                              : author.effectiveName,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          'Lv. ${author.level}',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      RankBadge(rankName: author.rankTitle, size: 16),
                    ],
                  ),
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: 2),
                    subtitle!,
                  ],
                ],
              ),
            ),

            ?trailing,
          ],
        ),
      ),
    );
  }
}
