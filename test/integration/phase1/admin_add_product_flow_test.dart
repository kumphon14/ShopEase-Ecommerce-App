import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/widgets/custom_button.dart';

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
    'Admin Product Management Flow: add product and verify admin/customer catalogs',
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
        name: 'Catalog Customer',
      );
      const newProductName = 'Integration Admin Product Gamma';

      await tester.pumpWidget(const TestAppWrapper());
      await tester.waitUntilVisible(find.text('Create New Account'));

      await loginAdminViaUi(
        tester,
        email: admin.email,
        password: admin.password,
      );

      await tester.tapWhenVisible(find.text('Manage Products'));
      await tester.waitUntilVisible(find.text('Manage Products'));
      await tester.waitUntilVisible(find.text(seededProductName));
      await tester.pageBack();
      await tester.waitUntilVisible(find.text('Admin Dashboard'));

      await tester.tapWhenVisible(find.text('Add New Product'));
      await tester.waitUntilVisible(find.text('Add Product'));
      await tester.enterText(
        find.byKey(TestKeys.input('Product Name')),
        newProductName,
      );
      await tester.enterText(
        find.byKey(TestKeys.input('Price (USD)')),
        '77.50',
      );
      await tester.enterText(
        find.byKey(TestKeys.input('Description')),
        'Created by the Phase 1 admin integration test.',
      );
      await tester.tapWhenVisible(find.text('Integration Gadgets'));
      await tester.tapWhenVisible(
        find.widgetWithText(CustomButton, 'Add Product'),
      );

      await tester.waitUntilVisible(find.text('Admin Dashboard'));

      final productQuery = await FirebaseFirestore.instance
          .collection('products')
          .where('name', isEqualTo: newProductName)
          .limit(1)
          .get();
      expect(productQuery.docs, isNotEmpty);

      await tester.tapWhenVisible(find.text('Manage Products'));
      await tester.waitUntilVisible(find.text(newProductName));
      await tester.pageBack();
      await logoutAdminViaUi(tester);

      await loginCustomerViaUi(
        tester,
        email: customer.email,
        password: customer.password,
      );
      await tester.waitUntilVisible(find.text('All Products'));
      await tester.waitUntilVisible(find.text(newProductName));
    },
  );
}
