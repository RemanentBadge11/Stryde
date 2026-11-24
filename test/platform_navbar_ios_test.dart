import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_theme.dart';
import 'package:stryde/core/widgets/platform_navbar/navbar_export.dart';

void main() {
  group('PlatformNavbar Architecture & Stability', () {
    testWidgets('Renders Material bottom bar on Android', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        var selectedBranch = -1;
        var startWorkoutTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              bottomNavigationBar: PlatformNavbar(
                currentIndex: 0,
                onDestinationSelected: (index) => selectedBranch = index,
                onStartWorkout: () => startWorkoutTapped = true,
                isWorkoutOngoing: false,
                isPaused: false,
                elapsed: Duration.zero,
                onResumeWorkout: () {},
                onCompleteWorkout: () {},
                onToggleTimer: () {},
                onDiscardWorkout: () {},
              ),
            ),
          ),
        );

        // Verify navigation slots exist
        expect(
          find.byKey(const ValueKey<String>('bottom-nav-home')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey<String>('bottom-nav-stats')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey<String>('bottom-nav-train')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey<String>('bottom-nav-social')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey<String>('bottom-nav-profile')),
          findsOneWidget,
        );

        // Verify start workout action button exists
        expect(
          find.byKey(const ValueKey<String>('start-workout-button')),
          findsOneWidget,
        );

        // Tap Stats tab
        await tester.tap(
          find.byKey(const ValueKey<String>('bottom-nav-stats')),
        );
        await tester.pump();
        expect(selectedBranch, 1);

        // Tap start workout button
        await tester.tap(
          find.byKey(const ValueKey<String>('start-workout-button')),
        );
        await tester.pump();
        expect(startWorkoutTapped, true);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets(
      'Train tab is cleanly tappable and Start Workout button has upward clearance',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 932));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        try {
          var selectedBranch = -1;
          var startWorkoutTapped = false;

          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.dark,
              home: Scaffold(
                bottomNavigationBar: PlatformNavbar(
                  currentIndex: 0,
                  onDestinationSelected: (index) => selectedBranch = index,
                  onStartWorkout: () => startWorkoutTapped = true,
                  isWorkoutOngoing: false,
                  isPaused: false,
                  elapsed: Duration.zero,
                  onResumeWorkout: () {},
                  onCompleteWorkout: () {},
                  onToggleTimer: () {},
                  onDiscardWorkout: () {},
                ),
              ),
            ),
          );

          // Verify Train navigation slot is directly tappable without obstruction
          final trainTab = find.byKey(
            const ValueKey<String>('bottom-nav-train'),
          );
          expect(trainTab, findsOneWidget);
          await tester.tap(trainTab);
          await tester.pump();
          expect(selectedBranch, 2);

          // Verify Start Workout button is tappable
          final startBtn = find.byKey(
            const ValueKey<String>('start-workout-button'),
          );
          expect(startBtn, findsOneWidget);
          await tester.tap(startBtn);
          await tester.pump();
          expect(startWorkoutTapped, true);

          // Verify physical vertical clearance between button bottom and train tab content
          final startBtnRect = tester.getRect(startBtn);
          final trainTabRect = tester.getRect(trainTab);
          expect(startBtnRect.bottom, lessThan(trainTabRect.bottom));
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      },
    );

    testWidgets('Renders Material bottom bar stably on iOS platform target', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        var selectedBranch = -1;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              bottomNavigationBar: PlatformNavbar(
                currentIndex: 2,
                onDestinationSelected: (index) => selectedBranch = index,
                onStartWorkout: () {},
                isWorkoutOngoing: false,
                isPaused: false,
                elapsed: Duration.zero,
                onResumeWorkout: () {},
                onCompleteWorkout: () {},
                onToggleTimer: () {},
                onDiscardWorkout: () {},
              ),
            ),
          ),
        );

        expect(
          find.byKey(const ValueKey<String>('bottom-nav-train')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey<String>('bottom-nav-profile')),
          findsOneWidget,
        );
        await tester.tap(
          find.byKey(const ValueKey<String>('bottom-nav-profile')),
        );
        await tester.pump();
        expect(selectedBranch, 4);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('Renders Active Workout Pill when workout is ongoing', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        var resumeTapped = false;
        var completeTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              bottomNavigationBar: PlatformNavbar(
                currentIndex: 0,
                onDestinationSelected: (_) {},
                onStartWorkout: () {},
                isWorkoutOngoing: true,
                isPaused: false,
                elapsed: const Duration(minutes: 12, seconds: 34),
                onResumeWorkout: () => resumeTapped = true,
                onCompleteWorkout: () => completeTapped = true,
                onToggleTimer: () {},
                onDiscardWorkout: () {},
              ),
            ),
          ),
        );

        expect(
          find.byKey(const ValueKey<String>('active-workout-pill')),
          findsOneWidget,
        );
        expect(find.text('00:12:34'), findsOneWidget);
        expect(
          find.byKey(const ValueKey<String>('workout-pill-complete')),
          findsOneWidget,
        );

        await tester.tap(
          find.byKey(const ValueKey<String>('workout-pill-complete')),
        );
        await tester.pump();
        expect(completeTapped, true);

        await tester.tap(
          find.byKey(const ValueKey<String>('active-workout-elapsed')),
        );
        await tester.pump();
        expect(resumeTapped, true);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    test(
      'navbar_export.dart directly exports navbar_android.dart without liquid_glass',
      () {
        final exportFile = File(
          'lib/core/widgets/platform_navbar/navbar_export.dart',
        );
        expect(exportFile.existsSync(), isTrue);
        final content = exportFile.readAsStringSync().trim();
        expect(content, equals("export 'navbar_android.dart';"));
        expect(content.contains('liquid_glass'), isFalse);
      },
    );

    test(
      'Info.plist does NOT contain UIApplicationSceneManifest (crash fix)',
      () {
        final file = File('ios/Runner/Info.plist');
        expect(file.existsSync(), isTrue);
        final content = file.readAsStringSync();
        expect(content.contains('UIApplicationSceneManifest'), isFalse);
      },
    );

    test('Info.plist contains required iOS photo and camera permissions', () {
      final file = File('ios/Runner/Info.plist');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      expect(
        content.contains('<key>NSPhotoLibraryUsageDescription</key>'),
        isTrue,
      );
      expect(
        content.contains(
          '<string>Stryde needs access to your photos to set a profile picture.</string>',
        ),
        isTrue,
      );
      expect(content.contains('<key>NSCameraUsageDescription</key>'), isTrue);
      expect(
        content.contains(
          '<string>Stryde needs access to your camera to take a profile picture.</string>',
        ),
        isTrue,
      );
      expect(content.contains('<key>CFBundleIdentifier</key>'), isTrue);
      expect(
        content.contains(r'<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>'),
        isTrue,
      );
      expect(content.contains('<key>CFBundleDisplayName</key>'), isTrue);
      expect(content.contains('<string>Stryde</string>'), isTrue);
    });

    test(
      'project.pbxproj and Podfile target iOS 15.0+ with com.stryde.app bundle id',
      () {
        final pbxproj = File('ios/Runner.xcodeproj/project.pbxproj');
        expect(pbxproj.existsSync(), isTrue);
        final pbxContent = pbxproj.readAsStringSync();
        expect(
          pbxContent.contains('PRODUCT_BUNDLE_IDENTIFIER = com.stryde.app;'),
          isTrue,
        );
        expect(
          pbxContent.contains('IPHONEOS_DEPLOYMENT_TARGET = 15.0;'),
          isTrue,
        );

        final podfile = File('ios/Podfile');
        expect(podfile.existsSync(), isTrue);
        final podfileContent = podfile.readAsStringSync();
        expect(podfileContent.contains("platform :ios, '15.0'"), isTrue);
      },
    );

    test(
      'AppDelegate.swift registers plugins via GeneratedPluginRegistrant.register',
      () {
        final appDelegate = File('ios/Runner/AppDelegate.swift');
        expect(appDelegate.existsSync(), isTrue);
        final content = appDelegate.readAsStringSync();
        expect(
          content.contains('GeneratedPluginRegistrant.register(with: self)'),
          isTrue,
        );
      },
    );
  });
}
