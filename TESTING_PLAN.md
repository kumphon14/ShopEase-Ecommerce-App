# Testing Plan: ShopEase Ecommerce

## 1. Testing Objectives

The objective of this testing plan is to define how ShopEase will be validated before submission. The plan covers:

- functional correctness
- navigation correctness
- Firebase/cloud data behavior
- local persistent storage behavior
- cross-platform execution evidence
- regression prevention through automated testing

## 2. Scope of Testing

This plan covers the current production scope of the ShopEase application:

- customer authentication and shopping flows
- admin authentication and management flows
- Firestore-backed CRUD features
- local cart persistence using `shared_preferences`
- Android and Web execution evidence

Out of current production scope:

- Order Tracking as a separate production flow
- performance benchmarking beyond documented evidence
- security penetration testing

## 3. Features Under Test

- login, signup, and logout
- home/catalog browsing
- category/search/product detail flows
- cart and checkout
- order history
- wishlist
- profile update
- admin login
- admin product management
- admin order management
- admin category management
- admin bank-details management
- local cart persistence across restart/refresh

## 4. Test Levels

### 4.1 Unit Testing

Purpose:

- verify isolated logic
- validate models, utilities, and provider behavior
- catch regressions quickly

### 4.2 Widget Testing

Purpose:

- verify UI rendering
- validate form behavior and interaction
- validate route-level navigation triggers
- verify provider-driven widget state

### 4.3 Integration Testing

Purpose:

- verify cross-boundary behavior across UI, Provider, navigation, and Firebase-backed paths
- verify Android smoke integration through standard `integration_test/` entry points
- retain full seeded suites for environment-backed execution

### 4.4 Manual Testing

Purpose:

- capture Android/Web screenshots for instructor-facing evidence
- confirm visible user/admin workflows
- verify local cart persistence across restart/refresh from an end-user perspective

## 5. Test Environment

Primary environment components:

- Flutter SDK
- Dart
- Android emulator `emulator-5554`
- Chrome browser
- Firebase Auth and Cloud Firestore integration
- `shared_preferences` local persistence

Environment note:

- Full seeded integration suites require Firebase Auth/Firestore emulators or a suitable backend configuration.
- Chrome integration automation requires WebDriver/ChromeDriver for `flutter drive`.

## 6. Test Data Assumptions

- Firebase configuration is present and valid for the project
- test user/admin credentials and seeded Firestore data are available when full integration suites are run
- product records exist for browse/cart/checkout flows
- local cart storage may be user-specific or guest-scoped depending on auth state

## 7. Requirement-to-Test Mapping

| Requirement | Planned validation |
|---|---|
| R1 Authentication | unit tests, widget tests, integration auth flows, manual login screenshots |
| R2 Navigation | widget navigation checks, integration smoke, manual customer/admin page screenshots |
| R3 Cross-platform execution | Android smoke integration, Android/Web screenshot evidence, device logs |
| R4 Data storage | provider/unit tests, local cart persistence tests, manual before/after restart/refresh screenshots |
| R5 CLI testability | documented Flutter commands and saved execution logs |

## 8. Test Case Design Approach

The plan uses a mix of:

- **Equivalence Partitioning** for valid/invalid auth input, form input, checkout states, and admin form cases
- **Boundary Value Analysis** for password length, cart quantity, and required-field cases
- **Scenario-based testing** for customer and admin workflows
- **Evidence-backed manual checks** for cross-platform execution and persistence confirmation

## 9. Entry Criteria

Testing may begin when:

- project dependencies are installed
- Firebase configuration is present
- Flutter toolchain is available
- emulator/browser targets are available as required
- code changes intended for the submission baseline are complete

## 10. Exit Criteria

Testing is considered sufficient for submission when:

- `flutter analyze` passes
- unit tests pass
- widget tests pass
- Android integration smoke test passes
- manual Android and Web evidence is collected
- known environment-dependent integration limitations are documented honestly

## 11. Risk-Based Testing Plan

| Risk Area | Risk Level | Planned response |
|---|---|---|
| Authentication failure or invalid form handling | High | strong unit/widget coverage plus manual login evidence |
| Cart/checkout regression | High | unit/widget coverage, manual persistence evidence, Android smoke infrastructure |
| Admin CRUD regressions | High | integration flow coverage plus manual admin screenshots |
| Local storage corruption or mismatch | Medium | unit tests for storage service and manual before/after restart checks |
| Web automation environment blocker | Medium | document blocker, preserve manual Web execution evidence |
| Full seeded integration flakiness | Medium | keep suites implemented, document emulator dependency honestly |

## 12. Planned Automated Commands

```powershell
flutter --version
flutter doctor -v
flutter devices
flutter analyze
flutter test test\unit
flutter test test\widget
flutter test integration_test -d emulator-5554
flutter test integration_test -d chrome
flutter drive --driver=test_driver\integration_test.dart --target=integration_test\app_smoke_test.dart -d chrome
```

## 13. Android Manual Testing Plan

1. Run `flutter run -d emulator-5554`
2. Open ShopEase on the Android emulator
3. Verify login or landing flow
4. Browse to home and product detail
5. Add a product to cart
6. Change cart quantity
7. Close and reopen the app
8. Confirm cart item and quantity persist
9. Verify checkout/order-history screen
10. Verify admin login and dashboard
11. Verify at least one admin management screen

## 14. Web Manual Testing Plan

1. Run `flutter run -d chrome`
2. Open ShopEase in Chrome
3. Verify login or landing flow
4. Browse to home and product detail
5. Add a product to cart
6. Change cart quantity
7. Refresh the browser
8. Confirm cart item and quantity persist
9. Verify checkout/order-history screen
10. Verify admin login and dashboard
11. Verify at least one admin management screen

## 15. Planned Evidence Outputs

- Flutter environment logs
- analyze/test execution logs
- Android integration smoke log
- Chrome integration blocker log
- Android screenshots
- Web screenshots
- final evidence index mapping each artifact to assignment requirements

## 16. Planned Exit Deliverables

Final instructor-facing documents:

- `README.md`
- `TECHNICAL_REPORT.md`
- `TESTING_PLAN.md`
- `TESTING_REPORT.md`
- `SUBMISSION_EVIDENCE_INDEX.md`
