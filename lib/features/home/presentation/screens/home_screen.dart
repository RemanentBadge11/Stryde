import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_spacing.dart';
import 'package:stryde/core/widgets/app_surface_card.dart';
import 'package:stryde/core/widgets/cycle_countdown.dart';
import 'package:stryde/core/widgets/loading_state_card.dart';
import 'package:stryde/core/widgets/section_header.dart';
import 'package:stryde/features/home/domain/entities/habit.dart';
import 'package:stryde/features/home/presentation/providers/daily_goals_provider.dart';
import 'package:stryde/features/home/presentation/providers/habits_provider.dart';
import 'package:stryde/features/home/presentation/providers/login_streak_provider.dart';
import 'package:stryde/features/home/presentation/providers/weekly_quests_provider.dart';
import 'package:stryde/features/profile/presentation/providers/profile_goals_provider.dart';
import 'package:stryde/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:stryde/features/progression/presentation/providers/user_progression_provider.dart';
import 'package:stryde/features/progression/presentation/widgets/progression_card.dart';
import 'package:stryde/features/workout_history/domain/entities/completed_workout.dart';
import 'package:stryde/features/workout_history/presentation/providers/workout_history_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progression = ref.watch(userProgressionProvider);
    final progressionLoading = ref.watch(userProgressionLoadingProvider);
    final profileGoals = ref.watch(profileGoalsProvider);
    final habitState = ref.watch(habitsProvider);
    final questState = ref.watch(weeklyQuestsProvider);
    final dailyGoalState = ref.watch(dailyGoalsProvider);
    final history = ref.watch(workoutHistoryProvider);
    final historyLoading = ref.watch(workoutHistoryLoadingProvider);
    final loginStreak = ref.watch(loginStreakProvider).currentStreak;
    final userProfile = ref.watch(userProfileProvider);

    final habits = habitDefinitionsFor(profileGoals);
    final completedHabits = habits
        .where((habit) => habitState.isCompleted(habit.id))
        .length;
    final allHabitsComplete =
        habits.isNotEmpty && completedHabits == habits.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space24,
            AppSpacing.space24,
            AppSpacing.space24,
            AppSpacing.space32,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  HomeHeader(
                    streak: loginStreak,
                    username: userProfile.greetingName,
                    avatarUrl: userProfile.avatarUrl,
                  ),
                  const SizedBox(height: AppSpacing.space24),
                  if (progressionLoading)
                    const LoadingStateCard(height: 180)
                  else
                    ProgressionCard(
                      progression: progression,
                      onRankTap: () => context.push('/ranks'),
                      onAssignSkills: () => context.go('/stats'),
                    ),
                  const SizedBox(height: AppSpacing.space32),
                  SectionHeader(
                    title: 'Habits',
                    subtitle: 'Resets every 12 hours',
                    trailing: allHabitsComplete
                        ? CycleCountdown(
                            endsAt: habitState.endsAt,
                            onElapsed: () => ref
                                .read(habitsProvider.notifier)
                                .refreshIfNeeded(),
                          )
                        : Text(
                            '$completedHabits / ${habits.length}',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                  ),
                  const SizedBox(height: AppSpacing.space12),
                  _ChecklistCard(
                    children: <Widget>[
                      for (var i = 0; i < habits.length; i++) ...<Widget>[
                        _ChecklistItem(
                          icon: _habitIcon(habits[i].id),
                          title: habits[i].title,
                          detail: habits[i].detail,
                          xp: habits[i].xp,
                          isCompleted: habitState.isCompleted(habits[i].id),
                          onTap: () {
                            final awarded = ref
                                .read(habitsProvider.notifier)
                                .complete(
                                  habits[i].id,
                                  xp: habits[i].xp,
                                  title: habits[i].title,
                                );
                            if (awarded) {
                              _showXp(context, habits[i].xp, habits[i].title);
                            }
                          },
                        ),
                        if (i != habits.length - 1) const Divider(),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space32),
                  SectionHeader(
                    title: 'Weekly Quests',
                    subtitle: '4 random quests · Resets Monday',
                    trailing: CycleCountdown(
                      endsAt: questState.endsAt,
                      onElapsed: () => ref
                          .read(weeklyQuestsProvider.notifier)
                          .refreshIfNeeded(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space12),
                  _ChecklistCard(
                    children: <Widget>[
                      for (
                        var i = 0;
                        i < questState.quests.length;
                        i++
                      ) ...<Widget>[
                        _ChecklistItem(
                          icon: Icons.bolt_rounded,
                          title: questState.quests[i].title,
                          detail: questState.quests[i].detail,
                          xp: questState.quests[i].xp,
                          isCompleted: questState.quests[i].isCompleted,
                          onTap: () {
                            final quest = questState.quests[i];
                            final awarded = ref
                                .read(weeklyQuestsProvider.notifier)
                                .complete(quest.id);
                            if (awarded) {
                              _showXp(context, quest.xp, quest.title);
                            }
                          },
                        ),
                        if (i != questState.quests.length - 1) const Divider(),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space32),
                  SectionHeader(
                    title: 'Daily Goals',
                    subtitle: 'Built from your recent workouts',
                    trailing: CycleCountdown(
                      endsAt: dailyGoalState.endsAt,
                      onElapsed: () => ref
                          .read(dailyGoalsProvider.notifier)
                          .refreshIfNeeded(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space12),
                  _ChecklistCard(
                    children: <Widget>[
                      for (
                        var i = 0;
                        i < dailyGoalState.goals.length;
                        i++
                      ) ...<Widget>[
                        _ChecklistItem(
                          icon: Icons.track_changes_rounded,
                          title: dailyGoalState.goals[i].title,
                          detail: dailyGoalState.goals[i].detail,
                          xp: dailyGoalState.goals[i].xp,
                          isCompleted: dailyGoalState.goals[i].isCompleted,
                          onTap: () {
                            final goal = dailyGoalState.goals[i];
                            final awarded = ref
                                .read(dailyGoalsProvider.notifier)
                                .complete(goal.id);
                            if (awarded) {
                              _showXp(context, goal.xp, goal.title);
                            }
                          },
                        ),
                        if (i != dailyGoalState.goals.length - 1)
                          const Divider(),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space32),
                  const _NextSessionCard(),
                  const SizedBox(height: AppSpacing.space32),
                  SectionHeader(
                    title: 'Quick Stats',
                    trailing: TextButton(
                      onPressed: () => context.go('/stats'),
                      child: const Text('View All'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space12),
                  if (historyLoading)
                    const LoadingStateCard()
                  else
                    _QuickStats(history: history, streak: loginStreak),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showXp(BuildContext context, int xp, String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('+$xp XP · $label'),
          backgroundColor: AppColors.surfaceVariant,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1500),
        ),
      );
  }
}

IconData _habitIcon(String id) {
  switch (id) {
    case 'steps':
      return Icons.directions_walk_rounded;
    case 'water':
      return Icons.water_drop_outlined;
    case 'protein':
      return Icons.restaurant_outlined;
    case 'gym':
      return Icons.fitness_center_rounded;
    default:
      return Icons.check_circle_outline_rounded;
  }
}

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.streak,
    this.username,
    this.avatarUrl,
    super.key,
  });

  final int streak;
  final String? username;
  final String? avatarUrl;

  static String greeting([DateTime? dateTime, String? username]) {
    if (username == null || username.trim().isEmpty) {
      return 'Good Morning';
    }
    final hour = (dateTime ?? DateTime.now()).hour;
    final String timeGreeting;
    if (hour >= 5 && hour < 12) {
      timeGreeting = 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      timeGreeting = 'Good Afternoon';
    } else {
      timeGreeting = 'Good Evening';
    }
    return '$timeGreeting, ${username.trim()}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    greeting(DateTime.now(), username),
                    maxLines: 1,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
              Text(
                "Keep going. You're on a roll.",
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.space16),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _ProfileButton(
              onTap: () => context.go('/profile'),
              avatarUrl: avatarUrl,
            ),
            const SizedBox(height: AppSpacing.space8),
            _StreakBubble(streak: streak),
          ],
        ),
      ],
    );
  }
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton({required this.onTap, this.avatarUrl});

  final VoidCallback onTap;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl != null && avatarUrl!.trim().isNotEmpty;

    return Semantics(
      button: true,
      label: 'Open profile',
      child: Tooltip(
        message: 'Open profile',
        child: SizedBox(
          key: const ValueKey<String>('home-profile-button'),
          width: 52,
          height: 52,
          child: Material(
            color: AppColors.surface,
            shape: CircleBorder(side: BorderSide(color: AppColors.border)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: hasAvatar
                  ? Image.network(
                      avatarUrl!,
                      fit: BoxFit.cover,
                      width: 52,
                      height: 52,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person_outline_rounded,
                        size: 27,
                        color: AppColors.textPrimary,
                      ),
                    )
                  : Icon(
                      Icons.person_outline_rounded,
                      size: 27,
                      color: AppColors.textPrimary,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StreakBubble extends StatelessWidget {
  const _StreakBubble({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$streak day login streak',
      container: true,
      child: Container(
        key: const ValueKey<String>('login-streak-bubble'),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: AppColors.borderStrong),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TweenAnimationBuilder<double>(
              key: ValueKey<int>(streak),
              tween: Tween<double>(begin: 0.82, end: 1),
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutBack,
              builder: (context, value, child) => Transform.rotate(
                angle: (1 - value) * -0.16,
                child: Transform.scale(scale: value, child: child),
              ),
              child: Icon(
                Icons.local_fire_department_rounded,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$streak',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
        child: Column(children: children),
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({
    required this.icon,
    required this.title,
    required this.detail,
    required this.xp,
    required this.isCompleted,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String detail;
  final int xp;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      checked: isCompleted,
      child: InkWell(
        onTap: isCompleted ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space12),
          child: Row(
            children: <Widget>[
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.primary
                      : AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted
                        ? AppColors.primary
                        : AppColors.borderStrong,
                  ),
                ),
                alignment: Alignment.center,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isCompleted
                      ? Icon(
                          Icons.check_rounded,
                          key: const ValueKey<String>('checked'),
                          size: 21,
                          color: AppColors.onPrimary,
                        )
                      : Icon(
                          icon,
                          key: const ValueKey<String>('pending'),
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: isCompleted
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(detail, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.space8),
              _XpPill(xp: xp, isCompleted: isCompleted),
            ],
          ),
        ),
      ),
    );
  }
}

class _XpPill extends StatelessWidget {
  const _XpPill({required this.xp, required this.isCompleted});

  final int xp;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.primary : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: isCompleted ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Text(
        isCompleted ? 'DONE' : '+$xp XP',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: isCompleted ? AppColors.onPrimary : AppColors.textSecondary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _NextSessionCard extends StatelessWidget {
  const _NextSessionCard();

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -48,
            top: 10,
            child: Transform.rotate(
              angle: -0.2,
              child: Icon(
                Icons.fitness_center_rounded,
                size: 178,
                color: AppColors.primary.withValues(alpha: 0.035),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 21,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.space8),
                    Expanded(
                      child: Text(
                        'Your Next Session',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                    const _UpNextPill(),
                  ],
                ),
                const SizedBox(height: AppSpacing.space24),
                Text(
                  'Push Day',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineLarge?.copyWith(fontSize: 30),
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  'Chest · Shoulders · Triceps',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.space24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: () => context.push('/workout/active/push-day'),
                    icon: const Icon(Icons.play_arrow_rounded, size: 24),
                    label: const Text('Start Workout'),
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

class _UpNextPill extends StatelessWidget {
  const _UpNextPill();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space12,
          vertical: AppSpacing.space8,
        ),
        child: Text(
          'UP NEXT',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  const _QuickStats({required this.history, required this.streak});

  final List<CompletedWorkout> history;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final totalSets = history.fold<int>(
      0,
      (total, workout) => total + workout.totalSets,
    );
    final totalMinutes = history.fold<int>(
      0,
      (total, workout) => total + workout.duration.inMinutes,
    );
    final timeLabel = totalMinutes >= 60
        ? '${(totalMinutes / 60).toStringAsFixed(1)}h'
        : '${totalMinutes}m';
    final stats = <_StatData>[
      _StatData(
        icon: Icons.fitness_center_rounded,
        value: '${history.length}',
        label: 'Workouts',
      ),
      _StatData(
        icon: Icons.checklist_rounded,
        value: '$totalSets',
        label: 'Sets',
      ),
      _StatData(
        icon: Icons.schedule_rounded,
        value: timeLabel,
        label: 'Total Time',
      ),
      _StatData(
        icon: Icons.local_fire_department_rounded,
        value: '${streak}d',
        label: 'Streak',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 376) {
          final cardWidth = (constraints.maxWidth - AppSpacing.space8) / 2;
          return Wrap(
            spacing: AppSpacing.space8,
            runSpacing: AppSpacing.space8,
            children: <Widget>[
              for (final stat in stats)
                SizedBox(
                  width: cardWidth,
                  child: _StatCard(data: stat),
                ),
            ],
          );
        }

        return Row(
          children: List<Widget>.generate(stats.length * 2 - 1, (index) {
            if (index.isOdd) return const SizedBox(width: AppSpacing.space8);
            return Expanded(child: _StatCard(data: stats[index ~/ 2]));
          }),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final _StatData data;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: AppSurfaceCard(
        radius: 16,
        padding: const EdgeInsets.all(AppSpacing.space8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(data.icon, size: 21, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.space8),
            Text(
              data.value,
              maxLines: 1,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontSize: 19),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                data.label,
                maxLines: 1,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatData {
  const _StatData({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;
}
