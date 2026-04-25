# ShopEase Integration Tests

## Purpose

This folder contains the source scenario files, helpers, fixtures, and deterministic seed utilities for the ShopEase integration layer.

The actual Flutter entry points used by the `integration_test` plugin now live under:

- `integration_test/`

That split is intentional:

- `test/integration/` keeps the scenario logic organized by phase
- `integration_test/` provides standard device-backed entry points so Flutter loads the integration plugin correctly

Order Tracking is intentionally outside the current production scope and is not included.

## Execution Structure

- `test/integration/helpers/` - bootstrap, emulator config, seeding, wait helpers, auth/admin/customer helpers, stable keys
- `test/integration/phase1/` - source files for Customer Auth, Golden Path, Admin Login, Admin Product Management
- `test/integration/phase2/` - source files for Admin Order Management, Admin Category Management, Admin Bank Details, Wishlist Persistence, Profile Update
- `integration_test/app_smoke_test.dart` - smoke test that proves plugin loading, Firebase initialization, app launch, splash transition, and landing screen rendering
- `integration_test/phase1_suite_test.dart` - opt-in wrapper for full Phase 1 emulator-backed suites
- `integration_test/phase2_suite_test.dart` - opt-in wrapper for full Phase 2 emulator-backed suites

## Current Flow Coverage

| Flow | Source file |
|---|---|
| Customer Auth | `test/integration/phase1/customer_auth_flow_test.dart` |
| Golden Path: Browse -> Product Detail -> Add to Cart -> Checkout -> Order Creation | `test/integration/phase1/golden_path_browse_cart_checkout_order_test.dart` |
| Admin Login | `test/integration/phase1/admin_login_flow_test.dart` |
| Admin Product Management | `test/integration/phase1/admin_add_product_flow_test.dart` |
| Admin Order Management | `test/integration/phase2/admin_order_management_flow_test.dart` |
| Admin Category Management | `test/integration/phase2/admin_category_management_flow_test.dart` |
| Admin Bank Details Management | `test/integration/phase2/admin_bank_details_flow_test.dart` |
| Wishlist Persistence | `test/integration/phase2/wishlist_persistence_flow_test.dart` |
| Profile Update | `test/integration/phase2/profile_update_flow_test.dart` |

## Emulator Assumptions

- Firestore emulator default: `localhost:8080`
- Firebase Auth emulator default: `localhost:9099`
- Android emulator host override: `10.0.2.2`
- Full business-flow suites require Firebase emulators to already be running

The audit environment did not include `firebase` CLI, so emulator startup was not automated locally.

## Seeding Strategy

The source scenario files use `helpers/seed_test_data.dart` to:

- sign out any existing user
- reset known Firestore collections
- clear the known wishlist collection group
- seed deterministic categories, products, payment settings, and orders
- create or reuse deterministic Auth emulator accounts
- rewrite Firestore user documents for stable roles/profile values

## Standard Android Run

```powershell
flutter test integration_test -d emulator-5554
```

Current verified result:

- smoke integration passed
- standard wrappers loaded correctly
- no `integration_test` plugin detection failure
- no `FirebaseCoreHostApi.initializeCore` startup failure

## Full Phase 1 Android Run

```powershell
flutter test integration_test\phase1_suite_test.dart -d emulator-5554 --dart-define=RUN_FULL_INTEGRATION=true --dart-define=FIREBASE_EMULATOR_HOST=10.0.2.2
```

## Full Phase 2 Android Run

```powershell
flutter test integration_test\phase2_suite_test.dart -d emulator-5554 --dart-define=RUN_FULL_INTEGRATION=true --dart-define=FIREBASE_EMULATOR_HOST=10.0.2.2
```

## Web Notes

For this Flutter toolchain:

```powershell
flutter test integration_test -d chrome
```

is not supported. The tool returns:

```text
Web devices are not supported for integration tests yet.
```

Use `flutter drive` instead:

```powershell
flutter drive --driver=test_driver\integration_test.dart --target=integration_test\app_smoke_test.dart -d chrome
```

That command additionally requires a running WebDriver server such as `chromedriver` on port `4444`.

## Troubleshooting

- If you see `integration_test plugin was not detected`, run the standard files under `integration_test/` on a device-backed target.
- If you see `FirebaseCoreHostApi.initializeCore` failures during startup, confirm you are no longer running the old `test/integration/...` directories directly as plain Flutter tests.
- If the full phase suites hang or time out, check Firebase emulator availability first.
- If Chrome `flutter drive` fails, verify that a compatible WebDriver server is already running.
- Prefer explicit wait helpers over arbitrary delays.

## Current Status Summary

- Android smoke execution: verified
- Full seeded business-flow suites: implemented, opt-in, not fully execution-verified in this audit
- Chrome standard command: blocked by Flutter web limitation
- Chrome `flutter drive`: blocked in this audit because WebDriver was not running
