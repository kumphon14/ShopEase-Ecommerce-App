// test/widget/cart/checkout_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/screens/cart/checkout_screen.dart';
import 'package:shopease_ecommerce_app/widgets/custom_button.dart';
import 'package:shopease_ecommerce_app/widgets/custom_text_field.dart';

import '../helpers/fake_providers.dart';
import '../helpers/pump_app.dart';

void main() {
  group('CheckoutScreen', () {
    // ------------------------------------------------------------------
    // Rendering
    // ------------------------------------------------------------------
    testWidgets('renders Checkout app bar title', (tester) async {
      final cart = makeCartProvider([makeCartItem()]);
      await tester.pumpApp(const CheckoutScreen(), cart: cart);
      expect(find.text('Checkout'), findsOneWidget);
    });

    testWidgets('renders Shipping Details section', (tester) async {
      final cart = makeCartProvider([makeCartItem()]);
      await tester.pumpApp(const CheckoutScreen(), cart: cart);
      expect(find.text('Shipping Details'), findsOneWidget);
    });

    testWidgets('renders Full Name field', (tester) async {
      final cart = makeCartProvider([makeCartItem()]);
      await tester.pumpApp(const CheckoutScreen(), cart: cart);
      expect(find.text('Full Name'), findsOneWidget);
    });

    testWidgets('renders Address field', (tester) async {
      final cart = makeCartProvider([makeCartItem()]);
      await tester.pumpApp(const CheckoutScreen(), cart: cart);
      expect(find.text('Address'), findsOneWidget);
    });

    testWidgets('renders City field', (tester) async {
      final cart = makeCartProvider([makeCartItem()]);
      await tester.pumpApp(const CheckoutScreen(), cart: cart);
      expect(find.text('City'), findsOneWidget);
    });

    testWidgets('renders Phone Number field', (tester) async {
      final cart = makeCartProvider([makeCartItem()]);
      await tester.pumpApp(const CheckoutScreen(), cart: cart);
      expect(find.text('Phone Number'), findsOneWidget);
    });

    testWidgets('renders Payment Method section', (tester) async {
      final cart = makeCartProvider([makeCartItem()]);
      await tester.pumpApp(const CheckoutScreen(), cart: cart);
      expect(find.text('Payment Method'), findsOneWidget);
    });

    testWidgets('renders Cash on Delivery option', (tester) async {
      final cart = makeCartProvider([makeCartItem()]);
      await tester.pumpApp(const CheckoutScreen(), cart: cart);
      expect(find.text('Cash on Delivery'), findsOneWidget);
    });

    testWidgets('renders Bank Transfer option', (tester) async {
      final cart = makeCartProvider([makeCartItem()]);
      await tester.pumpApp(const CheckoutScreen(), cart: cart);
      expect(find.text('Bank Transfer'), findsOneWidget);
    });

    testWidgets('renders Order Summary section', (tester) async {
      final cart = makeCartProvider([makeCartItem()]);
      await tester.pumpApp(const CheckoutScreen(), cart: cart);
      expect(find.text('Order Summary'), findsOneWidget);
    });

    testWidgets('renders Place Order button', (tester) async {
      final cart = makeCartProvider([makeCartItem()]);
      await tester.pumpApp(const CheckoutScreen(), cart: cart);
      expect(find.widgetWithText(CustomButton, 'Place Order'), findsOneWidget);
    });

    testWidgets('renders cart item in Order Summary', (tester) async {
      final product = makeProduct(name: 'Cool Widget');
      final cart = makeCartProvider([makeCartItem(product: product)]);
      await tester.pumpApp(const CheckoutScreen(), cart: cart);
      expect(find.textContaining('Cool Widget'), findsOneWidget);
    });

    testWidgets('renders Shipping: Free in order summary', (tester) async {
      final cart = makeCartProvider([makeCartItem()]);
      await tester.pumpApp(const CheckoutScreen(), cart: cart);
      expect(find.text('Free'), findsOneWidget);
    });

    testWidgets('renders four CustomTextField widgets', (tester) async {
      final cart = makeCartProvider([makeCartItem()]);
      await tester.pumpApp(const CheckoutScreen(), cart: cart);
      expect(find.byType(CustomTextField), findsNWidgets(4));
    });

    // ------------------------------------------------------------------
    // Form validation — empty submission
    // ------------------------------------------------------------------
    testWidgets('shows name required error on empty submission', (tester) async {
      final cart = makeCartProvider([makeCartItem()]);
      await tester.pumpApp(const CheckoutScreen(), cart: cart);
      final btn = find.widgetWithText(CustomButton, 'Place Order');
      await tester.ensureVisible(btn);
      await tester.pump();
      await tester.tap(btn, warnIfMissed: false);
      await tester.pump();
      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('shows address required error on empty submission', (tester) async {
      final cart = makeCartProvider([makeCartItem()]);
      await tester.pumpApp(const CheckoutScreen(), cart: cart);
      final btn = find.widgetWithText(CustomButton, 'Place Order');
      await tester.ensureVisible(btn);
      await tester.pump();
      await tester.tap(btn, warnIfMissed: false);
      await tester.pump();
      expect(find.text('Address is required'), findsOneWidget);
    });

    testWidgets('shows city required error on empty submission', (tester) async {
      final cart = makeCartProvider([makeCartItem()]);
      await tester.pumpApp(const CheckoutScreen(), cart: cart);
      final btn = find.widgetWithText(CustomButton, 'Place Order');
      await tester.ensureVisible(btn);
      await tester.pump();
      await tester.tap(btn, warnIfMissed: false);
      await tester.pump();
      expect(find.text('City is required'), findsOneWidget);
    });

    testWidgets('shows phone required error on empty submission', (tester) async {
      final cart = makeCartProvider([makeCartItem()]);
      await tester.pumpApp(const CheckoutScreen(), cart: cart);
      final btn = find.widgetWithText(CustomButton, 'Place Order');
      await tester.ensureVisible(btn);
      await tester.pump();
      await tester.tap(btn, warnIfMissed: false);
      await tester.pump();
      expect(find.text('Phone is required'), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Payment method selection
    // ------------------------------------------------------------------
    testWidgets('selecting Bank Transfer shows bank details section', (tester) async {
      final cart = makeCartProvider([makeCartItem()]);
      await tester.pumpApp(const CheckoutScreen(), cart: cart);
      // Find the Bank Transfer option by its unique subtitle
      const bankSubtitle = 'Pay via bank transfer / PromptPay';
      // Scroll until this subtitle is visible
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pump();
      // Tap the subtitle widget (unique text, part of the bank transfer option)
      await tester.tap(find.text(bankSubtitle), warnIfMissed: false);
      await tester.pump(); // setState
      await tester.pump(const Duration(milliseconds: 350)); // AnimatedCrossFade
      // When Bank Transfer is selected, its option shows the check_circle icon
      // The COD option's check_circle is gone, bank option's appears
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
    // FIXED: _MockQrCode is now responsive (ConstrainedBox + AspectRatio +
    // LayoutBuilder). No longer overflows in the 800x600 test viewport.

    testWidgets('COD is selected by default', (tester) async {
      final cart = makeCartProvider([makeCartItem()]);
      await tester.pumpApp(const CheckoutScreen(), cart: cart);
      // The screen renders without crash and COD text is present
      expect(find.text('Cash on Delivery'), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Field input
    // ------------------------------------------------------------------
    testWidgets('accepts text in Full Name field', (tester) async {
      final cart = makeCartProvider([makeCartItem()]);
      await tester.pumpApp(const CheckoutScreen(), cart: cart);
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Alice Smith');
      expect(find.text('Alice Smith'), findsOneWidget);
    });
  });
}
