import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/admin_flow_helper.dart';
import '../helpers/auth_test_helper.dart';
import '../helpers/integration_test_bootstrap.dart';
import '../helpers/seed_test_data.dart';
import '../helpers/test_app_wrapper.dart';
import '../helpers/test_keys.dart';
import '../helpers/wait_utils.dart';

void main() {
  initializeIntegrationTestBinding();
  setUpAll(bootstrapIntegrationTest);

  testWidgets(
    'Admin Order Management Flow: update a seeded pending order status',
    (tester) async {
      await seedPhase1BaseData();
      final admin = await seedAuthUser(
        email: seededAdminEmail,
        password: testAdminPassword,
        role: 'admin',
        name: 'Integration Admin',
      );
      final customer = await seedAuthUser(
        email: seededCustomerEmail,
        password: testCustomerPassword,
        role: 'customer',
        name: 'Order Customer',
      );
      final orderId = await seedPendingOrderForCustomer(
        customerUid: customer.uid,
        customerName: customer.name,
      );

      await tester.pumpWidget(const TestAppWrapper());
      await tester.waitUntilVisible(find.text('Create New Account'));
      await loginAdminViaUi(
        tester,
        email: admin.email,
        password: admin.password,
      );

      await tester.tapWhenVisible(find.text('Manage Orders'));
      await tester.waitUntilVisible(find.text('Order Management'));
      await tester.waitUntilVisible(
        find.byKey(TestKeys.adminOrderCard(orderId)),
      );
      await tester.tapWhenVisible(find.byKey(TestKeys.adminOrderCard(orderId)));
      await tester.tapWhenVisible(
        find.byKey(TestKeys.adminOrderStatus(orderId, 'Confirmed')),
      );

      await _waitForOrderStatus(orderId, 'Confirmed');
      await tester.waitUntilVisible(find.text('Confirmed'));

      final adminOrderDoc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .get();
      expect(adminOrderDoc.data()?['status'], 'Confirmed');

      await tester.pageBack();
      await logoutAdminViaUi(tester);
      await loginCustomerViaUi(
        tester,
        email: customer.email,
        password: customer.password,
      );
      await tester.tapWhenVisible(find.byKey(TestKeys.nav('Profile')));
      await tester.tapWhenVisible(find.text('Order History'));
      await tester.waitUntilVisible(find.text('Order History'));
      await tester.waitUntilVisible(find.byKey(TestKeys.orderTile(orderId)));
      expect(find.text('Confirmed'), findsWidgets);
    },
  );
}

Future<void> _waitForOrderStatus(String orderId, String expectedStatus) async {
  for (var i = 0; i < 40; i++) {
    final doc = await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .get();
    if (doc.data()?['status'] == expectedStatus) return;
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  fail('Timed out waiting for order $orderId status $expectedStatus');
}
