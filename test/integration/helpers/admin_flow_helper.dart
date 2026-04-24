import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'seed_test_data.dart';
import 'test_keys.dart';
import 'wait_utils.dart';

Future<void> loginAdminViaUi(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  await tester.tapWhenVisible(find.textContaining('Admin Access'));
  await tester.waitUntilVisible(find.byKey(TestKeys.input('Admin Email')));

  await tester.enterText(find.byKey(TestKeys.input('Admin Email')), email);
  await tester.enterText(find.byKey(TestKeys.input('Password')), password);
  await tester.enterText(
    find.byKey(TestKeys.input('Admin Secret Key')),
    testAdminSecretKey,
  );
  await tester.tapWhenVisible(find.text('Access Admin Dashboard'));

  await tester.waitUntilVisible(find.text('Admin Dashboard'));
}

Future<void> logoutAdminViaUi(WidgetTester tester) async {
  await tester.tapWhenVisible(find.byIcon(Icons.logout));
  await tester.waitUntilVisible(find.text('Create New Account'));
}
