// test/unit/services/mock_data_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/services/mock_data.dart';

void main() {
  group('MockData', () {
    group('products', () {
      test('contains exactly 8 products', () {
        expect(MockData.products.length, equals(8));
      });

      test('every product has a non-empty id', () {
        for (final product in MockData.products) {
          expect(product.id, isNotEmpty,
              reason: 'Found product with empty id');
        }
      });

      test('every product has a non-empty name', () {
        for (final product in MockData.products) {
          expect(product.name, isNotEmpty,
              reason: 'Product ${product.id} has empty name');
        }
      });

      test('every product has a non-empty imageUrl', () {
        for (final product in MockData.products) {
          expect(product.imageUrl, isNotEmpty,
              reason: 'Product ${product.id} has empty imageUrl');
        }
      });

      test('every product has a positive price', () {
        for (final product in MockData.products) {
          expect(product.price > 0, isTrue,
              reason: 'Product ${product.id} has non-positive price: ${product.price}');
        }
      });

      test('every product has a rating in range [1.0, 5.0]', () {
        for (final product in MockData.products) {
          expect(
            product.rating >= 1.0 && product.rating <= 5.0,
            isTrue,
            reason: 'Product ${product.id} has out-of-range rating: ${product.rating}',
          );
        }
      });

      test('every product categoryId exists in MockData.categories', () {
        final categoryIds = MockData.categories.map((c) => c.id).toSet();
        for (final product in MockData.products) {
          expect(
            categoryIds.contains(product.categoryId),
            isTrue,
            reason: 'Product ${product.id} has unknown categoryId: ${product.categoryId}',
          );
        }
      });

      test('all product ids are unique', () {
        final ids = MockData.products.map((p) => p.id).toList();
        expect(ids.toSet().length, equals(ids.length));
      });
    });

    group('categories', () {
      test('contains exactly 4 categories', () {
        expect(MockData.categories.length, equals(4));
      });

      test('every category has a non-empty id', () {
        for (final category in MockData.categories) {
          expect(category.id, isNotEmpty,
              reason: 'Found category with empty id');
        }
      });

      test('every category has a non-empty name', () {
        for (final category in MockData.categories) {
          expect(category.name, isNotEmpty,
              reason: 'Category ${category.id} has empty name');
        }
      });

      test('every category has a non-empty imageUrl', () {
        for (final category in MockData.categories) {
          expect(category.imageUrl, isNotEmpty,
              reason: 'Category ${category.id} has empty imageUrl');
        }
      });

      test('all category ids are unique', () {
        final ids = MockData.categories.map((c) => c.id).toList();
        expect(ids.toSet().length, equals(ids.length));
      });
    });

    group('banners', () {
      test('contains exactly 3 banners', () {
        expect(MockData.banners.length, equals(3));
      });

      test('every banner has a title key', () {
        for (final banner in MockData.banners) {
          expect(banner.containsKey('title'), isTrue);
        }
      });

      test('every banner has a subtitle key', () {
        for (final banner in MockData.banners) {
          expect(banner.containsKey('subtitle'), isTrue);
        }
      });

      test('every banner has an imageUrl key', () {
        for (final banner in MockData.banners) {
          expect(banner.containsKey('imageUrl'), isTrue);
        }
      });

      test('every banner has a tag key', () {
        for (final banner in MockData.banners) {
          expect(banner.containsKey('tag'), isTrue);
        }
      });

      test('every banner title is non-empty', () {
        for (final banner in MockData.banners) {
          expect((banner['title'] as String).isNotEmpty, isTrue);
        }
      });

      test('every banner tag is non-empty', () {
        for (final banner in MockData.banners) {
          expect((banner['tag'] as String).isNotEmpty, isTrue);
        }
      });
    });
  });
}
