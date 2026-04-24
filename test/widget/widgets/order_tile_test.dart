// test/widget/widgets/order_tile_test.dart
//
// OrderTile renders:
// - 'Order #' + first 8 chars of ID in uppercase
//   e.g. id='order00000001' → 'Order #ORDER000'
// - Payment status as 'Payment: Pending' (not 'Pending' alone)
// - Customer name is NOT rendered by OrderTile (it's in OrderHistoryScreen)
// - Items list: item product name, quantity × price

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/models/order.dart';
import 'package:shopease_ecommerce_app/widgets/order_tile.dart';

import '../helpers/fake_providers.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

void main() {
  group('OrderTile', () {
    // ------------------------------------------------------------------
    // Rendering
    // ------------------------------------------------------------------
    testWidgets('renders Order # prefix with first 8 chars uppercase', (tester) async {
      // 'order00000001'.substring(0, 8) = 'order000' → 'ORDER000'
      final order = makeOrder(id: 'order00000001');
      await tester.pumpWidget(_wrap(OrderTile(order: order)));
      expect(find.textContaining('Order #ORDER000'), findsOneWidget);
    });

    testWidgets('renders order status', (tester) async {
      final order = makeOrder(status: 'Shipped');
      await tester.pumpWidget(_wrap(OrderTile(order: order)));
      expect(find.text('Shipped'), findsOneWidget);
    });

    testWidgets('renders Order Placed status by default', (tester) async {
      final order = makeOrder(status: 'Order Placed');
      await tester.pumpWidget(_wrap(OrderTile(order: order)));
      expect(find.text('Order Placed'), findsOneWidget);
    });

    testWidgets('renders payment method label for COD', (tester) async {
      final order = makeOrder(paymentMethod: PaymentMethod.cod);
      await tester.pumpWidget(_wrap(OrderTile(order: order)));
      expect(find.text('Cash on Delivery'), findsOneWidget);
    });

    testWidgets('renders payment method label for bank transfer', (tester) async {
      final order = makeOrder(paymentMethod: PaymentMethod.bankTransfer);
      await tester.pumpWidget(_wrap(OrderTile(order: order)));
      expect(find.text('Bank Transfer'), findsOneWidget);
    });

    testWidgets('renders payment status as Payment: Pending chip', (tester) async {
      // Payment status renders as 'Payment: Pending' inside an _InfoChip
      final order = makeOrder(paymentStatus: 'Pending');
      await tester.pumpWidget(_wrap(OrderTile(order: order)));
      expect(find.text('Payment: Pending'), findsOneWidget);
    });

    testWidgets('renders item count text', (tester) async {
      final order = makeOrder(items: [makeCartItem()]);
      await tester.pumpWidget(_wrap(OrderTile(order: order)));
      expect(find.text('1 item(s)'), findsOneWidget);
    });

    testWidgets('renders total amount', (tester) async {
      final order = makeOrder(totalAmount: 149.99);
      await tester.pumpWidget(_wrap(OrderTile(order: order)));
      expect(find.textContaining('149'), findsOneWidget);
    });

    testWidgets('renders order date month abbreviation', (tester) async {
      final order = makeOrder();
      await tester.pumpWidget(_wrap(OrderTile(order: order)));
      // Date is Jan 15, 2024
      expect(find.textContaining('Jan'), findsOneWidget);
    });

    testWidgets('renders product name from items', (tester) async {
      final product = makeProduct(name: 'Widget X');
      final order = makeOrder(items: [makeCartItem(product: product)]);
      await tester.pumpWidget(_wrap(OrderTile(order: order)));
      expect(find.textContaining('Widget X'), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Tap callback
    // ------------------------------------------------------------------
    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      final order = makeOrder();
      await tester.pumpWidget(
        _wrap(OrderTile(order: order, onTap: () => tapped = true)),
      );
      await tester.tap(find.byType(InkWell).first);
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('does not crash when onTap is null', (tester) async {
      final order = makeOrder();
      await tester.pumpWidget(_wrap(OrderTile(order: order)));
      await tester.tap(find.byType(InkWell).first, warnIfMissed: false);
      await tester.pump();
      expect(find.byType(OrderTile), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Step progress indicator
    // ------------------------------------------------------------------
    testWidgets('renders step progress text', (tester) async {
      final order = makeOrder(status: 'Order Placed');
      await tester.pumpWidget(_wrap(OrderTile(order: order)));
      expect(find.textContaining('Step'), findsOneWidget);
    });

    testWidgets('renders LinearProgressIndicator', (tester) async {
      final order = makeOrder();
      await tester.pumpWidget(_wrap(OrderTile(order: order)));
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
