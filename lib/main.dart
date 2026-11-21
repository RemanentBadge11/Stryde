import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/routing/app_router.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_theme.dart';
import 'package:stryde/features/exercises/presentation/providers/exercise_library_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
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
    // cache. No values are persisted outside this ProviderScope.
    ref.watch(exerciseLibraryProvider);

    return MaterialApp.router(
      title: 'Stryde',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: _router,
    );
  }
}
