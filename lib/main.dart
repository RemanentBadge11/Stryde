import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stryde/core/routing/app_router.dart';
import 'package:stryde/core/sync/sync_service.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_theme.dart';
import 'package:stryde/features/exercises/presentation/providers/exercise_library_provider.dart';
import 'package:stryde/features/home/presentation/providers/daily_goals_provider.dart';
import 'package:stryde/features/home/presentation/providers/habits_provider.dart';
import 'package:stryde/features/home/presentation/providers/login_streak_provider.dart';
import 'package:stryde/features/home/presentation/providers/weekly_quests_provider.dart';
import 'package:stryde/features/profile/presentation/providers/profile_goals_provider.dart';
import 'package:stryde/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:stryde/features/progression/presentation/providers/skill_allocations_provider.dart';
import 'package:stryde/features/progression/presentation/providers/user_progression_provider.dart';
import 'package:stryde/features/progression/presentation/providers/xp_transactions_provider.dart';
import 'package:stryde/features/progression/presentation/widgets/global_notification_banner.dart';
import 'package:stryde/features/settings/presentation/providers/theme_provider.dart';
import 'package:stryde/features/workout_history/presentation/providers/workout_history_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://bagskoscduktogyjhrfr.supabase.co',
    publishableKey: 'sb_publishable_ECwqz1xsI19PxbdNchtRuw_C70CbZw2',
  );

  // Tell the router to re-evaluate its redirect guard whenever the auth
  // session changes (sign in, sign out, session refresh, ...).
  Supabase.instance.client.auth.onAuthStateChange.listen((_) {
    appRouterRefreshListenable.value = !appRouterRefreshListenable.value;
  });

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: AppColors.background,
    ),
  );

  runApp(const ProviderScope(child: StrydeApp()));
}

class StrydeApp extends ConsumerStatefulWidget {
  const StrydeApp({super.key});

  @override
  ConsumerState<StrydeApp> createState() => _StrydeAppState();
}

class _StrydeAppState extends ConsumerState<StrydeApp> {
  late final _router = createAppRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Eagerly place the JSON exercise collection in the in-memory provider
    // cache and start user-scoped Supabase hydration as soon as auth resolves.
    ref.watch(exerciseLibraryProvider);
    ref.watch(userProgressionProvider);
    ref.watch(loginStreakProvider);
    ref.watch(xpTransactionsProvider);
    ref.watch(skillAllocationsProvider);
    ref.watch(workoutHistoryProvider);
    ref.watch(habitsProvider);
    ref.watch(weeklyQuestsProvider);
    ref.watch(dailyGoalsProvider);
    ref.watch(profileGoalsProvider);
    ref.watch(userProfileProvider);
    ref.watch(syncServiceProvider);
    final themeState = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Stryde',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(
        isDark: false,
        accentColor: themeState.accentColor,
      ),
      darkTheme: AppTheme.buildTheme(
        isDark: true,
        accentColor: themeState.accentColor,
      ),
      themeMode: themeState.themeMode,
      routerConfig: _router,
      builder: (context, child) {
        return GlobalNotificationOverlay(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
