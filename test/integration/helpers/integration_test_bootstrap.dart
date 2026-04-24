import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shopease_ecommerce_app/firebase_options.dart';

import 'emulator_config.dart';

void initializeIntegrationTestBinding() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
}

Future<void> bootstrapIntegrationTest() async {
  initializeIntegrationTestBinding();
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  await configureFirebaseEmulators();
}
