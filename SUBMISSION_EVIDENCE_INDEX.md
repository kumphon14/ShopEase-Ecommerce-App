# Submission Evidence Index: ShopEase Ecommerce

This document indexes the final submission evidence used to support the SEA606 report.

| Evidence ID | Platform / Area | Evidence Type | File Path | Requirement Supported | Status | Notes |
|---|---|---|---|---|---|---|
| ENV-01 | Environment | Command Output | `submission_evidence/logs/flutter_version.txt` | R3, R5 | Collected | Flutter SDK version |
| ENV-02 | Environment | Command Output | `submission_evidence/logs/flutter_doctor.txt` | R3, R5 | Collected | Toolchain and platform readiness |
| ENV-03 | Environment | Command Output | `submission_evidence/logs/flutter_devices.txt` | R3 | Collected | Android/browser target discovery |
| QA-01 | Static Analysis | Command Output | `submission_evidence/logs/flutter_analyze.txt` | R5 | Collected | `flutter analyze` passed |
| QA-02 | Unit Testing | Command Output | `submission_evidence/logs/unit_test_result.txt` | R5 | Collected | 244 unit tests passed |
| QA-03 | Widget Testing | Command Output | `submission_evidence/logs/widget_test_result.txt` | R5 | Collected | 241 widget tests passed |
| QA-04 | Android Integration | Command Output | `submission_evidence/logs/android_integration_smoke_result.txt` | R3, R5 | Collected | Android smoke integration passed |
| QA-05 | Web Integration | Command Output | `submission_evidence/logs/chrome_integration_status.txt` | R3, R5 | Collected | Records Chrome automation limitations |
| QA-06 | Submission Packaging | Command Output / Notes | `submission_evidence/logs/submission_cleaning_notes.txt` | Submission packaging | Collected | Final ZIP preparation notes |
| AND-01 | Android | Screenshot | `submission_evidence/android/android_01_flutter_devices_or_emulator.png` | R3 | Collected | Emulator/device evidence |
| AND-02 | Android | Screenshot | `submission_evidence/android/android_02_login_screen_pixel6.png` | R1, R3 | Collected | Customer login screen |
| AND-03 | Android | Screenshot | `submission_evidence/android/android_03_home_screen_pixel6.png` | R2, R3 | Collected | Home screen |
| AND-04 | Android | Screenshot | `submission_evidence/android/android_04_product_detail_pixel6.png` | R2, R3 | Collected | Product detail |
| AND-05 | Android | Screenshot | `submission_evidence/android/android_05_cart_before_restart_pixel6.png` | R4 | Collected | Cart before restart |
| AND-06 | Android | Screenshot | `submission_evidence/android/android_06_cart_after_restart_pixel6.png` | R4 | Collected | Cart after restart |
| AND-07 | Android | Screenshot | `submission_evidence/android/android_07_checkout_or_order_history_pixel6.png` | R2, R4 | Collected | Checkout/order-history evidence |
| AND-08 | Android | Screenshot | `submission_evidence/android/android_07_2_checkout_or_order_history_pixel6.png` | R2, R4 | Collected | Additional checkout/order-history evidence |
| AND-09 | Android | Screenshot | `submission_evidence/android/android_07_3_checkout_or_order_history_pixel6.png` | R2, R4 | Collected | Additional checkout/order-history evidence |
| AND-10 | Android | Screenshot | `submission_evidence/android/android_07_4_checkout_or_order_history_pixel6.png` | R2, R4 | Collected | Additional checkout/order-history evidence |
| AND-11 | Android | Screenshot | `submission_evidence/android/android_08_admin_login_pixel6.png` | R1, R2 | Collected | Admin login |
| AND-12 | Android | Screenshot | `submission_evidence/android/android_09_admin_dashboard_pixel6.png` | R2 | Collected | Admin dashboard |
| AND-13 | Android | Screenshot | `submission_evidence/android/android_10_1_manage_products_or_orders_pixel6.png` | R2, R4 | Collected | Admin management view |
| AND-14 | Android | Screenshot | `submission_evidence/android/android_10_2_manage_products_or_orders_pixel6.png` | R2, R4 | Collected | Admin management view |
| AND-15 | Android | Screenshot | `submission_evidence/android/android_11__order_management_pixel6.png` | R2, R4 | Collected | Order management evidence |
| AND-16 | Android | Screenshot | `submission_evidence/android/android_12_manage_catagories_pixel6.png` | R2, R4 | Collected | Category management evidence |
| AND-17 | Android | Screenshot | `submission_evidence/android/android_13_manage_banking_pixel6.png` | R2, R4 | Collected | Bank-details management evidence |
| WEB-01 | Web | Screenshot | `submission_evidence/web/web_01_chrome_running_app.png` | R3 | Collected | Chrome running app |
| WEB-02 | Web | Screenshot | `submission_evidence/web/web_02_login_screen_chrome.png` | R1, R3 | Collected | Customer login screen |
| WEB-03 | Web | Screenshot | `submission_evidence/web/web_03_home_screen_chrome.png` | R2, R3 | Collected | Home screen |
| WEB-04 | Web | Screenshot | `submission_evidence/web/web_04_product_detail_chrome.png` | R2, R3 | Collected | Product detail |
| WEB-05 | Web | Screenshot | `submission_evidence/web/web_05_cart_before_refresh_chrome.png` | R4 | Collected | Cart before refresh |
| WEB-06 | Web | Screenshot | `submission_evidence/web/web_06_cart_after_refresh_chrome.png` | R4 | Collected | Cart after refresh |
| WEB-07 | Web | Screenshot | `submission_evidence/web/web_07_1_checkout_or_order_history_chrome.png` | R2, R4 | Collected | Checkout/order-history evidence |
| WEB-08 | Web | Screenshot | `submission_evidence/web/web_08_admin_login_chrome.png` | R1, R2 | Collected | Admin login |
| WEB-09 | Web | Screenshot | `submission_evidence/web/web_09_admin_dashboard_chrome.png` | R2 | Collected | Admin dashboard |
| WEB-10 | Web | Screenshot | `submission_evidence/web/web_10_manage_products_or_orders_chrome.png` | R2, R4 | Collected | Admin management evidence |

## Requirement Mapping Summary

- **R1 Firebase Authentication:** Android/Web login screenshots, admin login screenshots, and automated test evidence
- **R2 Pages and Navigation:** home, product detail, dashboard, and management screenshots across both platforms
- **R3 Cross-Platform Execution:** Flutter environment/device logs plus Android/Web execution screenshots
- **R4 Data Storage:** cart-before/cart-after screenshots, checkout/order-history evidence, and data-management screenshots
- **R5 Testing and CLI Testability:** analyze, unit, widget, and integration command logs
