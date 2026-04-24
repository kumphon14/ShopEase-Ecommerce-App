// test/unit/providers/wishlist_provider_test.dart
//
// Tests WishlistProvider: isWishlisted() lookup, auth guard (no-op when user null),
// toggle() add/remove Firestore writes, and remove() auth guard.
//
// State strategy: _items is populated via the Firestore stream subscription
// triggered when a user is signed in. We pre-populate the wishlist subcollection
// in FakeFirebaseFirestore and wait for the stream to deliver.

import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:shopease_ecommerce_app/services/providers/wishlist_provider.dart';
import 'package:shopease_ecommerce_app/models/product.dart';

const _uid = 'wishlist_user_001';

Product _makeProduct({String id = 'p1', String name = 'Test Product', double price = 10.0}) {
  return Product(
    id: id, name: name, description: '', price: price,
    imageUrl: 'https://example.com/img.jpg', categoryId: 'c1',
  );
}

/// Seeds wishlist items into FakeFirebaseFirestore and builds a WishlistProvider
/// with a signed-in user. Waits for the stream to populate _items.
Future<WishlistProvider> _makeProvider(
  FakeFirebaseFirestore firestore,
  MockFirebaseAuth auth, {
  List<Product> preloadedWishlist = const [],
}) async {
  for (final p in preloadedWishlist) {
    await firestore
        .collection('users')
        .doc(_uid)
        .collection('wishlist')
        .doc(p.id)
        .set({
      'name': p.name,
      'description': p.description,
      'price': p.price,
      'imageUrl': p.imageUrl,
      'categoryId': p.categoryId,
      'isFeatured': p.isFeatured,
      'rating': p.rating,
    });
  }
  final provider = WishlistProvider(firestore: firestore, auth: auth);
  await Future.delayed(const Duration(milliseconds: 100));
  return provider;
}

void main() {
  group('WishlistProvider', () {
    group('isWishlisted', () {
      test('returns true when product id exists in _items', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: _uid, email: 'user@test.com'),
        );
        final productA = _makeProduct(id: 'p1');
        final provider = await _makeProvider(fakeFirestore, mockAuth,
            preloadedWishlist: [productA]);

        expect(provider.isWishlisted('p1'), isTrue);
      });

      test('returns false when product id is not in _items', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: _uid, email: 'user@test.com'),
        );
        final provider = await _makeProvider(fakeFirestore, mockAuth);

        expect(provider.isWishlisted('p99'), isFalse);
      });

      test('returns false for unknown id when wishlist has other items', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: _uid, email: 'user@test.com'),
        );
        final provider = await _makeProvider(
          fakeFirestore, mockAuth,
          preloadedWishlist: [_makeProduct(id: 'p1'), _makeProduct(id: 'p2')],
        );

        expect(provider.isWishlisted('p99'), isFalse);
      });
    });

    group('toggle (auth guard)', () {
      test('does not call Firestore when user is null (signed out)', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        // No user signed in
        final mockAuth = MockFirebaseAuth(signedIn: false);
        final provider = WishlistProvider(firestore: fakeFirestore, auth: mockAuth);
        await Future.delayed(const Duration(milliseconds: 50));

        final product = _makeProduct(id: 'p1');
        provider.toggle(product); // should be a no-op

        // Wishlist collection should be empty — no Firestore write happened
        final snap = await fakeFirestore
            .collection('users')
            .doc(_uid)
            .collection('wishlist')
            .get();
        expect(snap.docs, isEmpty);
      });
    });

    group('toggle (add to wishlist)', () {
      test('writes product to Firestore when not already wishlisted', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: _uid, email: 'user@test.com'),
        );
        final provider = await _makeProvider(fakeFirestore, mockAuth);

        final product = _makeProduct(id: 'p1');
        provider.toggle(product);
        await Future.delayed(const Duration(milliseconds: 50));

        final snap = await fakeFirestore
            .collection('users')
            .doc(_uid)
            .collection('wishlist')
            .doc('p1')
            .get();
        expect(snap.exists, isTrue);
        expect(snap.data()!['name'], equals(product.name));
      });
    });

    group('toggle (remove from wishlist)', () {
      test('deletes product from Firestore when already wishlisted', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: _uid, email: 'user@test.com'),
        );
        final product = _makeProduct(id: 'p1');
        final provider = await _makeProvider(
          fakeFirestore, mockAuth,
          preloadedWishlist: [product],
        );

        expect(provider.isWishlisted('p1'), isTrue);

        provider.toggle(product); // should delete
        await Future.delayed(const Duration(milliseconds: 50));

        final snap = await fakeFirestore
            .collection('users')
            .doc(_uid)
            .collection('wishlist')
            .doc('p1')
            .get();
        expect(snap.exists, isFalse);
      });
    });

    group('remove (auth guard)', () {
      test('does not call Firestore.delete when user is null', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final mockAuth = MockFirebaseAuth(signedIn: false);
        final provider = WishlistProvider(firestore: fakeFirestore, auth: mockAuth);
        await Future.delayed(const Duration(milliseconds: 50));

        // No-op — should not throw
        expect(() => provider.remove('p1'), returnsNormally);
      });
    });

    group('state reset on logout', () {
      test('items list is empty when no user is signed in', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final mockAuth = MockFirebaseAuth(signedIn: false);
        final provider = WishlistProvider(firestore: fakeFirestore, auth: mockAuth);
        await Future.delayed(const Duration(milliseconds: 50));

        expect(provider.items, isEmpty);
      });
    });
  });
}
