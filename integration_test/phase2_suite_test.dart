import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/integration/phase2/admin_bank_details_flow_test.dart'
    as admin_bank_details_flow;
import '../test/integration/phase2/admin_category_management_flow_test.dart'
    as admin_category_flow;
import '../test/integration/phase2/admin_order_management_flow_test.dart'
    as admin_order_flow;
import '../test/integration/phase2/profile_update_flow_test.dart'
    as profile_update_flow;
import '../test/integration/phase2/wishlist_persistence_flow_test.dart'
    as wishlist_flow;
import 'helpers/full_suite_mode.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  if (!runFullIntegrationSuites) {
    testWidgets(
      'Phase 2 emulator-backed integration suite is opt-in',
      (tester) async {},
      skip: true,
    );
    return;
  }

  admin_order_flow.main();
  admin_category_flow.main();
  admin_bank_details_flow.main();
  wishlist_flow.main();
  profile_update_flow.main();
}
