# ShopEase Integration Tests

## Purpose

This folder contains the current production-scope integration tests for ShopEase. The tests are designed to drive the real Flutter UI, Provider graph, named routes, Firebase Auth, and Cloud Firestore through the Firebase Local Emulator Suite.

Current documentation status:

- Test files are implemented for all current production-scope integration flows.
- Successful local execution evidence was not produced during the 2026-04-23 documentation audit because the integration command timed out.
- Order Tracking is intentionally outside the current production scope and is not included.

## Folder Structure

- `helpers/` - app bootstrap, emulator configuration, deterministic seeding, auth/customer/admin flow helpers, stable test keys, and explicit waits.
- `fixtures/` - reference fixture folders for users, products, categories, and payments.
- `phase1/` - initial critical customer/admin paths.
- `phase2/` - remaining current production-scope paths.

## Current Flow Coverage

| Folder | Flow | File |
|---|---|---|
| `phase1/` | Customer Auth | `customer_auth_flow_test.dart` |
| `phase1/` | Golden Path: Browse -> Product Detail -> Add to Cart -> Checkout -> Order Creation | `golden_path_browse_cart_checkout_order_test.dart` |
| `phase1/` | Admin Login | `admin_login_flow_test.dart` |
| `phase1/` | Admin Product Management | `admin_add_product_flow_test.dart` |
| `phase2/` | Admin Order Management | `admin_order_management_flow_test.dart` |
| `phase2/` | Admin Category Management | `admin_category_management_flow_test.dart` |
| `phase2/` | Admin Bank Details Management | `admin_bank_details_flow_test.dart` |
| `phase2/` | Wishlist Persistence | `wishlist_persistence_flow_test.dart` |
| `phase2/` | Profile Update | `profile_update_flow_test.dart` |

## Emulator Assumptions

- Firestore emulator defaults to `localhost:8080`.
- Firebase Auth emulator defaults to `localhost:9099`.
- Android emulator runs should pass `--dart-define=FIREBASE_EMULATOR_HOST=10.0.2.2`.
- The runner must load Flutter plugins correctly for Firebase platform channels.

Start emulators before running integration tests:

```powershell
firebase emulators:start --only auth,firestore
```

## Seeding Strategy

Each test resets known Firestore collections, clears the known wishlist subcollection group, and seeds deterministic baseline catalog/payment data through `helpers/seed_test_data.dart`.

Tests create or reuse Auth emulator accounts by stable email, then rewrite Firestore user documents for deterministic roles and profile data. Seeded orders are written directly to Firestore when a flow requires existing order state.

## Run All Integration Tests

```powershell
flutter test test/integration/phase1 test/integration/phase2
```

## Run Phase 1 Only

```powershell
flutter test test/integration/phase1
```

## Run Phase 2 Only

```powershell
flutter test test/integration/phase2
```

## Android Emulator Example

```powershell
flutter test test/integration/phase1 test/integration/phase2 --dart-define=FIREBASE_EMULATOR_HOST=10.0.2.2
```

## Troubleshooting

- Use `waitUntilVisible` and `tapWhenVisible` instead of arbitrary delays.
- If Firestore-driven UI does not update, confirm the emulator is running and the host/port dart defines match the target device.
- Existing Auth emulator users are reused by email; this is expected during repeated local runs.
- Network images are not assertion targets. Tests assert product/category/order/payment/profile text and Firestore state.
- If `flutter test` reports that the `integration_test` plugin was not detected or Firebase cannot initialize `FirebaseCoreHostApi`, run the suite through a device-backed integration test configuration that loads Flutter plugins for the `test/integration` targets.
- If the command hangs or times out, verify emulator availability, device discovery, Firebase platform-channel initialization, and PowerShell profile behavior separately.

## Current Scope Note

Order Tracking is intentionally outside the current production scope. The production app currently exposes Order History but not an order tracking screen, route, or navigation path, so no integration test is required or included for Order Tracking.
