import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopease_ecommerce_app/models/local_cart_item.dart';
import 'package:shopease_ecommerce_app/services/local/local_cart_storage_service.dart';

void main() {
  group('LocalCartStorageService', () {
    late LocalCartStorageService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = LocalCartStorageService();
    });

    test('saves and loads cart items for guest storage', () async {
      final items = [
        LocalCartItem(
          productId: 'p1',
          quantity: 2,
          updatedAt: DateTime.parse('2026-04-24T10:00:00.000Z'),
        ),
        LocalCartItem(
          productId: 'p2',
          quantity: 1,
          updatedAt: DateTime.parse('2026-04-24T10:05:00.000Z'),
        ),
      ];

      await service.saveCartItems(items);
      final loaded = await service.loadCartItems();

      expect(loaded.length, equals(2));
      expect(loaded[0].productId, equals('p1'));
      expect(loaded[0].quantity, equals(2));
      expect(loaded[1].productId, equals('p2'));
    });

    test('uses user-specific storage key when uid is provided', () async {
      await service.saveCartItems([
        LocalCartItem(productId: 'p3', quantity: 4, updatedAt: DateTime.now()),
      ], userId: 'user_123');

      final guestItems = await service.loadCartItems();
      final userItems = await service.loadCartItems(userId: 'user_123');

      expect(guestItems, isEmpty);
      expect(userItems.single.productId, equals('p3'));
      expect(userItems.single.quantity, equals(4));
    });

    test('clearCart removes only the targeted cart key', () async {
      await service.saveCartItems([
        LocalCartItem(
          productId: 'guest_product',
          quantity: 1,
          updatedAt: DateTime.now(),
        ),
      ]);
      await service.saveCartItems([
        LocalCartItem(
          productId: 'user_product',
          quantity: 2,
          updatedAt: DateTime.now(),
        ),
      ], userId: 'user_abc');

      await service.clearCart(userId: 'user_abc');

      final guestItems = await service.loadCartItems();
      final userItems = await service.loadCartItems(userId: 'user_abc');

      expect(guestItems.single.productId, equals('guest_product'));
      expect(userItems, isEmpty);
    });

    test('returns empty list when stored JSON is corrupted', () async {
      SharedPreferences.setMockInitialValues({
        LocalCartStorageService.guestCartKey: '{not valid json',
      });

      final reloadedService = LocalCartStorageService();
      final loaded = await reloadedService.loadCartItems();

      expect(loaded, isEmpty);
    });

    test('returns empty list when stored payload is not a list', () async {
      SharedPreferences.setMockInitialValues({
        LocalCartStorageService.guestCartKey: '{"productId":"p1"}',
      });

      final reloadedService = LocalCartStorageService();
      final loaded = await reloadedService.loadCartItems();

      expect(loaded, isEmpty);
    });
  });
}
