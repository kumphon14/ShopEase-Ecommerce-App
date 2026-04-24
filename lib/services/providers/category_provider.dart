import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/category.dart';

class CategoryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore;
  List<CategoryModel> _categories = [];

  List<CategoryModel> get categories => _categories;

  CategoryProvider({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      _categories = snapshot.docs.map((doc) {
        final data = doc.data();
        return CategoryModel(
          id: doc.id,
          name: data['name'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> addCategory(String name, String imageUrl) async {
    try {
      final docRef = await _firestore.collection('categories').add({
        'name': name,
        'imageUrl': imageUrl,
      });
      final newCategory = CategoryModel(id: docRef.id, name: name, imageUrl: imageUrl);
      _categories.add(newCategory);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding category: $e');
    }
  }

  Future<void> updateCategory(String id, String newName, String newImageUrl) async {
    try {
      await _firestore.collection('categories').doc(id).update({
        'name': newName,
        'imageUrl': newImageUrl,
      });
      final index = _categories.indexWhere((cat) => cat.id == id);
      if (index >= 0) {
        _categories[index] = CategoryModel(id: id, name: newName, imageUrl: newImageUrl);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating category: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _firestore.collection('categories').doc(id).delete();
      _categories.removeWhere((cat) => cat.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting category: $e');
    }
  }
}
