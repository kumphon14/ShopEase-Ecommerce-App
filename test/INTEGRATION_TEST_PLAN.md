# ShopEase Integration Test Plan

**Document role:** Supporting integration planning document  
**Project:** ShopEase Flutter E-Commerce Application  
**Status:** Aligned with current production scope on 2026-04-23  
**Master report:** `test/TESTING_REPORT.md`  
**Implementation supplement:** `test/INTEGRATION_TEST_IMPLEMENTATION_REPORT.md`

---

## 1. Purpose

This document defines the integration testing scope, environment assumptions, flow priorities, and acceptance criteria for ShopEase. It is retained as a planning document. Current execution evidence and final SEA606 conclusions are consolidated in `test/TESTING_REPORT.md`.

---

## 2. Integration Testing Objective

Integration tests must validate cross-boundary production behavior:

```text
Flutter UI -> Provider state -> named navigation -> Firebase Auth / Firestore emulator -> UI and data assertions
```

An integration test is not sufficient if it only checks same-screen widget rendering or isolated provider logic.

---

## 3. Current Production-Scope Integration Flows

| Flow | Business purpose | Status |
|---|---|---|
| Customer Auth Flow | Verify signup, logout, login, and entry into the app | Implemented |
| Golden Path: Browse -> Detail -> Cart -> Checkout -> Order Creation | Verify the core shopping and order creation journey | Implemented |
| Admin Login Flow | Verify secret-key, credential, and admin-role access | Implemented |
| Admin Product Management Flow | Verify product creation and catalog reflection | Implemented |
| Admin Order Management Flow | Verify seeded order status updates and persistence | Implemented |
| Admin Category Management Flow | Verify category creation and catalog reflection | Implemented |
| Admin Bank Details Management Flow | Verify payment setting update and checkout reflection | Implemented |
| Wishlist Persistence Flow | Verify wishlist add/remove through Firestore-backed provider path | Implemented |
| Profile Update Flow | Verify supported profile field update and persistence | Implemented |

Order Tracking is intentionally out of current production scope. The current production app has Order History only; no tracking screen, route, or navigation path is required or restored by this plan.

---

## 4. Out of Scope

- Order Tracking integration tests.
- New production features solely for testing.
- Broad production refactors.
- Unit-test-only logic.
- Widget-only visual assertions.
- Performance testing.
- Security rules testing.
- Live production Firebase testing.

---

## 5. Environment Assumptions

The preferred environment is the Firebase Local Emulator Suite:

| Service | Assumed default |
|---|---|
| Firestore emulator | `localhost:8080` |
| Firebase Auth emulator | `localhost:9099` |
| Android emulator host override | `10.0.2.2` via `--dart-define=FIREBASE_EMULATOR_HOST=10.0.2.2` |

The test runner must load Flutter plugins correctly. Local audit execution did not complete successfully, so the integration layer remains implemented but not execution-verified.

---

## 6. Seeding Strategy

Integration tests should start from deterministic data:

- Reset known Firestore collections before each flow.
- Seed products, categories, payment/bank details, and orders where required.
- Create or reuse deterministic Firebase Auth emulator accounts.
- Rewrite Firestore user documents for deterministic customer/admin roles.
- Clear known wishlist subcollections to avoid state leakage.

The implemented helpers under `test/integration/helpers/` provide this structure.

---

## 7. Stability Strategy

Integration tests should:

- Use stable `Key`-based finders where available.
- Use explicit wait helpers for widget and Firestore state transitions.
- Avoid arbitrary sleep-based synchronization.
- Assert both UI outcome and persistence outcome where production behavior supports it.
- Keep each flow isolated by reseeding or cleaning affected test data.

---

## 8. Flow Acceptance Criteria

| Flow | Required evidence in test logic |
|---|---|
| Customer Auth | UI signup/login/logout, Firebase Auth user, Firestore user document, navigation to home/main area |
| Golden Path | Product selection, cart state, checkout submission, order document creation, cart empty state |
| Admin Login | Secret key, credential login, admin role validation, dashboard navigation |
| Admin Product Management | Admin creates product, Firestore document exists, customer catalog reflects product |
| Admin Order Management | Admin updates seeded order, Firestore status changes, customer order history reflects status if exposed |
| Admin Category Management | Admin creates category, Firestore document exists, customer category UI reflects category if exposed |
| Admin Bank Details | Admin updates payment details, Firestore settings update, checkout bank-transfer UI reflects details |
| Wishlist Persistence | Authenticated user adds/removes product, Firestore wishlist subcollection reflects both states |
| Profile Update | Supported profile fields update through UI and persist in Firestore/Auth-backed data |

---

## 9. Execution Commands

```powershell
# Start Firebase emulators
firebase emulators:start --only auth,firestore

# Run all current production-scope integration tests
flutter test test\integration\phase1 test\integration\phase2

# Run initial critical flows only
flutter test test\integration\phase1

# Run remaining current-scope flows only
flutter test test\integration\phase2

# Android emulator example
flutter test test\integration\phase1 test\integration\phase2 --dart-define=FIREBASE_EMULATOR_HOST=10.0.2.2
```

---

## 10. Current Execution Status

During the documentation audit, the all-integration command was attempted but did not complete:

- One run timed out after 300 seconds and printed a PowerShell profile execution-policy warning.
- A no-profile rerun also timed out after 300 seconds with no passing completion output.
- The integration implementation supplement records prior local Firebase plugin/platform-channel initialization blockers.

Therefore, current integration status is:

```text
Implemented but not execution-verified in this local audit environment.
```

---

## 11. Risks and Blockers

- Firebase emulator startup/cleanup must be reliable before CI use.
- Flutter plugin loading must work for the chosen integration runner.
- Auth emulator users may need deterministic reuse because client SDKs do not bulk-delete Auth users from within app tests.
- Firestore streams require explicit waits to avoid race-prone assertions.
- Network images should not be used as assertion targets.

---

## 12. Relationship to Final Report

This plan defines intended integration scope and execution strategy. The final evidence-based status is reported in `test/TESTING_REPORT.md`, while implementation file details and the per-test execution matrix are maintained in `test/INTEGRATION_TEST_IMPLEMENTATION_REPORT.md`.
