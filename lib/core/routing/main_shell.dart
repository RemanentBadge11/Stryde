import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/features/workout_logging/presentation/providers/active_workout_provider.dart';

class MainShell extends ConsumerWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const List<_Destination> _destinations = <_Destination>[
    _Destination(
      slotKey: 'home',
      label: 'Home',
      icon: Icons.home_rounded,
      branchIndex: 0,
    ),
    _Destination(
      slotKey: 'stats',
      label: 'Stats',
      icon: Icons.bar_chart_rounded,
      branchIndex: 1,
    ),
    _Destination(
      slotKey: 'train',
      label: 'Train',
      icon: Icons.fitness_center_rounded,
      branchIndex: 2,
    ),
    _Destination(
      slotKey: 'social',
      label: 'Social',
      icon: Icons.groups_rounded,
      branchIndex: 3,
    ),
    _Destination(
      slotKey: 'profile',
      label: 'Profile',
      icon: Icons.person_rounded,
      branchIndex: 4,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutState = ref.watch(activeWorkoutProvider);
    final activeSession = workoutState.session;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: _StrydeBottomBar(
        currentIndex: navigationShell.currentIndex,
        destinations: _destinations,
        onDestinationSelected: _onDestinationSelected,
        onStartWorkout: () => context.push('/workout/active/free-training'),
        isWorkoutOngoing: activeSession != null && workoutState.isMinimized,
        isPaused: workoutState.isPaused,
        elapsed: workoutState.elapsed,
        onResumeWorkout: () {
          if (activeSession == null) return;
          ref.read(activeWorkoutProvider.notifier).resumeWorkout();
          context.push(
            '/workout/active/${activeSession.routine.id}',
            extra: activeSession.routine,
          );
        },
        onCompleteWorkout: () {
          final result = ref
              .read(activeWorkoutProvider.notifier)
              .finishWorkout();
          if (result == null) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  result.xpAwarded == 0
                      ? 'Workout saved · 0 XP · No completed sets'
                      : result.completedDailyGoals == 0
                      ? 'Workout saved · +${result.xpAwarded} XP'
                      : 'Workout saved · +${result.xpAwarded} XP · ${result.completedDailyGoals} Daily Goal${result.completedDailyGoals == 1 ? '' : 's'} complete',
                ),
                backgroundColor: AppColors.surfaceVariant,
                behavior: SnackBarBehavior.floating,
              ),
            );
        },
        onToggleTimer: () =>
            ref.read(activeWorkoutProvider.notifier).toggleTimer(),
        onDiscardWorkout: () {
          final discarded = ref
              .read(activeWorkoutProvider.notifier)
              .discardWorkout();
          if (!discarded) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Workout discarded · 0 XP'),
                backgroundColor: AppColors.surfaceVariant,
                behavior: SnackBarBehavior.floating,
              ),
            );
        },
      ),
    );
  }

  void _onDestinationSelected(int branchIndex) {
    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }
}

class _StrydeBottomBar extends StatelessWidget {
  const _StrydeBottomBar({
    required this.currentIndex,
    required this.destinations,
    required this.onDestinationSelected,
    required this.onStartWorkout,
    required this.isWorkoutOngoing,
    required this.isPaused,
    required this.elapsed,
    required this.onResumeWorkout,
    required this.onCompleteWorkout,
    required this.onToggleTimer,
    required this.onDiscardWorkout,
  });

  static const double _barHeight = 72;
  static const double _protrusion = 42;
  static const double _expandedControlHeight = 72;

  final int currentIndex;
  final List<_Destination> destinations;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onStartWorkout;
  final bool isWorkoutOngoing;
  final bool isPaused;
  final Duration elapsed;
  final VoidCallback onResumeWorkout;
  final VoidCallback onCompleteWorkout;
  final VoidCallback onToggleTimer;
  final VoidCallback onDiscardWorkout;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SizedBox(
      height: _protrusion + _barHeight + bottomInset,
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: _barHeight + bottomInset,
              padding: EdgeInsets.only(bottom: bottomInset),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) => Row(
                  children: <Widget>[
                    for (final destination in destinations)
                      Expanded(
                        child: _NavSlot(
                          destination: destination,
                          isSelected: destination.branchIndex == currentIndex,
                          onTap: () =>
                              onDestinationSelected(destination.branchIndex),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _expandedControlHeight,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _WorkoutControl(
                isOngoing: isWorkoutOngoing,
                isPaused: isPaused,
                elapsed: elapsed,
                onStart: onStartWorkout,
                onResume: onResumeWorkout,
                onComplete: onCompleteWorkout,
                onToggleTimer: onToggleTimer,
                onDiscard: onDiscardWorkout,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavSlot extends StatelessWidget {
  const _NavSlot({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  final _Destination destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textMuted;

    return Semantics(
      key: ValueKey<String>('bottom-nav-${destination.slotKey}'),
      button: true,
      selected: isSelected,
      label: destination.label,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(destination.icon, size: 22, color: color),
              const SizedBox(height: 3),
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: isSelected ? 16 : 0,
                height: 2,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutControl extends StatelessWidget {
  const _WorkoutControl({
    required this.isOngoing,
    required this.isPaused,
    required this.elapsed,
    required this.onStart,
    required this.onResume,
    required this.onComplete,
    required this.onToggleTimer,
    required this.onDiscard,
  });

  final bool isOngoing;
  final bool isPaused;
  final Duration elapsed;
  final VoidCallback onStart;
  final VoidCallback onResume;
  final VoidCallback onComplete;
  final VoidCallback onToggleTimer;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final activeWidth = (MediaQuery.sizeOf(context).width - 48)
        .clamp(264.0, 296.0)
        .toDouble();
    return AnimatedContainer(
      key: const ValueKey<String>('workout-navbar-control'),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeInOutCubic,
      width: isOngoing ? activeWidth : 60,
      height: isOngoing ? 72 : 60,
      decoration: BoxDecoration(
        color: isOngoing ? AppColors.background : AppColors.primary,
        borderRadius: BorderRadius.circular(isOngoing ? 36 : 30),
        border: Border.all(
          color: isOngoing ? AppColors.borderStrong : AppColors.primary,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isOngoing ? 0.12 : 0.24),
            blurRadius: 24,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.65),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: isOngoing
              ? FittedBox(
                  key: const ValueKey<String>('active-workout-pill'),
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: activeWidth - 2,
                    height: 70,
                    child: _ActiveWorkoutPill(
                      elapsed: elapsed,
                      isPaused: isPaused,
                      onResume: onResume,
                      onComplete: onComplete,
                      onToggleTimer: onToggleTimer,
                      onDiscard: onDiscard,
                    ),
                  ),
                )
              : Tooltip(
                  key: const ValueKey<String>('start-workout-button'),
                  message: 'Start empty workout',
                  child: Semantics(
                    button: true,
                    label: 'Start empty workout',
                    onTap: onStart,
                    excludeSemantics: true,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onStart,
                      child: const Center(
                        child: Icon(
                          Icons.play_arrow_rounded,
                          size: 34,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _ActiveWorkoutPill extends StatelessWidget {
  const _ActiveWorkoutPill({
    required this.elapsed,
    required this.isPaused,
    required this.onResume,
    required this.onComplete,
    required this.onToggleTimer,
    required this.onDiscard,
  });

  final Duration elapsed;
  final bool isPaused;
  final VoidCallback onResume;
  final VoidCallback onComplete;
  final VoidCallback onToggleTimer;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const SizedBox(width: 10),
        Expanded(
          child: Semantics(
            button: true,
            label: 'Resume active workout, ${_formatElapsed(elapsed)} elapsed',
            onTap: onResume,
            excludeSemantics: true,
            child: Tooltip(
              message: 'Resume workout',
              child: InkWell(
                onTap: onResume,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Ongoing workout',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatElapsed(elapsed),
                        key: const ValueKey<String>('active-workout-elapsed'),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                          fontFeatures: const <FontFeature>[
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        _PillActionButton(
          key: const ValueKey<String>('workout-pill-complete'),
          tooltip: 'Complete workout',
          backgroundColor: Colors.green,
          foregroundColor: Colors.black,
          icon: Icons.check_rounded,
          onPressed: onComplete,
        ),
        const SizedBox(width: 6),
        _PillActionButton(
          key: const ValueKey<String>('workout-pill-pause'),
          tooltip: isPaused ? 'Resume workout timer' : 'Pause workout timer',
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          icon: isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
          onPressed: onToggleTimer,
        ),
        const SizedBox(width: 6),
        _PillActionButton(
          key: const ValueKey<String>('workout-pill-discard'),
          tooltip: 'Discard workout',
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          icon: Icons.delete_outline_rounded,
          onPressed: onDiscard,
        ),
        const SizedBox(width: 7),
      ],
    );
  }
}

class _PillActionButton extends StatelessWidget {
  const _PillActionButton({
    required this.tooltip,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final String tooltip;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 36,
        height: 36,
        child: IconButton(
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 36, height: 36),
          visualDensity: VisualDensity.compact,
          style: IconButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            shape: const CircleBorder(),
          ),
          icon: Icon(icon, size: 20),
        ),
      ),
    );
  }
}

String _formatElapsed(Duration elapsed) {
  final totalSeconds = elapsed.inSeconds < 0 ? 0 : elapsed.inSeconds;
  final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
  final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}

class _Destination {
  const _Destination({
    required this.slotKey,
    required this.label,
    required this.icon,
    required this.branchIndex,
  });

  final String slotKey;
  final String label;
  final IconData icon;
  final int branchIndex;
}
