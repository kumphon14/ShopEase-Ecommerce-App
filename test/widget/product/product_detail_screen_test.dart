// test/widget/product/product_detail_screen_test.dart
//
// ProductDetailScreen widget tests.
//
// FIXED: ProductDetailScreen.dispose() previously called
//   ScaffoldMessenger.of(context).hideCurrentSnackBar()
// which threw "Looking up a deactivated widget's ancestor is unsafe"
// during every test teardown. The production code has been fixed by
// removing that call from dispose(). All tests are now un-skipped.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shopease_ecommerce_app/screens/product/product_detail_screen.dart';
import 'package:shopease_ecommerce_app/services/providers/auth_provider.dart';
import 'package:shopease_ecommerce_app/services/providers/cart_provider.dart';
import 'package:shopease_ecommerce_app/services/providers/category_provider.dart';
import 'package:shopease_ecommerce_app/services/providers/order_provider.dart';
import 'package:shopease_ecommerce_app/services/providers/payment_provider.dart';
import 'package:shopease_ecommerce_app/services/providers/product_provider.dart';
import 'package:shopease_ecommerce_app/services/providers/wishlist_provider.dart';

import '../helpers/fake_providers.dart';


Future<void> _pumpDetail(WidgetTester tester, String productId) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: makeAuthProvider()),
        ChangeNotifierProvider<ProductProvider>.value(
            value: makeProductProvider()),
        ChangeNotifierProvider<CategoryProvider>.value(
            value: makeCategoryProvider()),
        ChangeNotifierProvider<CartProvider>.value(value: CartProvider()),
        ChangeNotifierProvider<OrderProvider>.value(value: makeOrderProvider()),
        ChangeNotifierProvider<WishlistProvider>.value(
            value: makeWishlistProvider([])),
        ChangeNotifierProvider<PaymentProvider>.value(
            value: makePaymentProvider()),
      ],
      child: MaterialApp(
        onGenerateInitialRoutes: (_) => [
          MaterialPageRoute(
            settings:
                RouteSettings(name: '/product_detail', arguments: productId),
            builder: (_) => const ProductDetailScreen(),
          ),
        ],
        onGenerateRoute: (settings) => MaterialPageRoute(
          settings: settings,
          builder: (_) => Scaffold(
            appBar: AppBar(title: Text(settings.name ?? '')),
            body: const SizedBox(),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('ProductDetailScreen', () {
    // ------------------------------------------------------------------
    // Rendering
    // ------------------------------------------------------------------
    testWidgets('renders Description section heading', (tester) async {
      await _pumpDetail(tester, 'p1');
      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('renders Quantity label', (tester) async {
      await _pumpDetail(tester, 'p1');
      expect(find.text('Quantity'), findsOneWidget);
    });

    testWidgets('renders Total Price label', (tester) async {
      await _pumpDetail(tester, 'p1');
      expect(find.text('Total Price'), findsOneWidget);
    });

    testWidgets('renders Add to Cart button', (tester) async {
      await _pumpDetail(tester, 'p1');
      expect(find.text('Add to Cart'), findsOneWidget);
    });

    testWidgets('renders wishlist favorite_border icon', (tester) async {
      await _pumpDetail(tester, 'p1');
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('renders cart icon in app bar', (tester) async {
      await _pumpDetail(tester, 'p1');
      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    });

    testWidgets('renders back arrow icon', (tester) async {
      await _pumpDetail(tester, 'p1');
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('renders Scaffold', (tester) async {
      await _pumpDetail(tester, 'p1');
      expect(find.byType(Scaffold), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Quantity controls
    // ------------------------------------------------------------------
    testWidgets('default quantity is 1', (tester) async {
      await _pumpDetail(tester, 'p1');
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('tapping increment increases quantity to 2', (tester) async {
      await _pumpDetail(tester, 'p1');
      // Scroll the quantity controls into view (they are below the fold)
      await tester.ensureVisible(find.byIcon(Icons.add));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add), warnIfMissed: false);
      await tester.pump();
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('tapping decrement when at 1 keeps quantity at 1', (tester) async {
      await _pumpDetail(tester, 'p1');
      // Scroll the quantity controls into view (they are below the fold)
      await tester.ensureVisible(find.byIcon(Icons.remove));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.remove), warnIfMissed: false);
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Add to Cart
    // ------------------------------------------------------------------
    testWidgets('tapping Add to Cart shows snackbar', (tester) async {
      await _pumpDetail(tester, 'p1');
      await tester.tap(find.text('Add to Cart'));
      await tester.pump();
      expect(find.textContaining('added to cart!'), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Back navigation
    // ------------------------------------------------------------------
    testWidgets('back icon is rendered and tappable without crashing', (tester) async {
      await _pumpDetail(tester, 'p1');
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });
}
