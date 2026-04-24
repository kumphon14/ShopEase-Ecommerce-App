import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/admin_flow_helper.dart';
import '../helpers/integration_test_bootstrap.dart';
import '../helpers/seed_test_data.dart';
import '../helpers/test_app_wrapper.dart';
import '../helpers/wait_utils.dart';

void main() {
  initializeIntegrationTestBinding();
  setUpAll(bootstrapIntegrationTest);

  testWidgets(
    'Admin Login Flow: secret key and credentials open admin dashboard',
    (tester) async {
      await seedPhase1BaseData();
      final admin = await seedAuthUser(
        email: seededAdminEmail,
        password: testAdminPassword,
        role: 'admin',
        name: 'Integration Admin',
      );

      await tester.pumpWidget(const TestAppWrapper());
      await tester.waitUntilVisible(find.text('Create New Account'));

      await loginAdminViaUi(
        tester,
        email: admin.email,
        password: admin.password,
      );

      expect(FirebaseAuth.instance.currentUser?.email, admin.email);
      expect(find.text('Management'), findsOneWidget);
      expect(find.text('Manage Products'), findsOneWidget);
    },
  );
}
