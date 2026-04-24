# SEA606 Modern Software Testing Final Testing Report

**Course:** SEA606 Modern Software Testing  
**Project:** ShopEase - Cross-Platform Mobile Application  
**Technology Context:** Flutter + Provider + Firebase Auth + Cloud Firestore  
**Submission Context:** PDF Report + GitHub Repository Link  
**Audit Date:** 2026-04-23  
**Evidence Rule:** This report distinguishes implemented tests from execution-verified tests. It does not claim successful execution without command output or repository evidence.

---

## 1. Overview

ShopEase is a Flutter e-commerce application with customer shopping features and an admin management portal. The project includes unit tests, widget tests, and an implemented integration testing layer under `test/integration/`.

This document is the master final testing report for the SEA606 assignment. Supporting planning and integration-specific evidence are maintained in:

- `test/TESTING_PLAN.md`
- `test/INTEGRATION_TEST_PLAN.md`
- `test/INTEGRATION_TEST_IMPLEMENTATION_REPORT.md`
- `test/integration/README.md`
- `test/ADMIN_WIDGET_TEST_REPAIR_PLAN.md`
- `test/ADMIN_WIDGET_TEST_REPAIR_TASK.md`

---

## 2. Objective

The objective is to document the system-wide testing strategy, implementation status, execution evidence, requirement traceability, known defects, and remaining risks for ShopEase. The report covers:

- Unit testing for model, utility, provider, routing, and mock-data behavior.
- Widget testing for UI rendering, validation, navigation triggers, and provider-driven screen states.
- Integration testing for production-scope user and admin flows through UI, Provider, navigation, Firebase Auth, and Firestore emulator boundaries.
- Requirement validation for R1-R5.
- CLI reproducibility for grading and future regression testing.

---

## 3. Project Testing Scope

| Layer | Current implementation status | Current execution status | Evidence |
|---|---|---|---|
| Unit testing | Implemented | Executed successfully | `flutter test test\unit` passed 235 tests |
| Widget testing | Implemented | Executed successfully | `flutter test test\widget` passed 241 tests |
| Integration testing | Implemented | Execution attempted but blocked/timed out locally | `test/integration/phase1` and `test/integration/phase2` exist; local command timed out |
| Performance testing | Report structure only | No direct empirical evidence found | Metrics section is template-ready |
| Usability testing | Report structure only | No direct empirical evidence found | Workshop/usability sections are template-ready |
| Security testing | Out of scope | Not executed | Firebase Security Rules testing is not evidenced |

Order Tracking is intentionally outside the current production scope. It is not required for integration completion and was not restored or reintroduced.

---

## 4. Overview and Execution Commands

The following commands were used during the documentation audit.

| Purpose | Command | Result |
|---|---|---|
| Unit tests | `flutter test test\unit` | Passed: `+235`, failed: `0`, skipped: `0` |
| Widget tests | `flutter test test\widget` | Passed: `+241`, failed: `0`, skipped: `0`; hit-test warnings were printed for some off-screen tap cases |
| Integration tests | `flutter test test\integration\phase1 test\integration\phase2` | Attempted; first run timed out after 300 seconds with PowerShell profile policy noise; second no-profile run timed out after 300 seconds with no useful Flutter completion output |
| Device discovery | `flutter devices` | Attempted; timed out after 120 seconds in this audit shell |

Recommended reproducible commands:

```powershell
# Dependencies
flutter pub get

# Unit tests
flutter test test\unit

# Widget tests
flutter test test\widget

# Integration tests, after Firebase emulators and device-backed runner are ready
firebase emulators:start --only auth,firestore
flutter test test\integration\phase1 test\integration\phase2

# Phase-specific integration runs
flutter test test\integration\phase1
flutter test test\integration\phase2
```

For Android emulator integration runs, the integration README documents:

```powershell
flutter test test\integration\phase1 test\integration\phase2 --dart-define=FIREBASE_EMULATOR_HOST=10.0.2.2
```

---

## 5. Testing Strategy

### 5.1 Testing Pyramid

ShopEase follows a layered testing-pyramid approach:

| Pyramid level | Role in ShopEase | Evidence |
|---|---|---|
| Unit tests | Fast verification of models, utilities, route constants, mock data, and provider business logic in isolation | 235 tests executed successfully |
| Widget tests | UI-level verification of screens, forms, navigation triggers, and provider-driven rendering without requiring a real backend | 241 tests executed successfully |
| Integration tests | End-to-end flow verification across UI, Provider, navigation, Firebase Auth, and Firestore emulator boundaries | 9 production-scope flow files implemented; local execution blocked/timed out |

The pyramid is appropriate for this project because most business rules can be checked quickly at unit level, while UI behavior is isolated at widget level. Integration tests are reserved for cross-boundary workflows where Firebase-backed persistence and navigation continuity must be proven together.

### 5.2 Black-Box Focus

The tests validate observable behavior through inputs, actions, and expected outputs. Examples include form validation, login outcomes, cart totals, order creation, admin CRUD effects, and persisted Firestore state.

---

## 6. Requirements to Be Validated

| Requirement | Description | Validation expectation |
|---|---|---|
| R1 Authentication | Customer signup/login/logout and admin authentication are testable | Unit provider tests, widget auth tests, integration auth/admin login flows |
| R2 Navigation | Main customer/admin navigation paths are testable | Widget navigation tests and integration flow transitions |
| R3 Cross-Platform Execution | Tests can be executed from CLI and should support target platform execution | CLI commands documented; current Android/Web execution evidence is limited |
| R4 Data Storage | Firebase Auth and Cloud Firestore-backed persistence is testable | Unit tests use fakes; integration tests are implemented against emulator assumptions |
| R5 CLI Testability | Test suites can be run from command line | Unit/widget commands executed successfully; integration command documented but locally blocked/timed out |

Local storage is not directly evidenced in the reviewed repository documentation. R4 evidence is therefore limited to Firebase Auth, Cloud Firestore, and in-memory provider state where applicable.

---

## 7. Requirements Traceability Matrix

| Requirement | Test files / flows | Command / evidence | Current status |
|---|---|---|---|
| R1 Authentication | `test/unit/providers/auth_provider_test.dart`, `test/widget/auth/*`, `test/integration/phase1/customer_auth_flow_test.dart`, `test/integration/phase1/admin_login_flow_test.dart` | Unit/widget passed; integration implemented but local execution timed out | Partially execution verified |
| R2 Navigation | `test/widget/home/home_screen_test.dart`, `test/widget/widgets/product_card_test.dart`, `test/widget/auth/*`, integration phase1/phase2 flow navigation | Widget passed; integration implemented | Partially execution verified |
| R3 Cross-Platform Execution | CLI commands, integration README Android command | `flutter devices` timed out during audit; no direct Android/Web pass evidence found | Evidence limited |
| R4 Data Storage | Provider unit tests with fake Firebase, integration Firestore/Auth assertions in phase1/phase2 files | Unit passed; integration implemented with Firestore/Auth assertions but runtime blocked/timed out | Partially execution verified |
| R5 CLI Testability | `flutter test test\unit`, `flutter test test\widget`, documented integration commands | Unit/widget passed from CLI; integration CLI attempted but did not complete | Partially execution verified |

---

## 8. Black-Box Test Design

### 8.1 Equivalence Partitioning

| Feature | Valid partitions | Invalid partitions | Evidence |
|---|---|---|---|
| Authentication forms | Valid email/password/customer fields | Empty fields, malformed email, weak password, mismatched confirmation | Unit/widget auth tests |
| Cart quantity | Positive quantity, duplicate product addition | Zero or negative quantity removes/no-ops as designed | Unit cart provider tests |
| Payment selection | Cash on Delivery, Bank Transfer | Missing required checkout fields | Widget checkout tests; integration bank-details flow implemented |
| Admin product/category forms | Complete valid input | Empty required fields, invalid price | Widget admin tests; integration admin add product/category flows implemented |
| Wishlist | Authenticated user toggles product | Unauthenticated mutation no-op | Unit/widget/provider evidence; integration wishlist flow implemented |

### 8.2 Boundary Value Analysis

| Area | Boundary | Evidence |
|---|---|---|
| Password validation | Minimum length boundary around 6 characters | Unit/widget auth tests |
| Product rating | Valid rating range 1.0-5.0 | Unit model/provider/mock-data tests |
| Cart quantity | Quantity `1`, quantity update to `0`, negative quantity | Unit cart provider tests |
| Price formatting | Zero, positive decimal, larger currency values | Unit currency utility tests |
| Order status index | First status, last status, unknown status fallback | Unit order model/provider tests |

---

## 9. Unit Test Report

| Item | Status |
|---|---|
| Test directory | `test/unit/` |
| Dart test files inventoried | 16 |
| Execution command | `flutter test test\unit` |
| Result | 235 passed, 0 failed, 0 skipped |
| Confidence | Execution verified |

Unit tests cover models, providers, utilities, mock data, route constants, and isolated business rules. Firebase-dependent provider behavior is tested using fake/mock dependencies rather than live backend services.

Limitations:

- Unit tests do not prove real Firebase platform-channel behavior.
- Unit tests do not verify complete UI navigation flows.
- Firestore emulator behavior is deferred to integration testing.

---

## 10. Widget Test Report

| Item | Status |
|---|---|
| Test directory | `test/widget/` |
| Dart test files inventoried | 29 |
| Execution command | `flutter test test\widget` |
| Result | 241 passed, 0 failed, 0 skipped |
| Confidence | Execution verified with warnings |

Widget tests cover authentication screens, home/catalog screens, cart and checkout screens, profile/wishlist screens, search, admin screens, and shared widgets.

Residual risk:

- The widget run printed hit-test warnings for some taps targeting widgets outside the default 800x600 root bounds. These warnings did not fail the run, but they should be treated as flakiness risk if hit-test warnings are made fatal in future CI configuration.

---

## 11. Integration Test Report

### 11.1 Integration Scope

The current production-scope integration coverage consists of nine flows:

1. Customer Auth Flow
2. Golden Path: Browse -> Product Detail -> Add to Cart -> Checkout -> Order Creation
3. Admin Login Flow
4. Admin Product Management Flow
5. Admin Order Management Flow
6. Admin Category Management Flow
7. Admin Bank Details Management Flow
8. Wishlist Persistence Flow
9. Profile Update Flow

Order Tracking is intentionally out of current production scope and is not counted as missing coverage.

### 11.2 Integration Implementation Evidence

| File path | Flow | Evidence in file | Status |
|---|---|---|---|
| `test/integration/phase1/customer_auth_flow_test.dart` | Customer Auth | UI signup/logout/login/home flow with Firebase Auth/Firestore user expectations | Implemented; not execution-verified in this audit |
| `test/integration/phase1/golden_path_browse_cart_checkout_order_test.dart` | Golden Path | Product detail, cart, checkout, order creation, cart empty checks | Implemented; not execution-verified in this audit |
| `test/integration/phase1/admin_login_flow_test.dart` | Admin Login | Secret key, credentials, admin role, dashboard navigation | Implemented; not execution-verified in this audit |
| `test/integration/phase1/admin_add_product_flow_test.dart` | Admin Product Management | Admin add product with Firestore/customer catalog verification | Implemented; not execution-verified in this audit |
| `test/integration/phase2/admin_order_management_flow_test.dart` | Admin Order Management | Seeded order status update, Firestore status assertion, customer order history reflection | Implemented; not execution-verified in this audit |
| `test/integration/phase2/admin_category_management_flow_test.dart` | Admin Category Management | Add category, Firestore lookup, admin/customer UI reflection | Implemented; not execution-verified in this audit |
| `test/integration/phase2/admin_bank_details_flow_test.dart` | Admin Bank Details | Update bank details, Firestore assertion, checkout bank-transfer reflection | Implemented; not execution-verified in this audit |
| `test/integration/phase2/wishlist_persistence_flow_test.dart` | Wishlist Persistence | Add/remove wishlist product with Firestore subcollection checks | Implemented; not execution-verified in this audit |
| `test/integration/phase2/profile_update_flow_test.dart` | Profile Update | Edit profile fields with Firestore and profile UI assertions | Implemented; not execution-verified in this audit |

### 11.3 Integration Execution Evidence

The integration command was attempted in this audit:

```powershell
flutter test test\integration\phase1 test\integration\phase2
```

Result:

- First attempt timed out after 300 seconds and printed a PowerShell profile execution-policy warning.
- Second no-profile attempt timed out after 300 seconds with no successful test completion output.
- Existing integration supplement also records a previous local Firebase platform-channel/plugin initialization blocker (`FirebaseCoreHostApi.initializeCore` / `integration_test` plugin detection). That earlier evidence is treated as project-local blocker evidence, not as a passing run.

Conclusion: integration tests are implemented, but no successful integration execution evidence was found during this audit.

---

## 12. Cross-Platform Evidence

| Target | Evidence found | Status |
|---|---|---|
| Android | Integration README provides Android emulator host command; no current successful Android run output found | No direct execution evidence found |
| Web | No current successful web test run output found | No direct execution evidence found |
| Host Flutter test runner | Unit and widget tests executed successfully through CLI | Execution verified for unit/widget only |

Cross-platform claims should remain conservative until Android/Web command output is added as repository evidence.

---

## 13. Performance and Usability Metrics

No empirical performance or usability measurement logs were found in the repository at the time of audit. The following structure is template-ready and awaiting empirical insertion.

| Metric | Definition | Current evidence status |
|---|---|---|
| Task Success Rate | Percentage of users completing assigned tasks | Awaiting empirical insertion |
| Time-on-Task | Time required to complete key workflows | Awaiting empirical insertion |
| Error Rate | Frequency of user mistakes or failed task attempts | Awaiting empirical insertion |
| Efficiency | Completion time and action count compared with expected path | Awaiting empirical insertion |
| Learnability | Improvement between first and repeated task attempts | Awaiting empirical insertion |

---

## 14. Performance Dashboard

| Workflow | Target metric | Measured value | Evidence status |
|---|---|---|---|
| Customer signup/login | Task success, time-on-task | To be filled | Not evidenced in repository |
| Browse -> checkout -> order | Task success, time-on-task, error rate | To be filled | Not evidenced in repository |
| Admin add product | Task success, time-on-task | To be filled | Not evidenced in repository |
| Wishlist add/remove | Task success, error rate | To be filled | Not evidenced in repository |
| Profile update | Task success, error rate | To be filled | Not evidenced in repository |

---

## 15. Defect Report

| Defect ID | Severity | Description | Root cause | Evidence | Fix / status | Impact |
|---|---|---|---|---|---|---|
| D1 | Major, historical | Admin widget tests failed to locate form fields | Tests used `find.widgetWithText(TextFormField, ...)` while custom fields rendered label text outside the `TextFormField` | `test/ADMIN_WIDGET_TEST_REPAIR_PLAN.md` and `test/ADMIN_WIDGET_TEST_REPAIR_TASK.md`; current widget run passed 241 tests | Repaired in test code historically; current audit did not change test code | Admin widget test suite is now executable |
| D2 | Major, current blocker | Integration tests did not complete in local audit runner | Integration command timed out; existing supplement records Firebase plugin/platform-channel initialization blocker in prior local run | Current audit command timed out twice; supplement records `FirebaseCoreHostApi.initializeCore` issue | Open; requires device-backed/plugin-ready integration runner and emulator setup verification | Integration implementation cannot yet be reported as execution verified |
| D3 | Minor, current risk | Widget tests pass but print hit-test warnings | Some tap targets are outside default test viewport bounds | `flutter test test\widget` output contains hit-test warnings | Open risk; not failing under current configuration | Could become failing if hit-test warnings are made fatal |

---

## 16. Workshop Summary and Reflection

No direct workshop observation notes or on-site participant feedback were found in the repository at the time of audit. This section is template-ready and awaiting workshop evidence insertion.

Recommended reflection structure:

| Topic | Notes to insert after workshop |
|---|---|
| Testing approach learned | To be filled from workshop notes |
| Team testing responsibilities | To be filled from workshop notes |
| Most useful testing technique | To be filled from workshop notes |
| Main challenge encountered | To be filled from workshop notes |
| Improvement for future testing | To be filled from workshop notes |

---

## 17. Known Limitations

- Integration tests are implemented but not execution-verified in this audit.
- Firebase emulator startup, device-backed Flutter plugin loading, and platform-channel initialization remain the main integration execution risks.
- Android and Web execution evidence was not found.
- Performance and usability metrics are structurally documented but not empirically measured in repository evidence.
- Firebase Security Rules validation is not evidenced.
- Widget tests pass with non-fatal hit-test warnings.

---

## 18. Conclusion

ShopEase has a strong execution-verified foundation at the unit and widget levels: 235 unit tests and 241 widget tests passed during this audit. The integration layer exists and covers all current production-scope flows in implementation, including customer auth, golden path purchase, admin management, wishlist persistence, and profile update.

However, the integration layer must be described accurately: it is implemented but not successfully execution-verified in the current audit environment. The master testing status is therefore:

- Unit testing: implemented and executed successfully.
- Widget testing: implemented and executed successfully, with non-fatal hit-test warnings.
- Integration testing: implemented for current production scope, execution attempted but blocked/timed out locally.
- Order Tracking: intentionally out of current production scope.
- Performance/usability/workshop evidence: template-ready, awaiting empirical insertion.

---

## 19. Appendix: Supporting Documents

- `test/TESTING_PLAN.md` - supporting system-wide planning document.
- `test/INTEGRATION_TEST_PLAN.md` - supporting integration test plan.
- `test/INTEGRATION_TEST_IMPLEMENTATION_REPORT.md` - focused integration implementation and execution supplement.
- `test/integration/README.md` - integration folder guide and run instructions.
- `test/ADMIN_WIDGET_TEST_REPAIR_PLAN.md` - historical admin widget repair plan.
- `test/ADMIN_WIDGET_TEST_REPAIR_TASK.md` - historical admin widget repair completion notes.
