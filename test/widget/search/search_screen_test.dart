// test/widget/search/search_screen_test.dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/screens/search/search_screen.dart';
import 'package:shopease_ecommerce_app/services/providers/product_provider.dart';

import '../helpers/pump_app.dart';

void main() {
  group('SearchScreen', () {
    testWidgets('renders empty state initially', (tester) async {
      await tester.pumpApp(const SearchScreen());
      expect(find.text('Start searching'), findsOneWidget);
    });

    testWidgets('displays no results when searching for unknown product', (tester) async {
      final firestore = FakeFirebaseFirestore();
      final productProvider = ProductProvider(firestore: firestore);

      await tester.pumpApp(const SearchScreen(), products: productProvider);
      
      await tester.enterText(find.byType(TextField), 'unknown');
      await tester.pumpAndSettle();

      expect(find.text('No results found'), findsOneWidget);
    });

    testWidgets('displays results when products match', (tester) async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('products').doc('p1').set({
        'name': 'Laptop',
        'price': 999.0,
        'categoryId': 'c1',
        'isFeatured': false,
        'rating': 4.5,
        'imageUrl': '',
        'description': 'A laptop',
      });
      final productProvider = ProductProvider(firestore: firestore);

      await tester.pumpApp(const SearchScreen(), products: productProvider);
      
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'lap');
      await tester.pumpAndSettle();

      expect(find.text('Laptop'), findsOneWidget);
    });
  });
}
