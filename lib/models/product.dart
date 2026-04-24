// lib/models/product.dart
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String categoryId;
  final bool isFeatured;
  double rating; // Admin-assigned star rating (1-5)

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    this.isFeatured = false,
    this.rating = 4.0,
  });
}
