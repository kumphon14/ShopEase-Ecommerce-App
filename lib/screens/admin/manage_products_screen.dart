// lib/screens/admin/manage_products_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/providers/product_provider.dart';
import '../../utils/currency_utils.dart';
import '../../widgets/star_rating.dart';

class ManageProductsScreen extends StatelessWidget {
  const ManageProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Manage Products'),
        backgroundColor: Colors.white,
      ),
      body: productProvider.products.isEmpty
          ? const Center(child: Text('No products found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: productProvider.products.length,
              itemBuilder: (ctx, i) {
                final product = productProvider.products[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            product.imageUrl,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 70,
                              height: 70,
                              color: AppTheme.backgroundColor,
                              child: const Icon(Icons.image_not_supported,
                                  color: AppTheme.textLightColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                CurrencyUtils.format(product.price),
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Rating selector
                              Row(
                                children: [
                                  const Text(
                                    'Rating: ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textMediumColor,
                                    ),
                                  ),
                                  StarRating(
                                    rating: product.rating,
                                    size: 16,
                                    interactive: true,
                                    onRatingChanged: (newRating) {
                                      productProvider.updateRating(
                                          product.id, newRating);
                                    },
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    product.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textMediumColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  color: Colors.blue),
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, '/edit_product', arguments: product);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: AppTheme.errorColor),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Product'),
                                    content: Text(
                                        'Delete "${product.name}"? This cannot be undone.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          productProvider.deleteProduct(product.id);
                                          Navigator.pop(ctx);
                                        },
                                        child: const Text('Delete',
                                            style: TextStyle(
                                                color: AppTheme.errorColor)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
