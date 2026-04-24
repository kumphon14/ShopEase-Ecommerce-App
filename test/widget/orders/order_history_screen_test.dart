// test/widget/orders/order_history_screen_test.dart
//
// OrderHistoryScreen widget tests.
// OrderProvider uses Firebase streams; without a signed-in user the
// provider holds an empty list, so all non-empty tests use real Firestore
// seeding via addOrder() called after sign-in.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/screens/orders/order_history_screen.dart';

import '../helpers/fake_providers.dart';
import '../helpers/pump_app.dart';

void main() {
  group('OrderHistoryScreen', () {
    // ------------------------------------------------------------------
    // Empty state (no signed-in user → provider has no orders)
    // ------------------------------------------------------------------
    testWidgets('renders Order History app bar title', (tester) async {
      await tester.pumpApp(const OrderHistoryScreen(), orders: makeOrderProvider());
      expect(find.text('Order History'), findsOneWidget);
    });

    testWidgets('renders no orders message when orders list is empty', (tester) async {
      await tester.pumpApp(const OrderHistoryScreen(), orders: makeOrderProvider());
      expect(find.text('No orders yet'), findsOneWidget);
    });

    testWidgets('renders hint text about orders appearing here', (tester) async {
      await tester.pumpApp(const OrderHistoryScreen(), orders: makeOrderProvider());
      expect(find.textContaining('completed orders will appear'), findsOneWidget);
    });

    testWidgets('renders empty-state icon', (tester) async {
      await tester.pumpApp(const OrderHistoryScreen(), orders: makeOrderProvider());
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
    });

    testWidgets('does not show list view when empty', (tester) async {
      await tester.pumpApp(const OrderHistoryScreen(), orders: makeOrderProvider());
      expect(find.byType(ListView), findsNothing);
    });

    // ------------------------------------------------------------------
    // Structure / layout tests
    // ------------------------------------------------------------------
    testWidgets('renders Scaffold with AppBar', (tester) async {
      await tester.pumpApp(const OrderHistoryScreen(), orders: makeOrderProvider());
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders Scaffold body', (tester) async {
      await tester.pumpApp(const OrderHistoryScreen(), orders: makeOrderProvider());
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
