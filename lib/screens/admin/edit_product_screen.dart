import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/product.dart';
import '../../services/providers/product_provider.dart';
import '../../services/providers/category_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  late TextEditingController _imageUrlController;
  String? _selectedCategoryId;
  double _rating = 4.0;
  bool _isFeatured = false;

  Product? _existingProduct;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final product = ModalRoute.of(context)?.settings.arguments as Product?;
      if (product != null) {
        _existingProduct = product;
        _nameController = TextEditingController(text: product.name);
        _priceController = TextEditingController(text: product.price.toString());
        _descController = TextEditingController(text: product.description);
        _imageUrlController = TextEditingController(text: product.imageUrl);
        _selectedCategoryId = product.categoryId;
        _rating = product.rating;
        _isFeatured = product.isFeatured;
      } else {
        _nameController = TextEditingController();
        _priceController = TextEditingController();
        _descController = TextEditingController();
        _imageUrlController = TextEditingController();
      }
      _isInit = false;
    }
  }

  void _updateProduct() {
    if (_formKey.currentState!.validate() && _existingProduct != null) {
      final updatedProduct = Product(
        id: _existingProduct!.id,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        price: double.parse(_priceController.text),
        imageUrl: _imageUrlController.text.isEmpty
            ? 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=800&q=80'
            : _imageUrlController.text.trim(),
        categoryId: _selectedCategoryId ?? '',
        isFeatured: _isFeatured,
        rating: _rating,
      );

      try {
        Provider.of<ProductProvider>(context, listen: false)
            .updateProduct(_existingProduct!.id, updatedProduct);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.successColor,
            content: const Text('Product updated successfully!'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );

        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.errorColor,
            content: const Text('Error updating product!'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_existingProduct == null) {
      return const Scaffold(
        body: Center(child: Text('Product not found!')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Edit Product'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_imageUrlController.text.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    _imageUrlController.text,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Product Information',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Product Name',
                      hint: 'e.g. TechPro Smartphone X',
                      controller: _nameController,
                      prefixIcon: Icons.label_outline,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Price',
                      hint: 'e.g. 99.99',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      controller: _priceController,
                      prefixIcon: Icons.attach_money,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Price is required';
                        if (double.tryParse(v) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Description',
                      hint: 'Enter product description...',
                      controller: _descController,
                      maxLines: 3,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Description is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Image URL',
                      hint: 'https://example.com/image.jpg',
                      controller: _imageUrlController,
                      prefixIcon: Icons.image_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category & Settings',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: Provider.of<CategoryProvider>(context)
                          .categories
                          .map((cat) {
                        final isSelected = _selectedCategoryId == cat.id;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategoryId = cat.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : AppTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : AppTheme.textLightColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              cat.name,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.textDarkColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Initial Rating',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: List.generate(
                        5,
                        (i) => GestureDetector(
                          onTap: () => setState(() => _rating = i + 1.0),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              i < _rating ? Icons.star : Icons.star_border,
                              color: AppTheme.warningColor,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mark as Featured',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Switch(
                          value: _isFeatured,
                          onChanged: (val) => setState(() => _isFeatured = val),
                          activeThumbColor: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Update Product',
                onPressed: _updateProduct,
                icon: Icons.save_outlined,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}