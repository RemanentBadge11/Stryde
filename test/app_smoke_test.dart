import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/main.dart';

void main() {
  testWidgets('home greeting and streak layout fit a compact screen', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: StrydeApp()));
    await tester.pumpAndSettle();

    expect(find.text('Good Morning'), findsOneWidget);
    final profileRect = tester.getRect(
      find.byKey(const ValueKey<String>('home-profile-button')),
    );
    final streakRect = tester.getRect(
      find.byKey(const ValueKey<String>('login-streak-bubble')),
    );
    expect(streakRect.top, greaterThanOrEqualTo(profileRect.bottom));
    expect(streakRect.center.dx, closeTo(profileRect.center.dx, 0.01));

    await tester.tap(find.byTooltip('Start empty workout'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byTooltip('Complete workout'), findsOneWidget);
    expect(find.byTooltip('Pause workout timer'), findsOneWidget);
    expect(find.byTooltip('Discard workout'), findsOneWidget);
  });

  testWidgets('renders the home cycles and the reordered navigation', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: StrydeApp()));
    await tester.pumpAndSettle();

    expect(find.text('Good Morning'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('login-streak-bubble')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey<String>('login-streak-bubble')),
        matching: find.text('0'),
      ),
      findsOneWidget,
    );
    expect(find.text('LEVEL 1'), findsOneWidget);
    expect(find.text('New Blood'), findsOneWidget);
    expect(find.text('0 / 500 XP', findRichText: true), findsOneWidget);
    expect(find.text('Habits'), findsOneWidget);
    expect(find.text('Weekly Quests'), findsOneWidget);
    expect(find.text('Daily Goals'), findsOneWidget);
    expect(find.text('Walk 10,000 steps'), findsOneWidget);
    expect(find.text('Drink 4L water'), findsOneWidget);
    expect(find.text('Hit 160g protein'), findsOneWidget);
    expect(find.text('Go to the gym'), findsOneWidget);

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('Train'), findsOneWidget);
    expect(find.text('Social'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.byTooltip('Start empty workout'), findsOneWidget);

    final profileButton = find.byKey(
      const ValueKey<String>('home-profile-button'),
    );
    final streakBubble = find.byKey(
      const ValueKey<String>('login-streak-bubble'),
    );
    final profileRect = tester.getRect(profileButton);
    final streakRect = tester.getRect(streakBubble);
    expect(streakRect.top, greaterThanOrEqualTo(profileRect.bottom));
    expect(streakRect.center.dx, closeTo(profileRect.center.dx, 0.01));

    final navCenters = <double>[
      for (final slot in const <String>[
        'home',
        'stats',
        'train',
        'social',
        'profile',
      ])
        tester.getCenter(find.byKey(ValueKey<String>('bottom-nav-$slot'))).dx,
    ];
    final navGaps = <double>[
      for (var i = 1; i < navCenters.length; i++)
        navCenters[i] - navCenters[i - 1],
    ];
    for (final gap in navGaps.skip(1)) {
      expect(gap, closeTo(navGaps.first, 0.01));
    }

    await tester.tap(find.text('Walk 10,000 steps'));
    await tester.pump();
    expect(find.text('30 / 500 XP', findRichText: true), findsOneWidget);
    expect(find.textContaining('+30 XP'), findsWidgets);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey<String>('login-streak-bubble')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    expect(find.text('XP Breakdown'), findsOneWidget);
    expect(find.text('Habit · Walk 10,000 steps'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Assign Skill Points'), 200);
    expect(find.text('Assign Skill Points'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Chest'), 200);
    expect(find.text('Chest'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('bottom-nav-train')));
    await tester.pumpAndSettle();
    expect(find.text('My Routines'), findsOneWidget);
    expect(find.text('Start Empty Workout'), findsOneWidget);
    expect(find.text('Create Routine'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Open profile'));
    await tester.pumpAndSettle();
    expect(find.text('Goals'), findsOneWidget);
    expect(find.text('Daily Steps'), findsOneWidget);
    expect(find.text('10,000 steps'), findsOneWidget);
    expect(find.text('Daily Water'), findsOneWidget);
    expect(find.text('4 liters'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Good Morning'), findsOneWidget);
  });

  testWidgets('floating start button opens free training and ranks open', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: StrydeApp()));
    await tester.pumpAndSettle();

    final workoutControl = find.byKey(
      const ValueKey<String>('workout-navbar-control'),
    );
    expect(tester.getSize(workoutControl).width, 60);

    await tester.tap(find.byTooltip('Start empty workout'));
    await tester.pumpAndSettle();
    expect(find.text('Active Workout'), findsOneWidget);
    expect(find.text('Empty workout'), findsOneWidget);
    expect(find.text('Add Exercise'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('active-screen-workout-elapsed')),
      findsOneWidget,
    );

    final finishButton = tester.widget<IconButton>(
      find.descendant(
        of: find.byTooltip('Finish workout'),
        matching: find.byType(IconButton),
      ),
    );
    final activeScreenDiscardButton = tester.widget<IconButton>(
      find.descendant(
        of: find.byTooltip('Discard workout'),
        matching: find.byType(IconButton),
      ),
    );
    expect(
      finishButton.style!.backgroundColor!.resolve(<WidgetState>{}),
      Colors.green,
    );
    expect(
      activeScreenDiscardButton.style!.backgroundColor!.resolve(
        <WidgetState>{},
      ),
      Colors.red,
    );

    await tester.tap(find.byTooltip('Pause workout timer'));
    await tester.pump();
    final pausedScreenTime = tester
        .widget<Text>(
          find.byKey(const ValueKey<String>('active-screen-workout-elapsed')),
        )
        .data;
    await tester.pump(const Duration(seconds: 2));
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey<String>('active-screen-workout-elapsed')),
          )
          .data,
      pausedScreenTime,
    );
    expect(find.text('WORKOUT PAUSED'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byTooltip('Resume workout'), findsOneWidget);
    expect(find.byTooltip('Complete workout'), findsOneWidget);
    expect(find.byTooltip('Resume workout timer'), findsOneWidget);
    expect(find.byTooltip('Discard workout'), findsOneWidget);
    expect(find.byTooltip('Start empty workout'), findsNothing);
    expect(tester.getSize(workoutControl).width, greaterThan(264));
    expect(tester.getSize(workoutControl).height, 72);
    expect(find.text('Ongoing workout'), findsOneWidget);
    final pillRect = tester.getRect(workoutControl);
    for (final entry in <String, IconData>{
      'home': Icons.home_rounded,
      'stats': Icons.bar_chart_rounded,
      'train': Icons.fitness_center_rounded,
      'social': Icons.groups_rounded,
      'profile': Icons.person_rounded,
    }.entries) {
      final icon = find.descendant(
        of: find.byKey(ValueKey<String>('bottom-nav-${entry.key}')),
        matching: find.byIcon(entry.value),
      );
      expect(icon, findsOneWidget);
      expect(tester.getRect(icon).top, greaterThanOrEqualTo(pillRect.bottom));
    }
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey<String>('active-workout-elapsed')),
          )
          .data,
      pausedScreenTime,
    );

    await tester.tap(find.byTooltip('Resume workout timer'));
    await tester.pump();
    expect(find.byTooltip('Pause workout timer'), findsOneWidget);

    final completeButton = tester.widget<IconButton>(
      find.descendant(
        of: find.byKey(const ValueKey<String>('workout-pill-complete')),
        matching: find.byType(IconButton),
      ),
    );
    final pauseButton = tester.widget<IconButton>(
      find.descendant(
        of: find.byKey(const ValueKey<String>('workout-pill-pause')),
        matching: find.byType(IconButton),
      ),
    );
    final discardButton = tester.widget<IconButton>(
      find.descendant(
        of: find.byKey(const ValueKey<String>('workout-pill-discard')),
        matching: find.byType(IconButton),
      ),
    );
    expect(
      completeButton.style!.backgroundColor!.resolve(<WidgetState>{}),
      Colors.green,
    );
    expect(
      pauseButton.style!.backgroundColor!.resolve(<WidgetState>{}),
      Colors.amber,
    );
    expect(
      discardButton.style!.backgroundColor!.resolve(<WidgetState>{}),
      Colors.red,
    );

    await tester.tap(find.byTooltip('Pause workout timer'));
    await tester.pump();
    final pausedTime = tester
        .widget<Text>(
          find.byKey(const ValueKey<String>('active-workout-elapsed')),
        )
        .data;
    await tester.pump(const Duration(seconds: 2));
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey<String>('active-workout-elapsed')),
          )
          .data,
      pausedTime,
    );
    expect(find.byTooltip('Resume workout timer'), findsOneWidget);
    await tester.tap(find.byTooltip('Resume workout timer'));
    await tester.pump();
    expect(find.byTooltip('Pause workout timer'), findsOneWidget);

    await tester.tap(find.byTooltip('Resume workout'));
    await tester.pumpAndSettle();
    expect(find.text('Active Workout'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Discard workout'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Start empty workout'), findsOneWidget);
    expect(tester.getSize(workoutControl).width, 60);
    expect(find.text('0 / 500 XP', findRichText: true), findsOneWidget);

    await tester.tap(find.text('Rank Progression'));
    await tester.pumpAndSettle();
    expect(find.text('The climb'), findsOneWidget);
    expect(find.text('All Ranks'), findsOneWidget);
    expect(find.text('New Blood'), findsWidgets);
    expect(find.text('Prodigy'), findsOneWidget);
    expect(find.text('Hunter'), findsOneWidget);
    expect(find.text('More Coming Soon'), findsOneWidget);
    expect(find.text('CURRENT'), findsOneWidget);
  });

  testWidgets('finishing a workout awards XP and writes the ledger', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: StrydeApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Train'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Push Day'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Start This Routine'));
    await tester.tap(find.text('Start This Routine'));
    await tester.pumpAndSettle();

    final inputs = find.byType(TextFormField);
    await tester.enterText(inputs.at(0), '80');
    await tester.enterText(inputs.at(1), '8');
    await tester.tap(find.byTooltip('Complete set 1 for Bench Press'));
    await tester.pump();

    expect(find.text('REST TIMER'), findsOneWidget);
    expect(find.text('1:30'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byTooltip('Resume workout'), findsOneWidget);
    await tester.tap(find.byTooltip('Resume workout'));
    await tester.pumpAndSettle();

    expect(find.text('REST TIMER'), findsOneWidget);
    final resumedInputs = find.byType(EditableText);
    expect(
      tester.widget<EditableText>(resumedInputs.at(0)).controller.text,
      '80',
    );
    expect(
      tester.widget<EditableText>(resumedInputs.at(1)).controller.text,
      '8',
    );

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Finish workout'));
    await tester.pumpAndSettle();
    expect(find.text('Workout Complete'), findsOneWidget);
    await tester.tap(find.text('Back Home'));
    await tester.pumpAndSettle();

    expect(find.text('100 / 500 XP', findRichText: true), findsOneWidget);

    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    expect(find.text('+100 XP'), findsOneWidget);
    expect(find.text('Completed Push Day'), findsOneWidget);
  });

  testWidgets('active screen discard wipes the workout without XP', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: StrydeApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Start empty workout'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Finish workout'), findsOneWidget);
    expect(find.byTooltip('Discard workout'), findsOneWidget);
    expect(find.text('Finish'), findsNothing);

    await tester.tap(find.byTooltip('Discard workout'));
    await tester.pumpAndSettle();

    expect(find.text('Good Morning'), findsOneWidget);
    expect(find.text('0 / 500 XP', findRichText: true), findsOneWidget);
    expect(find.byTooltip('Start empty workout'), findsOneWidget);

    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    expect(find.text('No XP earned yet'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('No sessions yet'), 250);
    expect(find.text('No sessions yet'), findsOneWidget);
  });

  testWidgets('finishing an empty workout saves it but awards zero XP', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: StrydeApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Start empty workout'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Finish workout'));
    await tester.pumpAndSettle();

    expect(find.text('Workout Saved'), findsOneWidget);
    expect(find.textContaining('Session saved with 0 XP'), findsOneWidget);
    await tester.tap(find.text('Back Home'));
    await tester.pumpAndSettle();
    expect(find.text('0 / 500 XP', findRichText: true), findsOneWidget);

    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    expect(find.text('No XP earned yet'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Free Training'), 250);
    expect(find.text('Free Training'), findsOneWidget);
  });
}
