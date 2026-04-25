import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/integration/phase1/admin_add_product_flow_test.dart'
    as admin_add_product_flow;
import '../test/integration/phase1/admin_login_flow_test.dart'
    as admin_login_flow;
import '../test/integration/phase1/customer_auth_flow_test.dart'
    as customer_auth_flow;
import '../test/integration/phase1/golden_path_browse_cart_checkout_order_test.dart'
    as golden_path_flow;
import 'helpers/full_suite_mode.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  if (!runFullIntegrationSuites) {
    testWidgets(
      'Phase 1 emulator-backed integration suite is opt-in',
      (tester) async {},
      skip: true,
    );
    return;
  }

  customer_auth_flow.main();
  golden_path_flow.main();
  admin_login_flow.main();
  admin_add_product_flow.main();
}
