import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_spacing.dart';
import 'package:stryde/core/widgets/app_surface_card.dart';
import 'package:stryde/features/home/presentation/providers/login_streak_provider.dart';
import 'package:stryde/features/medals/domain/entities/medal.dart';
import 'package:stryde/features/medals/presentation/providers/medals_provider.dart';
import 'package:stryde/features/progression/presentation/providers/user_progression_provider.dart';
import 'package:stryde/features/workout_history/presentation/providers/workout_history_provider.dart';

class MedalsScreen extends ConsumerStatefulWidget {
  const MedalsScreen({super.key});

  @override
  ConsumerState<MedalsScreen> createState() => _MedalsScreenState();
}

class _MedalsScreenState extends ConsumerState<MedalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _evaluateMedals();
    });
  }

  void _evaluateMedals() {
    final progression = ref.read(userProgressionProvider);
    final streak = ref.read(loginStreakProvider).currentStreak;
    final history = ref.read(workoutHistoryProvider);
    final totalPrs = calculateTotalPrsFromHistory(history);

    ref.read(medalsProvider.notifier).evaluateAndUnlock(
          level: progression.currentLevel,
          streak: streak,
          totalPrs: totalPrs,
        );
  }

  @override
  Widget build(BuildContext context) {
    final medalState = ref.watch(medalsProvider);

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
          'Medals',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space24,
            vertical: AppSpacing.space16,
          ),
          children: <Widget>[
            AppSurfaceCard(
              padding: const EdgeInsets.all(AppSpacing.space20),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(
                      Icons.military_tech_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${medalState.unlockedCount} of ${kStaticMedals.length} Unlocked',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Earn medals by hitting milestones, streaks, and personal records.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space24),
            Text(
              'ACHIEVEMENTS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.0,
                  ),
            ),
            const SizedBox(height: AppSpacing.space12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: kStaticMedals.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final medal = kStaticMedals[index];
                final isUnlocked = medalState.isUnlocked(medal.id);
                return _MedalCard(
                  key: ValueKey<String>('medal-card-${medal.id}'),
                  medal: medal,
                  isUnlocked: isUnlocked,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MedalCard extends StatelessWidget {
  const _MedalCard({
    required this.medal,
    required this.isUnlocked,
    super.key,
  });

  final Medal medal;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isUnlocked ? AppColors.surfaceVariant : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isUnlocked
              ? (AppColors.isDark
                  ? const Color(0xFFE0E0E0)
                  : const Color(0xFF4A4A4A))
              : AppColors.border,
          width: isUnlocked ? 1.5 : 1.0,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.08),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? (AppColors.isDark
                      ? const Color(0xFF2C2C2C)
                      : const Color(0xFFDDDDDD))
                  : AppColors.surfaceElevated,
              shape: BoxShape.circle,
              border: Border.all(
                color: isUnlocked
                    ? const Color(0xFFCCCCCC)
                    : AppColors.borderStrong,
              ),
            ),
            child: Icon(
              isUnlocked ? medal.icon : Icons.lock_outline_rounded,
              size: 26,
              color: isUnlocked
                  ? (AppColors.isDark ? Colors.white : Colors.black)
                  : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.space12),
          Text(
            medal.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isUnlocked
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              medal.description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: isUnlocked
                        ? AppColors.textSecondary
                        : AppColors.textMuted,
                  ),
            ),
          ),
          const SizedBox(height: AppSpacing.space8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? (AppColors.isDark
                      ? const Color(0xFF333333)
                      : const Color(0xFFEEEEEE))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: isUnlocked
                    ? const Color(0xFF888888)
                    : AppColors.borderStrong,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  isUnlocked ? Icons.check_circle_rounded : Icons.lock_rounded,
                  size: 11,
                  color: isUnlocked
                      ? (AppColors.isDark ? Colors.white : Colors.black)
                      : AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  isUnlocked ? 'UNLOCKED' : 'LOCKED',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: isUnlocked
                        ? (AppColors.isDark ? Colors.white : Colors.black)
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
