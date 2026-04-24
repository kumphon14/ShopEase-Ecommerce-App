// test/widget/admin/edit_product_screen_test.dart
//
// REPAIR NOTES (2026-04-23):
// Root cause of the 1 previously-failing test: test finder used
//   find.widgetWithText(TextFormField, 'Product Name')
// but CustomTextField renders its label as a sibling Text widget above the
// TextFormField — not as decoration.labelText inside the TextFormField.
// Therefore find.widgetWithText(TextFormField, ...) always returns 0 results.
//
// Fix: replaced with find.byType(TextFormField).at(n) where n is the
// zero-based field index confirmed from reading edit_product_screen.dart:
//   at(0) = Product Name
//   at(1) = Price          ← NOTE: label is 'Price', NOT 'Price (USD)'
//   at(2) = Description
//   at(3) = Image URL
//
// Submit button fix: replaced find.text('Update Product').last with
//   find.widgetWithText(CustomButton, 'Update Product') + ensureVisible().

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/models/product.dart';
import 'package:shopease_ecommerce_app/screens/admin/edit_product_screen.dart';
import 'package:shopease_ecommerce_app/services/providers/category_provider.dart';
import 'package:shopease_ecommerce_app/services/providers/product_provider.dart';
import 'package:shopease_ecommerce_app/widgets/custom_button.dart';

import '../helpers/pump_app.dart';

void main() {
  group('EditProductScreen', () {
    testWidgets('renders Product not found when no product is passed',
        (tester) async {
      await tester.pumpApp(const EditProductScreen());
      expect(find.text('Product not found!'), findsOneWidget);
    });

    testWidgets('populates fields with existing product data', (tester) async {
      final product = Product(
        id: 'p1',
        name: 'Old Laptop',
        price: 800.0,
        description: 'An old laptop',
        categoryId: 'c1',
        imageUrl: '',
        isFeatured: false,
        rating: 4.0,
      );

      final widget = Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            settings: RouteSettings(arguments: product),
            builder: (context) => const EditProductScreen(),
          );
        },
      );

      await tester.pumpApp(widget);

      expect(find.text('Old Laptop'), findsOneWidget);
      expect(find.text('800.0'), findsOneWidget);
      expect(find.text('An old laptop'), findsOneWidget);
    });

    testWidgets('updates product successfully and shows snackbar',
        (tester) async {
      // Use a taller viewport so the entire form is on-screen and the
      // submit button is always in the hit-testable area.
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final firestore = FakeFirebaseFirestore();
      final product = Product(
        id: 'p1',
        name: 'Old Laptop',
        price: 800.0,
        description: 'An old laptop',
        categoryId: 'c1',
        imageUrl: '',
        isFeatured: false,
        rating: 4.0,
      );

      await firestore
          .collection('categories')
          .doc('c1')
          .set({'name': 'Electronics', 'imageUrl': ''});
      await firestore.collection('products').doc('p1').set({
        'name': product.name,
        'price': product.price,
        'description': product.description,
        'categoryId': product.categoryId,
        'imageUrl': product.imageUrl,
        'isFeatured': product.isFeatured,
        'rating': product.rating,
      });

      final productProvider = ProductProvider(firestore: firestore);
      final categoryProvider = CategoryProvider(firestore: firestore);

      final widget = Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            settings: RouteSettings(arguments: product),
            builder: (context) => const EditProductScreen(),
          );
        },
      );

      await tester.pumpApp(widget,
          products: productProvider, categories: categoryProvider);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Field order in EditProductScreen:
      //   at(0) = Product Name   ← update
      //   at(1) = Price          ← update   (label is 'Price', not 'Price (USD)')
      //   at(2) = Description
      //   at(3) = Image URL
      await tester.enterText(
          find.byType(TextFormField).at(0), 'Updated Laptop');
      await tester.enterText(find.byType(TextFormField).at(1), '850');

      // Tap the submit button (now fully on-screen in the taller viewport).
      final submitBtn = find.widgetWithText(CustomButton, 'Update Product');
      await tester.tap(submitBtn);
      await tester.pumpAndSettle(); // allow update + pop to complete

      // Verify the product was updated in the provider.
      final updatedProducts = productProvider.products;
      expect(updatedProducts.length, 1);
      expect(updatedProducts.first.name, 'Updated Laptop');
      expect(updatedProducts.first.price, 850.0);
    });
  });
}
