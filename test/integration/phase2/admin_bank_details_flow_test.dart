import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/admin_flow_helper.dart';
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
    'Admin Bank Details Management Flow: update payment details and verify checkout',
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
        name: 'Bank Customer',
      );
      const bankName = 'Phase Two Bank';
      const accountNumber = '9988776655';
      const accountName = 'ShopEase Phase Two';
      const promptPay = '0998877665';

      await tester.pumpWidget(const TestAppWrapper());
      await tester.waitUntilVisible(find.text('Create New Account'));
      await loginAdminViaUi(
        tester,
        email: admin.email,
        password: admin.password,
      );

      await tester.tapWhenVisible(find.text('Bank & Payment Details'));
      await tester.waitUntilVisible(find.text('Manage Bank Details'));
      await tester.enterText(find.byKey(TestKeys.input('Bank Name')), bankName);
      await tester.enterText(
        find.byKey(TestKeys.input('Account Number')),
        accountNumber,
      );
      await tester.enterText(
        find.byKey(TestKeys.input('Account Name (Company)')),
        accountName,
      );
      await tester.enterText(
        find.byKey(TestKeys.input('PromptPay ID')),
        promptPay,
      );
      await tester.tapWhenVisible(find.text('Save Bank Details'));

      await _waitForBankDetails(
        bankName: bankName,
        accountNumber: accountNumber,
        accountName: accountName,
        promptPayId: promptPay,
      );

      await tester.waitUntilVisible(find.text('Admin Dashboard'));
      await tester.tapWhenVisible(find.text('Bank & Payment Details'));
      await tester.waitUntilVisible(find.text(bankName));
      await tester.waitUntilVisible(find.text(accountNumber));
      await tester.pageBack();
      await logoutAdminViaUi(tester);

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
      await tester.waitUntilVisible(find.text(bankName));
      await tester.waitUntilVisible(find.text(accountNumber));
      await tester.waitUntilVisible(find.text(accountName));
      await tester.waitUntilVisible(find.text(promptPay));
    },
  );
}

Future<void> _waitForBankDetails({
  required String bankName,
  required String accountNumber,
  required String accountName,
  required String promptPayId,
}) async {
  for (var i = 0; i < 40; i++) {
    final doc = await FirebaseFirestore.instance
        .collection('settings')
        .doc('company_info')
        .get();
    final data = doc.data();
    if (data?['bankName'] == bankName &&
        data?['accountNumber'] == accountNumber &&
        data?['accountName'] == accountName &&
        data?['promptPayId'] == promptPayId) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  fail('Timed out waiting for updated bank details');
}
