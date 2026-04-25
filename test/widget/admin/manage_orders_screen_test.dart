// test/widget/admin/manage_orders_screen_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/screens/admin/manage_orders_screen.dart';
import 'package:shopease_ecommerce_app/services/providers/order_provider.dart';

import '../helpers/pump_app.dart';

void main() {
  group('ManageOrdersScreen', () {
    testWidgets('renders tabs and basic structure', (tester) async {
      await tester.pumpApp(const ManageOrdersScreen());
      expect(find.text('Order Management'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Archive'), findsOneWidget);
    });

    testWidgets('shows orders when they exist', (tester) async {
      final firestore = FakeFirebaseFirestore();

      // Make admin user
      await firestore.collection('users').doc('admin_uid').set({
        'role': 'admin',
      });

      final orderProvider = OrderProvider(
        firestore: firestore,
        auth: MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'admin_uid'),
        ),
      );

      await firestore.collection('orders').doc('order_123').set({
        'orderId': 'order_123',
        'items': [],
        'totalAmount': 99.99,
        'date': Timestamp.now(),
        'status': 'Order Placed',
        'isNotificationRead': false,
        'isArchived': false,
        'paymentMethod': 'cod',
        'paymentStatus': 'Pending',
        'customerName': 'Test User',
        'customerId': 'uid_1',
      });

      await tester.pumpApp(const ManageOrdersScreen(), orders: orderProvider);

      await tester.pump(const Duration(milliseconds: 100)); // wait for streams
      await tester.pumpAndSettle();

      expect(find.text('order_123'), findsOneWidget);
    });

    testWidgets('filtering works', (tester) async {
      final firestore = FakeFirebaseFirestore();

      await firestore.collection('users').doc('admin_uid').set({
        'role': 'admin',
      });

      final orderProvider = OrderProvider(
        firestore: firestore,
        auth: MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'admin_uid'),
        ),
      );

      await firestore.collection('orders').doc('order_123').set({
        'orderId': 'order_123',
        'items': [],
        'totalAmount': 99.99,
        'date': Timestamp.now(),
        'status': 'Order Placed',
        'isArchived': false,
      });

      await firestore.collection('orders').doc('order_456').set({
        'orderId': 'order_456',
        'items': [],
        'totalAmount': 50.0,
        'date': Timestamp.now(),
        'status': 'Shipped',
        'isArchived': false,
      });

      await tester.pumpApp(const ManageOrdersScreen(), orders: orderProvider);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Initially shows both
      expect(find.text('order_123'), findsOneWidget);
      expect(find.text('order_456'), findsOneWidget);

      // Tap Shipped filter
      await tester.drag(
        find.text('Shipped (1)').first,
        const Offset(0, 0),
      ); // make sure it's in view
      await tester.tap(find.text('Shipped (1)').first);
      await tester.pumpAndSettle();

      expect(find.text('order_456'), findsOneWidget);
      expect(find.text('order_123'), findsNothing);
    });
  });
}
