// test/unit/providers/product_provider_test.dart
//
// Tests ProductProvider pure filtering methods against an in-memory product list.
// FakeFirebaseFirestore is used to seed the product collection, which the
// provider's stream subscription will pick up in-memory.

import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:shopease_ecommerce_app/services/providers/product_provider.dart';

/// Seeds [firestore] with [products] and returns a provider backed by it.
/// Waits briefly for the stream to emit the first snapshot.
Future<ProductProvider> _makeProvider(
  FakeFirebaseFirestore firestore,
  List<Map<String, dynamic>> products,
) async {
  for (final p in products) {
    await firestore.collection('products').doc(p['id'] as String).set(p);
  }
  final provider = ProductProvider(firestore: firestore);
  // Allow the stream snapshot to be delivered
  await Future.delayed(const Duration(milliseconds: 50));
  return provider;
}

const _base = {
  'description': '',
  'imageUrl': 'https://example.com/img.jpg',
  'isFeatured': false,
  'admin_rating': 4.0,
};

void main() {
  group('ProductProvider', () {
    group('featuredProducts', () {
      test('returns only products where isFeatured is true', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore, [
          {..._base, 'id': 'p1', 'name': 'Featured A', 'price': 100.0, 'categoryId': 'c1', 'isFeatured': true},
          {..._base, 'id': 'p2', 'name': 'Normal B',   'price': 200.0, 'categoryId': 'c1', 'isFeatured': false},
          {..._base, 'id': 'p3', 'name': 'Featured C', 'price': 300.0, 'categoryId': 'c2', 'isFeatured': true},
          {..._base, 'id': 'p4', 'name': 'Normal D',   'price': 400.0, 'categoryId': 'c2', 'isFeatured': false},
        ]);

        expect(provider.featuredProducts.length, equals(2));
        expect(provider.featuredProducts.every((p) => p.isFeatured), isTrue);
      });

      test('returns empty list when no products are featured', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore, [
          {..._base, 'id': 'p1', 'name': 'A', 'price': 10.0, 'categoryId': 'c1', 'isFeatured': false},
        ]);

        expect(provider.featuredProducts, isEmpty);
      });

      test('returns empty list when product collection is empty', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore, []);

        expect(provider.featuredProducts, isEmpty);
      });
    });

    group('findById', () {
      test('returns the matching product when id exists in list', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore, [
          {..._base, 'id': 'p1', 'name': 'Laptop', 'price': 999.0, 'categoryId': 'c1'},
        ]);

        final product = provider.findById('p1');
        expect(product.id, equals('p1'));
        expect(product.name, equals('Laptop'));
      });

      test('returns placeholder with name Loading... when id not in list', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore, [
          {..._base, 'id': 'p1', 'name': 'Laptop', 'price': 999.0, 'categoryId': 'c1'},
        ]);

        final product = provider.findById('p_unknown');
        expect(product.name, equals('Loading...'));
        expect(product.id, equals('p_unknown'));
      });

      test('returns placeholder immediately when product list is empty', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore, []);

        final product = provider.findById('p1');
        expect(product.name, equals('Loading...'));
      });
    });

    group('findByCategory', () {
      test('returns all products matching the given categoryId', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore, [
          {..._base, 'id': 'p1', 'name': 'A', 'price': 10.0, 'categoryId': 'c1'},
          {..._base, 'id': 'p2', 'name': 'B', 'price': 20.0, 'categoryId': 'c1'},
          {..._base, 'id': 'p3', 'name': 'C', 'price': 30.0, 'categoryId': 'c2'},
        ]);

        final results = provider.findByCategory('c1');
        expect(results.length, equals(2));
        expect(results.every((p) => p.categoryId == 'c1'), isTrue);
      });

      test('returns empty list when no products match the categoryId', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore, [
          {..._base, 'id': 'p1', 'name': 'A', 'price': 10.0, 'categoryId': 'c1'},
        ]);

        expect(provider.findByCategory('c99'), isEmpty);
      });

      test('returns empty list for empty string categoryId when no product has empty categoryId', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore, [
          {..._base, 'id': 'p1', 'name': 'A', 'price': 10.0, 'categoryId': 'c1'},
        ]);

        expect(provider.findByCategory(''), isEmpty);
      });
    });

    group('searchByName', () {
      test('returns all products when query is empty string', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore, [
          {..._base, 'id': 'p1', 'name': 'Alpha',   'price': 10.0, 'categoryId': 'c1'},
          {..._base, 'id': 'p2', 'name': 'Beta',    'price': 20.0, 'categoryId': 'c1'},
          {..._base, 'id': 'p3', 'name': 'Gamma',   'price': 30.0, 'categoryId': 'c1'},
        ]);

        expect(provider.searchByName('').length, equals(3));
      });

      test('performs case-insensitive substring match', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore, [
          {..._base, 'id': 'p1', 'name': 'SmartBand Premium',    'price': 10.0, 'categoryId': 'c1'},
          {..._base, 'id': 'p2', 'name': 'TechPro Smartphone X', 'price': 20.0, 'categoryId': 'c1'},
          {..._base, 'id': 'p3', 'name': 'Laptop Pro',           'price': 30.0, 'categoryId': 'c1'},
        ]);

        final results = provider.searchByName('smart');
        expect(results.length, equals(2));
        final names = results.map((p) => p.name).toList();
        expect(names, containsAll(['SmartBand Premium', 'TechPro Smartphone X']));
      });

      test('matches with uppercase query', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore, [
          {..._base, 'id': 'p1', 'name': 'SmartBand', 'price': 10.0, 'categoryId': 'c1'},
          {..._base, 'id': 'p2', 'name': 'Laptop',    'price': 20.0, 'categoryId': 'c1'},
        ]);

        final results = provider.searchByName('SM');
        expect(results.length, equals(1));
        expect(results.first.name, equals('SmartBand'));
      });

      test('returns empty list when no product name matches query', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore, [
          {..._base, 'id': 'p1', 'name': 'Alpha', 'price': 10.0, 'categoryId': 'c1'},
        ]);

        expect(provider.searchByName('zzz'), isEmpty);
      });

      test('returns only the exact matched products (partial string match)', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore, [
          {..._base, 'id': 'p1', 'name': 'Sony Camera',   'price': 10.0, 'categoryId': 'c1'},
          {..._base, 'id': 'p2', 'name': 'Sony Headphone','price': 20.0, 'categoryId': 'c1'},
          {..._base, 'id': 'p3', 'name': 'Samsung TV',    'price': 30.0, 'categoryId': 'c1'},
        ]);

        final results = provider.searchByName('Sony');
        expect(results.length, equals(2));
      });
    });

    group('isLoading', () {
      test('isLoading is false after stream delivers first snapshot', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore, []);
        expect(provider.isLoading, isFalse);
      });
    });

    group('products getter', () {
      test('returns all seeded products', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore, [
          {..._base, 'id': 'p1', 'name': 'A', 'price': 10.0, 'categoryId': 'c1'},
          {..._base, 'id': 'p2', 'name': 'B', 'price': 20.0, 'categoryId': 'c1'},
        ]);

        expect(provider.products.length, equals(2));
      });
    });
  });
}
