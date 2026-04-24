import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/providers/product_provider.dart';
import '../../services/providers/cart_provider.dart';
import '../../services/providers/category_provider.dart';
import '../../widgets/product_card.dart';
import '../../core/routes/app_routes.dart';

class CategoryProductsScreen extends StatelessWidget {
  const CategoryProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryId = ModalRoute.of(context)!.settings.arguments as String;
    final productData = Provider.of<ProductProvider>(context);
    final categoryData = Provider.of<CategoryProvider>(context);
    final cartItemCount = Provider.of<CartProvider>(context).itemCount;

    final displayedProducts = productData.findByCategory(categoryId);

    final category = categoryData.categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => throw Exception('Category not found'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        actions: [
          IconButton(
            icon: Badge(
              label: Text(cartItemCount.toString()),
              isLabelVisible: cartItemCount > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
          ),
        ],
      ),
      body: displayedProducts.isEmpty
          ? const Center(
              child: Text('No products found in this category.'),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: displayedProducts.length,
              itemBuilder: (ctx, i) =>
                  ProductCard(product: displayedProducts[i]),
            ),
    );
  }
}