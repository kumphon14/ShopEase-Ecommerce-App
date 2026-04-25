# ShopEase Ecommerce

ShopEase is a cross-platform Flutter + Firebase e-commerce application developed for the SEA606 coursework. The system supports customer shopping workflows, admin management workflows, cloud-backed shared data, and device-local cart persistence.

## Project Overview

ShopEase demonstrates a practical two-tier data model for a mobile/web commerce application:

- **Cloud data** is managed with Firebase Authentication and Cloud Firestore.
- **Local data** is managed with `shared_preferences` to persist the shopping cart across app restarts and browser refreshes.

The application is designed as a realistic course project rather than a prototype-only UI. It includes customer-facing purchasing flows and administrator-facing management flows.

## Objective

The project objective is to build and test a cross-platform e-commerce application that demonstrates:

- Firebase Authentication
- Firestore-backed CRUD operations
- multi-page navigation
- meaningful local persistent storage
- executable unit, widget, and integration testing

## Target Users

- **Customers** who browse products, manage wishlists, update profiles, add items to cart, and place orders
- **Administrators** who manage products, categories, orders, and bank/payment details

## Technology Stack

- Flutter
- Dart
- Provider
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- `shared_preferences`

## Main Features

- Firebase email/password authentication
- customer browsing and checkout flow
- admin login and dashboard flow
- Firestore-backed product, category, order, and bank-detail management
- wishlist and profile features
- local cart persistence across restart/refresh

## User Features

- landing, login, and signup
- home, category browsing, search, and product detail
- cart and checkout
- order history
- wishlist
- profile update
- notifications

## Admin Features

- admin login
- admin dashboard
- manage products
- add/edit products
- manage orders
- manage categories
- manage bank details

## Firebase Authentication Summary

ShopEase uses Firebase Authentication for customer login/signup and admin login flows. The repository evidence shows authentication UI, validation, and logout behavior. Session-startup behavior is documented honestly as a minor limitation because the splash/entry flow is not fully auth-aware at startup.

## Firestore Cloud Data Summary

Cloud Firestore is used for shared application data, including:

- products
- categories
- orders
- wishlist data
- bank/payment details
- profile-related user data

These collections support the app's shared multi-user business features. The Firestore product schema was not changed during the local persistence work.

## Local Persistent Storage Summary

Local persistent storage is implemented with `shared_preferences`.

- **Stored fields:** `productId`, `quantity`, `updatedAt`
- **Key strategy:** `shop_ease_cart_<uid>` for authenticated users, `shop_ease_cart_guest` for guest/device-local storage
- **Design:** lightweight cart references are stored locally, then product details are rehydrated from Firestore

This keeps the Product model unchanged while satisfying the assignment requirement for meaningful local persistent storage.

## Android and Web Execution Summary

Current execution evidence shows:

- Android integration smoke execution verified on `emulator-5554`
- Android manual screenshots collected under `submission_evidence/android/`
- Web manual screenshots collected under `submission_evidence/web/`
- Chrome integration automation remains environment-dependent because WebDriver/ChromeDriver is required

## Testing Summary

Verified results:

- `flutter analyze`: passed, no issues found
- `flutter test test\unit`: passed, **244** tests
- `flutter test test\widget`: passed, **241** tests
- `flutter test integration_test -d emulator-5554`: passed for Android smoke integration

Important limitation:

- Full seeded integration suites remain environment-dependent because they require Firebase Auth/Firestore emulator setup or a suitable test backend.
- Chrome integration automation remains environment-dependent because `flutter test integration_test -d chrome` is unsupported in this toolchain and `flutter drive` requires WebDriver.

## Setup Instructions

```powershell
flutter pub get
```

Firebase configuration files are already present in the repository. For full emulator-backed integration execution, start the required Firebase emulators before running seeded integration flows.

## Run Commands

```powershell
flutter run
flutter run -d emulator-5554
flutter run -d chrome
```

## Test Commands

```powershell
flutter analyze
flutter test test\unit
flutter test test\widget
flutter test integration_test -d emulator-5554
flutter test integration_test -d chrome
flutter drive --driver=test_driver\integration_test.dart --target=integration_test\app_smoke_test.dart -d chrome
```

## Documentation Index

Final instructor-facing documents:

1. [README.md](E:/shopease_ecommerce_app/README.md)
2. [TECHNICAL_REPORT.md](E:/shopease_ecommerce_app/TECHNICAL_REPORT.md)
3. [TESTING_PLAN.md](E:/shopease_ecommerce_app/TESTING_PLAN.md)
4. [TESTING_REPORT.md](E:/shopease_ecommerce_app/TESTING_REPORT.md)
5. [SUBMISSION_EVIDENCE_INDEX.md](E:/shopease_ecommerce_app/SUBMISSION_EVIDENCE_INDEX.md)

Supporting/internal working documents are archived under `docs/internal/`.

## Known Limitations

- Full seeded integration suites are implemented but still environment-dependent.
- Chrome integration automation is not fully execution-verified in the current environment.
- Startup session behavior is only partially evidenced because the splash/entry flow does not fully skip the landing route.
- Performance/usability workshop metrics are not the focus of the repository evidence set.

## Integrity Notes

- Product model structure was not changed.
- Firestore product schema was not changed.
- Provider architecture was preserved.
- This final documentation set is evidence-based and does not claim unsupported test results.
