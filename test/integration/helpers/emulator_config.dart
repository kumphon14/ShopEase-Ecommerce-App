import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmulatorConfig {
  const EmulatorConfig({
    required this.host,
    required this.firestorePort,
    required this.authPort,
  });

  factory EmulatorConfig.fromEnvironment() {
    return const EmulatorConfig(
      host: String.fromEnvironment(
        'FIREBASE_EMULATOR_HOST',
        defaultValue: 'localhost',
      ),
      firestorePort: int.fromEnvironment(
        'FIRESTORE_EMULATOR_PORT',
        defaultValue: 8080,
      ),
      authPort: int.fromEnvironment(
        'FIREBASE_AUTH_EMULATOR_PORT',
        defaultValue: 9099,
      ),
    );
  }

  final String host;
  final int firestorePort;
  final int authPort;
}

bool _configured = false;

Future<void> configureFirebaseEmulators({
  EmulatorConfig config = const EmulatorConfig(
    host: String.fromEnvironment(
      'FIREBASE_EMULATOR_HOST',
      defaultValue: 'localhost',
    ),
    firestorePort: int.fromEnvironment(
      'FIRESTORE_EMULATOR_PORT',
      defaultValue: 8080,
    ),
    authPort: int.fromEnvironment(
      'FIREBASE_AUTH_EMULATOR_PORT',
      defaultValue: 9099,
    ),
  ),
}) async {
  if (_configured) return;

  FirebaseFirestore.instance.useFirestoreEmulator(
    config.host,
    config.firestorePort,
  );
  await FirebaseAuth.instance.useAuthEmulator(config.host, config.authPort);

  _configured = true;
}
