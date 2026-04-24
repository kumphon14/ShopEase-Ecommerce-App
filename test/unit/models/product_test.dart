// test/unit/models/product_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/models/product.dart';

void main() {
  group('Product', () {
    group('constructor', () {
      test('stores all required fields correctly', () {
        final product = Product(
          id: 'p1',
          name: 'Test Product',
          description: 'A description',
          price: 99.99,
          imageUrl: 'https://example.com/img.jpg',
          categoryId: 'c1',
        );

        expect(product.id, equals('p1'));
        expect(product.name, equals('Test Product'));
        expect(product.description, equals('A description'));
        expect(product.price, equals(99.99));
        expect(product.imageUrl, equals('https://example.com/img.jpg'));
        expect(product.categoryId, equals('c1'));
      });

      test('isFeatured defaults to false when not provided', () {
        final product = Product(
          id: 'p1',
          name: 'Test',
          description: '',
          price: 10.0,
          imageUrl: '',
          categoryId: 'c1',
        );

        expect(product.isFeatured, isFalse);
      });

      test('rating defaults to 4.0 when not provided', () {
        final product = Product(
          id: 'p1',
          name: 'Test',
          description: '',
          price: 10.0,
          imageUrl: '',
          categoryId: 'c1',
        );

        expect(product.rating, equals(4.0));
      });

      test('stores isFeatured: true when explicitly provided', () {
        final product = Product(
          id: 'p1',
          name: 'Featured',
          description: '',
          price: 10.0,
          imageUrl: '',
          categoryId: 'c1',
          isFeatured: true,
        );

        expect(product.isFeatured, isTrue);
      });

      test('stores explicit rating value', () {
        final product = Product(
          id: 'p1',
          name: 'Test',
          description: '',
          price: 10.0,
          imageUrl: '',
          categoryId: 'c1',
          rating: 3.5,
        );

        expect(product.rating, equals(3.5));
      });
    });

    group('rating mutability', () {
      test('rating can be mutated after construction', () {
        final product = Product(
          id: 'p1',
          name: 'Test',
          description: '',
          price: 10.0,
          imageUrl: '',
          categoryId: 'c1',
        );

        product.rating = 5.0;

        expect(product.rating, equals(5.0));
      });
    });

    group('edge cases', () {
      test('accepts price of 0.0 without error', () {
        final product = Product(
          id: 'p1',
          name: 'Free Product',
          description: '',
          price: 0.0,
          imageUrl: '',
          categoryId: 'c1',
        );

        expect(product.price, equals(0.0));
      });

      test('accepts empty name string without error', () {
        final product = Product(
          id: 'p1',
          name: '',
          description: '',
          price: 10.0,
          imageUrl: '',
          categoryId: 'c1',
        );

        expect(product.name, equals(''));
      });

      test('accepts very large price value', () {
        final product = Product(
          id: 'p1',
          name: 'Expensive',
          description: '',
          price: 999999.99,
          imageUrl: '',
          categoryId: 'c1',
        );

        expect(product.price, equals(999999.99));
      });

      test('rating can be set outside 1-5 range at model level', () {
        final product = Product(
          id: 'p1',
          name: 'Test',
          description: '',
          price: 10.0,
          imageUrl: '',
          categoryId: 'c1',
          rating: 9.9,
        );

        // Model does not clamp — clamping is provider-level
        expect(product.rating, equals(9.9));
      });
    });
  });
}
