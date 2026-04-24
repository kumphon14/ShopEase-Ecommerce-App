// test/widget/auth/login_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/screens/auth/login_screen.dart';
import 'package:shopease_ecommerce_app/widgets/custom_button.dart';
import 'package:shopease_ecommerce_app/widgets/custom_text_field.dart';

import '../helpers/fake_providers.dart';
import '../helpers/pump_app.dart';

void main() {
  group('LoginScreen', () {
    // ------------------------------------------------------------------
    // Rendering
    // ------------------------------------------------------------------
    testWidgets('renders welcome text', (tester) async {
      await tester.pumpApp(const LoginScreen());
      expect(find.text('Welcome Back! 👋'), findsOneWidget);
    });

    testWidgets('renders subtitle text', (tester) async {
      await tester.pumpApp(const LoginScreen());
      expect(find.text('Sign in to continue shopping'), findsOneWidget);
    });

    testWidgets('renders email label', (tester) async {
      await tester.pumpApp(const LoginScreen());
      expect(find.text('Email Address'), findsOneWidget);
    });

    testWidgets('renders password label', (tester) async {
      await tester.pumpApp(const LoginScreen());
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('renders Login button', (tester) async {
      await tester.pumpApp(const LoginScreen());
      expect(find.widgetWithText(CustomButton, 'Login'), findsOneWidget);
    });

    testWidgets('renders Sign Up navigation link', (tester) async {
      await tester.pumpApp(const LoginScreen());
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('renders two CustomTextField widgets', (tester) async {
      await tester.pumpApp(const LoginScreen());
      expect(find.byType(CustomTextField), findsNWidgets(2));
    });

    // ------------------------------------------------------------------
    // Form validation — empty submission
    // ------------------------------------------------------------------
    testWidgets('shows email required error on empty submission', (tester) async {
      await tester.pumpApp(const LoginScreen());
      await tester.tap(find.widgetWithText(CustomButton, 'Login'));
      await tester.pump();
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('shows password required error on empty submission', (tester) async {
      await tester.pumpApp(const LoginScreen());
      await tester.tap(find.widgetWithText(CustomButton, 'Login'));
      await tester.pump();
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('shows invalid email error for malformed email', (tester) async {
      await tester.pumpApp(const LoginScreen());
      // Enter invalid email
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'notanemail');
      await tester.tap(find.widgetWithText(CustomButton, 'Login'));
      await tester.pump();
      expect(find.text('Enter a valid email address'), findsOneWidget);
    });

    testWidgets('shows minimum-length password error for short password', (tester) async {
      await tester.pumpApp(const LoginScreen());
      final emailField = find.byType(TextFormField).first;
      final passField = find.byType(TextFormField).last;
      await tester.enterText(emailField, 'user@example.com');
      await tester.enterText(passField, 'short');
      await tester.tap(find.widgetWithText(CustomButton, 'Login'));
      await tester.pump();
      expect(find.text('Minimum 8 characters required'), findsOneWidget);
    });

    testWidgets('shows must-contain-number error when no digit in password', (tester) async {
      await tester.pumpApp(const LoginScreen());
      final emailField = find.byType(TextFormField).first;
      final passField = find.byType(TextFormField).last;
      await tester.enterText(emailField, 'user@example.com');
      await tester.enterText(passField, 'NoDigitsHere!');
      await tester.tap(find.widgetWithText(CustomButton, 'Login'));
      await tester.pump();
      expect(find.text('Must contain at least one number'), findsOneWidget);
    });

    testWidgets('shows special-character error when no symbol in password', (tester) async {
      await tester.pumpApp(const LoginScreen());
      final emailField = find.byType(TextFormField).first;
      final passField = find.byType(TextFormField).last;
      await tester.enterText(emailField, 'user@example.com');
      await tester.enterText(passField, 'NoSymbol1234');
      await tester.tap(find.widgetWithText(CustomButton, 'Login'));
      await tester.pump();
      expect(find.text('Must contain at least one special character'), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Field interaction
    // ------------------------------------------------------------------
    testWidgets('accepts text input in email field', (tester) async {
      await tester.pumpApp(const LoginScreen());
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'user@example.com');
      expect(find.text('user@example.com'), findsOneWidget);
    });

    testWidgets('accepts text input in password field', (tester) async {
      await tester.pumpApp(const LoginScreen());
      final passField = find.byType(TextFormField).last;
      await tester.enterText(passField, 'SecurePass1!');
      // password is obscured by default so just verify no error
      await tester.pump();
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    // ------------------------------------------------------------------
    // Navigation
    // ------------------------------------------------------------------
    testWidgets('tapping Sign Up pushes to another route', (tester) async {
      final observer = _TestNavigatorObserver();
      await tester.pumpApp(const LoginScreen(), observers: [observer]);
      await tester.tap(find.text('Sign Up'));
      await tester.pump();
      // A push occurred
      expect(observer.pushedRoutes.isNotEmpty, isTrue);
    });

    // ------------------------------------------------------------------
    // Login trigger (provider returns false → stays on screen)
    // ------------------------------------------------------------------
    testWidgets('tapping Login with valid input calls login without crashing', (tester) async {
      await tester.pumpApp(
        const LoginScreen(),
        auth: makeAuthProvider(),
      );
      final emailField = find.byType(TextFormField).first;
      final passField = find.byType(TextFormField).last;
      await tester.enterText(emailField, 'user@example.com');
      await tester.enterText(passField, 'ValidPass1!');
      await tester.tap(find.widgetWithText(CustomButton, 'Login'));
      await tester.pump(); // start async
      await tester.pump(const Duration(milliseconds: 100)); // settle
      // Screen is still shown (login returns false with no real Firebase)
      expect(find.text('Welcome Back! 👋'), findsOneWidget);
    });
  });
}

// Minimal observer to assert navigation pushes occurred
class _TestNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
  }
}
