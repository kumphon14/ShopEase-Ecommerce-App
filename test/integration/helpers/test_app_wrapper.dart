import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopease_ecommerce_app/core/routes/app_routes.dart';
import 'package:shopease_ecommerce_app/core/theme/app_theme.dart';
import 'package:shopease_ecommerce_app/screens/admin/add_product_screen.dart';
import 'package:shopease_ecommerce_app/screens/admin/admin_dashboard_screen.dart';
import 'package:shopease_ecommerce_app/screens/admin/admin_login_screen.dart';
import 'package:shopease_ecommerce_app/screens/admin/edit_product_screen.dart';
import 'package:shopease_ecommerce_app/screens/admin/manage_bank_details_screen.dart';
import 'package:shopease_ecommerce_app/screens/admin/manage_categories_screen.dart';
import 'package:shopease_ecommerce_app/screens/admin/manage_orders_screen.dart';
import 'package:shopease_ecommerce_app/screens/admin/manage_products_screen.dart';
import 'package:shopease_ecommerce_app/screens/auth/login_screen.dart';
import 'package:shopease_ecommerce_app/screens/auth/signup_screen.dart';
import 'package:shopease_ecommerce_app/screens/cart/cart_screen.dart';
import 'package:shopease_ecommerce_app/screens/cart/checkout_screen.dart';
import 'package:shopease_ecommerce_app/screens/category/category_screen.dart';
import 'package:shopease_ecommerce_app/screens/home/home_screen.dart';
import 'package:shopease_ecommerce_app/screens/main_navigation.dart';
import 'package:shopease_ecommerce_app/screens/orders/order_history_screen.dart';
import 'package:shopease_ecommerce_app/screens/product/product_detail_screen.dart';
import 'package:shopease_ecommerce_app/screens/profile/edit_profile_screen.dart';
import 'package:shopease_ecommerce_app/screens/profile/notifications_screen.dart';
import 'package:shopease_ecommerce_app/screens/profile/profile_screen.dart';
import 'package:shopease_ecommerce_app/screens/profile/wishlist_screen.dart';
import 'package:shopease_ecommerce_app/screens/search/search_screen.dart';
import 'package:shopease_ecommerce_app/screens/splash_screen.dart';
import 'package:shopease_ecommerce_app/screens/welcome/landing_screen.dart';
import 'package:shopease_ecommerce_app/services/providers/auth_provider.dart';
import 'package:shopease_ecommerce_app/services/providers/cart_provider.dart';
import 'package:shopease_ecommerce_app/services/providers/category_provider.dart';
import 'package:shopease_ecommerce_app/services/providers/order_provider.dart';
import 'package:shopease_ecommerce_app/services/providers/payment_provider.dart';
import 'package:shopease_ecommerce_app/services/providers/product_provider.dart';
import 'package:shopease_ecommerce_app/services/providers/wishlist_provider.dart';

class TestAppWrapper extends StatelessWidget {
  const TestAppWrapper({super.key, this.initialRoute = AppRoutes.landing});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: MaterialApp(
        title: 'ShopEase',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: initialRoute,
        routes: {
          AppRoutes.splash: (context) => const SplashScreen(),
          AppRoutes.landing: (context) => const LandingScreen(),
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.signup: (context) => const SignupScreen(),
          AppRoutes.mainNav: (context) => const MainNavigation(),
          AppRoutes.home: (context) => const HomeScreen(),
          AppRoutes.category: (context) => const CategoryScreen(),
          AppRoutes.search: (context) => const SearchScreen(),
          AppRoutes.productDetail: (context) => const ProductDetailScreen(),
          AppRoutes.cart: (context) => const CartScreen(),
          AppRoutes.checkout: (context) => const CheckoutScreen(),
          AppRoutes.orderHistory: (context) => const OrderHistoryScreen(),
          AppRoutes.editProfile: (context) => const EditProfileScreen(),
          AppRoutes.profile: (context) => const ProfileScreen(),
          AppRoutes.wishlist: (context) => const WishlistScreen(),
          AppRoutes.notifications: (context) => const NotificationsScreen(),
          AppRoutes.adminLogin: (context) => const AdminLoginScreen(),
          AppRoutes.adminDashboard: (context) => const AdminDashboardScreen(),
          AppRoutes.manageProducts: (context) => const ManageProductsScreen(),
          AppRoutes.addProduct: (context) => const AddProductScreen(),
          AppRoutes.editProduct: (context) => const EditProductScreen(),
          AppRoutes.manageOrders: (context) => const ManageOrdersScreen(),
          AppRoutes.manageBankDetails: (context) =>
              const ManageBankDetailsScreen(),
          AppRoutes.manageCategories: (context) =>
              const ManageCategoriesScreen(),
        },
      ),
    );
  }
}
