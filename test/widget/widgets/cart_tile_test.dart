// test/widget/widgets/cart_tile_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/models/cart_item.dart';
import 'package:shopease_ecommerce_app/widgets/cart_tile.dart';

import '../helpers/fake_providers.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: child));

void main() {
  group('CartTile', () {
    CartItem cartItemWith({
      String name = 'Test Product',
      double price = 49.99,
      int quantity = 1,
    }) =>
        makeCartItem(
          product: makeProduct(name: name, price: price),
          quantity: quantity,
        );

    // ------------------------------------------------------------------
    // Rendering
    // ------------------------------------------------------------------
    testWidgets('renders product name', (tester) async {
      await tester.pumpWidget(_wrap(CartTile(
        cartItem: cartItemWith(name: 'Galaxy Phone'),
        onIncrement: () {},
        onDecrement: () {},
        onRemove: () {},
      )));
      expect(find.text('Galaxy Phone'), findsOneWidget);
    });

    testWidgets('renders quantity', (tester) async {
      await tester.pumpWidget(_wrap(CartTile(
        cartItem: cartItemWith(quantity: 3),
        onIncrement: () {},
        onDecrement: () {},
        onRemove: () {},
      )));
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('renders increment icon', (tester) async {
      await tester.pumpWidget(_wrap(CartTile(
        cartItem: cartItemWith(),
        onIncrement: () {},
        onDecrement: () {},
        onRemove: () {},
      )));
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('renders decrement icon', (tester) async {
      await tester.pumpWidget(_wrap(CartTile(
        cartItem: cartItemWith(),
        onIncrement: () {},
        onDecrement: () {},
        onRemove: () {},
      )));
      expect(find.byIcon(Icons.remove), findsOneWidget);
    });

    testWidgets('renders delete icon', (tester) async {
      await tester.pumpWidget(_wrap(CartTile(
        cartItem: cartItemWith(),
        onIncrement: () {},
        onDecrement: () {},
        onRemove: () {},
      )));
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('renders product price', (tester) async {
      await tester.pumpWidget(_wrap(CartTile(
        cartItem: cartItemWith(price: 99.99),
        onIncrement: () {},
        onDecrement: () {},
        onRemove: () {},
      )));
      // CurrencyUtils.format renders the price
      expect(find.textContaining('99'), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Interaction
    // ------------------------------------------------------------------
    testWidgets('calls onIncrement when add icon tapped', (tester) async {
      var incremented = false;
      await tester.pumpWidget(_wrap(CartTile(
        cartItem: cartItemWith(),
        onIncrement: () => incremented = true,
        onDecrement: () {},
        onRemove: () {},
      )));
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(incremented, isTrue);
    });

    testWidgets('calls onDecrement when remove icon tapped', (tester) async {
      var decremented = false;
      await tester.pumpWidget(_wrap(CartTile(
        cartItem: cartItemWith(),
        onIncrement: () {},
        onDecrement: () => decremented = true,
        onRemove: () {},
      )));
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      expect(decremented, isTrue);
    });

    testWidgets('calls onRemove when delete icon tapped', (tester) async {
      var removed = false;
      await tester.pumpWidget(_wrap(CartTile(
        cartItem: cartItemWith(),
        onIncrement: () {},
        onDecrement: () {},
        onRemove: () => removed = true,
      )));
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();
      expect(removed, isTrue);
    });
  });
}
