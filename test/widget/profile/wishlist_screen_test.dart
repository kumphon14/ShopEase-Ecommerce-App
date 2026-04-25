// test/widget/profile/wishlist_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/screens/profile/wishlist_screen.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WishlistScreen', () {
    // ------------------------------------------------------------------
    // Empty wishlist state (no signed-in user → empty list)
    // ------------------------------------------------------------------
    testWidgets('renders My Wishlist app bar title', (tester) async {
      await tester.pumpApp(const WishlistScreen());
      expect(find.text('My Wishlist'), findsOneWidget);
    });

    testWidgets('renders No saved items yet when wishlist is empty', (
      tester,
    ) async {
      await tester.pumpApp(const WishlistScreen());
      expect(find.text('No saved items yet'), findsOneWidget);
    });

    testWidgets('renders Browse Products button when wishlist is empty', (
      tester,
    ) async {
      await tester.pumpApp(const WishlistScreen());
      expect(find.text('Browse Products'), findsOneWidget);
    });

    testWidgets('does not show Clear button when wishlist is empty', (
      tester,
    ) async {
      await tester.pumpApp(const WishlistScreen());
      expect(find.text('Clear'), findsNothing);
    });

    testWidgets('renders Scaffold', (tester) async {
      await tester.pumpApp(const WishlistScreen());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('renders AppBar', (tester) async {
      await tester.pumpApp(const WishlistScreen());
      expect(find.byType(AppBar), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Navigation
    // ------------------------------------------------------------------
    testWidgets('tapping Browse Products triggers navigation', (tester) async {
      final observer = _TestNavigatorObserver();
      await tester.pumpApp(const WishlistScreen(), observers: [observer]);
      await tester.tap(find.text('Browse Products'));
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
