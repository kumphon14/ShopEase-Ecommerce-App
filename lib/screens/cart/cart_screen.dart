// lib/screens/cart/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../services/providers/cart_provider.dart';
import '../../utils/currency_utils.dart';
import '../../widgets/cart_tile.dart';
import '../../widgets/custom_button.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: Colors.white,
        actions: [
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: () => cart.clear(),
              child: const Text('Clear All',
                  style: TextStyle(color: AppTheme.errorColor, fontSize: 13)),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: AppTheme.textLightColor),
                  const SizedBox(height: 16),
                  const Text('Your cart is empty',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDarkColor)),
                  const SizedBox(height: 8),
                  const Text('Add items from the store to get started',
                      style: TextStyle(color: AppTheme.textMediumColor)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(
                            context, AppRoutes.mainNav),
                    child: const Text('Continue Shopping'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) {
                      final productId = cart.items.keys.toList()[i];
                      final item = cart.items.values.toList()[i];
                      return CartTile(
                        cartItem: item,
                        onIncrement: () => cart.updateQuantity(
                            productId, item.quantity + 1),
                        onDecrement: () => cart.updateQuantity(
                            productId, item.quantity - 1),
                        onRemove: () => cart.removeItem(productId),
                      );
                    },
                  ),
                ),
                // Bottom summary
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${cart.itemCount} item(s)',
                            style: const TextStyle(
                                color: AppTheme.textMediumColor, fontSize: 14),
                          ),
                          Text(
                            CurrencyUtils.format(cart.totalAmount),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Proceed to Checkout',
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.checkout),
                        icon: Icons.arrow_forward,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
