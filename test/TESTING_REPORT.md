# SEA606 Modern Software Testing Final Testing Report

**Course:** SEA606 Modern Software Testing  
**Project:** ShopEase - Cross-Platform Mobile Application  
**Technology Context:** Flutter + Provider + Firebase Auth + Cloud Firestore  
**Submission Context:** PDF Report + GitHub Repository Link  
**Audit Date:** 2026-04-25  
**Evidence Rule:** This report distinguishes implemented tests from execution-verified tests. It does not claim successful execution without command output.

---

## 1. Overview

ShopEase is a Flutter e-commerce application with customer and admin flows, Firebase-backed cloud data, and local cart persistence using `shared_preferences`.

This document is the master testing report. Supporting documents:

- `test/TESTING_PLAN.md`
- `test/INTEGRATION_TEST_PLAN.md`
- `test/INTEGRATION_TEST_IMPLEMENTATION_REPORT.md`
- `test/integration/README.md`

---

## 2. Objective

This report consolidates:

- testing strategy
- execution evidence
- requirement traceability
- defect history
- known limitations

---

## 3. Project Testing Scope

| Layer | Implementation status | Execution status | Evidence |
|---|---|---|---|
| Unit testing | Implemented | Executed successfully | `flutter test test\unit` passed 244 tests |
| Widget testing | Implemented | Executed successfully | `flutter test test\widget` passed 241 tests |
| Integration testing | Implemented | Partially execution verified | Android smoke integration passed; full business suites remain environment-dependent |
| Performance testing | Report structure only | No empirical evidence in repository | Template-ready |
| Usability testing | Report structure only | No empirical evidence in repository | Template-ready |

Order Tracking is intentionally out of current production scope.

---

## 4. Overview and Execution Commands

| Command | Purpose | Result | Evidence file | Notes / Remaining blocker |
|---|---|---|---|---|
| `flutter --version` | Record Flutter SDK/toolchain version used for submission evidence | Passed | `submission_evidence/logs/flutter_version.txt` | Use this in the final PDF/report appendix if version proof is requested |
| `flutter doctor -v` | Capture environment/toolchain readiness snapshot | Passed | `submission_evidence/logs/flutter_doctor.txt` | Confirms installed Flutter tooling and host environment |
| `flutter devices` | Record currently detected execution targets | Passed | `submission_evidence/logs/flutter_devices.txt` | Device availability is environment-dependent at the time of capture |
| `flutter analyze` | Static analysis validation | Passed, no issues found | `submission_evidence/logs/flutter_analyze.txt` | Clean analyzer result |
| `flutter test test\unit` | Execute unit-test suite | Passed: 244 tests | `submission_evidence/logs/unit_test_result.txt` | Execution verified |
| `flutter test test\widget` | Execute widget-test suite | Passed: 241 tests | `submission_evidence/logs/widget_test_result.txt` | Execution verified; non-fatal hit-test warnings may still appear in output |
| `flutter test integration_test -d emulator-5554` | Execute Android device-backed integration smoke path | Passed | `submission_evidence/logs/android_integration_smoke_result.txt` | Confirms integration harness fix on Android |
| `flutter test integration_test -d chrome` | Attempt standard Chrome integration execution | Blocked | `submission_evidence/logs/chrome_integration_status.txt` | Flutter toolchain reports that web devices are not supported for `flutter test integration_test` |
| `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_smoke_test.dart -d chrome` | Attempt Chrome integration fallback path | Blocked | `submission_evidence/logs/chrome_integration_status.txt` | Requires WebDriver/ChromeDriver server on port `4444` |

---

## 5. Testing Strategy

### 5.1 Testing Pyramid

| Level | Role | Evidence |
|---|---|---|
| Unit | Validate isolated models, providers, utilities, routes, mock data | 244 tests passed |
| Widget | Validate UI rendering, form validation, navigation triggers, provider-driven state | 241 tests passed |
| Integration | Validate real device-backed launch path, plugin loading, Firebase initialization, and end-to-end flow infrastructure | Android smoke passed; full seeded suites implemented but not fully verified |

### 5.2 Integration Strategy

The integration layer now uses:

- `integration_test/` for standard device-backed entry points
- `test/integration/` for source scenario files

This fixes the prior structural problem where the meaningful integration files existed outside the standard plugin-loading path.

---

## 6. Requirements to Be Validated

| Requirement | Validation expectation |
|---|---|
| R1 Authentication | Customer and admin auth paths are testable |
| R2 Navigation | Main customer/admin navigation paths are testable |
| R3 Cross-Platform Execution | Device-backed testing paths are documented and partially execution verified |
| R4 Data Storage | Firebase cloud storage plus local persistent cart storage are testable |
| R5 CLI Testability | Unit, widget, and Android integration smoke can be run from CLI |

---

## 7. Requirements Traceability Matrix

| Requirement | Evidence | Status |
|---|---|---|
| R1 | Unit auth tests, widget auth tests, source integration auth/admin files | Partially execution verified |
| R2 | Widget navigation tests, Android smoke, source integration flows | Partially execution verified |
| R3 | Android emulator smoke run, Chrome command evidence, device discovery | Partially execution verified |
| R4 | Firestore/Auth provider tests, local-cart storage tests, source integration seed flows | Partially execution verified |
| R5 | CLI runs for analyze/unit/widget/integration smoke | Partially execution verified |

---

## 8. Black-Box Test Design

### 8.1 Equivalence Partitioning

- valid/invalid authentication input
- valid/invalid checkout fields
- cart quantity mutations
- admin form submission states
- wishlist and profile update states

### 8.2 Boundary Value Analysis

- password length boundaries
- quantity `1`, `0`, negative values
- rating range handling
- order status index boundaries
- currency formatting boundaries

---

## 9. Unit Test Report

| Item | Status |
|---|---|
| Directory | `test/unit/` |
| Result | 244 passed |
| Confidence | Execution verified |

---

## 10. Widget Test Report

| Item | Status |
|---|---|
| Directory | `test/widget/` |
| Result | 241 passed |
| Confidence | Execution verified |

Residual note:

- Widget tests still print non-fatal hit-test warnings in some cases, but the suite passes.

---

## 11. Integration Test Report

### 11.1 Current Production-Scope Integration Flows

- Customer Auth Flow
- Golden Path
- Admin Login Flow
- Admin Product Management Flow
- Admin Order Management Flow
- Admin Category Management Flow
- Admin Bank Details Management Flow
- Wishlist Persistence Flow
- Profile Update Flow

### 11.2 Harness Fix Status

Resolved:

- `integration_test` plugin detection blocker for Android device-backed runs
- Firebase startup crash path seen when integration scenarios were not run through standard `integration_test/` entry points

### 11.3 Execution Status Matrix

| Item | Status | Evidence |
|---|---|---|
| `integration_test/app_smoke_test.dart` | Executed successfully | Android emulator run passed |
| `integration_test/phase1_suite_test.dart` | Executed successfully in default mode | Android emulator run passed |
| `integration_test/phase2_suite_test.dart` | Executed successfully in default mode | Android emulator run passed |
| Full seeded business-flow suites under `test/integration/` | Implemented | Require emulators and `RUN_FULL_INTEGRATION=true`; not fully execution-verified in this audit |

### 11.4 Conclusion

The integration harness is fixed and partially execution verified. Full end-to-end business suites remain implemented but environment-dependent.

---

## 12. Cross-Platform Evidence

| Target | Evidence | Status |
|---|---|---|
| Android | `flutter test integration_test -d emulator-5554` passed | Execution verified for smoke path |
| Web | `flutter test integration_test -d chrome` unsupported by toolchain; `flutter drive` blocked by missing WebDriver | Not execution verified |

---

## 13. Performance and Usability Metrics

No empirical performance/usability measurements were found in the repository. This section remains template-ready.

---

## 14. Performance Dashboard

| Workflow | Measured value | Evidence status |
|---|---|---|
| Customer auth | To be filled | Not evidenced |
| Browse to checkout | To be filled | Not evidenced |
| Admin CRUD flows | To be filled | Not evidenced |

---

## 15. Defect Report

| Defect ID | Description | Status |
|---|---|---|
| D1 | Historical admin widget finder mismatch | Resolved historically |
| D2 | Integration plugin/Firebase startup failure caused by non-standard execution path | Partially resolved; Android verified |
| D3 | Web integration execution blocked by toolchain/WebDriver environment | Open environment issue |

---

## 16. Workshop Summary / Reflection

Workshop evidence was not found in the repository. This section remains template-ready.

---

## 17. Known Limitations

- Full emulator-backed business-flow suites were not fully execution-verified in this audit
- Chrome execution still requires additional environment setup
- Performance/usability evidence is not yet empirical

---

## 18. Conclusion

ShopEase has strong execution-verified unit and widget coverage, plus a repaired integration harness that now executes successfully on Android for smoke coverage. The full production-scope integration scenarios remain implemented and wired into standard entry points, but they still depend on external Firebase emulator availability for complete execution verification.
