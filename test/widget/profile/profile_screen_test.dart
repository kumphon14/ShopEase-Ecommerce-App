// test/widget/profile/profile_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/screens/profile/profile_screen.dart';

import '../helpers/fake_providers.dart';
import '../helpers/pump_app.dart';

void main() {
  group('ProfileScreen', () {
    // ------------------------------------------------------------------
    // Unauthenticated state
    // ------------------------------------------------------------------
    testWidgets('renders Guest User when not authenticated', (tester) async {
      await tester.pumpApp(const ProfileScreen(), auth: makeAuthProvider());
      await tester.pump();
      expect(find.text('Guest User'), findsOneWidget);
    });

    testWidgets('renders Not signed in when not authenticated', (tester) async {
      await tester.pumpApp(const ProfileScreen(), auth: makeAuthProvider());
      await tester.pump();
      expect(find.text('Not signed in'), findsOneWidget);
    });

    testWidgets('renders Login to Your Account button when not authenticated',
        (tester) async {
      await tester.pumpApp(const ProfileScreen(), auth: makeAuthProvider());
      await tester.pump();
      expect(find.text('Login to Your Account'), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Menu items always visible
    // ------------------------------------------------------------------
    testWidgets('renders Order History menu item', (tester) async {
      await tester.pumpApp(const ProfileScreen());
      await tester.pump();
      expect(find.text('Order History'), findsOneWidget);
    });

    testWidgets('renders My Wishlist menu item', (tester) async {
      await tester.pumpApp(const ProfileScreen());
      await tester.pump();
      expect(find.text('My Wishlist'), findsOneWidget);
    });

    testWidgets('renders Edit Profile menu item', (tester) async {
      await tester.pumpApp(const ProfileScreen());
      await tester.pump();
      expect(find.text('Edit Profile'), findsOneWidget);
    });

    testWidgets('renders Notifications menu item', (tester) async {
      await tester.pumpApp(const ProfileScreen());
      await tester.pump();
      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('renders Scaffold', (tester) async {
      await tester.pumpApp(const ProfileScreen());
      await tester.pump();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Navigation triggers
    // ------------------------------------------------------------------
    testWidgets('tapping Notifications triggers navigation', (tester) async {
      final observer = _TestNavigatorObserver();
      await tester.pumpApp(const ProfileScreen(), observers: [observer]);
      await tester.pump();
      await tester.tap(find.text('Notifications'));
      await tester.pump();
      expect(observer.pushedRoutes.isNotEmpty, isTrue);
    });

    testWidgets('tapping Login to Your Account triggers navigation', (tester) async {
      final observer = _TestNavigatorObserver();
      await tester.pumpApp(const ProfileScreen(), observers: [observer]);
      await tester.pump();
      await tester.tap(find.text('Login to Your Account'));
      await tester.pump();
      expect(observer.pushedRoutes.isNotEmpty, isTrue);
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
