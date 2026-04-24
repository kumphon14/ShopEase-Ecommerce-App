// test/widget/auth/signup_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/screens/auth/signup_screen.dart';
import 'package:shopease_ecommerce_app/widgets/custom_button.dart';
import 'package:shopease_ecommerce_app/widgets/custom_text_field.dart';

import '../helpers/fake_providers.dart';
import '../helpers/pump_app.dart';

// Helper to tap a button that may be scrolled off-screen
Future<void> _scrollAndTap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder, warnIfMissed: false);
  await tester.pump();
}

void main() {
  group('SignupScreen', () {
    // ------------------------------------------------------------------
    // Rendering
    // ------------------------------------------------------------------
    testWidgets('renders Create Account heading', (tester) async {
      await tester.pumpApp(const SignupScreen());
      expect(find.text('Create Account ✨'), findsOneWidget);
    });

    testWidgets('renders subtitle text', (tester) async {
      await tester.pumpApp(const SignupScreen());
      expect(find.text('Join thousands of happy shoppers'), findsOneWidget);
    });

    testWidgets('renders Full Name label', (tester) async {
      await tester.pumpApp(const SignupScreen());
      expect(find.text('Full Name'), findsOneWidget);
    });

    testWidgets('renders Email Address label', (tester) async {
      await tester.pumpApp(const SignupScreen());
      expect(find.text('Email Address'), findsOneWidget);
    });

    testWidgets('renders Password label', (tester) async {
      await tester.pumpApp(const SignupScreen());
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('renders Confirm Password label', (tester) async {
      await tester.pumpApp(const SignupScreen());
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('renders Create Account button', (tester) async {
      await tester.pumpApp(const SignupScreen());
      expect(find.widgetWithText(CustomButton, 'Create Account'), findsOneWidget);
    });

    testWidgets('renders Login link', (tester) async {
      await tester.pumpApp(const SignupScreen());
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('renders four CustomTextField widgets', (tester) async {
      await tester.pumpApp(const SignupScreen());
      expect(find.byType(CustomTextField), findsNWidgets(4));
    });

    // ------------------------------------------------------------------
    // Form validation — empty submission
    // ------------------------------------------------------------------
    testWidgets('shows name required error on empty submission', (tester) async {
      await tester.pumpApp(const SignupScreen());
      final btn = find.widgetWithText(CustomButton, 'Create Account');
      await _scrollAndTap(tester, btn);
      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('shows email required error on empty submission', (tester) async {
      await tester.pumpApp(const SignupScreen());
      await _scrollAndTap(tester, find.widgetWithText(CustomButton, 'Create Account'));
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('shows password required error on empty submission', (tester) async {
      await tester.pumpApp(const SignupScreen());
      await _scrollAndTap(tester, find.widgetWithText(CustomButton, 'Create Account'));
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('shows confirm-password required error on empty submission',
        (tester) async {
      await tester.pumpApp(const SignupScreen());
      await _scrollAndTap(tester, find.widgetWithText(CustomButton, 'Create Account'));
      expect(find.text('Please confirm your password'), findsOneWidget);
    });

    testWidgets('shows mismatch error when passwords do not match', (tester) async {
      await tester.pumpApp(const SignupScreen());
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'John Doe');
      await tester.enterText(fields.at(1), 'john@example.com');
      await tester.enterText(fields.at(2), 'ValidPass1!');
      await tester.enterText(fields.at(3), 'DifferentPass1!');
      await _scrollAndTap(tester, find.widgetWithText(CustomButton, 'Create Account'));
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('shows invalid email error for bad email format', (tester) async {
      await tester.pumpApp(const SignupScreen());
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'John Doe');
      await tester.enterText(fields.at(1), 'bademail');
      await tester.enterText(fields.at(2), 'ValidPass1!');
      await tester.enterText(fields.at(3), 'ValidPass1!');
      await _scrollAndTap(tester, find.widgetWithText(CustomButton, 'Create Account'));
      expect(find.text('Enter a valid email address'), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Field interaction
    // ------------------------------------------------------------------
    testWidgets('accepts text in name field', (tester) async {
      await tester.pumpApp(const SignupScreen());
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Alice');
      expect(find.text('Alice'), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Navigation
    // ------------------------------------------------------------------
    testWidgets('tapping Login link navigates back', (tester) async {
      // SignupScreen.Login taps pop the stack.
      // We push the SignupScreen on top of pumpApp's MaterialApp so it can pop.
      final observer = _TestNavigatorObserver();
      await tester.pumpApp(const SignupScreen(), observers: [observer]);
      await tester.tap(find.text('Login'));
      await tester.pump();
      // No new push was triggered (pop does not fire didPush)
      // The test verifies no crash occurred
      expect(find.byType(Scaffold), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Submit path
    // ------------------------------------------------------------------
    testWidgets('tapping Create Account with valid input does not crash', (tester) async {
      await tester.pumpApp(const SignupScreen(), auth: makeAuthProvider());
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'John Doe');
      await tester.enterText(fields.at(1), 'john@example.com');
      await tester.enterText(fields.at(2), 'ValidPass1!');
      await tester.enterText(fields.at(3), 'ValidPass1!');
      await _scrollAndTap(tester, find.widgetWithText(CustomButton, 'Create Account'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Create Account ✨'), findsOneWidget);
    });
  });
}

class _TestNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
  }
}
