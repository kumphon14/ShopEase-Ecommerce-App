# Technical Report: ShopEase Ecommerce

## 1. Project Overview

ShopEase is a cross-platform Flutter e-commerce application for the SEA606 assignment. It supports customer shopping workflows and admin management workflows using Firebase services.

Target users:

- customers browsing and purchasing products
- administrators managing products, categories, orders, and payment details

## 2. Technology Stack

- Flutter
- Dart
- Provider
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- shared_preferences

## 3. Architecture Summary

The codebase uses:

- `models/` for domain entities
- `services/providers/` for Provider-based state and Firebase access
- `screens/` for customer/admin UI
- `widgets/` for reusable components
- `core/` for routes and theming

Provider remains the primary state-management approach.

## 4. Application Pages and Navigation

Customer pages include:

- Splash
- Landing
- Login
- Signup
- Home
- Category
- Search
- Product Detail
- Cart
- Checkout
- Order History
- Profile
- Edit Profile
- Wishlist
- Notifications

Admin pages include:

- Admin Login
- Admin Dashboard
- Manage Products
- Add Product
- Edit Product
- Manage Orders
- Manage Bank Details
- Manage Categories

Navigation uses named routes defined in `lib/core/routes/app_routes.dart`.

## 5. Firebase Usage

### Authentication

Firebase Authentication handles:

- customer signup
- customer login
- logout
- identity for user-scoped data

### Cloud Firestore

Cloud Firestore stores:

- products
- categories
- orders
- payment/bank details
- user profiles
- wishlist data

## 6. Data Storage Design

### 6.1 Cloud Storage

Cloud data is implemented with Firebase Auth and Cloud Firestore.

### 6.2 Local Storage

ShopEase now implements local persistent cart storage using `shared_preferences`.

Stored local fields:

- `productId`
- `quantity`
- `updatedAt`

Storage keys:

- `shop_ease_cart_<uid>`
- `shop_ease_cart_guest`

Rehydration strategy:

1. read lightweight local records
2. decode JSON safely
3. fetch product details from Firestore
4. rebuild runtime cart state
5. skip missing products safely

## 7. Local Persistence Behavior

The local cart persists:

- add-to-cart
- quantity changes
- removal
- clear-cart
- restart/refresh restoration

Product model structure and Firestore product schema were not changed.

## 8. Security and Safety Notes

- Firebase app configuration is present for platform initialization
- local storage contains lightweight cart references only
- no new sensitive credential storage was introduced

## 9. Testing Strategy

Testing is split across:

- unit tests
- widget tests
- integration tests

Integration harness update:

- source scenario files stay under `test/integration/`
- standard device-backed entry points now live under `integration_test/`
- Android smoke execution is verified through `flutter test integration_test -d emulator-5554`
- web integration in this Flutter version requires `flutter drive` plus WebDriver

## 10. Verification Commands and Results

Commands run:

```powershell
flutter pub get
flutter analyze
flutter test test\unit
flutter test test\widget
flutter test integration_test -d emulator-5554
flutter test integration_test -d chrome
flutter drive --driver=test_driver\integration_test.dart --target=integration_test\app_smoke_test.dart -d chrome
```

Results:

- `flutter pub get`: passed
- `flutter analyze`: passed, no issues found
- `flutter test test\unit`: passed, 244 tests
- `flutter test test\widget`: passed, 241 tests
- `flutter test integration_test -d emulator-5554`: passed for smoke integration and standard wrappers
- `flutter test integration_test -d chrome`: blocked because web devices are not supported for integration tests in this Flutter toolchain
- `flutter drive ... -d chrome`: blocked because no WebDriver server was running on port `4444`

## 11. Limitations

- Full emulator-backed business-flow suites were not fully execution-verified in this audit
- Chrome integration execution still requires external WebDriver setup
- Firebase emulators must be running for the seeded full suites

## 12. Conclusion

ShopEase demonstrates:

- cloud storage through Firebase Auth + Cloud Firestore
- local storage through `shared_preferences`
- strong unit and widget coverage
- a repaired integration harness with Android smoke execution verified

Product model structure and Firestore product schema remain unchanged.
