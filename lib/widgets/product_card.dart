// lib/widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../core/routes/app_routes.dart';
import '../core/theme/app_theme.dart';
import '../services/providers/wishlist_provider.dart';
import '../utils/currency_utils.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistProvider>(
      builder: (context, wishlist, _) {
        final isWishlisted = wishlist.isWishlisted(product.id);
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.productDetail,
                arguments: product.id);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.08),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with wishlist button
                Expanded(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18)),
                        child: Image.network(
                          product.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (ctx, child, progress) =>
                              progress == null
                                  ? child
                                  : Container(
                                      color: Colors.grey[100],
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                          errorBuilder: (_, _, _) => Container(
                            color: AppTheme.backgroundColor,
                            child: const Center(
                                child: Icon(Icons.image_not_supported,
                                    color: AppTheme.textLightColor)),
                          ),
                        ),
                      ),
                      // Wishlist heart button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => wishlist.toggle(product),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Icon(
                              isWishlisted
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isWishlisted
                                  ? AppTheme.secondaryColor
                                  : AppTheme.textLightColor,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Info section
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppTheme.textDarkColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Star rating
                      Row(
                        children: [
                          ...List.generate(5, (i) {
                            if (i < product.rating.floor()) {
                              return const Icon(Icons.star,
                                  color: AppTheme.warningColor, size: 13);
                            } else if (i < product.rating) {
                              return const Icon(Icons.star_half,
                                  color: AppTheme.warningColor, size: 13);
                            } else {
                              return const Icon(Icons.star_border,
                                  color: AppTheme.warningColor, size: 13);
                            }
                          }),
                          const SizedBox(width: 4),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMediumColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        CurrencyUtils.format(product.price),
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
