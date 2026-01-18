/// Full onboarding integration test
///
/// Tests the complete user flow:
/// 1. App launches and shows login screen
/// 2. User signs in with email/password
/// 3. User is redirected to home screen
/// 4. User navigates to routines
/// 5. Routines list loads successfully
///
/// Prerequisites:
/// - Copy test_config.dart to test_config_local.dart
/// - Fill in valid test credentials
/// - Set authTestsEnabled = true
///
/// Run with:
///   flutter test integration_test/onboarding_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:treoir/main.dart' as app;

// Try to import local config, fall back to template
import 'test_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Launch', () {
    testWidgets('shows login screen on first launch', (tester) async {
      // Load environment
      await dotenv.load(fileName: '.env');

      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Verify login screen elements
      expect(find.text('Treoir'), findsOneWidget);
      expect(find.text("The thinking athlete's training log"), findsOneWidget);
      expect(find.text('Sign In'), findsWidgets);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('login form validation works', (tester) async {
      await dotenv.load(fileName: '.env');
      app.main();
      await tester.pumpAndSettle();

      // Try to submit empty form
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('can toggle between Sign In and Sign Up', (tester) async {
      await dotenv.load(fileName: '.env');
      app.main();
      await tester.pumpAndSettle();

      // Initial state is Sign In
      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);

      // Tap Sign Up segment
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Button should change to Create Account
      expect(find.widgetWithText(ElevatedButton, 'Create Account'), findsOneWidget);

      // Tap back to Sign In
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
    });
  });

  group('Authentication Flow', () {
    testWidgets('full login and navigation flow', (tester) async {
      // Skip if auth tests not enabled
      if (!TestConfig.authTestsEnabled) {
        print('Skipping auth test - set authTestsEnabled = true in test_config.dart');
        return;
      }

      await dotenv.load(fileName: '.env');
      app.main();
      await tester.pumpAndSettle();

      // === Step 1: Login ===
      print('Step 1: Entering credentials...');

      // Enter email
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email').first,
        TestConfig.testEmail,
      );
      await tester.pump();

      // Enter password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password').first,
        TestConfig.testPassword,
      );
      await tester.pump();

      // Tap Sign In
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));

      // Wait for authentication (may take a few seconds)
      print('Step 2: Waiting for authentication...');
      await tester.pumpAndSettle(TestConfig.defaultTimeout);

      // === Step 2: Verify Home Screen ===
      print('Step 3: Verifying home screen...');

      // Should see home screen elements
      expect(find.text('Treoir'), findsOneWidget);
      expect(find.text('Start Workout'), findsOneWidget);
      expect(find.text('Quick Start'), findsOneWidget);
      expect(find.text('From Routine'), findsOneWidget);
      expect(find.text('Recent Workouts'), findsOneWidget);

      // === Step 3: Navigate to Routines ===
      print('Step 4: Navigating to routines...');

      await tester.tap(find.text('From Routine'));
      await tester.pumpAndSettle(TestConfig.uiTimeout);

      // Should see routines screen
      expect(find.text('Routines'), findsOneWidget);

      // Wait for routines to load
      await tester.pumpAndSettle(TestConfig.defaultTimeout);

      // Should see either routines list or empty state
      final hasRoutines = find.byType(Card).evaluate().isNotEmpty;
      final hasEmptyState = find.text('No routines yet').evaluate().isNotEmpty;

      expect(
        hasRoutines || hasEmptyState,
        isTrue,
        reason: 'Should show either routines or empty state',
      );

      print('Step 5: Test completed successfully!');
    });

    testWidgets('can navigate to history from home', (tester) async {
      if (!TestConfig.authTestsEnabled) {
        print('Skipping auth test - set authTestsEnabled = true in test_config.dart');
        return;
      }

      await dotenv.load(fileName: '.env');
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email').first,
        TestConfig.testEmail,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password').first,
        TestConfig.testPassword,
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle(TestConfig.defaultTimeout);

      // Tap history icon in app bar
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle(TestConfig.uiTimeout);

      // Should see history screen
      expect(find.text('Workout History'), findsOneWidget);

      // Wait for history to load
      await tester.pumpAndSettle(TestConfig.defaultTimeout);

      // Should show workouts or empty state
      final hasWorkouts = find.byType(Card).evaluate().isNotEmpty;
      final hasEmptyState = find.text('No workouts yet').evaluate().isNotEmpty ||
          find.textContaining('No workouts').evaluate().isNotEmpty;

      expect(
        hasWorkouts || hasEmptyState,
        isTrue,
        reason: 'Should show either workouts or empty state',
      );
    });

    testWidgets('can navigate to settings', (tester) async {
      if (!TestConfig.authTestsEnabled) {
        print('Skipping auth test - set authTestsEnabled = true in test_config.dart');
        return;
      }

      await dotenv.load(fileName: '.env');
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email').first,
        TestConfig.testEmail,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password').first,
        TestConfig.testPassword,
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle(TestConfig.defaultTimeout);

      // Tap settings icon in app bar
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle(TestConfig.uiTimeout);

      // Should see settings screen
      expect(find.text('Settings'), findsOneWidget);

      // Should see sign out option
      expect(find.text('Sign Out'), findsOneWidget);
    });
  });
}
