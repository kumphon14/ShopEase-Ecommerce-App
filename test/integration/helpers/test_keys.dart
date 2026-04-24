import 'package:flutter/widgets.dart';

class TestKeys {
  const TestKeys._();

  static ValueKey<String> input(String label) =>
      ValueKey<String>('shopease.input.$label');

  static ValueKey<String> nav(String label) =>
      ValueKey<String>('shopease.nav.$label');

  static const homeCartButton = ValueKey<String>('shopease.home.cartButton');

  static ValueKey<String> productCard(String productId) =>
      ValueKey<String>('shopease.productCard.$productId');

  static ValueKey<String> orderTile(String orderId) =>
      ValueKey<String>('shopease.orderTile.$orderId');

  static ValueKey<String> adminOrderCard(String orderId) =>
      ValueKey<String>('shopease.admin.orderCard.$orderId');

  static ValueKey<String> adminOrderStatus(String orderId, String status) =>
      ValueKey<String>('shopease.admin.orderStatus.$orderId.$status');

  static ValueKey<String> categoryTile(String categoryId) =>
      ValueKey<String>('shopease.categoryTile.$categoryId');

  static const categoryNameInput = ValueKey<String>(
    'shopease.category.nameInput',
  );

  static const categoryImageUrlInput = ValueKey<String>(
    'shopease.category.imageUrlInput',
  );

  static ValueKey<String> productDetailWishlist(String productId) =>
      ValueKey<String>('shopease.productDetail.wishlist.$productId');

  static ValueKey<String> wishlistProductCard(String productId) =>
      ValueKey<String>('shopease.wishlist.productCard.$productId');

  static ValueKey<String> editProfileInput(String label) =>
      ValueKey<String>('shopease.editProfile.input.$label');
}
