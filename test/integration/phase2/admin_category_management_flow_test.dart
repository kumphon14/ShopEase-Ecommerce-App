import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
    'Admin Category Management Flow: add category and verify admin/customer UI',
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
        name: 'Category Customer',
      );
      const categoryName = 'Integration Cameras';
      const imageUrl = 'https://picsum.photos/seed/integration-cameras/400/400';

      await tester.pumpWidget(const TestAppWrapper());
      await tester.waitUntilVisible(find.text('Create New Account'));
      await loginAdminViaUi(
        tester,
        email: admin.email,
        password: admin.password,
      );

      await tester.tapWhenVisible(find.text('Manage Categories'));
      await tester.waitUntilVisible(find.text('Manage Categories'));
      await tester.tapWhenVisible(find.byIcon(Icons.add));
      await tester.waitUntilVisible(find.text('Add Category'));
      await tester.enterText(
        find.byKey(TestKeys.categoryNameInput),
        categoryName,
      );
      await tester.enterText(
        find.byKey(TestKeys.categoryImageUrlInput),
        imageUrl,
      );
      await tester.tapWhenVisible(find.text('Save'));

      final categoryDocId = await _waitForCategoryByName(categoryName);
      await tester.waitUntilVisible(
        find.byKey(TestKeys.categoryTile(categoryDocId)),
      );
      expect(find.text(categoryName), findsOneWidget);

      await tester.pageBack();
      await logoutAdminViaUi(tester);
      await loginCustomerViaUi(
        tester,
        email: customer.email,
        password: customer.password,
      );
      await tester.tapWhenVisible(find.byKey(TestKeys.nav('Categories')));
      await tester.waitUntilVisible(find.text(categoryName));
    },
  );
}

Future<String> _waitForCategoryByName(String categoryName) async {
  for (var i = 0; i < 40; i++) {
    final snapshot = await FirebaseFirestore.instance
        .collection('categories')
        .where('name', isEqualTo: categoryName)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) return snapshot.docs.first.id;
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  fail('Timed out waiting for category $categoryName');
}
