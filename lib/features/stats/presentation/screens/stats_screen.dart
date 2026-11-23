import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_spacing.dart';
import 'package:stryde/core/theme/app_typography.dart';
import 'package:stryde/core/widgets/app_surface_card.dart';
import 'package:stryde/core/widgets/empty_state_card.dart';
import 'package:stryde/core/widgets/loading_state_card.dart';
import 'package:stryde/core/widgets/section_header.dart';
import 'package:stryde/features/progression/domain/entities/xp_transaction.dart';
import 'package:stryde/features/progression/presentation/providers/skill_allocations_provider.dart';
import 'package:stryde/features/progression/presentation/providers/user_progression_provider.dart';
import 'package:stryde/features/progression/presentation/providers/xp_transactions_provider.dart';
import 'package:stryde/features/progression/presentation/widgets/progression_card.dart';
import 'package:stryde/features/workout_history/presentation/providers/workout_history_provider.dart';
import 'package:stryde/features/workout_history/presentation/widgets/workout_history_card.dart';
import 'package:stryde/features/workout_history/presentation/workout_formatters.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progression = ref.watch(userProgressionProvider);
    final progressionLoading = ref.watch(userProgressionLoadingProvider);
    final transactions = ref.watch(xpTransactionsProvider);
    final transactionsLoading = ref.watch(xpTransactionsLoadingProvider);
    final allocations = ref.watch(skillAllocationsProvider);
    final allocationsLoading = ref.watch(skillAllocationsLoadingProvider);
    final history = ref.watch(workoutHistoryProvider);
    final historyLoading = ref.watch(workoutHistoryLoadingProvider);
    final recentTransactions = transactions.take(4).toList(growable: false);
    final recentHistory = history.take(3).toList(growable: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space24,
            AppSpacing.space24,
            AppSpacing.space24,
            AppSpacing.space32,
          ),
          children: <Widget>[
            Text('Stats', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: AppSpacing.space8),
            Text(
              'Your progression, ledger, and skill build.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.space24),
            if (progressionLoading)
              const LoadingStateCard(height: 180)
            else
              ProgressionCard(
                progression: progression,
                onRankTap: () => context.push('/ranks'),
              ),
            const SizedBox(height: AppSpacing.space32),
            SectionHeader(
              title: 'XP Breakdown',
              subtitle: 'Every award across your account',
              trailing: TextButton(
                key: const ValueKey<String>('view-all-xp'),
                onPressed: () => context.push('/stats/xp-history'),
                child: const Text('View All'),
              ),
            ),
            const SizedBox(height: AppSpacing.space12),
            if (transactionsLoading)
              const LoadingStateCard()
            else
              _TransactionLedger(transactions: recentTransactions),
            const SizedBox(height: AppSpacing.space32),
            SectionHeader(
              title: 'Assign Skill Points',
              subtitle: 'Invest in the muscles you train',
              trailing: _AvailablePill(points: progression.skillPoints),
            ),
            const SizedBox(height: AppSpacing.space12),
            if (allocationsLoading || progressionLoading)
              const LoadingStateCard(height: 280)
            else
              _SkillAllocationCard(
                allocations: allocations,
                available: progression.skillPoints,
                onSpend: (muscle) {
                  final spent = ref
                      .read(skillAllocationsProvider.notifier)
                      .spend(muscle);
                  if (!spent) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Earn more skill points by leveling up.',
                          ),
                          backgroundColor: AppColors.surfaceVariant,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                  }
                },
              ),
            const SizedBox(height: AppSpacing.space32),
            SectionHeader(
              title: 'Recent Workouts',
              subtitle: 'Synced from your training history',
              trailing: TextButton(
                key: const ValueKey<String>('view-all-workouts'),
                onPressed: () => context.push('/stats/workout-history'),
                child: const Text('View All'),
              ),
            ),
            const SizedBox(height: AppSpacing.space12),
            if (historyLoading)
              const LoadingStateCard()
            else if (history.isEmpty)
              const EmptyStateCard(
                icon: Icons.history_rounded,
                title: 'No sessions yet',
                message: 'Finish a workout and it will appear here.',
              )
            else
              for (var i = 0; i < recentHistory.length; i++) ...<Widget>[
                WorkoutHistoryCard(
                  workout: recentHistory[i],
                  onTap: () =>
                      context.push('/stats/history/${recentHistory[i].id}'),
                ),
                if (i != recentHistory.length - 1)
                  const SizedBox(height: AppSpacing.space12),
              ],
          ],
        ),
      ),
    );
  }
}

class XpHistoryScreen extends ConsumerWidget {
  const XpHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(xpTransactionsProvider);
    final isLoading = ref.watch(xpTransactionsLoadingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text('XP History'),
      ),
      body: SafeArea(
        top: false,
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(AppSpacing.space24),
                child: LoadingStateCard(),
              )
            : transactions.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(AppSpacing.space24),
                child: EmptyStateCard(
                  icon: Icons.receipt_long_rounded,
                  title: 'No XP earned yet',
                  message:
                      'Complete a habit, quest, daily goal, or workout to start the ledger.',
                ),
              )
            : ListView.separated(
                key: const ValueKey<String>('complete-xp-history'),
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.space24),
                itemCount: transactions.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.space12),
                itemBuilder: (context, index) => AppSurfaceCard(
                  key: ValueKey<String>('xp-history-${transactions[index].id}'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space16,
                  ),
                  child: _TransactionRow(transaction: transactions[index]),
                ),
              ),
      ),
    );
  }
}

class WorkoutHistoryScreen extends ConsumerWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(workoutHistoryProvider);
    final isLoading = ref.watch(workoutHistoryLoadingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text('Workout History'),
      ),
      body: SafeArea(
        top: false,
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(AppSpacing.space24),
                child: LoadingStateCard(),
              )
            : history.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(AppSpacing.space24),
                child: EmptyStateCard(
                  icon: Icons.history_rounded,
                  title: 'No sessions yet',
                  message: 'Finish a workout and it will appear here.',
                ),
              )
            : ListView.separated(
                key: const ValueKey<String>('complete-workout-history'),
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.space24),
                itemCount: history.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.space12),
                itemBuilder: (context, index) => WorkoutHistoryCard(
                  key: ValueKey<String>('workout-history-${history[index].id}'),
                  workout: history[index],
                  onTap: () => context.push(
                    '/stats/workout-history/${history[index].id}',
                  ),
                ),
              ),
      ),
    );
  }
}

class _TransactionLedger extends StatelessWidget {
  const _TransactionLedger({required this.transactions});

  final List<XpTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const EmptyStateCard(
        icon: Icons.receipt_long_rounded,
        title: 'No XP earned yet',
        message:
            'Complete a habit, quest, daily goal, or workout to start the ledger.',
      );
    }

    return AppSurfaceCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
        child: Column(
          children: <Widget>[
            for (var i = 0; i < transactions.length; i++) ...<Widget>[
              _TransactionRow(transaction: transactions[i]),
              if (i != transactions.length - 1) const Divider(),
            ],
          ],
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.transaction});

  final XpTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space12),
      child: Row(
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(
              _sourceIcon(transaction.source),
              size: 17,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  transaction.description,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  formatLedgerTimestamp(transaction.occurredAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.space8),
          Text(
            '+${transaction.amount} XP',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

IconData _sourceIcon(XpSource source) {
  switch (source) {
    case XpSource.habit:
      return Icons.repeat_rounded;
    case XpSource.quest:
      return Icons.bolt_rounded;
    case XpSource.goal:
      return Icons.track_changes_rounded;
    case XpSource.workout:
      return Icons.fitness_center_rounded;
  }
}

class _AvailablePill extends StatelessWidget {
  const _AvailablePill({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: points > 0 ? AppColors.primary : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: points > 0 ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space12,
          vertical: AppSpacing.space8,
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style:
              (Theme.of(context).textTheme.labelMedium ??
                      const TextStyle(fontSize: 12))
                  .copyWith(
                    color: points > 0
                        ? AppColors.onPrimary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
          child: Text('$points available'),
        ),
      ),
    );
  }
}

class _SkillAllocationCard extends StatelessWidget {
  const _SkillAllocationCard({
    required this.allocations,
    required this.available,
    required this.onSpend,
  });

  final Map<String, int> allocations;
  final int available;
  final ValueChanged<String> onSpend;

  @override
  Widget build(BuildContext context) {
    final totalSpent = allocations.values.fold<int>(
      0,
      (sum, value) => sum + value,
    );

    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.auto_awesome_outlined,
                size: 20,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: AppSpacing.space8),
              Expanded(
                child: Text(
                  'MUSCLE INVESTMENTS',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(letterSpacing: 0.7),
                ),
              ),
              Text(
                '$totalSpent spent',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space12),
          const Divider(),
          for (var i = 0; i < skillMuscleGroups.length; i++) ...<Widget>[
            _MuscleRow(
              muscle: skillMuscleGroups[i],
              points: allocations[skillMuscleGroups[i]] ?? 0,
              canSpend: available > 0,
              onSpend: () => onSpend(skillMuscleGroups[i]),
            ),
            if (i != skillMuscleGroups.length - 1) const Divider(),
          ],
        ],
      ),
    );
  }
}

class _MuscleRow extends StatelessWidget {
  const _MuscleRow({
    required this.muscle,
    required this.points,
    required this.canSpend,
    required this.onSpend,
  });

  final String muscle;
  final int points;
  final bool canSpend;
  final VoidCallback onSpend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
      child: Row(
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: Text(
              muscle.substring(0, 1),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Text(muscle, style: Theme.of(context).textTheme.titleSmall),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              ),
              child: child,
            ),
            child: Text(
              '$points',
              key: ValueKey<int>(points),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: points > 0 ? AppColors.textPrimary : AppColors.textMuted,
                fontFeatures: AppTypography.tabularFontFeatures,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space12),
          IconButton(
            onPressed: canSpend ? onSpend : null,
            tooltip: 'Add point to $muscle',
            style: IconButton.styleFrom(
              minimumSize: const Size(38, 38),
              maximumSize: const Size(38, 38),
              backgroundColor: canSpend
                  ? AppColors.primary
                  : AppColors.surfaceVariant,
              foregroundColor: canSpend
                  ? AppColors.onPrimary
                  : AppColors.textMuted,
              disabledBackgroundColor: AppColors.surfaceVariant,
              disabledForegroundColor: AppColors.textMuted,
              side: BorderSide(
                color: canSpend ? AppColors.primary : AppColors.border,
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}
