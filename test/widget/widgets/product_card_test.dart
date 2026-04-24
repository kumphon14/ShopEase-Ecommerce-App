// test/widget/widgets/product_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shopease_ecommerce_app/services/providers/wishlist_provider.dart';
import 'package:shopease_ecommerce_app/widgets/product_card.dart';

import '../helpers/fake_providers.dart';

Widget _wrapWithWishlist(Widget child, WishlistProvider wishlist) =>
    MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<WishlistProvider>.value(
          value: wishlist,
          child: child,
        ),
      ),
      onGenerateRoute: (settings) => MaterialPageRoute(
        settings: settings,
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(settings.name ?? '')),
          body: const SizedBox(),
        ),
      ),
    );

void main() {
  group('ProductCard', () {
    // ------------------------------------------------------------------
    // Rendering
    // ------------------------------------------------------------------
    testWidgets('renders product name', (tester) async {
      final product = makeProduct(name: 'Stellar Phone');
      await tester.pumpWidget(
        _wrapWithWishlist(
          ProductCard(product: product),
          makeWishlistProvider([]),
        ),
      );
      expect(find.text('Stellar Phone'), findsOneWidget);
    });

    testWidgets('renders product price', (tester) async {
      final product = makeProduct(price: 249.99);
      await tester.pumpWidget(
        _wrapWithWishlist(
          ProductCard(product: product),
          makeWishlistProvider([]),
        ),
      );
      expect(find.textContaining('249'), findsOneWidget);
    });

    testWidgets('renders rating value', (tester) async {
      final product = makeProduct(rating: 4.5);
      await tester.pumpWidget(
        _wrapWithWishlist(
          ProductCard(product: product),
          makeWishlistProvider([]),
        ),
      );
      expect(find.textContaining('4.5'), findsOneWidget);
    });

    testWidgets('renders unfilled heart icon when not wishlisted', (tester) async {
      final product = makeProduct(id: 'p1');
      await tester.pumpWidget(
        _wrapWithWishlist(
          ProductCard(product: product),
          makeWishlistProvider([]),
        ),
      );
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('renders icons (star, heart, etc.)', (tester) async {
      final product = makeProduct();
      await tester.pumpWidget(
        _wrapWithWishlist(
          ProductCard(product: product),
          makeWishlistProvider([]),
        ),
      );
      final icons = tester.widgetList<Icon>(find.byType(Icon)).toList();
      expect(icons.isNotEmpty, isTrue);
    });

    // ------------------------------------------------------------------
    // Navigation
    // ------------------------------------------------------------------
    testWidgets('tapping card navigates to product detail', (tester) async {
      var pushed = false;
      final product = makeProduct(id: 'p1');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<WishlistProvider>.value(
              value: makeWishlistProvider([]),
              child: ProductCard(product: product),
            ),
          ),
          onGenerateRoute: (settings) {
            pushed = true;
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const SizedBox(),
            );
          },
        ),
      );
      await tester.tap(find.byType(GestureDetector).first, warnIfMissed: false);
      await tester.pump();
      expect(pushed, isTrue);
    });
  });
}
