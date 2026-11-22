import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/widgets/platform_navbar/navbar_export.dart';
import 'package:stryde/features/workout_logging/presentation/providers/active_workout_provider.dart';

class MainShell extends ConsumerWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutState = ref.watch(activeWorkoutProvider);
    final activeSession = workoutState.session;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: PlatformNavbar(
        currentIndex: navigationShell.currentIndex,
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
              SnackBar(
                content: const Text('Workout discarded · 0 XP'),
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
