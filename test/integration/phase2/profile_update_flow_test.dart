import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

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
    'Profile Update Flow: update supported profile fields and verify persistence',
    (tester) async {
      await seedPhase1BaseData();
      final customer = await seedAuthUser(
        email: seededCustomerEmail,
        password: testCustomerPassword,
        role: 'customer',
        name: 'Original Profile Name',
      );
      const updatedName = 'Updated Profile Name';
      const updatedPhone = '+66 88 111 2222';
      const updatedAddress = '456 Updated Integration Road';

      await tester.pumpWidget(const TestAppWrapper());
      await tester.waitUntilVisible(find.text('Create New Account'));
      await loginCustomerViaUi(
        tester,
        email: customer.email,
        password: customer.password,
      );

      await tester.tapWhenVisible(find.byKey(TestKeys.nav('Profile')));
      await tester.waitUntilVisible(find.text('Original Profile Name'));
      await tester.tapWhenVisible(find.text('Edit Profile'));
      await tester.waitUntilVisible(find.text('Edit Profile'));

      await tester.enterText(
        find.byKey(TestKeys.editProfileInput('Full Name')),
        updatedName,
      );
      await tester.enterText(
        find.byKey(TestKeys.editProfileInput('Phone Number')),
        updatedPhone,
      );
      await tester.enterText(
        find.byKey(TestKeys.editProfileInput('Shipping Address')),
        updatedAddress,
      );
      await tester.tapWhenVisible(find.text('Save Changes'));

      final uid = FirebaseAuth.instance.currentUser!.uid;
      await _waitForProfile(
        uid: uid,
        name: updatedName,
        phone: updatedPhone,
        address: updatedAddress,
      );

      await tester.waitUntilVisible(find.text(updatedName));
      expect(find.text(customer.email), findsOneWidget);

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      expect(doc.data()?['name'], updatedName);
      expect(doc.data()?['phone'], updatedPhone);
      expect(doc.data()?['address'], updatedAddress);
    },
  );
}

Future<void> _waitForProfile({
  required String uid,
  required String name,
  required String phone,
  required String address,
}) async {
  for (var i = 0; i < 40; i++) {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final data = doc.data();
    if (data?['name'] == name &&
        data?['phone'] == phone &&
        data?['address'] == address) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  fail('Timed out waiting for updated profile');
}
