import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/routing/app_router.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/features/progression/presentation/providers/global_notification_provider.dart';

class GlobalNotificationOverlay extends StatelessWidget {
  const GlobalNotificationOverlay({
    required this.child,
    this.navigatorKey,
    super.key,
  });

  final Widget child;
  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 10,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: GlobalNotificationBanner(navigatorKey: navigatorKey),
          ),
        ),
      ],
    );
  }
}

class GlobalNotificationBanner extends ConsumerWidget {
  const GlobalNotificationBanner({this.navigatorKey, super.key});

  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(globalNotificationProvider);
    final notification = notificationState.currentNotification;
    final isVisible = notificationState.isVisible && notification != null;

    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return IgnorePointer(
      ignoring: !isVisible,
      child: AnimatedSlide(
        duration: disableAnimations
            ? Duration.zero
            : const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        offset: isVisible ? Offset.zero : const Offset(0, -0.8),
        child: AnimatedOpacity(
          duration: disableAnimations
              ? Duration.zero
              : const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          opacity: isVisible ? 1.0 : 0.0,
          child: notification == null
              ? const SizedBox.shrink()
              : Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _handleTap(context, ref, notification),
                        borderRadius: BorderRadius.circular(16),
                        child: Ink(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.isDark
                                ? const Color(0xFF1E1E22)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.isDark
                                  ? const Color(0xFF333338)
                                  : const Color(0xFFE2E2E8),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: AppColors.isDark ? 0.35 : 0.12,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: _buildContent(context, notification),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ProgressionNotification notification,
  ) {
    return switch (notification) {
      LevelUpNotification() => _buildLevelUp(context, notification),
      RankUpNotification() => _buildRankUp(context, notification),
      MedalAwardedNotification() => _buildMedalAwarded(context, notification),
    };
  }

  Widget _buildLevelUp(BuildContext context, LevelUpNotification notification) {
    return Row(
      children: [
        Text(
          'Level Up!',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          '${notification.oldLevel} → ${notification.newLevel}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
      ],
    );
  }

  Widget _buildRankUp(BuildContext context, RankUpNotification notification) {
    final rank = notification.rank;
    final startsWithVowel = RegExp(r'^[AEIOU]').hasMatch(rank.name);
    final subtitle = 'You are now ${startsWithVowel ? 'an' : 'a'} ${rank.name}';

    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RANKUP!',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        SizedBox(
          width: 44,
          height: 44,
          child: SvgPicture.asset(rank.assetPath, fit: BoxFit.contain),
        ),
        const SizedBox(width: 6),
        Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
      ],
    );
  }

  Widget _buildMedalAwarded(
    BuildContext context,
    MedalAwardedNotification notification,
  ) {
    final medal = notification.medal;
    return Row(
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: SvgPicture.asset(medal.assetPath, fit: BoxFit.contain),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Medal Awarded',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '• ${medal.rarity.label}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: medal.rarity.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                medal.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
      ],
    );
  }

  void _handleTap(
    BuildContext context,
    WidgetRef ref,
    ProgressionNotification notification,
  ) {
    ref.read(globalNotificationProvider.notifier).dismissCurrent();

    final targetPath = switch (notification) {
      LevelUpNotification() => '/ranks',
      RankUpNotification() => '/ranks',
      MedalAwardedNotification() => '/medals',
    };

    final effectiveKey = navigatorKey ?? rootNavigatorKey;
    final navContext = effectiveKey.currentContext;
    if (navContext != null) {
      try {
        GoRouter.of(navContext).push(targetPath);
        return;
      } catch (_) {
        try {
          navContext.push(targetPath);
          return;
        } catch (_) {}
      }
    }

    try {
      GoRouter.of(context).push(targetPath);
      return;
    } catch (_) {}
    try {
      context.push(targetPath);
      return;
    } catch (_) {}
  }
}
