// test/widget/admin/add_product_screen_test.dart
//
// REPAIR NOTES (2026-04-23):
// Root cause of all 3 previously-failing tests: test finders used
//   find.widgetWithText(TextFormField, '<label>')
// but CustomTextField renders its label as a sibling Text widget above the
// TextFormField — not as decoration.labelText inside the TextFormField.
// Therefore find.widgetWithText(TextFormField, ...) always returns 0 results,
// causing StateError: Bad state: No element.
//
// Fix: replaced with find.byType(TextFormField).at(n) where n is the
// zero-based field index confirmed from reading add_product_screen.dart:
//   at(0) = Product Name
//   at(1) = Price (USD)
//   at(2) = Description
//   at(3) = Image URL (optional)
//
// Submit button fix: replaced find.text('Add Product').last with
//   find.widgetWithText(CustomButton, 'Add Product')
// to avoid ambiguity with the AppBar title Text node.
// Added ensureVisible() before each tap/enterText that targets a field
// that may be below the fold.

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/screens/admin/add_product_screen.dart';
import 'package:shopease_ecommerce_app/services/providers/category_provider.dart';
import 'package:shopease_ecommerce_app/services/providers/product_provider.dart';
import 'package:shopease_ecommerce_app/widgets/custom_button.dart';

import '../helpers/pump_app.dart';

void main() {
  group('AddProductScreen', () {
    testWidgets('renders all fields and add button', (tester) async {
      await tester.pumpApp(const AddProductScreen());
      expect(find.text('Add Product'), findsWidgets);
      expect(find.text('Product Name'), findsOneWidget);
      expect(find.text('Price (USD)'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('shows validation errors when submitting empty form',
        (tester) async {
      await tester.pumpApp(const AddProductScreen());

      // Locate and scroll to the submit button, then tap it.
      final submitBtn = find.widgetWithText(CustomButton, 'Add Product');
      await tester.ensureVisible(submitBtn);
      await tester.pump();
      await tester.tap(submitBtn);
      await tester.pump(); // trigger validation

      expect(find.text('Name is required'), findsOneWidget);
      expect(find.text('Price is required'), findsOneWidget);
      expect(find.text('Description is required'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid price', (tester) async {
      // Use a taller viewport so the entire form is on-screen and the
      // submit button is always in the hit-testable area.
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpApp(const AddProductScreen());

      // Field order in AddProductScreen:
      //   at(0) = Product Name
      //   at(1) = Price (USD)   ← target
      //   at(2) = Description
      //   at(3) = Image URL (optional)
      await tester.enterText(find.byType(TextFormField).at(1), 'abc');
      await tester.pump();

      final submitBtn = find.widgetWithText(CustomButton, 'Add Product');
      await tester.tap(submitBtn);
      await tester.pump();

      expect(find.text('Enter a valid number'), findsOneWidget);
    });

    testWidgets('successfully saves product and shows snackbar', (tester) async {
      final firestore = FakeFirebaseFirestore();
      await firestore
          .collection('categories')
          .doc('c1')
          .set({'name': 'Electronics', 'imageUrl': ''});

      final productProvider = ProductProvider(firestore: firestore);
      final categoryProvider = CategoryProvider(firestore: firestore);

      await tester.pumpApp(
        const AddProductScreen(),
        products: productProvider,
        categories: categoryProvider,
      );

      await tester.pump(const Duration(milliseconds: 100)); // allow streams
      await tester.pumpAndSettle();

      // Field order in AddProductScreen:
      //   at(0) = Product Name   ← fill
      //   at(1) = Price (USD)    ← fill
      //   at(2) = Description    ← fill
      //   at(3) = Image URL (optional)
      await tester.enterText(find.byType(TextFormField).at(0), 'New Phone');
      await tester.enterText(find.byType(TextFormField).at(1), '500');
      await tester.enterText(
          find.byType(TextFormField).at(2), 'A brand new phone');

      // Scroll to category section and tap the Electronics chip.
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -500));
      await tester.pump();

      await tester.tap(find.text('Electronics'), warnIfMissed: false);
      await tester.pump();

      // Tap the submit button.
      final submitBtn = find.widgetWithText(CustomButton, 'Add Product');
      await tester.ensureVisible(submitBtn);
      await tester.pump();
      await tester.tap(submitBtn);
      await tester.pump();

      // Success snackbar should appear.
      expect(find.text('Product added successfully!'), findsOneWidget);

      await tester.pumpAndSettle(); // wait for Navigator.pop animation

      final products = productProvider.products;
      expect(products.length, 1);
      expect(products.first.name, 'New Phone');
    });
  });
}
