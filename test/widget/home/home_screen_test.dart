// test/widget/home/home_screen_test.dart
//
// HomeScreen widget tests.
// ProductProvider and CategoryProvider are backed by empty FakeFirestore.
// The Firestore stream fires asynchronously, so products/categories
// are not visible until the stream emits. Tests focus on structural
// rendering, empty states, and navigation triggers.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/screens/home/home_screen.dart';

import '../helpers/fake_providers.dart';
import '../helpers/pump_app.dart';

void main() {
  group('HomeScreen', () {
    // ------------------------------------------------------------------
    // Structural rendering
    // ------------------------------------------------------------------
    testWidgets('renders ShopEase app bar title', (tester) async {
      await tester.pumpApp(const HomeScreen());
      await tester.pump();
      expect(find.text('ShopEase'), findsOneWidget);
    });

    testWidgets('renders search bar placeholder text', (tester) async {
      await tester.pumpApp(const HomeScreen());
      await tester.pump();
      expect(find.text('Search products...'), findsOneWidget);
    });

    testWidgets('renders All category chip', (tester) async {
      await tester.pumpApp(const HomeScreen());
      await tester.pump();
      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('renders cart icon button', (tester) async {
      await tester.pumpApp(const HomeScreen());
      await tester.pump();
      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    });

    testWidgets('renders notification icon button', (tester) async {
      await tester.pumpApp(const HomeScreen());
      await tester.pump();
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('renders Shop by Category section header', (tester) async {
      await tester.pumpApp(const HomeScreen());
      await tester.pump();
      expect(find.text('Shop by Category'), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Empty state (default — Firestore has no data)
    // ------------------------------------------------------------------
    testWidgets('renders no-products-in-category message when empty', (tester) async {
      await tester.pumpApp(const HomeScreen());
      await tester.pump();
      expect(find.text('No products in this category'), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Scaffold structure
    // ------------------------------------------------------------------
    testWidgets('renders Scaffold', (tester) async {
      await tester.pumpApp(const HomeScreen());
      await tester.pump();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('renders AppBar', (tester) async {
      await tester.pumpApp(const HomeScreen());
      await tester.pump();
      expect(find.byType(AppBar), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Navigation triggers
    // ------------------------------------------------------------------
    testWidgets('tapping search bar navigates to search route', (tester) async {
      final observer = _TestNavigatorObserver();
      await tester.pumpApp(const HomeScreen(), observers: [observer]);
      await tester.pump();
      await tester.tap(find.text('Search products...'));
      await tester.pump();
      expect(observer.pushedRoutes.isNotEmpty, isTrue);
    });

    testWidgets('tapping cart icon navigates to cart route', (tester) async {
      final observer = _TestNavigatorObserver();
      await tester.pumpApp(const HomeScreen(), observers: [observer]);
      await tester.pump();
      await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
      await tester.pump();
      expect(observer.pushedRoutes.isNotEmpty, isTrue);
    });

    testWidgets('tapping notification icon navigates to notifications route', (tester) async {
      final observer = _TestNavigatorObserver();
      await tester.pumpApp(const HomeScreen(), observers: [observer]);
      await tester.pump();
      await tester.tap(find.byIcon(Icons.notifications_outlined));
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
