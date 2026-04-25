# Technical Report: ShopEase Ecommerce

## 1. Application Overview

ShopEase is a cross-platform Flutter e-commerce application developed for the SEA606 assignment. The system combines customer shopping workflows and administrator management workflows using Firebase services and Provider-based state management.

The project is intended to demonstrate practical software engineering concerns in a mobile/web application, including authentication, CRUD operations, navigation, testability, and two-tier data storage.

## 2. Target Users

The system has two primary user groups:

- **Customers**, who browse products, manage carts and wishlists, update profile information, and place orders
- **Administrators**, who manage product data, categories, orders, and bank/payment details

## 3. Theme and Rationale

The project theme is an e-commerce application because it naturally supports the assignment requirements:

- authentication and authorization flows
- multiple functional pages
- shared cloud data
- user-specific local data
- meaningful business workflows for testing

This domain also provides clear evidence for CRUD operations, navigation, and persistent state handling.

## 4. System Architecture

ShopEase follows a Flutter + Provider + Firebase architecture.

### 4.1 Presentation Layer

- `lib/screens/` contains customer and admin screens
- `lib/widgets/` contains reusable UI components
- `lib/core/routes/` contains named-route definitions
- `lib/core/theme/` contains theme configuration

### 4.2 State and Service Layer

- `lib/services/providers/` contains Provider-based state management
- Providers coordinate UI state, business actions, and Firebase/local persistence access

### 4.3 Data Layer

- Firebase Authentication manages identity
- Cloud Firestore stores shared application data
- `shared_preferences` stores lightweight local cart records

## 5. Folder and Project Structure

Key folders:

- `lib/core/` - routes and theme
- `lib/models/` - domain entities
- `lib/screens/` - application pages
- `lib/services/providers/` - state management and backend coordination
- `lib/services/local/` - local persistence services
- `lib/widgets/` - reusable UI components
- `integration_test/` - standard integration test entry points
- `test/unit/` - unit tests
- `test/widget/` - widget tests
- `test/integration/` - integration flow source files and helpers
- `submission_evidence/` - execution logs and manual screenshot evidence

## 6. Page Navigation

ShopEase uses named routes configured in `lib/core/routes/app_routes.dart`.

### Customer-facing pages

- splash
- landing
- login
- signup
- main navigation
- home
- category
- search
- product detail
- cart
- checkout
- order history
- profile
- wishlist
- notifications

### Admin-facing pages

- admin login
- admin dashboard
- manage products
- add product
- edit product
- manage orders
- manage categories
- manage bank details

## 7. User Flow

Typical customer flow:

1. Open app
2. Login or sign up
3. Browse products
4. View product detail
5. Add item to cart
6. Adjust quantity
7. Proceed to checkout
8. Create order
9. Review order history
10. Manage profile or wishlist

## 8. Admin Flow

Typical administrator flow:

1. Open admin login
2. Authenticate with admin credentials
3. Enter admin dashboard
4. Manage products
5. Manage categories
6. Manage orders
7. Manage bank/payment details

## 9. Firebase Authentication Design

Firebase Authentication is used for:

- customer signup
- customer login
- logout
- user-scoped data association
- admin login flow

The authentication design keeps credentials within Firebase-managed flows rather than storing sensitive values in local persistence.

## 10. Firestore Collections and Data Structures

Repository evidence shows Firestore-backed handling for:

- products
- categories
- orders
- bank/payment details
- wishlist data
- user/profile data

The Firestore product schema was intentionally left unchanged during the local persistence implementation.

## 11. CRUD Mapping

### Products

- Create: admin add product
- Read: customer catalog and admin management views
- Update: admin edit product
- Delete: admin product-management flow

### Categories

- Create: admin category management
- Read: category browsing and admin category list
- Update/Delete: admin category-management operations where provided by production UI

### Orders

- Create: checkout/order creation
- Read: order history and admin order list
- Update: admin order status management

### Bank Details

- Read/Update: admin bank-detail management and checkout visibility where applicable

## 12. Local Persistent Storage Design

Local persistent storage is implemented using `shared_preferences`.

### 12.1 Rationale

The assignment requires meaningful device-local or user-local persistence in addition to cloud storage. The shopping cart is an appropriate local data target because it is user-specific, changes frequently, and benefits directly from persistence across app restarts and browser refreshes.

### 12.2 Stored Local Data

The local cart stores lightweight records only:

- `productId`
- `quantity`
- `updatedAt`

### 12.3 Key Design

- Authenticated users: `shop_ease_cart_<uid>`
- Guest users: `shop_ease_cart_guest`

### 12.4 Rehydration Strategy

1. Load lightweight cart records from local storage
2. Decode JSON safely
3. Match local records to product data loaded from Firestore
4. Restore in-memory cart state
5. Skip missing products safely without crashing

### 12.5 Design Integrity

- Product model structure was not changed
- Firestore product schema was not changed
- Provider architecture was preserved

## 13. Cross-Platform Execution on Android and Web

### Android

Execution evidence includes:

- Android device discovery logs
- Android integration smoke test pass on `emulator-5554`
- manual screenshot evidence under `submission_evidence/android/`

### Web

Execution evidence includes:

- device discovery logs showing Chrome availability
- manual screenshot evidence under `submission_evidence/web/`

Automation limitation:

- `flutter test integration_test -d chrome` is blocked by the current Flutter toolchain
- `flutter drive` on Chrome requires a running WebDriver/ChromeDriver server

## 14. Security Considerations

- Authentication is delegated to Firebase Authentication
- Local storage contains lightweight cart references only, not full payment credentials
- Sensitive business data remains cloud-backed
- Firebase configuration files included in the repository are intended for platform initialization and classroom submission use
- No private custom secrets were introduced as part of the local persistence work

## 15. Testing Strategy Summary

The testing approach follows a practical testing pyramid:

- **Unit tests** validate isolated logic, models, utilities, and provider behavior
- **Widget tests** validate UI behavior, form validation, rendering, and route-level interaction
- **Integration tests** validate device-backed startup, plugin loading, and representative end-to-end flow infrastructure
- **Manual testing** provides Android/Web visual evidence and user-flow confirmation

Verified results:

- `flutter analyze`: passed
- unit tests: 244 passed
- widget tests: 241 passed
- Android integration smoke test: passed

Environment-dependent results:

- full seeded integration suites
- Chrome integration automation

## 16. Requirement Compliance Matrix

| Requirement | Description | Status | Evidence summary |
|---|---|---|---|
| R1 | Firebase Authentication | Complete with minor startup-session limitation | Auth screens, logout, validation, Firebase-backed flows |
| R2 | Application Pages and Navigation | Complete | Customer and admin multi-page navigation with named routes |
| R3 | Cross-Platform Execution | Complete with environment-dependent automation limitation | Android smoke pass, Android/Web screenshots collected, Chrome automation limitation documented |
| R4 | Data Storage | Complete | Firestore cloud data plus `shared_preferences` local cart persistence |
| R5 | Testing and CLI Testability | Complete with partial integration automation limitation | Analyze/unit/widget passed, Android smoke passed, seeded/Chrome limits documented |

## 17. Limitations

- Full seeded integration suites remain environment-dependent because they require Firebase emulator readiness
- Chrome integration automation remains environment-dependent because WebDriver/ChromeDriver is required
- Startup session behavior is only partially evidenced at app entry
- Performance/usability workshop metrics are not the main focus of the repository evidence set

## 18. Conclusion

ShopEase satisfies the major technical expectations of the SEA606 assignment:

- Firebase-backed authentication and cloud data
- multi-page customer and admin workflows
- meaningful local persistence using `shared_preferences`
- strong static analysis, unit testing, and widget testing results
- repaired Android integration harness with execution evidence
- manual Android and Web execution evidence collected for final submission

The final submission should be read together with `README.md`, `TESTING_PLAN.md`, `TESTING_REPORT.md`, and `SUBMISSION_EVIDENCE_INDEX.md`.
