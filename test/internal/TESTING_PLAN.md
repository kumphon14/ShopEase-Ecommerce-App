# ShopEase System Testing Plan

**Document role:** Supporting planning document for the SEA606 final testing report  
**Project:** ShopEase Flutter E-Commerce Application  
**Status:** Aligned with repository audit on 2026-04-23  
**Master report:** `test/TESTING_REPORT.md`

---

## 1. Purpose

This document describes the planned and implemented testing approach for the ShopEase system. It is now a supporting plan rather than the final evidence report. Current execution evidence, requirement traceability, defects, and final conclusions are consolidated in `test/TESTING_REPORT.md`.

---

## 2. Testing Scope

| Testing layer | Planned role | Current repository status |
|---|---|---|
| Unit testing | Verify isolated models, utilities, provider logic, route constants, and mock/seed data integrity | Implemented and execution verified |
| Widget testing | Verify UI rendering, form validation, interaction, provider-driven screen states, and navigation triggers | Implemented and execution verified |
| Integration testing | Verify real business flows across UI, Provider, navigation, Firebase Auth, and Firestore emulator boundaries | Implemented; local execution not verified in the audit runner |
| Performance testing | Collect workflow timing, error-rate, and efficiency metrics | Structure documented; empirical evidence not found |
| Usability testing | Record workshop/user task results and reflections | Structure documented; empirical evidence not found |
| Security testing | Validate Firebase Security Rules and abuse cases | Out of scope for the current repository evidence |

Order Tracking is intentionally outside the current production scope. The current app exposes Order History, but no production tracking route or integration flow is required.

---

## 3. System Under Test

ShopEase is a Flutter application using:

- `Provider` / `ChangeNotifier` for app state.
- Firebase Auth for customer/admin authentication.
- Cloud Firestore for products, categories, orders, bank details, users, wishlist, and notifications.
- Named routes in `lib/core/routes/app_routes.dart`.
- Customer-facing screens for browsing, cart, checkout, profile, wishlist, and order history.
- Admin screens for login, product, category, order, and bank-detail management.

---

## 4. Testing Pyramid

The planned strategy follows a testing pyramid:

1. **Unit tests** provide the broadest, fastest regression layer for pure logic and provider state behavior.
2. **Widget tests** validate screen/widget behavior with controlled provider dependencies.
3. **Integration tests** validate only the flows that require multiple screens, providers, navigation, and Firebase-backed persistence.

This division prevents integration tests from being used as expensive replacements for unit/widget checks.

---

## 5. Unit Test Plan

### In scope

- Model serialization/deserialization.
- Derived model getters.
- Provider state transitions.
- Validation logic.
- Currency utilities.
- Route constant correctness.
- Mock data and seed-data integrity where testable without backend execution.

### Expected command

```powershell
flutter test test\unit
```

### Current evidence

The audit run passed 235 unit tests with 0 failures and 0 skips.

---

## 6. Widget Test Plan

### In scope

- Authentication/admin login forms.
- Home, category, search, product detail, cart, checkout, profile, wishlist, and admin screens.
- Shared widgets such as product cards, order tiles, custom buttons, custom text fields, and star ratings.
- Navigation triggers and route pushes where widget-level verification is sufficient.

### Expected command

```powershell
flutter test test\widget
```

### Current evidence

The audit run passed 241 widget tests with 0 failures and 0 skips. The command output included non-fatal hit-test warnings for some off-screen taps; these are documented as residual flakiness risk in the master report.

---

## 7. Integration Test Plan

Integration tests should validate true cross-boundary behavior:

```text
UI -> Provider -> Navigation -> Firebase Auth / Firestore emulator -> UI/data assertion
```

### Current production-scope flows

| Flow | Status |
|---|---|
| Customer Auth Flow | Implemented |
| Golden Path: Browse -> Product Detail -> Add to Cart -> Checkout -> Order Creation | Implemented |
| Admin Login Flow | Implemented |
| Admin Product Management Flow | Implemented |
| Admin Order Management Flow | Implemented |
| Admin Category Management Flow | Implemented |
| Admin Bank Details Management Flow | Implemented |
| Wishlist Persistence Flow | Implemented |
| Profile Update Flow | Implemented |

Order Tracking is not part of the current production-scope target.

### Expected commands

```powershell
firebase emulators:start --only auth,firestore
flutter test test\integration\phase1 test\integration\phase2
```

### Current evidence

The integration test files exist, but the audit command timed out locally and did not produce passing integration execution evidence. The integration implementation supplement also records prior local Firebase plugin/platform-channel initialization blockers.

---

## 8. Requirement Mapping Plan

| Requirement | Planned validation layer |
|---|---|
| R1 Authentication | Unit provider tests, widget auth forms, integration customer/admin auth flows |
| R2 Navigation | Widget route/navigation tests, integration multi-screen flows |
| R3 Cross-Platform Execution | CLI commands plus Android/Web execution evidence when available |
| R4 Data Storage | Unit fake Firebase tests plus integration Firestore/Auth emulator assertions |
| R5 CLI Testability | `flutter test` commands for unit, widget, and integration test groups |

---

## 9. Black-Box Test Design Plan

### Equivalence Partitioning

- Valid/invalid authentication input.
- Valid/invalid admin form input.
- Empty/non-empty cart and wishlist states.
- COD/bank-transfer payment options.
- Existing/non-existing Firestore records.

### Boundary Value Analysis

- Password minimum length.
- Cart quantity at 1 and 0.
- Rating bounds of 1.0 and 5.0.
- Empty strings for required form fields.
- Order status first/last/unknown values.

---

## 10. Evidence and Reporting Rules

Documentation must use the following language precisely:

- **Implemented:** test files or logic exist.
- **Executed successfully:** command output confirms pass.
- **Execution attempted but blocked:** command was run but environment/runtime prevented completion.
- **Planned only:** described but not implemented.
- **No direct evidence found:** no repository or command evidence supports the claim.

The final SEA606 report must not convert implemented integration coverage into executed integration coverage unless successful command output is added.

---

## 11. Open Evidence Gaps

- Successful integration-test execution output.
- Android execution evidence.
- Web execution evidence.
- Empirical performance measurements.
- Workshop/usability observation notes.
- Firebase Security Rules test evidence.

---

## 12. Relationship to Other Documents

- `test/TESTING_REPORT.md` is the authoritative final report.
- `test/INTEGRATION_TEST_PLAN.md` provides integration-specific planning detail.
- `test/INTEGRATION_TEST_IMPLEMENTATION_REPORT.md` records integration implementation files, scope, and blockers.
- Admin widget repair documents are historical defect/repair evidence.
