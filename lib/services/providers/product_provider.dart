// lib/services/providers/product_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/product.dart';

class ProductProvider with ChangeNotifier {
  final FirebaseFirestore _firestore;
  List<Product> _products = [];
  bool _isLoading = true;

  bool get isLoading => _isLoading;
  List<Product> get products => [..._products];

  List<Product> get featuredProducts => _products.where((p) => p.isFeatured).toList();

  ProductProvider({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _initProductStream();
  }

  void _initProductStream() {
    _firestore.collection('products').snapshots().listen((snapshot) {
      _products = snapshot.docs.map((doc) {
        final data = doc.data();
        return Product(
          id: doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          price: (data['price'] ?? 0).toDouble(),
          imageUrl: data['imageUrl'] ?? '',
          categoryId: data['categoryId'] ?? '',
          isFeatured: data['isFeatured'] ?? false,
          rating: (data['admin_rating'] ?? data['rating'] ?? 4.0).toDouble(),
        );
      }).toList();
      _isLoading = false;
      notifyListeners();
    });
  }

  Product findById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      // Fallback if not found yet
      return Product(id: id, name: 'Loading...', description: '', price: 0, imageUrl: '', categoryId: '');
    }
  }

  List<Product> findByCategory(String categoryId) {
    return _products.where((p) => p.categoryId == categoryId).toList();
  }

  List<Product> searchByName(String query) {
    return _products
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void addProduct(Product product) {
    _firestore.collection('products').add({
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'imageUrl': product.imageUrl,
      'categoryId': product.categoryId,
      'isFeatured': product.isFeatured,
      'admin_rating': product.rating,
      'rating': product.rating,
    });
  }

  void deleteProduct(String id) {
    _firestore.collection('products').doc(id).delete();
  }

  /// Admin can update a product's star rating
  void updateRating(String productId, double newRating) {
    _firestore.collection('products').doc(productId).update({
      'admin_rating': newRating.clamp(1.0, 5.0),
    });
  }

  void updateProduct(String id, Product product) {
    _firestore.collection('products').doc(id).update({
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'imageUrl': product.imageUrl,
      'categoryId': product.categoryId,
      'isFeatured': product.isFeatured,
      'admin_rating': product.rating,
      'rating': product.rating,
    });
  }
}
