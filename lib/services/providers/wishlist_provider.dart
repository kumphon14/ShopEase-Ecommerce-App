// lib/services/providers/wishlist_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/product.dart';

class WishlistProvider with ChangeNotifier {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  List<Product> _items = [];

  List<Product> get items => [..._items];

  WishlistProvider({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _listenToWishlist(user.uid);
      } else {
        _items = [];
        notifyListeners();
      }
    });
  }

  void _listenToWishlist(String uid) {
    _firestore
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .snapshots()
        .listen((snapshot) {
      _items = snapshot.docs.map((doc) {
        final data = doc.data();
        return Product(
          id: doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          price: (data['price'] ?? 0).toDouble(),
          imageUrl: data['imageUrl'] ?? '',
          categoryId: data['categoryId'] ?? '',
          isFeatured: data['isFeatured'] ?? false,
          rating: (data['rating'] ?? 4.0).toDouble(),
        );
      }).toList();
      notifyListeners();
    });
  }

  bool isWishlisted(String productId) {
    return _items.any((p) => p.id == productId);
  }

  void toggle(Product product) {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(product.id);

    if (isWishlisted(product.id)) {
      docRef.delete();
    } else {
      docRef.set({
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'categoryId': product.categoryId,
        'isFeatured': product.isFeatured,
        'rating': product.rating,
      });
    }
  }

  void remove(String productId) {
    final user = _auth.currentUser;
    if (user != null) {
      _firestore
          .collection('users')
          .doc(user.uid)
          .collection('wishlist')
          .doc(productId)
          .delete();
    }
  }
}
