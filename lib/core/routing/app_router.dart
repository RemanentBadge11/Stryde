import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/routing/main_shell.dart';
import 'package:stryde/core/supabase/supabase_client.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/features/auth/presentation/screens/auth_screen.dart';
import 'package:stryde/features/exercises/presentation/screens/exercise_library_screen.dart';
import 'package:stryde/features/home/presentation/screens/home_screen.dart';
import 'package:stryde/features/medals/presentation/screens/medals_screen.dart';
import 'package:stryde/features/profile/presentation/screens/profile_screen.dart';
import 'package:stryde/features/progression/presentation/screens/rank_progression_screen.dart';
import 'package:stryde/features/routines/data/mock_workout_data.dart';
import 'package:stryde/features/routines/domain/entities/mastery_routine_definition.dart';
import 'package:stryde/features/routines/domain/entities/workout_routine.dart';
import 'package:stryde/features/routines/presentation/screens/custom_routine_builder_screen.dart';
import 'package:stryde/features/routines/presentation/screens/routine_detail_screen.dart';
import 'package:stryde/features/routines/presentation/screens/train_screen.dart';
import 'package:stryde/features/settings/presentation/screens/customize_profile_screen.dart';
import 'package:stryde/features/settings/presentation/screens/settings_screen.dart';
import 'package:stryde/features/settings/presentation/screens/theme_screen.dart';
import 'package:stryde/features/stats/presentation/screens/stats_screen.dart';
import 'package:stryde/features/workout_history/presentation/screens/workout_history_detail_screen.dart';
import 'package:stryde/features/workout_logging/presentation/screens/active_workout_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Notifies the router when the auth session changes so the redirect guard
/// is re-evaluated (sign in, sign out, session refresh, ...).
final ValueNotifier<bool> appRouterRefreshListenable = ValueNotifier<bool>(
  false,
);

GoRouter createAppRouter({GlobalKey<NavigatorState>? navigatorKey}) {
  return GoRouter(
    navigatorKey: navigatorKey ?? rootNavigatorKey,
    initialLocation: '/home',
    refreshListenable: appRouterRefreshListenable,
    redirect: (BuildContext context, GoRouterState state) {
      final location = state.uri.path;
      final client = supabaseClientOrNull;
      // Supabase is always initialized in production. Isolated widget tests
      // can build StrydeApp directly without running main(), so leave routing
      // unguarded only in that test-only state.
      if (client == null) return location == '/' ? '/home' : null;

      final session = client.auth.currentSession;
      final isLoggingIn = location == '/login';

      // No session: every route except the login screen redirects to /login.
      if (session == null) {
        return isLoggingIn ? null : '/login';
      }

      // Session exists: send the user from the login screen to /home.
      if (isLoggingIn || location == '/') return '/home';

      return null;
    },
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) {
              return MainShell(navigationShell: navigationShell);
            },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/stats',
                name: 'stats',
                builder: (context, state) => const StatsScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'history/:workoutId',
                    name: 'workout-history-detail',
                    builder: (context, state) => WorkoutHistoryDetailScreen(
                      workoutId: state.pathParameters['workoutId'] ?? '',
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/train',
                name: 'train',
                builder: (context, state) => const TrainScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'routine/:routineId',
                    name: 'routine-detail',
                    builder: (context, state) {
                      final routineId = state.pathParameters['routineId'] ?? '';
                      final routine = state.extra is WorkoutRoutine
                          ? state.extra! as WorkoutRoutine
                          : (MockWorkoutData.routineById(routineId) ??
                                MasteryRoutineDefinitions.findDefaultRoutineById(
                                  routineId,
                                ));
                      return routine == null
                          ? const _NotFoundScreen(message: 'Routine not found')
                          : RoutineDetailScreen(routine: routine);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/social',
                name: 'social',
                builder: (context, state) =>
                    const _PlaceholderScreen(label: 'Social Screen'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/stats/xp-history',
        name: 'xp-history',
        builder: (context, state) => const XpHistoryScreen(),
      ),
      GoRoute(
        path: '/stats/workout-history',
        name: 'workout-history',
        builder: (context, state) => const WorkoutHistoryScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: ':workoutId',
            name: 'all-workouts-detail',
            builder: (context, state) => WorkoutHistoryDetailScreen(
              workoutId: state.pathParameters['workoutId'] ?? '',
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/workout/active/:routineId',
        name: 'active-workout',
        builder: (context, state) {
          final routineId = state.pathParameters['routineId'] ?? '';
          final routine = state.extra is WorkoutRoutine
              ? state.extra! as WorkoutRoutine
              : routineId == MockWorkoutData.freeTraining.id
              ? MockWorkoutData.freeTraining
              : (MockWorkoutData.routineById(routineId) ??
                    MasteryRoutineDefinitions.findDefaultRoutineById(
                      routineId,
                    ));
          return routine == null
              ? const _NotFoundScreen(message: 'Workout not found')
              : ActiveWorkoutScreen(routine: routine);
        },
      ),
      GoRoute(
        path: '/ranks',
        name: 'rank-progression',
        builder: (context, state) => const RankProgressionScreen(),
      ),
      GoRoute(
        path: '/exercises',
        name: 'exercise-library',
        builder: (context, state) => const ExerciseLibraryScreen(),
      ),
      GoRoute(
        path: '/routines/create',
        name: 'create-routine',
        builder: (context, state) => const CustomRoutineBuilderScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: 'theme',
            name: 'settings-theme',
            builder: (context, state) => const ThemeScreen(),
          ),
          GoRoute(
            path: 'profile',
            name: 'settings-profile',
            builder: (context, state) => const CustomizeProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/medals',
        name: 'medals',
        builder: (context, state) => const MedalsScreen(),
      ),
    ],
  );
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Text(label, style: Theme.of(context).textTheme.headlineSmall),
        ),
      ),
    );
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.background),
      body: SafeArea(
        child: Center(
          child: Text(
            message,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ),
    );
  }
}
