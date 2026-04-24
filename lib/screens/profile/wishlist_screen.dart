// lib/screens/profile/wishlist_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../services/providers/wishlist_provider.dart';
import '../../widgets/product_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = Provider.of<WishlistProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('My Wishlist'),
        backgroundColor: Colors.white,
        actions: [
          if (wishlist.items.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Wishlist'),
                    content: const Text('Remove all items from wishlist?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          for (final p in [...wishlist.items]) {
                            wishlist.remove(p.id);
                          }
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'Clear All',
                          style: TextStyle(color: AppTheme.errorColor),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                'Clear',
                style: TextStyle(color: AppTheme.errorColor),
              ),
            ),
        ],
      ),
      body: wishlist.items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: AppTheme.textLightColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No saved items yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDarkColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap the heart on any product\nto add it to your wishlist.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textMediumColor),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.mainNav),
                    child: const Text('Browse Products'),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: wishlist.items.length,
              itemBuilder: (_, i) => ProductCard(
                key: ValueKey<String>(
                  'shopease.wishlist.productCard.${wishlist.items[i].id}',
                ),
                product: wishlist.items[i],
              ),
            ),
    );
  }
}
