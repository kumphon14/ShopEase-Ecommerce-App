// test/widget/helpers/fake_providers.dart
//
// Widget-test provider factories.
// All factories are SYNCHRONOUS — no Future.delayed allowed.
// Providers are constructed with FakeFirebaseFirestore / MockFirebaseAuth
// which start with empty state. Product/Category data visible in the UI
// must be seeded into Firestore BEFORE constructing the provider, or
// supplied through a pre-built ProductProvider.

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:shopease_ecommerce_app/models/cart_item.dart';
import 'package:shopease_ecommerce_app/models/category.dart';
import 'package:shopease_ecommerce_app/models/order.dart';
import 'package:shopease_ecommerce_app/models/product.dart';
import 'package:shopease_ecommerce_app/services/providers/auth_provider.dart';
import 'package:shopease_ecommerce_app/services/providers/cart_provider.dart';
import 'package:shopease_ecommerce_app/services/providers/category_provider.dart';
import 'package:shopease_ecommerce_app/services/providers/order_provider.dart';
import 'package:shopease_ecommerce_app/services/providers/payment_provider.dart';
import 'package:shopease_ecommerce_app/services/providers/product_provider.dart';
import 'package:shopease_ecommerce_app/services/providers/wishlist_provider.dart';

// ---------------------------------------------------------------------------
// Seed helpers
// ---------------------------------------------------------------------------
Product makeProduct({
  String id = 'p1',
  String name = 'Test Product',
  double price = 99.99,
  String categoryId = 'c1',
  bool isFeatured = false,
  double rating = 4.0,
  String imageUrl = '',
  String description = 'Test description',
}) =>
    Product(
      id: id,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      categoryId: categoryId,
      isFeatured: isFeatured,
      rating: rating,
    );

CategoryModel makeCategory({
  String id = 'c1',
  String name = 'Electronics',
  String imageUrl = '',
}) =>
    CategoryModel(id: id, name: name, imageUrl: imageUrl);

CartItem makeCartItem({
  String id = 'ci1',
  int quantity = 1,
  Product? product,
}) =>
    CartItem(id: id, product: product ?? makeProduct(), quantity: quantity);

OrderModel makeOrder({
  String id = 'order00000001',
  List<CartItem>? items,
  double totalAmount = 99.99,
  String status = 'Order Placed',
  PaymentMethod paymentMethod = PaymentMethod.cod,
  String paymentStatus = 'Pending',
  String? proofOfTransferPath,
  bool isArchived = false,
  String? customerName = 'Test User',
}) =>
    OrderModel(
      id: id,
      items: items ?? [makeCartItem()],
      totalAmount: totalAmount,
      date: DateTime(2024, 1, 15),
      status: status,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      proofOfTransferPath: proofOfTransferPath,
      isArchived: isArchived,
      customerName: customerName,
    );

// ---------------------------------------------------------------------------
// Provider factories — all synchronous
// ---------------------------------------------------------------------------

/// Auth provider backed by a fake Firebase (no signed-in user by default).
AuthProvider makeAuthProvider({bool signedIn = false}) {
  final mockAuth = MockFirebaseAuth(
    signedIn: signedIn,
    mockUser: signedIn
        ? MockUser(uid: 'uid_001', email: 'test@example.com', displayName: 'Test User')
        : null,
  );
  return AuthProvider(auth: mockAuth, firestore: FakeFirebaseFirestore());
}

/// Product provider backed by empty FakeFirestore.
/// Products visible in UI require seeding separately (see [makeSeededProductProvider]).
ProductProvider makeProductProvider() {
  return ProductProvider(firestore: FakeFirebaseFirestore());
}

/// Category provider backed by empty FakeFirestore.
CategoryProvider makeCategoryProvider() {
  return CategoryProvider(firestore: FakeFirebaseFirestore());
}

/// Cart provider seeded with the given items.
CartProvider makeCartProvider(List<CartItem> items) {
  final provider = CartProvider();
  for (final item in items) {
    for (var i = 0; i < item.quantity; i++) {
      provider.addItem(item.product);
    }
  }
  return provider;
}

/// Wishlist provider backed by empty FakeFirestore (no items).
WishlistProvider makeWishlistProvider(List<Product> products) {
  // WishlistProvider listens to auth state; with MockFirebaseAuth (no user)
  // the items list remains empty. products param is kept for API compatibility.
  return WishlistProvider(
    firestore: FakeFirebaseFirestore(),
    auth: MockFirebaseAuth(),
  );
}

/// Order provider backed by empty FakeFirestore (no orders).
OrderProvider makeOrderProvider() {
  return OrderProvider(
    firestore: FakeFirebaseFirestore(),
    auth: MockFirebaseAuth(),
  );
}

/// Payment provider backed by FakeFirestore.
PaymentProvider makePaymentProvider() {
  return PaymentProvider(firestore: FakeFirebaseFirestore());
}
