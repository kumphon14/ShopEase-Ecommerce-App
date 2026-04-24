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
    'Wishlist Persistence Flow: add, verify, remove, and verify Firestore',
    (tester) async {
      await seedPhase1BaseData();
      final customer = await seedAuthUser(
        email: seededCustomerEmail,
        password: testCustomerPassword,
        role: 'customer',
        name: 'Wishlist Customer',
      );

      await tester.pumpWidget(const TestAppWrapper());
      await tester.waitUntilVisible(find.text('Create New Account'));
      await loginCustomerViaUi(
        tester,
        email: customer.email,
        password: customer.password,
      );

      await openSeededProductDetail(tester);
      await tester.tapWhenVisible(
        find.byKey(TestKeys.productDetailWishlist(seededProductId)),
      );

      final uid = FirebaseAuth.instance.currentUser!.uid;
      await _waitForWishlistDoc(uid, seededProductId, exists: true);

      await tester.pageBack();
      await tester.waitUntilVisible(find.text('All Products'));
      await tester.tapWhenVisible(find.byKey(TestKeys.nav('Profile')));
      await tester.tapWhenVisible(find.text('My Wishlist'));
      await tester.waitUntilVisible(find.text('My Wishlist'));
      await tester.waitUntilVisible(
        find.byKey(TestKeys.wishlistProductCard(seededProductId)),
      );
      expect(find.text(seededProductName), findsOneWidget);

      await tester.tapWhenVisible(
        find.byKey(TestKeys.wishlistProductCard(seededProductId)),
      );
      await tester.waitUntilVisible(find.text(seededProductName));
      await tester.tapWhenVisible(
        find.byKey(TestKeys.productDetailWishlist(seededProductId)),
      );
      await _waitForWishlistDoc(uid, seededProductId, exists: false);

      await tester.pageBack();
      await tester.waitUntilVisible(find.text('No saved items yet'));
      expect(find.text(seededProductName), findsNothing);
    },
  );
}

Future<void> _waitForWishlistDoc(
  String uid,
  String productId, {
  required bool exists,
}) async {
  for (var i = 0; i < 40; i++) {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .doc(productId)
        .get();
    if (doc.exists == exists) return;
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  fail('Timed out waiting for wishlist doc $productId exists=$exists');
}
