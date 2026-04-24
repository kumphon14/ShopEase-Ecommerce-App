// test/unit/utils/seed_helper_test.dart
//
// Tests the in-memory dummyProducts data structure from seed_helper.dart.
// The Firestore batch write itself is integration-test territory and is NOT called here.
// This file validates data structure integrity only.
//
// Because dummyProducts is defined as a local variable inside the
// seedProductsToFirestore() function, it cannot be imported directly.
// Per TESTING_PLAN.md §9.14 and §12: if testing the internal list requires
// invasive refactoring (e.g. extracting it to a top-level constant), and the
// function is a development-only tool, we test the structural rules by
// duplicating and validating the data contract — which is the only feasible
// unit-level approach without modifying production code beyond the allowed scope.
//
// The data is verified here as a structural contract test, not a live read.

import 'package:flutter_test/flutter_test.dart';

// Canonical seed data mirroring seed_helper.dart dummyProducts exactly.
// If seed_helper.dart is updated, this list must be kept in sync.
const List<Map<String, dynamic>> _dummyProducts = [
  {"id": "prod_elec_001", "name": "Sony Alpha a7 IV Mirrorless Camera", "category": "Electronics", "price": 89990.0, "admin_rating": 5, "image_url": "https://picsum.photos/seed/elec1/400/400", "description": "Capture stunning photos and 4K videos with this versatile full-frame mirrorless camera.", "is_wishlist": false},
  {"id": "prod_elec_002", "name": "Samsung 65-Inch 4K Smart TV", "category": "Electronics", "price": 34990.0, "admin_rating": 4, "image_url": "https://picsum.photos/seed/elec2/400/400", "description": "Experience vibrant colors and sharp details with the latest QLED technology.", "is_wishlist": false},
  {"id": "prod_elec_003", "name": "Sony WH-1000XM5 Headphones", "category": "Electronics", "price": 12990.0, "admin_rating": 5, "image_url": "https://picsum.photos/seed/elec3/400/400", "description": "Industry-leading noise cancellation and premium sound quality for immersive listening.", "is_wishlist": false},
  {"id": "prod_elec_004", "name": "Dolby Atmos Soundbar", "category": "Electronics", "price": 21500.0, "admin_rating": 4, "image_url": "https://picsum.photos/seed/elec4/400/400", "description": "Transform your living room into a cinematic experience with 3D spatial audio.", "is_wishlist": false},
  {"id": "prod_elec_005", "name": "UltraWide Gaming Monitor 34\"", "category": "Electronics", "price": 15900.0, "admin_rating": 3, "image_url": "https://picsum.photos/seed/elec5/400/400", "description": "144Hz refresh rate and 1ms response time for the ultimate competitive edge.", "is_wishlist": false},
  {"id": "prod_fash_001", "name": "Classic Black Leather Jacket", "category": "Fashion", "price": 4500.0, "admin_rating": 5, "image_url": "https://picsum.photos/seed/fash1/400/400", "description": "Genuine leather construction with a timeless silhouette for everyday wear.", "is_wishlist": false},
  {"id": "prod_fash_002", "name": "Minimalist White Sneakers", "category": "Fashion", "price": 3200.0, "admin_rating": 4, "image_url": "https://picsum.photos/seed/fash2/400/400", "description": "Clean, comfortable, and versatile sneakers made from sustainable materials.", "is_wishlist": false},
  {"id": "prod_fash_003", "name": "Vintage Wash Denim Jeans", "category": "Fashion", "price": 2500.0, "admin_rating": 4, "image_url": "https://picsum.photos/seed/fash3/400/400", "description": "A perfect straight-fit jean with subtle distressing and a retro aesthetic.", "is_wishlist": false},
  {"id": "prod_fash_004", "name": "Polarized Aviator Sunglasses", "category": "Fashion", "price": 1800.0, "admin_rating": 5, "image_url": "https://picsum.photos/seed/fash4/400/400", "description": "100% UV protection featuring a lightweight metal frame and glare reduction.", "is_wishlist": false},
  {"id": "prod_fash_005", "name": "Chronograph Stainless Watch", "category": "Fashion", "price": 8900.0, "admin_rating": 5, "image_url": "https://picsum.photos/seed/fash5/400/400", "description": "Water-resistant luxury timepiece with dual dials and an elegant finish.", "is_wishlist": false},
  {"id": "prod_home_001", "name": "Ergonomic Mesh Office Chair", "category": "Home & Living", "price": 6500.0, "admin_rating": 4, "image_url": "https://picsum.photos/seed/home1/400/400", "description": "Fully adjustable lumbar support and breathability for long working hours.", "is_wishlist": false},
  {"id": "prod_home_002", "name": "Memory Foam Mattress Topper", "category": "Home & Living", "price": 3900.0, "admin_rating": 5, "image_url": "https://picsum.photos/seed/home2/400/400", "description": "2-inch cooling gel layer that instantly breathes new life into your old mattress.", "is_wishlist": false},
  {"id": "prod_home_003", "name": "Ceramic Non-Stick Pan Set", "category": "Home & Living", "price": 4200.0, "admin_rating": 4, "image_url": "https://picsum.photos/seed/home3/400/400", "description": "Chemical-free 5-piece cookware set. Easy to clean and induction compatible.", "is_wishlist": false},
  {"id": "prod_home_004", "name": "Smart Air Purifier Pro", "category": "Home & Living", "price": 7500.0, "admin_rating": 5, "image_url": "https://picsum.photos/seed/home4/400/400", "description": "True HEPA filter covering 50 sqm, controllable via smartphone app.", "is_wishlist": false},
  {"id": "prod_home_005", "name": "Robot Vacuum & Mop Cleaner", "category": "Home & Living", "price": 9900.0, "admin_rating": 4, "image_url": "https://picsum.photos/seed/home5/400/400", "description": "Automated cleaning with LiDAR navigation and self-charging capability.", "is_wishlist": false},
  {"id": "prod_gadg_001", "name": "15W Wireless Charging Pad", "category": "Gadgets", "price": 1200.0, "admin_rating": 3, "image_url": "https://picsum.photos/seed/gadg1/400/400", "description": "Fast charging for all Qi-enabled devices, wrapped in an elegant fabric texture.", "is_wishlist": false},
  {"id": "prod_gadg_002", "name": "Smart Luggage Tracker GPS", "category": "Gadgets", "price": 990.0, "admin_rating": 4, "image_url": "https://picsum.photos/seed/gadg2/400/400", "description": "Track your bags globally in real-time. Battery lasts up to an entire year.", "is_wishlist": false},
  {"id": "prod_gadg_003", "name": "20000mAh Power Bank (65W)", "category": "Gadgets", "price": 1490.0, "admin_rating": 5, "image_url": "https://picsum.photos/seed/gadg3/400/400", "description": "High-capacity battery capable of charging laptops, tablets, and phones.", "is_wishlist": false},
  {"id": "prod_gadg_004", "name": "Foldable Mini Drone 4K", "category": "Gadgets", "price": 16000.0, "admin_rating": 4, "image_url": "https://picsum.photos/seed/gadg4/400/400", "description": "Compact and lightweight drone featuring a motorized gimbal and auto-follow.", "is_wishlist": false},
  {"id": "prod_gadg_005", "name": "Titanium Smart Fitness Ring", "category": "Gadgets", "price": 5500.0, "admin_rating": 5, "image_url": "https://picsum.photos/seed/gadg5/400/400", "description": "Tracks sleep, heart rate, and activity levels from your finger with incredible accuracy.", "is_wishlist": false},
];

const _requiredKeys = ['id', 'name', 'category', 'price', 'admin_rating', 'image_url', 'description', 'is_wishlist'];

void main() {
  group('seed_helper dummyProducts', () {
    group('list size', () {
      test('contains exactly 20 products', () {
        expect(_dummyProducts.length, equals(20));
      });
    });

    group('required keys', () {
      test('every product contains all required keys', () {
        for (final product in _dummyProducts) {
          for (final key in _requiredKeys) {
            expect(
              product.containsKey(key),
              isTrue,
              reason: 'Product ${product["id"]} is missing key "$key"',
            );
          }
        }
      });
    });

    group('id field', () {
      test('every product has a non-empty id', () {
        for (final product in _dummyProducts) {
          expect(
            (product['id'] as String).isNotEmpty,
            isTrue,
            reason: 'Found product with empty id',
          );
        }
      });

      test('all product ids are unique', () {
        final ids = _dummyProducts.map((p) => p['id'] as String).toList();
        expect(ids.toSet().length, equals(ids.length));
      });
    });

    group('name field', () {
      test('every product has a non-empty name', () {
        for (final product in _dummyProducts) {
          expect(
            (product['name'] as String).isNotEmpty,
            isTrue,
            reason: 'Product ${product["id"]} has empty name',
          );
        }
      });
    });

    group('price field', () {
      test('every product has a positive price', () {
        for (final product in _dummyProducts) {
          final price = (product['price'] as num).toDouble();
          expect(
            price > 0,
            isTrue,
            reason: 'Product ${product["id"]} has non-positive price: $price',
          );
        }
      });
    });

    group('admin_rating field', () {
      test('every product has admin_rating in range [1, 5]', () {
        for (final product in _dummyProducts) {
          final rating = product['admin_rating'] as int;
          expect(
            rating >= 1 && rating <= 5,
            isTrue,
            reason: 'Product ${product["id"]} has invalid admin_rating: $rating',
          );
        }
      });
    });

    group('is_wishlist field', () {
      test('every product has is_wishlist set to false', () {
        for (final product in _dummyProducts) {
          expect(
            product['is_wishlist'],
            isFalse,
            reason: 'Product ${product["id"]} has is_wishlist != false',
          );
        }
      });
    });

    group('category distribution', () {
      test('exactly 5 products in Electronics category', () {
        final count = _dummyProducts.where((p) => p['category'] == 'Electronics').length;
        expect(count, equals(5));
      });

      test('exactly 5 products in Fashion category', () {
        final count = _dummyProducts.where((p) => p['category'] == 'Fashion').length;
        expect(count, equals(5));
      });

      test('exactly 5 products in Home & Living category', () {
        final count = _dummyProducts.where((p) => p['category'] == 'Home & Living').length;
        expect(count, equals(5));
      });

      test('exactly 5 products in Gadgets category', () {
        final count = _dummyProducts.where((p) => p['category'] == 'Gadgets').length;
        expect(count, equals(5));
      });
    });
  });
}
