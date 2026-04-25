# ShopEase Ecommerce

ShopEase is a Flutter + Firebase e-commerce application built for the SEA606 coursework. The project includes customer shopping flows, admin management flows, Firebase Authentication, Cloud Firestore-backed CRUD, and a local persistent cart implemented with `shared_preferences`.

## Core Features

- Customer authentication with Firebase Auth
- Product browsing, product detail, cart, checkout, and order history
- Wishlist and profile management
- Admin login, product management, order management, category management, and bank details management
- Cloud-backed shared data with Firestore
- Local persistent cart storage across app restarts and browser refreshes

## Local Persistent Storage

To satisfy the assignment's two-tier storage requirement, ShopEase now persists cart data locally using `shared_preferences`.

- Package used: `shared_preferences`
- Stored data: lightweight cart records only
  - `productId`
  - `quantity`
  - `updatedAt`
- Storage key strategy:
  - authenticated user: `shop_ease_cart_<uid>`
  - guest fallback: `shop_ease_cart_guest`
- Rehydration strategy:
  - local storage keeps lightweight references
  - product details are reloaded from Firestore when the app restores the cart
  - missing products are skipped safely

This keeps the Product model and Firestore product schema unchanged while providing meaningful device-local persistence for Android and Web.

## Project Structure

- `lib/` production source
- `test/unit/` unit tests
- `test/widget/` widget tests
- `test/integration/` integration tests and helpers
- `test/TESTING_REPORT.md` master testing report

## Setup

```powershell
flutter pub get
```

Firebase configuration is already present in the repository. For emulator-backed integration tests, start the required Firebase emulators before running those flows.

## Run the App

```powershell
flutter run
```

Examples:

```powershell
flutter run -d chrome
flutter run -d emulator-5554
```

## Test Commands

```powershell
flutter analyze
flutter test test\unit
flutter test test\widget
```

Integration tests are documented under `test/integration/README.md`. The integration harness is now fixed, standard `integration_test/` entry points exist, and Android smoke execution is verified. Full seeded business-flow suites still require Firebase emulator availability, and Chrome verification still requires WebDriver.

## Manual Verification for Local Cart Persistence

### Android

1. Run the app on a Pixel 6 Android 14 emulator.
2. Login or continue as guest.
3. Add a product to cart.
4. Close the app.
5. Reopen the app.
6. Confirm the cart still contains the product and quantity.

### Web

1. Run the app on Chrome.
2. Login or continue as guest.
3. Add a product to cart.
4. Refresh the browser.
5. Confirm the cart still contains the product and quantity.

## Verification Snapshot

Latest verified local status:

- `flutter pub get`: passed
- `flutter analyze`: passed, no issues found
- `flutter test test\unit`: passed, 244 tests
- `flutter test test\widget`: passed, 241 tests
- `flutter test integration_test -d emulator-5554`: passed for Android smoke integration

## Notes

- Product model structure was not changed.
- Firestore product collection schema was not changed.
- Provider architecture was preserved.
- The cart persistence implementation is intentionally lightweight and assignment-safe.
