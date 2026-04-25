import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopease_ecommerce_app/models/local_cart_item.dart';
import 'package:shopease_ecommerce_app/models/product.dart';
import 'package:shopease_ecommerce_app/services/local/local_cart_storage_service.dart';
import 'package:shopease_ecommerce_app/services/providers/cart_provider.dart';

Product _makeProduct({
  String id = 'p1',
  String name = 'Test Product',
  double price = 10.0,
}) {
  return Product(
    id: id,
    name: name,
    description: '',
    price: price,
    imageUrl: '',
    categoryId: 'c1',
  );
}

void main() {
  group('CartProvider', () {
    late CartProvider cart;
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth fakeAuth;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      fakeFirestore = FakeFirebaseFirestore();
      fakeAuth = MockFirebaseAuth();
      cart = CartProvider(
        firestore: fakeFirestore,
        auth: fakeAuth,
        localCartStorageService: LocalCartStorageService(),
      );
    });

    group('initial state', () {
      test('totalAmount is 0.0 on empty cart', () {
        expect(cart.totalAmount, equals(0.0));
      });

      test('itemCount is 0 on empty cart', () {
        expect(cart.itemCount, equals(0));
      });

      test('items is an empty map on empty cart', () {
        expect(cart.items, equals(<String, dynamic>{}));
      });
    });

    group('addItem', () {
      test('adds a new product with quantity 1 on first add', () {
        final product = _makeProduct();
        cart.addItem(product);

        expect(cart.itemCount, equals(1));
        expect(cart.items[product.id]!.quantity, equals(1));
      });

      test('increments quantity to 2 when same product added twice', () {
        final product = _makeProduct();
        cart.addItem(product);
        cart.addItem(product);

        expect(cart.itemCount, equals(1));
        expect(cart.items[product.id]!.quantity, equals(2));
      });

      test('adds two distinct products as two separate entries', () {
        final productA = _makeProduct(id: 'p1', price: 10.0);
        final productB = _makeProduct(id: 'p2', price: 20.0);
        cart.addItem(productA);
        cart.addItem(productB);

        expect(cart.itemCount, equals(2));
      });

      test('totalAmount equals product price after adding product once', () {
        final product = _makeProduct(price: 25.0);
        cart.addItem(product);

        expect(cart.totalAmount, equals(25.0));
      });

      test('totalAmount is price * 2 after adding same product twice', () {
        final product = _makeProduct(price: 25.0);
        cart.addItem(product);
        cart.addItem(product);

        expect(cart.totalAmount, equals(50.0));
      });

      test(
        'totalAmount is sum of both products after adding two distinct products',
        () {
          final productA = _makeProduct(id: 'p1', price: 10.0);
          final productB = _makeProduct(id: 'p2', price: 20.0);
          cart.addItem(productA);
          cart.addItem(productB);

          expect(cart.totalAmount, equals(30.0));
        },
      );

      test('totalAmount stays 0.0 when product price is 0.0', () {
        final product = _makeProduct(price: 0.0);
        cart.addItem(product);

        expect(cart.totalAmount, equals(0.0));
      });
    });

    group('removeItem', () {
      test('removes the product from cart by product id', () {
        final product = _makeProduct();
        cart.addItem(product);
        cart.removeItem(product.id);

        expect(cart.itemCount, equals(0));
      });

      test('does not throw when removing a non-existent product id', () {
        expect(() => cart.removeItem('non_existent'), returnsNormally);
        expect(cart.itemCount, equals(0));
      });

      test(
        'only removes the target product, leaving other products intact',
        () {
          final productA = _makeProduct(id: 'p1');
          final productB = _makeProduct(id: 'p2');
          cart.addItem(productA);
          cart.addItem(productB);

          cart.removeItem(productA.id);

          expect(cart.itemCount, equals(1));
          expect(cart.items.containsKey(productB.id), isTrue);
        },
      );
    });

    group('updateQuantity', () {
      test('sets quantity to the given value when > 0', () {
        final product = _makeProduct(price: 10.0);
        cart.addItem(product);
        cart.updateQuantity(product.id, 5);

        expect(cart.items[product.id]!.quantity, equals(5));
        expect(cart.totalAmount, equals(50.0));
      });

      test('sets quantity to 1', () {
        final product = _makeProduct();
        cart.addItem(product);
        cart.addItem(product);
        cart.updateQuantity(product.id, 1);

        expect(cart.items[product.id]!.quantity, equals(1));
      });

      test('removes product when quantity is set to 0', () {
        final product = _makeProduct();
        cart.addItem(product);
        cart.updateQuantity(product.id, 0);

        expect(cart.itemCount, equals(0));
      });

      test('removes product when quantity is set to a negative value', () {
        final product = _makeProduct();
        cart.addItem(product);
        cart.updateQuantity(product.id, -1);

        expect(cart.itemCount, equals(0));
      });

      test('does nothing when product id is not in cart', () {
        cart.updateQuantity('non_existent', 5);

        expect(cart.itemCount, equals(0));
      });
    });

    group('clear', () {
      test('empties the cart completely', () {
        cart.addItem(_makeProduct(id: 'p1'));
        cart.addItem(_makeProduct(id: 'p2'));
        cart.addItem(_makeProduct(id: 'p3'));
        cart.clear();

        expect(cart.itemCount, equals(0));
        expect(cart.totalAmount, equals(0.0));
      });

      test('does not throw when clearing an already empty cart', () {
        expect(() => cart.clear(), returnsNormally);
      });
    });

    group('totalAmount', () {
      test(
        'calculates correct total across multiple products and quantities',
        () {
          final productA = _makeProduct(id: 'p1', price: 10.0);
          final productB = _makeProduct(id: 'p2', price: 15.0);
          cart.addItem(productA);
          cart.addItem(productA);
          cart.addItem(productB);
          cart.addItem(productB);
          cart.addItem(productB);

          expect(cart.totalAmount, equals(65.0));
        },
      );

      test('handles mix of zero and non-zero priced products', () {
        final freeProduct = _makeProduct(id: 'p_free', price: 0.0);
        final paidProduct = _makeProduct(id: 'p_paid', price: 50.0);
        cart.addItem(freeProduct);
        cart.addItem(paidProduct);

        expect(cart.totalAmount, equals(50.0));
      });
    });

    group('itemCount', () {
      test('reflects distinct product count, not total quantity', () {
        final product = _makeProduct();
        cart.addItem(product);
        cart.addItem(product);
        cart.addItem(product);

        expect(cart.itemCount, equals(1));
      });

      test('returns 10 after adding 10 distinct products', () {
        for (var i = 0; i < 10; i++) {
          cart.addItem(_makeProduct(id: 'p$i'));
        }
        expect(cart.itemCount, equals(10));
      });
    });

    group('items getter (defensive copy)', () {
      test(
        'returned map is a copy and mutating it does not affect provider state',
        () {
          final product = _makeProduct();
          cart.addItem(product);

          final itemsCopy = cart.items;
          itemsCopy.remove(product.id);

          expect(cart.itemCount, equals(1));
        },
      );
    });

    group('local persistence', () {
      late LocalCartStorageService storageService;

      setUp(() {
        SharedPreferences.setMockInitialValues({});
        fakeFirestore = FakeFirebaseFirestore();
        fakeAuth = MockFirebaseAuth();
        storageService = LocalCartStorageService();
      });

      Future<void> seedProduct(Product product) async {
        await fakeFirestore.collection('products').doc(product.id).set({
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'categoryId': product.categoryId,
          'isFeatured': product.isFeatured,
          'rating': product.rating,
          'admin_rating': product.rating,
        });
      }

      test('persists added cart item for guest storage key', () async {
        final product = _makeProduct(id: 'persist_guest');
        await seedProduct(product);

        final provider = CartProvider(
          firestore: fakeFirestore,
          auth: fakeAuth,
          localCartStorageService: storageService,
        );

        provider.addItem(product);
        await Future<void>.delayed(const Duration(milliseconds: 20));

        final stored = await storageService.loadCartItems();
        expect(stored.length, equals(1));
        expect(stored.first.productId, equals(product.id));
        expect(stored.first.quantity, equals(1));
      });

      test('persists quantity updates', () async {
        final product = _makeProduct(id: 'persist_quantity');
        await seedProduct(product);

        final provider = CartProvider(
          firestore: fakeFirestore,
          auth: fakeAuth,
          localCartStorageService: storageService,
        );

        provider.addItem(product);
        provider.updateQuantity(product.id, 4);
        await Future<void>.delayed(const Duration(milliseconds: 20));

        final stored = await storageService.loadCartItems();
        expect(stored.single.productId, equals(product.id));
        expect(stored.single.quantity, equals(4));
      });

      test('clears persisted cart when cart is cleared', () async {
        final product = _makeProduct(id: 'persist_clear');
        await seedProduct(product);

        final provider = CartProvider(
          firestore: fakeFirestore,
          auth: fakeAuth,
          localCartStorageService: storageService,
        );

        provider.addItem(product);
        provider.clear();
        await Future<void>.delayed(const Duration(milliseconds: 20));

        final stored = await storageService.loadCartItems();
        expect(stored, isEmpty);
      });

      test(
        'restores persisted cart items from local storage and Firestore',
        () async {
          final product = _makeProduct(id: 'persist_restore', price: 55.0);
          await seedProduct(product);
          await storageService.saveCartItems([
            LocalCartItem(
              productId: product.id,
              quantity: 3,
              updatedAt: DateTime.now(),
            ),
          ]);

          final provider = CartProvider(
            firestore: fakeFirestore,
            auth: fakeAuth,
            localCartStorageService: storageService,
          );
          await Future<void>.delayed(const Duration(milliseconds: 50));

          expect(provider.itemCount, equals(1));
          expect(provider.items[product.id]!.quantity, equals(3));
          expect(provider.totalAmount, equals(165.0));
        },
      );
    });
  });
}
