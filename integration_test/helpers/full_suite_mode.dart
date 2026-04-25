const bool runFullIntegrationSuites = bool.fromEnvironment(
  'RUN_FULL_INTEGRATION',
  defaultValue: false,
);

const String fullSuiteSkipReason =
    'Full integration suites require Firebase Auth/Firestore emulators and '
    '--dart-define=RUN_FULL_INTEGRATION=true. '
    'The default integration_test run executes the smoke suite only.';
