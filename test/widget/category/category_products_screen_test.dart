// test/widget/category/category_products_screen_test.dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/screens/category/category_products_screen.dart';
import 'package:shopease_ecommerce_app/services/providers/category_provider.dart';
import 'package:shopease_ecommerce_app/services/providers/product_provider.dart';

import '../helpers/pump_app.dart';

void main() {
  group('CategoryProductsScreen', () {
    testWidgets('renders category name as title and lists products', (tester) async {
      final firestore = FakeFirebaseFirestore();
      
      await firestore.collection('categories').doc('c1').set({'name': 'Electronics', 'imageUrl': ''});
      await firestore.collection('products').doc('p1').set({
        'name': 'Laptop',
        'price': 999.0,
        'categoryId': 'c1',
        'isFeatured': false,
        'rating': 4.5,
        'imageUrl': '',
        'description': 'A laptop',
      });

      final categoryProvider = CategoryProvider(firestore: firestore);
      final productProvider = ProductProvider(firestore: firestore);
      
      // Inject ModalRoute context using a Navigator
      final widget = Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            settings: const RouteSettings(arguments: 'c1'),
            builder: (context) => const CategoryProductsScreen(),
          );
        },
      );

      await tester.pumpApp(widget, categories: categoryProvider, products: productProvider);
      
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('Electronics'), findsOneWidget);
      expect(find.text('Laptop'), findsOneWidget);
    });

    testWidgets('displays empty state if no products in category', (tester) async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('categories').doc('c1').set({'name': 'Electronics', 'imageUrl': ''});

      final categoryProvider = CategoryProvider(firestore: firestore);
      final productProvider = ProductProvider(firestore: firestore);
      
      final widget = Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            settings: const RouteSettings(arguments: 'c1'),
            builder: (context) => const CategoryProductsScreen(),
          );
        },
      );

      await tester.pumpApp(widget, categories: categoryProvider, products: productProvider);
      
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('No products found in this category.'), findsOneWidget);
    });
  });
}
