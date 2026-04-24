import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/auth_test_helper.dart';
import '../helpers/customer_flow_helper.dart';
import '../helpers/integration_test_bootstrap.dart';
import '../helpers/seed_test_data.dart';
import '../helpers/test_app_wrapper.dart';
import '../helpers/test_keys.dart';
import '../helpers/wait_utils.dart';

void main() {
  initializeIntegrationTestBinding();
  setUpAll(bootstrapIntegrationTest);

  testWidgets(
    'Golden Path: browse, cart, checkout, order history, and empty cart',
    (tester) async {
      await seedPhase1BaseData();
      final customer = await seedAuthUser(
        email: seededCustomerEmail,
        password: testCustomerPassword,
        role: 'customer',
        name: 'Golden Path Customer',
      );

      await tester.pumpWidget(const TestAppWrapper());
      await tester.waitUntilVisible(find.text('Create New Account'));
      await loginCustomerViaUi(
        tester,
        email: customer.email,
        password: customer.password,
      );

      await openSeededProductDetail(tester);
      await addCurrentProductToCart(tester);

      await tester.tapWhenVisible(find.text('Proceed to Checkout'));
      await tester.waitUntilVisible(find.text('Checkout'));
      await fillShippingDetails(tester);

      await tester.tapWhenVisible(find.text('Bank Transfer'));
      await tester.waitUntilVisible(find.text('Integration Test Bank'));
      expect(find.text('1234567890'), findsOneWidget);

      await tester.tapWhenVisible(find.text('Place Order'));
      await tester.waitUntilVisible(find.text('No Proof Attached'));
      await tester.tapWhenVisible(find.text('Continue'));
      await tester.waitUntilVisible(find.textContaining('Order Placed'));
      await tester.tapWhenVisible(find.text('Back to Home'));
      await tester.waitUntilVisible(find.text('All Products'));

      final uid = FirebaseAuth.instance.currentUser!.uid;
      final orderId = await latestOrderIdForCurrentUser(uid);
      final orderDoc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .get();
      expect(orderDoc.exists, isTrue);
      expect(orderDoc.data()?['paymentMethod'], 'bankTransfer');
      expect(orderDoc.data()?['status'], 'Order Placed');

      await tester.tapWhenVisible(find.byKey(TestKeys.nav('Profile')));
      await tester.tapWhenVisible(find.text('Order History'));
      await tester.waitUntilVisible(find.text('Order History'));
      await tester.waitUntilVisible(find.text(seededProductName));
      expect(find.byKey(TestKeys.orderTile(orderId)), findsOneWidget);

      await tester.pageBack();
      await tester.waitUntilVisible(find.text('My Account'));
      await tester.tapWhenVisible(find.byKey(TestKeys.nav('Home')));
      await tester.tapWhenVisible(find.byKey(TestKeys.homeCartButton));
      await tester.waitUntilVisible(find.text('Your cart is empty'));
    },
  );
}
