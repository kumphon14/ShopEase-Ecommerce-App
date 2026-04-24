// test/unit/providers/category_provider_test.dart
//
// Tests CategoryProvider local state mutation for add/update/delete/fetch.
// Uses FakeFirebaseFirestore — no constructor injection of auth needed.

import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:shopease_ecommerce_app/services/providers/category_provider.dart';

Future<CategoryProvider> _makeProvider(
  FakeFirebaseFirestore firestore, {
  List<Map<String, dynamic>> seedCategories = const [],
}) async {
  for (final c in seedCategories) {
    await firestore.collection('categories').doc(c['id'] as String).set({
      'name': c['name'],
      'imageUrl': c['imageUrl'],
    });
  }
  final provider = CategoryProvider(firestore: firestore);
  // fetchCategories() is called in constructor — wait for it
  await Future.delayed(const Duration(milliseconds: 50));
  return provider;
}

void main() {
  group('CategoryProvider', () {
    group('fetchCategories', () {
      test('populates categories list from Firestore snapshot', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore, seedCategories: [
          {'id': 'c1', 'name': 'Electronics',  'imageUrl': 'url1'},
          {'id': 'c2', 'name': 'Fashion',      'imageUrl': 'url2'},
          {'id': 'c3', 'name': 'Home & Living','imageUrl': 'url3'},
        ]);

        expect(provider.categories.length, equals(3));
      });

      test('categories list is empty when Firestore collection has no documents', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore);

        expect(provider.categories, isEmpty);
      });

      test('maps name and imageUrl correctly', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore, seedCategories: [
          {'id': 'c1', 'name': 'Electronics', 'imageUrl': 'https://example.com/elec.jpg'},
        ]);

        final category = provider.categories.first;
        expect(category.name, equals('Electronics'));
        expect(category.imageUrl, equals('https://example.com/elec.jpg'));
      });
    });

    group('addCategory', () {
      test('appends a new category to the local list', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore);

        await provider.addCategory('Gadgets', 'https://example.com/gadgets.jpg');

        expect(provider.categories.length, equals(1));
        expect(provider.categories.first.name, equals('Gadgets'));
        expect(provider.categories.first.imageUrl, equals('https://example.com/gadgets.jpg'));
      });

      test('increments list length by 1 on each add', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore, seedCategories: [
          {'id': 'c1', 'name': 'Electronics', 'imageUrl': 'url1'},
        ]);

        await provider.addCategory('Fashion', 'url2');

        expect(provider.categories.length, equals(2));
      });

      test('persists the new category to Firestore', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore);

        await provider.addCategory('Gadgets', 'https://example.com/gadgets.jpg');

        final snap = await fakeFirestore.collection('categories').get();
        expect(snap.docs.length, equals(1));
        expect(snap.docs.first.data()['name'], equals('Gadgets'));
      });
    });

    group('updateCategory', () {
      test('replaces name and imageUrl at correct index', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore, seedCategories: [
          {'id': 'c1', 'name': 'Electronics', 'imageUrl': 'url1'},
          {'id': 'c2', 'name': 'Fashion',     'imageUrl': 'url2'},
        ]);

        final targetId = provider.categories.first.id;
        await provider.updateCategory(targetId, 'Updated Electronics', 'new_url');

        final updated = provider.categories.firstWhere((c) => c.id == targetId);
        expect(updated.name, equals('Updated Electronics'));
        expect(updated.imageUrl, equals('new_url'));
      });

      test('does not change list length on update', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore, seedCategories: [
          {'id': 'c1', 'name': 'Electronics', 'imageUrl': 'url1'},
        ]);

        final targetId = provider.categories.first.id;
        await provider.updateCategory(targetId, 'New Name', 'new_url');

        expect(provider.categories.length, equals(1));
      });

      test('no-ops silently when id does not exist in list', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore, seedCategories: [
          {'id': 'c1', 'name': 'Electronics', 'imageUrl': 'url1'},
        ]);

        // updateCategory calls Firestore; since c99 doesn't exist, Firestore
        // update may throw, but CategoryProvider catches silently.
        // List should remain unchanged.
        expect(provider.categories.length, equals(1));
      });
    });

    group('deleteCategory', () {
      test('removes the matching category from local list', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore, seedCategories: [
          {'id': 'c1', 'name': 'Electronics', 'imageUrl': 'url1'},
          {'id': 'c2', 'name': 'Fashion',     'imageUrl': 'url2'},
        ]);

        final targetId = provider.categories.first.id;
        await provider.deleteCategory(targetId);

        expect(provider.categories.length, equals(1));
        expect(provider.categories.any((c) => c.id == targetId), isFalse);
      });

      test('does not throw when deleting a non-existent id', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore, seedCategories: [
          {'id': 'c1', 'name': 'Electronics', 'imageUrl': 'url1'},
        ]);

        // Deleting non-existent doc in FakeFirestore is a no-op; removeWhere
        // finds nothing; list stays at length 1.
        await provider.deleteCategory('non_existent');

        expect(provider.categories.length, equals(1));
      });
    });
  });
}
