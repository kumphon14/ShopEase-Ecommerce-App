import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'seed_test_data.dart';
import 'test_keys.dart';
import 'wait_utils.dart';

Future<void> openSeededProductDetail(WidgetTester tester) async {
  await tester.waitUntilVisible(
    find.byKey(TestKeys.productCard(seededProductId)),
  );
  await tester.tap(find.byKey(TestKeys.productCard(seededProductId)));
  await tester.waitUntilVisible(find.text(seededProductName));
}

Future<void> addCurrentProductToCart(WidgetTester tester) async {
  await tester.tapWhenVisible(find.text('Add to Cart'));
  await tester.tapWhenVisible(find.text('View Cart'));
  await tester.waitUntilVisible(find.text('Shopping Cart'));
  await tester.waitUntilVisible(find.text(seededProductName));
}

Future<String> latestOrderIdForCurrentUser(String uid) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('orders')
      .where('customerId', isEqualTo: uid)
      .get();

  expect(snapshot.docs, isNotEmpty);
  final docs = snapshot.docs.toList()
    ..sort((a, b) {
      final aDate = a.data()['date'] as Timestamp?;
      final bDate = b.data()['date'] as Timestamp?;
      return (bDate?.millisecondsSinceEpoch ?? 0).compareTo(
        aDate?.millisecondsSinceEpoch ?? 0,
      );
    });
  return docs.first.id;
}

Future<void> fillShippingDetails(WidgetTester tester) async {
  await tester.enterText(
    find.byKey(TestKeys.input('Full Name')),
    'Test Shopper',
  );
  await tester.enterText(
    find.byKey(TestKeys.input('Address')),
    '123 Integration Street',
  );
  await tester.enterText(find.byKey(TestKeys.input('City')), 'Bangkok');
  await tester.enterText(
    find.byKey(TestKeys.input('Phone Number')),
    '+66 81 234 5678',
  );
}
