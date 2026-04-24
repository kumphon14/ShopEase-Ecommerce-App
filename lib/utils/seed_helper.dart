import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

Future<void> seedProductsToFirestore() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  // Directly parsed from the JSON array
  final List<Map<String, dynamic>> dummyProducts = [
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
    {"id": "prod_gadg_005", "name": "Titanium Smart Fitness Ring", "category": "Gadgets", "price": 5500.0, "admin_rating": 5, "image_url": "https://picsum.photos/seed/gadg5/400/400", "description": "Tracks sleep, heart rate, and activity levels from your finger with incredible accuracy.", "is_wishlist": false}
  ];

  try {
    // 1. Get a reference to the products collection
    final CollectionReference productsRef = firestore.collection('products');
    
    // 2. Initialize a WriteBatch
    WriteBatch batch = firestore.batch();

    // 3. Iterate and schedule sets (using the 'id' field as the Document ID)
    for (var product in dummyProducts) {
      // By using .doc(product['id']), we manually set the Firestore ID to match the data model
      DocumentReference docRef = productsRef.doc(product['id']);
      batch.set(docRef, product);
    }

    // 4. Commit the batch operation simultaneously
    await batch.commit();
    
    if (kDebugMode) {
      print('✅ All 20 products seeded to Firestore successfully!');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Error seeding products: $e');
    }
  }
}
