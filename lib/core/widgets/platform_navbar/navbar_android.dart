import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';

class DestinationItem {
  const DestinationItem({
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

class PlatformNavbar extends StatelessWidget {
  const PlatformNavbar({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.onStartWorkout,
    required this.isWorkoutOngoing,
    required this.isPaused,
    required this.elapsed,
    required this.onResumeWorkout,
    required this.onCompleteWorkout,
    required this.onToggleTimer,
    required this.onDiscardWorkout,
    super.key,
  });

  static const List<DestinationItem> destinations = <DestinationItem>[
    DestinationItem(
      slotKey: 'home',
      label: 'Home',
      icon: Icons.home_rounded,
      branchIndex: 0,
    ),
    DestinationItem(
      slotKey: 'stats',
      label: 'Stats',
      icon: Icons.bar_chart_rounded,
      branchIndex: 1,
    ),
    DestinationItem(
      slotKey: 'train',
      label: 'Train',
      icon: Icons.fitness_center_rounded,
      branchIndex: 2,
    ),
    DestinationItem(
      slotKey: 'social',
      label: 'Social',
      icon: Icons.groups_rounded,
      branchIndex: 3,
    ),
    DestinationItem(
      slotKey: 'profile',
      label: 'Profile',
      icon: Icons.person_rounded,
      branchIndex: 4,
    ),
  ];

  static const double _barHeight = 72;
  static const double _protrusion = 42;
  static const double _expandedControlHeight = 72;

  final int currentIndex;
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
              decoration: BoxDecoration(
                color: AppColors.isDark
                    ? AppColors.background
                    : const Color(0xFFF4F4F6),
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) => Row(
                  children: <Widget>[
                    for (final destination in destinations)
                      Expanded(
                        child: NavSlot(
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
              child: WorkoutControl(
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

class NavSlot extends StatelessWidget {
  const NavSlot({
    required this.destination,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final DestinationItem destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark;
    final Color iconColor;
    final Color textColor;
    final Color indicatorColor;

    if (isDark) {
      iconColor = isSelected ? AppColors.primary : AppColors.textMuted;
      textColor = iconColor;
      indicatorColor = AppColors.primary;
    } else {
      // In light mode: selected icons must remain visible, all navbar icons must be black rather than grey or white
      iconColor = Colors.black;
      final isWhiteAccent = AppColors.primary.computeLuminance() > 0.85;
      indicatorColor = isWhiteAccent ? Colors.black : AppColors.primary;
      textColor = isSelected ? Colors.black : const Color(0xFF222222);
    }

    final iconShadows = <Shadow>[
      Shadow(
        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
        offset: const Offset(0, 1),
        blurRadius: 2,
      ),
    ];

    return Semantics(
      key: ValueKey<String>('bottom-nav-${destination.slotKey}'),
      button: true,
      selected: isSelected,
      label: destination.label,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        splashColor: (isDark ? AppColors.primary : Colors.black).withValues(
          alpha: 0.08,
        ),
        highlightColor: (isDark ? AppColors.primary : Colors.black).withValues(
          alpha: 0.04,
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                destination.icon,
                size: 20,
                color: iconColor,
                shadows: iconShadows,
              ),
              const SizedBox(height: 2),
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.2,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.25 : 0.06,
                      ),
                      offset: const Offset(0, 0.5),
                      blurRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: isSelected ? 16 : 0,
                height: 2,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: indicatorColor.withValues(alpha: 0.35),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkoutControl extends StatelessWidget {
  const WorkoutControl({
    required this.isOngoing,
    required this.isPaused,
    required this.elapsed,
    required this.onStart,
    required this.onResume,
    required this.onComplete,
    required this.onToggleTimer,
    required this.onDiscard,
    super.key,
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
                    child: ActiveWorkoutPill(
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
                      child: Center(
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

class ActiveWorkoutPill extends StatelessWidget {
  const ActiveWorkoutPill({
    required this.elapsed,
    required this.isPaused,
    required this.onResume,
    required this.onComplete,
    required this.onToggleTimer,
    required this.onDiscard,
    super.key,
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
            label:
                'Resume active workout, ${formatNavbarElapsed(elapsed)} elapsed',
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
                        formatNavbarElapsed(elapsed),
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
        PillActionButton(
          key: const ValueKey<String>('workout-pill-complete'),
          tooltip: 'Complete workout',
          backgroundColor: Colors.green,
          foregroundColor: Colors.black,
          icon: Icons.check_rounded,
          onPressed: onComplete,
        ),
        const SizedBox(width: 6),
        PillActionButton(
          key: const ValueKey<String>('workout-pill-pause'),
          tooltip: isPaused ? 'Resume workout timer' : 'Pause workout timer',
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          icon: isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
          onPressed: onToggleTimer,
        ),
        const SizedBox(width: 6),
        PillActionButton(
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

class PillActionButton extends StatelessWidget {
  const PillActionButton({
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

String formatNavbarElapsed(Duration elapsed) {
  final totalSeconds = elapsed.inSeconds < 0 ? 0 : elapsed.inSeconds;
  final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
  final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}
