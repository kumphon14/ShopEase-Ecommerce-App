// test/widget/helpers/pump_app.dart
//
// Core harness: pumpApp wraps a widget in MaterialApp with all providers.
// All providers use real types backed by FakeFirebaseFirestore/MockFirebaseAuth.
// Everything is synchronous to avoid issues with fake time in flutter_test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shopease_ecommerce_app/services/providers/auth_provider.dart';
import 'package:shopease_ecommerce_app/services/providers/cart_provider.dart';
import 'package:shopease_ecommerce_app/services/providers/category_provider.dart';
import 'package:shopease_ecommerce_app/services/providers/order_provider.dart';
import 'package:shopease_ecommerce_app/services/providers/payment_provider.dart';
import 'package:shopease_ecommerce_app/services/providers/product_provider.dart';
import 'package:shopease_ecommerce_app/services/providers/wishlist_provider.dart';

import 'fake_providers.dart';

extension PumpApp on WidgetTester {
  /// Pump a screen widget inside a MaterialApp with all providers injected.
  /// All provider creation is synchronous.
  Future<void> pumpApp(
    Widget widget, {
    AuthProvider? auth,
    ProductProvider? products,
    CategoryProvider? categories,
    CartProvider? cart,
    OrderProvider? orders,
    WishlistProvider? wishlist,
    PaymentProvider? payment,
    List<NavigatorObserver> observers = const [],
  }) async {
    await pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(
              value: auth ?? makeAuthProvider()),
          ChangeNotifierProvider<ProductProvider>.value(
              value: products ?? makeProductProvider()),
          ChangeNotifierProvider<CategoryProvider>.value(
              value: categories ?? makeCategoryProvider()),
          ChangeNotifierProvider<CartProvider>.value(
              value: cart ?? CartProvider()),
          ChangeNotifierProvider<OrderProvider>.value(
              value: orders ?? makeOrderProvider()),
          ChangeNotifierProvider<WishlistProvider>.value(
              value: wishlist ?? makeWishlistProvider([])),
          ChangeNotifierProvider<PaymentProvider>.value(
              value: payment ?? makePaymentProvider()),
        ],
        child: MaterialApp(
          home: widget,
          navigatorObservers: observers,
          // Fallback route so Navigator.pushNamed won't throw
          onGenerateRoute: (settings) => MaterialPageRoute(
            settings: settings,
            builder: (_) => Scaffold(
              appBar: AppBar(title: Text(settings.name ?? 'Route')),
              body: const SizedBox(),
            ),
          ),
        ),
      ),
    );
  }
}
