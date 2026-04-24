import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/auth_test_helper.dart';
import '../helpers/integration_test_bootstrap.dart';
import '../helpers/seed_test_data.dart';
import '../helpers/test_app_wrapper.dart';
import '../helpers/wait_utils.dart';

void main() {
  initializeIntegrationTestBinding();
  setUpAll(bootstrapIntegrationTest);

  testWidgets('Customer Auth Flow: landing to signup, logout, login, and home', (
    tester,
  ) async {
    await seedPhase1BaseData();
    final email =
        'customer.auth.flow.${DateTime.now().microsecondsSinceEpoch}@shopease.test';
    const password = testCustomerPassword;
    const name = 'Customer Auth Flow';

    await tester.pumpWidget(const TestAppWrapper());
    await tester.waitUntilVisible(find.text('Create New Account'));

    await signUpCustomerViaUi(
      tester,
      name: name,
      email: email,
      password: password,
    );

    final signedUpUser = FirebaseAuth.instance.currentUser;
    expect(signedUpUser, isNotNull);
    expect(signedUpUser!.email, email);

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(signedUpUser.uid)
        .get();
    expect(userDoc.exists, isTrue);
    expect(userDoc.data()?['name'], name);
    expect(userDoc.data()?['role'], 'customer');

    await logoutCustomerViaUi(tester);

    await loginCustomerViaUi(tester, email: email, password: password);

    expect(FirebaseAuth.instance.currentUser?.email, email);
    expect(find.text('All Products'), findsOneWidget);
  });
}
