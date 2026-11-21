import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_spacing.dart';
import 'package:stryde/core/widgets/app_surface_card.dart';
import 'package:stryde/features/progression/domain/entities/rank.dart';
import 'package:stryde/features/progression/presentation/providers/user_progression_provider.dart';

class RankProgressionScreen extends ConsumerWidget {
  const RankProgressionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progression = ref.watch(userProgressionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text('Rank Progression'),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space24,
            AppSpacing.space16,
            AppSpacing.space24,
            AppSpacing.space32,
          ),
          children: <Widget>[
            Text('The climb', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: AppSpacing.space8),
            Text(
              'Every level costs 500 XP. Rank breakthroughs award 3 bonus skill points.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.space24),
            _CurrentRankCard(
              level: progression.currentLevel,
              rank: progression.rank,
              skillPoints: progression.skillPoints,
            ),
            const SizedBox(height: AppSpacing.space32),
            Text('All Ranks', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.space12),
            for (var i = 0; i < Ranks.all.length; i++) ...<Widget>[
              _RankCard(
                rank: Ranks.all[i],
                currentLevel: progression.currentLevel,
              ),
              if (i != Ranks.all.length - 1)
                const SizedBox(height: AppSpacing.space12),
            ],
            const SizedBox(height: AppSpacing.space24),
            const _RuleCard(
              icon: Icons.bolt_rounded,
              title: '+1 skill point per level',
              detail:
                  'Spend points on Chest, Back, Legs, Shoulders, Biceps, or Triceps.',
            ),
            const SizedBox(height: AppSpacing.space12),
            const _RuleCard(
              icon: Icons.workspace_premium_outlined,
              title: '+3 bonus points at rank breakthroughs',
              detail: 'Crossing into Level 6, 11, or 16 triggers the bonus.',
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentRankCard extends StatelessWidget {
  const _CurrentRankCard({
    required this.level,
    required this.rank,
    required this.skillPoints,
  });

  final int level;
  final Rank rank;
  final int skillPoints;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.space24),
      child: Row(
        children: <Widget>[
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: Text(
              '$level',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: AppColors.onPrimary),
            ),
          ),
          const SizedBox(width: AppSpacing.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'CURRENT RANK',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(letterSpacing: 0.8),
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(rank.name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  '${rank.levelRange} · '
                  '${skillPoints == 1 ? '1 skill point' : '$skillPoints skill points'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RankCard extends StatelessWidget {
  const _RankCard({required this.rank, required this.currentLevel});

  final Rank rank;
  final int currentLevel;

  @override
  Widget build(BuildContext context) {
    final isCurrent = rank.containsLevel(currentLevel);
    final isUnlocked = currentLevel >= rank.minLevel;
    final status = isCurrent
        ? 'CURRENT'
        : isUnlocked
        ? 'CLEARED'
        : 'LOCKED';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isCurrent ? AppColors.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: AppSurfaceCard(
        radius: 20,
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Row(
          children: <Widget>[
            Icon(
              isCurrent
                  ? Icons.military_tech_rounded
                  : isUnlocked
                  ? Icons.check_circle_outline_rounded
                  : Icons.lock_outline_rounded,
              color: isCurrent
                  ? AppColors.primary
                  : isUnlocked
                  ? AppColors.textSecondary
                  : AppColors.textMuted,
              size: 26,
            ),
            const SizedBox(width: AppSpacing.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          rank.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      _StatusPill(label: status, isCurrent: isCurrent),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    rank.levelRange,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    rank.tagline,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.isCurrent});

  final String label;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.primary : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: isCurrent ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space8,
          vertical: 4,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isCurrent ? AppColors.onPrimary : AppColors.textSecondary,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      radius: 16,
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 22, color: AppColors.textPrimary),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(detail, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
