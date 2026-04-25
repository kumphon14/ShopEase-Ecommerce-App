// test/widget/cart/cart_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/screens/cart/cart_screen.dart';
import 'package:shopease_ecommerce_app/widgets/custom_button.dart';

import '../helpers/fake_providers.dart';
import '../helpers/pump_app.dart';

void main() {
  group('CartScreen', () {
    // ------------------------------------------------------------------
    // Empty cart state
    // ------------------------------------------------------------------
    testWidgets('renders empty cart message when cart is empty', (
      tester,
    ) async {
      await tester.pumpApp(const CartScreen());
      expect(find.text('Your cart is empty'), findsOneWidget);
    });

    testWidgets('renders Continue Shopping button when cart is empty', (
      tester,
    ) async {
      await tester.pumpApp(const CartScreen());
      expect(find.text('Continue Shopping'), findsOneWidget);
    });

    testWidgets('does not show checkout button when cart is empty', (
      tester,
    ) async {
      await tester.pumpApp(const CartScreen());
      expect(
        find.widgetWithText(CustomButton, 'Proceed to Checkout'),
        findsNothing,
      );
    });

    // ------------------------------------------------------------------
    // Non-empty cart state
    // ------------------------------------------------------------------
    testWidgets('renders product name in cart when cart has items', (
      tester,
    ) async {
      final product = makeProduct(name: 'Widget Pro');
      final cart = makeCartProvider([makeCartItem(product: product)]);
      await tester.pumpApp(const CartScreen(), cart: cart);
      expect(find.text('Widget Pro'), findsOneWidget);
    });

    testWidgets('renders Proceed to Checkout button when cart has items', (
      tester,
    ) async {
      final cart = makeCartProvider([makeCartItem()]);
      await tester.pumpApp(const CartScreen(), cart: cart);
      expect(
        find.widgetWithText(CustomButton, 'Proceed to Checkout'),
        findsOneWidget,
      );
    });

    testWidgets('renders Clear All action when cart is not empty', (
      tester,
    ) async {
      final cart = makeCartProvider([makeCartItem()]);
      await tester.pumpApp(const CartScreen(), cart: cart);
      expect(find.text('Clear All'), findsOneWidget);
    });

    testWidgets('renders Shopping Cart app bar title', (tester) async {
      await tester.pumpApp(const CartScreen());
      expect(find.text('Shopping Cart'), findsOneWidget);
    });

    testWidgets('renders quantity controls for cart item', (tester) async {
      final cart = makeCartProvider([makeCartItem()]);
      await tester.pumpApp(const CartScreen(), cart: cart);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
    });

    testWidgets('renders delete icon for cart item', (tester) async {
      final cart = makeCartProvider([makeCartItem()]);
      await tester.pumpApp(const CartScreen(), cart: cart);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Multiple items
    // ------------------------------------------------------------------
    testWidgets('renders multiple cart items', (tester) async {
      final p1 = makeProduct(id: 'p1', name: 'Product A');
      final p2 = makeProduct(id: 'p2', name: 'Product B');
      final cart = makeCartProvider([
        makeCartItem(id: 'ci1', product: p1),
        makeCartItem(id: 'ci2', product: p2),
      ]);
      await tester.pumpApp(const CartScreen(), cart: cart);
      expect(find.text('Product A'), findsOneWidget);
      expect(find.text('Product B'), findsOneWidget);
    });

    testWidgets('shows correct item count in total area', (tester) async {
      final cart = makeCartProvider([
        makeCartItem(
          id: 'ci1',
          product: makeProduct(id: 'p1'),
        ),
      ]);
      await tester.pumpApp(const CartScreen(), cart: cart);
      expect(find.textContaining('item(s)'), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Quantity controls interaction
    // ------------------------------------------------------------------
    testWidgets('tapping increment updates quantity display', (tester) async {
      final cart = makeCartProvider([makeCartItem(quantity: 1)]);
      await tester.pumpApp(const CartScreen(), cart: cart);
      // Quantity starts at 1
      expect(find.text('1'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('2'), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Navigation
    // ------------------------------------------------------------------
    testWidgets('tapping Proceed to Checkout navigates to checkout', (
      tester,
    ) async {
      final observer = _TestNavigatorObserver();
      final cart = makeCartProvider([makeCartItem()]);
      await tester.pumpApp(
        const CartScreen(),
        cart: cart,
        observers: [observer],
      );
      await tester.tap(
        find.widgetWithText(CustomButton, 'Proceed to Checkout'),
      );
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
