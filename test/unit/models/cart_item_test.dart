// test/unit/models/cart_item_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/models/cart_item.dart';
import 'package:shopease_ecommerce_app/models/product.dart';

Product _makeProduct({String id = 'p1', double price = 10.0}) {
  return Product(
    id: id,
    name: 'Test Product',
    description: '',
    price: price,
    imageUrl: '',
    categoryId: 'c1',
  );
}

void main() {
  group('CartItem', () {
    group('constructor', () {
      test('stores required fields correctly', () {
        final product = _makeProduct();
        final item = CartItem(id: 'ci1', product: product);

        expect(item.id, equals('ci1'));
        expect(item.product, same(product));
      });

      test('quantity defaults to 1 when not provided', () {
        final item = CartItem(id: 'ci1', product: _makeProduct());

        expect(item.quantity, equals(1));
      });

      test('stores explicit quantity value', () {
        final item = CartItem(id: 'ci1', product: _makeProduct(), quantity: 5);

        expect(item.quantity, equals(5));
      });

      test('accepts quantity of 0 without error (model does not validate)', () {
        final item = CartItem(id: 'ci1', product: _makeProduct(), quantity: 0);

        expect(item.quantity, equals(0));
      });
    });

    group('quantity mutability', () {
      test('quantity can be mutated after construction', () {
        final item = CartItem(id: 'ci1', product: _makeProduct());

        item.quantity = 3;

        expect(item.quantity, equals(3));
      });
    });

    group('edge cases', () {
      test('accepts very large quantity value', () {
        final item = CartItem(id: 'ci1', product: _makeProduct(), quantity: 9999);

        expect(item.quantity, equals(9999));
      });

      test('product reference is preserved exactly', () {
        final product = _makeProduct(id: 'p42', price: 199.99);
        final item = CartItem(id: 'ci1', product: product);

        expect(item.product.id, equals('p42'));
        expect(item.product.price, equals(199.99));
      });
    });
  });
}
