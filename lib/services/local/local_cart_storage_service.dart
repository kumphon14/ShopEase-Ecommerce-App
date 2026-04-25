import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/local_cart_item.dart';

class LocalCartStorageService {
  static const String guestCartKey = 'shop_ease_cart_guest';
  static const String _keyPrefix = 'shop_ease_cart_';

  String storageKeyForUser(String? userId) {
    final trimmedUserId = userId?.trim() ?? '';
    if (trimmedUserId.isEmpty) {
      return guestCartKey;
    }
    return '$_keyPrefix$trimmedUserId';
  }

  Future<List<LocalCartItem>> loadCartItems({String? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(storageKeyForUser(userId));
      if (raw == null || raw.trim().isEmpty) {
        return const [];
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) => LocalCartItem.fromJson(Map<String, dynamic>.from(item)),
          )
          .where((item) => item.productId.isNotEmpty && item.quantity > 0)
          .toList();
    } catch (e) {
      debugPrint('LocalCartStorageService.loadCartItems error: $e');
      return const [];
    }
  }

  Future<void> saveCartItems(
    List<LocalCartItem> items, {
    String? userId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (items.isEmpty) {
        await prefs.remove(storageKeyForUser(userId));
        return;
      }

      final payload = jsonEncode(items.map((item) => item.toJson()).toList());
      await prefs.setString(storageKeyForUser(userId), payload);
    } catch (e) {
      debugPrint('LocalCartStorageService.saveCartItems error: $e');
    }
  }

  Future<void> clearCart({String? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(storageKeyForUser(userId));
    } catch (e) {
      debugPrint('LocalCartStorageService.clearCart error: $e');
    }
  }
}
