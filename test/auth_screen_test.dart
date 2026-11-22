import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_theme.dart';
import 'package:stryde/features/auth/presentation/screens/auth_screen.dart';

void main() {
  Future<void> pumpAuthScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.dark, home: const AuthScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('toggles between login and signup on a compact screen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpAuthScreen(tester);

    expect(find.text('Username'), findsNothing);
    await tester.tap(find.text('SIGN UP'));
    await tester.pumpAndSettle();

    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows validation and authentication errors under the fields', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpAuthScreen(tester);

    await tester.tap(find.text('Login'));
    await tester.pump();
    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(find.text('Enter a password'), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'user@example.com');
    await tester.enterText(fields.at(1), 'password123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // This isolated widget test does not initialize Supabase. Production does
    // so in main(), but the fallback still verifies graceful error rendering.
    expect(find.text('Authentication is unavailable.'), findsOneWidget);
    final errorText = tester.widget<Text>(
      find.text('Authentication is unavailable.'),
    );
    expect(errorText.style?.color, const Color(0xFFE45757));
  });
}
