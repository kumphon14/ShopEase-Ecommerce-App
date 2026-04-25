# ShopEase Integration Test Plan

**Document role:** Supporting integration planning document  
**Project:** ShopEase Flutter E-Commerce Application  
**Status:** Aligned with current production scope on 2026-04-24  
**Master report:** `test/TESTING_REPORT.md`  
**Implementation supplement:** `test/INTEGRATION_TEST_IMPLEMENTATION_REPORT.md`

---

## 1. Purpose

This document defines the intended integration scope, environment assumptions, and execution strategy for ShopEase. Final evidence and actual execution outcomes are recorded in `test/TESTING_REPORT.md`.

---

## 2. Integration Testing Objective

Integration tests should validate cross-boundary production behavior:

```text
Flutter UI -> Provider state -> named navigation -> Firebase Auth / Firestore -> UI and data assertions
```

---

## 3. Current Production-Scope Integration Flows

- Customer Auth Flow
- Golden Path: Browse -> Detail -> Cart -> Checkout -> Order Creation
- Admin Login Flow
- Admin Product Management Flow
- Admin Order Management Flow
- Admin Category Management Flow
- Admin Bank Details Management Flow
- Wishlist Persistence Flow
- Profile Update Flow

Order Tracking is intentionally out of scope.

---

## 4. Execution Strategy

### Standard Flutter Entry Points

Standard device-backed entry points now live under:

- `integration_test/app_smoke_test.dart`
- `integration_test/phase1_suite_test.dart`
- `integration_test/phase2_suite_test.dart`

### Source Scenario Files

The actual business-flow scenario implementations remain under:

- `test/integration/phase1/`
- `test/integration/phase2/`

### Execution Modes

1. **Smoke mode**
   - verifies plugin loading
   - verifies Firebase initialization
   - verifies app launch and landing
   - can run through `flutter test integration_test -d emulator-5554`

2. **Full emulator-backed business suites**
   - require `RUN_FULL_INTEGRATION=true`
   - require Firebase emulators to already be running
   - execute the existing source scenario files through the standard wrappers

---

## 5. Environment Assumptions

| Item | Assumption |
|---|---|
| Firestore emulator | `localhost:8080` |
| Firebase Auth emulator | `localhost:9099` |
| Android emulator host override | `10.0.2.2` |
| Web smoke runner | `flutter drive` plus WebDriver |

---

## 6. Commands

### Android Smoke

```powershell
flutter test integration_test -d emulator-5554
```

### Full Phase 1

```powershell
firebase emulators:start --only auth,firestore
flutter test integration_test\phase1_suite_test.dart -d emulator-5554 --dart-define=RUN_FULL_INTEGRATION=true --dart-define=FIREBASE_EMULATOR_HOST=10.0.2.2
```

### Full Phase 2

```powershell
firebase emulators:start --only auth,firestore
flutter test integration_test\phase2_suite_test.dart -d emulator-5554 --dart-define=RUN_FULL_INTEGRATION=true --dart-define=FIREBASE_EMULATOR_HOST=10.0.2.2
```

### Chrome Smoke Fallback

```powershell
flutter drive --driver=test_driver\integration_test.dart --target=integration_test\app_smoke_test.dart -d chrome
```

---

## 7. Current Execution Status

- Android smoke path: execution verified
- Standard Android wrappers: execution verified
- Full seeded business-flow suites: implemented, not fully execution-verified in this audit
- Chrome standard command: unsupported by current Flutter toolchain
- Chrome fallback command: requires WebDriver and was blocked in the audit environment

---

## 8. Relationship to Final Report

This plan defines intended strategy only. The final evidence-based position is documented in:

- `test/TESTING_REPORT.md`
- `test/INTEGRATION_TEST_IMPLEMENTATION_REPORT.md`
