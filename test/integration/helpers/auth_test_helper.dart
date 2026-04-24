import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_keys.dart';
import 'wait_utils.dart';

Future<void> signUpCustomerViaUi(
  WidgetTester tester, {
  required String name,
  required String email,
  required String password,
}) async {
  await tester.tapWhenVisible(find.text('Create New Account'));
  await tester.waitUntilVisible(find.byKey(TestKeys.input('Full Name')));

  await tester.enterText(find.byKey(TestKeys.input('Full Name')), name);
  await tester.enterText(find.byKey(TestKeys.input('Email Address')), email);
  await tester.enterText(find.byKey(TestKeys.input('Password')), password);
  await tester.enterText(
    find.byKey(TestKeys.input('Confirm Password')),
    password,
  );
  await tester.tapWhenVisible(find.text('Create Account'));

  await tester.waitUntilVisible(find.text('All Products'));
}

Future<void> loginCustomerViaUi(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  await tester.tapWhenVisible(find.text('Login to Your Account'));
  await tester.waitUntilVisible(find.byKey(TestKeys.input('Email Address')));

  await tester.enterText(find.byKey(TestKeys.input('Email Address')), email);
  await tester.enterText(find.byKey(TestKeys.input('Password')), password);
  await tester.tapWhenVisible(find.text('Login'));

  await tester.waitUntilVisible(find.text('All Products'));
}

Future<void> logoutCustomerViaUi(WidgetTester tester) async {
  await tester.tapWhenVisible(find.byKey(TestKeys.nav('Profile')));
  await tester.tapWhenVisible(find.text('Sign Out'));
  await tester.waitUntilVisible(find.text('Create New Account'));
  expect(FirebaseAuth.instance.currentUser, isNull);
}
