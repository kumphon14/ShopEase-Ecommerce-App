import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../models/cart_item.dart';
import '../../models/local_cart_item.dart';
import '../../models/product.dart';
import '../local/local_cart_storage_service.dart';

class CartProvider with ChangeNotifier {
  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;
  final LocalCartStorageService _localCartStorageService;

  Map<String, CartItem> _items = {};
  StreamSubscription<User?>? _authSubscription;
  String _activeStorageKey = LocalCartStorageService.guestCartKey;

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }

  CartProvider({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    LocalCartStorageService? localCartStorageService,
  }) : _firestore = firestore ?? _tryGetFirestore(),
       _auth = auth ?? _tryGetAuth(),
       _localCartStorageService =
           localCartStorageService ?? LocalCartStorageService() {
    unawaited(_restoreCartForUser(_auth?.currentUser));
    _authSubscription = _auth?.authStateChanges().listen(_restoreCartForUser);
  }

  static FirebaseFirestore? _tryGetFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      debugPrint('CartProvider FirebaseFirestore unavailable: $e');
      return null;
    }
  }

  static FirebaseAuth? _tryGetAuth() {
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      debugPrint('CartProvider FirebaseAuth unavailable: $e');
      return null;
    }
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          product: existingCartItem.product,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(
          id: DateTime.now().toString(),
          product: product,
          quantity: 1,
        ),
      );
    }
    unawaited(_persistCart());
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    unawaited(_persistCart());
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (!_items.containsKey(productId)) return;
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    _items.update(
      productId,
      (existingCartItem) => CartItem(
        id: existingCartItem.id,
        product: existingCartItem.product,
        quantity: quantity,
      ),
    );
    unawaited(_persistCart());
    notifyListeners();
  }

  void clear() {
    _items = {};
    unawaited(_persistCart());
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _restoreCartForUser(User? user) async {
    final userId = user?.uid;
    _activeStorageKey = _localCartStorageService.storageKeyForUser(userId);

    final storedItems = await _localCartStorageService.loadCartItems(
      userId: userId,
    );
    if (storedItems.isEmpty) {
      if (_items.isNotEmpty) {
        _items = {};
        notifyListeners();
      }
      return;
    }

    final restoredItems = <String, CartItem>{};
    for (final item in storedItems) {
      final product = await _fetchProduct(item.productId);
      if (product == null) {
        continue;
      }

      restoredItems[item.productId] = CartItem(
        id: item.productId,
        product: product,
        quantity: item.quantity,
      );
    }

    _items = restoredItems;
    notifyListeners();
  }

  Future<Product?> _fetchProduct(String productId) async {
    final firestore = _firestore;
    if (firestore == null) {
      return null;
    }

    try {
      final doc = await firestore.collection('products').doc(productId).get();
      if (!doc.exists) {
        return null;
      }

      final data = doc.data() ?? <String, dynamic>{};
      return Product(
        id: doc.id,
        name: data['name'] ?? '',
        description: data['description'] ?? '',
        price: (data['price'] ?? 0).toDouble(),
        imageUrl: data['imageUrl'] ?? '',
        categoryId: data['categoryId'] ?? '',
        isFeatured: data['isFeatured'] ?? false,
        rating: (data['admin_rating'] ?? data['rating'] ?? 4.0).toDouble(),
      );
    } catch (e) {
      debugPrint('CartProvider._fetchProduct error: $e');
      return null;
    }
  }

  Future<void> _persistCart() async {
    final userId = _auth?.currentUser?.uid;
    final currentKey = _localCartStorageService.storageKeyForUser(userId);
    if (_activeStorageKey != currentKey) {
      _activeStorageKey = currentKey;
    }

    await _localCartStorageService.saveCartItems(
      _items.entries
          .map(
            (entry) => LocalCartItem(
              productId: entry.key,
              quantity: entry.value.quantity,
              updatedAt: DateTime.now(),
            ),
          )
          .toList(),
      userId: userId,
    );
  }
}
