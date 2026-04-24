import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/product.dart';
import '../../services/providers/product_provider.dart';
import '../../services/providers/category_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String? _selectedCategoryId;
  double _rating = 4.0;
  bool _isFeatured = false;

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final newProduct = Product(
        id: 'p_${DateTime.now().millisecondsSinceEpoch}',
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

      Provider.of<ProductProvider>(context, listen: false).addProduct(newProduct);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.successColor,
          content: const Text('Product added successfully!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );

      Navigator.pop(context);
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
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Add Product'),
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
                      label: 'Price (USD)',
                      hint: 'e.g. 99.99',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      controller: _priceController,
                      prefixIcon: Icons.attach_money,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Price is required';
                        }
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
                      label: 'Image URL (optional)',
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
                text: 'Add Product',
                onPressed: _saveProduct,
                icon: Icons.add_circle_outline,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}