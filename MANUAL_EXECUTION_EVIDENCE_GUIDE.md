# Manual Execution Evidence Guide

This guide lists the screenshots and manual verification steps to capture before final submission.

## Android Screenshot Checklist

- `android_01_flutter_devices_or_emulator.png`
- `android_02_login_screen_pixel6.png`
- `android_03_home_screen_pixel6.png`
- `android_04_product_detail_pixel6.png`
- `android_05_cart_before_restart_pixel6.png`
- `android_06_cart_after_restart_pixel6.png`
- `android_07_checkout_or_order_history_pixel6.png`
- `android_08_admin_login_pixel6.png`
- `android_09_admin_dashboard_pixel6.png`
- `android_10_manage_products_or_orders_pixel6.png`

## Web Screenshot Checklist

- `web_01_chrome_running_app.png`
- `web_02_login_screen_chrome.png`
- `web_03_home_screen_chrome.png`
- `web_04_product_detail_chrome.png`
- `web_05_cart_before_refresh_chrome.png`
- `web_06_cart_after_refresh_chrome.png`
- `web_07_checkout_or_order_history_chrome.png`
- `web_08_admin_login_chrome.png`
- `web_09_admin_dashboard_chrome.png`
- `web_10_manage_products_or_orders_chrome.png`

## Manual Android Verification Flow

1. Run `flutter run -d emulator-5554`
2. Open the app on the Pixel 6 Android 14 emulator
3. Login or continue with the available customer flow
4. Add a product to the cart
5. Change quantity
6. Capture the cart state before restart
7. Close the app completely
8. Reopen the app
9. Confirm cart item and quantity persist
10. Capture the cart state after restart
11. Test checkout or order history if possible
12. Test admin login and admin dashboard

## Manual Web Verification Flow

1. Run `flutter run -d chrome`
2. Open the app in Chrome
3. Login or continue with the available customer flow
4. Add a product to the cart
5. Change quantity
6. Capture the cart state before refresh
7. Refresh the browser
8. Confirm cart item and quantity persist
9. Capture the cart state after refresh
10. Test checkout or order history if possible
11. Test admin login and admin dashboard

## Notes

- Keep screenshot names exactly as listed above for traceability
- Save Android screenshots under `submission_evidence/android/`
- Save Web screenshots under `submission_evidence/web/`
- Command/log evidence is already stored under `submission_evidence/logs/`
