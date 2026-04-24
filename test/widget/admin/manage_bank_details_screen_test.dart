// test/widget/admin/manage_bank_details_screen_test.dart
//
// REPAIR NOTES (2026-04-23):
// Root cause of the 2 previously-failing tests: test finders used
//   find.widgetWithText(TextFormField, 'Bank Name')
//   find.widgetWithText(TextFormField, 'Account Number')
// but CustomTextField renders its label as a sibling Text widget above the
// TextFormField — not as decoration.labelText inside the TextFormField.
// Therefore find.widgetWithText(TextFormField, ...) always returns 0 results,
// causing StateError: Bad state: No element.
//
// Fix: replaced with find.byType(TextFormField).at(n) where n is the
// zero-based field index confirmed from reading manage_bank_details_screen.dart:
//   at(0) = Bank Name              (controller pre-filled: 'Kasikorn Bank (KBank)')
//   at(1) = Account Number         (controller pre-filled: account number)
//   at(2) = Account Name (Company) (controller pre-filled: account name)
//   at(3) = PromptPay ID           (controller pre-filled: prompt pay id)
//   at(4) = QR Code Image URL (optional)
//
// Note: to "clear" a pre-filled TextFormField, enterText with '' works because
// enterText replaces the entire field content.
//
// Submit button: replaced find.text('Save Bank Details').last with
//   find.widgetWithText(CustomButton, 'Save Bank Details') + ensureVisible().

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/screens/admin/manage_bank_details_screen.dart';
import 'package:shopease_ecommerce_app/widgets/custom_button.dart';

import '../helpers/fake_providers.dart';
import '../helpers/pump_app.dart';

void main() {
  group('ManageBankDetailsScreen', () {
    testWidgets('renders all fields and populates with current provider data',
        (tester) async {
      final paymentProvider = makePaymentProvider();

      await tester.pumpApp(const ManageBankDetailsScreen(),
          payment: paymentProvider);

      expect(find.text('Manage Bank Details'), findsOneWidget);
      expect(find.text('Kasikorn Bank (KBank)'), findsWidgets);
      expect(find.text('ShopEase Co., Ltd.'), findsWidgets);
    });

    testWidgets('shows validation errors for empty fields', (tester) async {
      final paymentProvider = makePaymentProvider();
      await tester.pumpApp(const ManageBankDetailsScreen(),
          payment: paymentProvider);

      // Field order in ManageBankDetailsScreen:
      //   at(0) = Bank Name              ← clear
      //   at(1) = Account Number         ← clear
      //   at(2) = Account Name (Company)
      //   at(3) = PromptPay ID
      //   at(4) = QR Code Image URL (optional)
      //
      // enterText replaces the full field content, so entering '' clears the field.
      await tester.enterText(find.byType(TextFormField).at(0), '');
      await tester.pump();
      await tester.enterText(find.byType(TextFormField).at(1), '');
      await tester.pump();

      final submitBtn =
          find.widgetWithText(CustomButton, 'Save Bank Details');
      await tester.ensureVisible(submitBtn);
      await tester.pumpAndSettle();
      // Tap the inner ElevatedButton — more reliable than tapping CustomButton
      // by coordinate in a long scrollable form.
      await tester.tap(find.byType(ElevatedButton).last, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 300)); // allow validation + SnackBar frame

      expect(find.text('Bank name is required'), findsOneWidget);
      expect(find.text('Account number is required'), findsOneWidget);
    });

    testWidgets('saves new details successfully', (tester) async {
      final paymentProvider = makePaymentProvider();
      await tester.pumpApp(const ManageBankDetailsScreen(),
          payment: paymentProvider);

      // Update the Bank Name field (index 0).
      await tester.enterText(find.byType(TextFormField).at(0), 'New Bank');
      await tester.pump(); // settle controller update

      final submitBtn =
          find.widgetWithText(CustomButton, 'Save Bank Details');
      await tester.ensureVisible(submitBtn);
      await tester.pumpAndSettle();
      // Tap the inner ElevatedButton — more reliable than tapping CustomButton
      // by coordinate in a long scrollable form.
      await tester.tap(find.byType(ElevatedButton).last, warnIfMissed: false);
      // Use pump() (not pumpAndSettle) so the SnackBar is captured before
      // Navigator.pop() completes its animation and removes the scaffold.
      await tester.pump();

      expect(find.text('Bank details saved!'), findsOneWidget);
      expect(paymentProvider.bankDetails.bankName, 'New Bank');
    });
  });
}
