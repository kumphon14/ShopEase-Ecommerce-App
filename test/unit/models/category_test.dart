// test/unit/models/category_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/models/category.dart';

void main() {
  group('CategoryModel', () {
    group('constructor', () {
      test('stores all required fields correctly', () {
        final category = CategoryModel(
          id: 'c1',
          name: 'Electronics',
          imageUrl: 'https://example.com/elec.jpg',
        );

        expect(category.id, equals('c1'));
        expect(category.name, equals('Electronics'));
        expect(category.imageUrl, equals('https://example.com/elec.jpg'));
      });

      test('accepts empty strings without error (no model-level validation)', () {
        final category = CategoryModel(id: '', name: '', imageUrl: '');

        expect(category.id, equals(''));
        expect(category.name, equals(''));
        expect(category.imageUrl, equals(''));
      });
    });

    group('edge cases', () {
      test('accepts very long name string', () {
        final longName = 'A' * 500;
        final category = CategoryModel(id: 'c1', name: longName, imageUrl: '');

        expect(category.name.length, equals(500));
      });
    });
  });
}
