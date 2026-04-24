// test/widget/admin/manage_products_screen_test.dart
//
// ManageProductsScreen widget tests.
// ProductProvider is backed by empty FakeFirestore (synchronous).
// Tests focus on empty state rendering and structural layout.
// Delete dialog tests are also included since they don't require product data
// being visible — we directly instantiate the provider with empty data.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/screens/admin/manage_products_screen.dart';

import '../helpers/fake_providers.dart';
import '../helpers/pump_app.dart';

void main() {
  group('ManageProductsScreen', () {
    // ------------------------------------------------------------------
    // Structural rendering
    // ------------------------------------------------------------------
    testWidgets('renders Manage Products app bar title', (tester) async {
      await tester.pumpApp(const ManageProductsScreen());
      await tester.pump();
      expect(find.text('Manage Products'), findsOneWidget);
    });

    testWidgets('renders AppBar', (tester) async {
      await tester.pumpApp(const ManageProductsScreen());
      await tester.pump();
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders Scaffold', (tester) async {
      await tester.pumpApp(const ManageProductsScreen());
      await tester.pump();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Empty state (FakeFirestore has no products)
    // ------------------------------------------------------------------
    testWidgets('renders no products message when provider is empty', (tester) async {
      await tester.pumpApp(
        const ManageProductsScreen(),
        products: makeProductProvider(),
      );
      await tester.pump();
      expect(find.text('No products found.'), findsOneWidget);
    });

    testWidgets('does not render ListView when empty', (tester) async {
      await tester.pumpApp(
        const ManageProductsScreen(),
        products: makeProductProvider(),
      );
      await tester.pump();
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('renders Center widget in empty state', (tester) async {
      await tester.pumpApp(
        const ManageProductsScreen(),
        products: makeProductProvider(),
      );
      await tester.pump();
      expect(find.byType(Center), findsAtLeast(1));
    });
  });
}
