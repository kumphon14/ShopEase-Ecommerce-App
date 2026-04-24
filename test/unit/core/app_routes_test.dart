// test/unit/core/app_routes_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/core/routes/app_routes.dart';

void main() {
  // Collect all route constants in declaration order
  final allRoutes = [
    AppRoutes.splash,
    AppRoutes.landing,
    AppRoutes.login,
    AppRoutes.signup,
    AppRoutes.mainNav,
    AppRoutes.home,
    AppRoutes.category,
    AppRoutes.search,
    AppRoutes.productDetail,
    AppRoutes.cart,
    AppRoutes.checkout,
    AppRoutes.orderHistory,
    AppRoutes.editProfile,
    AppRoutes.profile,
    AppRoutes.wishlist,
    AppRoutes.notifications,
    AppRoutes.adminLogin,
    AppRoutes.adminDashboard,
    AppRoutes.manageProducts,
    AppRoutes.addProduct,
    AppRoutes.manageOrders,
    AppRoutes.manageBankDetails,
    AppRoutes.orderArchive,
    AppRoutes.editProduct,
    AppRoutes.manageCategories,
  ];

  group('AppRoutes', () {
    group('constant format', () {
      test('all route constants are non-empty strings', () {
        for (final route in allRoutes) {
          expect(route, isNotEmpty,
              reason: 'Found empty route constant');
        }
      });

      test('all route constants start with /', () {
        for (final route in allRoutes) {
          expect(route.startsWith('/'), isTrue,
              reason: 'Route "$route" does not start with /');
        }
      });
    });

    group('uniqueness', () {
      test('all route constants are unique (no duplicates)', () {
        expect(allRoutes.toSet().length, equals(allRoutes.length));
      });
    });

    group('specific route values', () {
      test('splash is /', () {
        expect(AppRoutes.splash, equals('/'));
      });

      test('login is /login', () {
        expect(AppRoutes.login, equals('/login'));
      });

      test('adminLogin is /admin_login', () {
        expect(AppRoutes.adminLogin, equals('/admin_login'));
      });

      test('signup is /signup', () {
        expect(AppRoutes.signup, equals('/signup'));
      });

      test('cart is /cart', () {
        expect(AppRoutes.cart, equals('/cart'));
      });

      test('checkout is /checkout', () {
        expect(AppRoutes.checkout, equals('/checkout'));
      });

      test('orderHistory is /order_history', () {
        expect(AppRoutes.orderHistory, equals('/order_history'));
      });

      test('adminDashboard is /admin_dashboard', () {
        expect(AppRoutes.adminDashboard, equals('/admin_dashboard'));
      });
    });

    group('total count', () {
      test('AppRoutes defines exactly 25 route constants', () {
        expect(allRoutes.length, equals(25));
      });
    });
  });
}
