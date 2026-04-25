// test/widget/admin/admin_dashboard_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/screens/admin/admin_dashboard_screen.dart';

import '../helpers/pump_app.dart';

void main() {
  group('AdminDashboardScreen', () {
    // ------------------------------------------------------------------
    // Structural rendering
    // ------------------------------------------------------------------
    testWidgets('renders Admin Dashboard heading', (tester) async {
      await tester.pumpApp(const AdminDashboardScreen());
      await tester.pump();
      expect(find.text('Admin Dashboard'), findsOneWidget);
    });

    testWidgets('renders ShopEase Control Panel subtitle', (tester) async {
      await tester.pumpApp(const AdminDashboardScreen());
      await tester.pump();
      expect(find.text('ShopEase Control Panel'), findsOneWidget);
    });

    testWidgets('renders Management section title', (tester) async {
      await tester.pumpApp(const AdminDashboardScreen());
      await tester.pump();
      expect(find.text('Management'), findsOneWidget);
    });

    testWidgets('renders Manage Products card', (tester) async {
      await tester.pumpApp(const AdminDashboardScreen());
      await tester.pump();
      expect(find.text('Manage Products'), findsOneWidget);
    });

    testWidgets('renders Add New Product card', (tester) async {
      await tester.pumpApp(const AdminDashboardScreen());
      await tester.pump();
      expect(find.text('Add New Product'), findsOneWidget);
    });

    testWidgets('renders Manage Orders card', (tester) async {
      await tester.pumpApp(const AdminDashboardScreen());
      await tester.pump();
      expect(find.text('Manage Orders'), findsOneWidget);
    });

    testWidgets('renders Manage Categories card', (tester) async {
      await tester.pumpApp(const AdminDashboardScreen());
      await tester.pump();
      expect(find.text('Manage Categories'), findsOneWidget);
    });

    testWidgets('renders Products stat badge', (tester) async {
      await tester.pumpApp(const AdminDashboardScreen());
      await tester.pump();
      expect(find.text('Products'), findsOneWidget);
    });

    testWidgets('renders Orders stat badge', (tester) async {
      await tester.pumpApp(const AdminDashboardScreen());
      await tester.pump();
      expect(find.text('Orders'), findsOneWidget);
    });

    testWidgets('renders Revenue stat badge', (tester) async {
      await tester.pumpApp(const AdminDashboardScreen());
      await tester.pump();
      expect(find.text('Revenue'), findsOneWidget);
    });

    testWidgets('renders AppBar', (tester) async {
      await tester.pumpApp(const AdminDashboardScreen());
      await tester.pump();
      expect(find.byType(AppBar), findsAtLeast(1));
    });

    testWidgets('renders Scaffold', (tester) async {
      await tester.pumpApp(const AdminDashboardScreen());
      await tester.pump();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Stat values with empty providers
    // ------------------------------------------------------------------
    testWidgets('shows zero count with empty providers', (tester) async {
      await tester.pumpApp(const AdminDashboardScreen());
      await tester.pump();
      // All stats show 0 with empty FakeFirestore
      expect(find.text('0'), findsAtLeast(1));
    });

    // ------------------------------------------------------------------
    // Navigation triggers
    // ------------------------------------------------------------------
    testWidgets('tapping Manage Products navigates', (tester) async {
      final observer = _TestNavigatorObserver();
      await tester.pumpApp(const AdminDashboardScreen(), observers: [observer]);
      await tester.pump();
      await tester.tap(find.text('Manage Products'));
      await tester.pump();
      expect(observer.pushedRoutes.isNotEmpty, isTrue);
    });

    testWidgets('tapping Add New Product navigates', (tester) async {
      final observer = _TestNavigatorObserver();
      await tester.pumpApp(const AdminDashboardScreen(), observers: [observer]);
      await tester.pump();
      await tester.tap(find.text('Add New Product'));
      await tester.pump();
      expect(observer.pushedRoutes.isNotEmpty, isTrue);
    });

    testWidgets('tapping Manage Orders navigates', (tester) async {
      final observer = _TestNavigatorObserver();
      await tester.pumpApp(const AdminDashboardScreen(), observers: [observer]);
      await tester.pump();
      await tester.tap(find.text('Manage Orders'));
      await tester.pump();
      expect(observer.pushedRoutes.isNotEmpty, isTrue);
    });

    testWidgets('tapping Manage Categories navigates', (tester) async {
      final observer = _TestNavigatorObserver();
      await tester.pumpApp(const AdminDashboardScreen(), observers: [observer]);
      await tester.pump();
      await tester.tap(find.text('Manage Categories'));
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
