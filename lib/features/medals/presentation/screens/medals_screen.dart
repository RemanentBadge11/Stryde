import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_spacing.dart';
import 'package:stryde/core/widgets/app_surface_card.dart';
import 'package:stryde/features/home/presentation/providers/login_streak_provider.dart';
import 'package:stryde/features/medals/domain/entities/medal.dart';
import 'package:stryde/features/medals/presentation/providers/medals_provider.dart';
import 'package:stryde/features/progression/presentation/providers/skill_allocations_provider.dart';
import 'package:stryde/features/progression/presentation/providers/user_progression_provider.dart';
import 'package:stryde/features/routines/domain/entities/mastery_routine_definition.dart';
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
    final allocations = ref.read(skillAllocationsProvider);

    int ind = 0;
    int comb = 0;
    int tot = 0;
    for (final def in MasteryRoutineDefinitions.all) {
      if (def.isUnlocked(allocations)) {
        tot++;
        if (def.requiredPoints.length == 1) {
          ind++;
        } else {
          comb++;
        }
      }
    }

    ref
        .read(medalsProvider.notifier)
        .evaluateAndUnlock(
          level: progression.currentLevel,
          streak: streak,
          totalPrs: totalPrs,
          totalWorkouts: history.length,
          individualMasteryCount: ind,
          combinedMasteryCount: comb,
          totalMasteryCount: tot,
          isReconciling: true,
        );
  }

  List<Medal> _medalsForCategory(MedalCategory category) {
    return kStaticMedals
        .where((m) => m.category == category)
        .toList(growable: false);
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
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space24,
            vertical: AppSpacing.space16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Earn medals by hitting milestones, streaks, and personal records.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              for (final category in MedalCategory.values) ...<Widget>[
                const SizedBox(height: AppSpacing.space24),
                Text(
                  category.displayName,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.space12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _medalsForCategory(category).length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (context, index) {
                    final medal = _medalsForCategory(category)[index];
                    final isUnlocked = medalState.isUnlocked(medal.id);
                    return _MedalCard(
                      key: ValueKey<String>('medal-card-${medal.id}'),
                      medal: medal,
                      isUnlocked: isUnlocked,
                    );
                  },
                ),
              ],
              const SizedBox(height: AppSpacing.space32),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedalCard extends StatelessWidget {
  const _MedalCard({required this.medal, required this.isUnlocked, super.key});

  final Medal medal;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
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
                  color: (AppColors.isDark ? Colors.white : Colors.black)
                      .withValues(alpha: AppColors.isDark ? 0.08 : 0.04),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space12,
        vertical: AppSpacing.space12,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // 1. Full medal SVG artwork (+ semi-transparent circular lock overlay on top if locked)
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Opacity(
                  opacity: isUnlocked ? 1.0 : 0.40,
                  child: SvgPicture.asset(
                    medal.assetPath,
                    width: 52,
                    height: 52,
                    fit: BoxFit.contain,
                  ),
                ),
                if (!isUnlocked)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.50),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1.0,
                      ),
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space8),

          // 2. Medal Name
          Text(
            medal.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: isUnlocked
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),

          // 3. RARITY (colored Flutter text)
          Text(
            medal.rarity.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: medal.rarity.color,
            ),
          ),
          const SizedBox(height: 3),

          // 4. Description
          Expanded(
            child: Text(
              medal.description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10.5,
                height: 1.25,
                color: isUnlocked
                    ? AppColors.textSecondary
                    : AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space8),

          // 5. LOCKED / UNLOCKED badge
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
