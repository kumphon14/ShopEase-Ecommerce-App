// lib/services/mock_data.dart
import '../models/category.dart';
import '../models/product.dart';

class MockData {
  // Promotional banners for the home screen carousel
  static const List<Map<String, String>> banners = [
    {
      'title': 'Summer Sale!',
      'subtitle': 'Up to 50% off on all items',
      'imageUrl': 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80',
      'tag': 'HOT DEAL',
    },
    {
      'title': 'New Arrivals',
      'subtitle': 'Explore the latest tech gadgets',
      'imageUrl': 'https://images.unsplash.com/photo-1498049794561-7780e7231661?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80',
      'tag': 'NEW',
    },
    {
      'title': 'Premium Laptops',
      'subtitle': 'Power meets performance',
      'imageUrl': 'https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80',
      'tag': 'FEATURED',
    },
  ];

  static List<CategoryModel> categories = [
    CategoryModel(id: 'c1', name: 'Smartphones', imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80'),
    CategoryModel(id: 'c2', name: 'Laptops', imageUrl: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80'),
    CategoryModel(id: 'c3', name: 'Headphones', imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80'),
    CategoryModel(id: 'c4', name: 'Smartwatches', imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80'),
  ];

  static List<Product> products = [
    Product(
      id: 'p1',
      name: 'TechPro Smartphone X',
      description: 'The latest TechPro smartphone with an amazing camera and battery life. Enjoy a 6.7-inch OLED display and ultra-fast processor.',
      price: 899.99,
      imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      categoryId: 'c1',
      isFeatured: true,
      rating: 4.8,
    ),
    Product(
      id: 'p2',
      name: 'GamerBook Pro 15',
      description: 'High performance gaming laptop with RTX 4070 and Intel i9 processor. 144Hz display for ultimate gaming experience.',
      price: 1499.50,
      imageUrl: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      categoryId: 'c2',
      isFeatured: true,
      rating: 4.9,
    ),
    Product(
      id: 'p3',
      name: 'SonicBass Wireless Headphones',
      description: 'Noise-cancelling over-ear headphones with 40-hour battery life and deep bass.',
      price: 199.00,
      imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      categoryId: 'c3',
      isFeatured: false,
      rating: 4.5,
    ),
    Product(
      id: 'p4',
      name: 'FitWatch Series 8',
      description: 'Track your health, receive notifications, and stay fit with this sleek smartwatch.',
      price: 249.99,
      imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      categoryId: 'c4',
      isFeatured: true,
      rating: 4.3,
    ),
    Product(
      id: 'p5',
      name: 'BudgetPhone Lite',
      description: 'Affordable smartphone with essential features for everyday use.',
      price: 299.00,
      imageUrl: 'https://images.unsplash.com/photo-1598327105666-5b89351cb31b?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      categoryId: 'c1',
      isFeatured: false,
      rating: 3.8,
    ),
    Product(
      id: 'p6',
      name: 'UltraBook Air 13',
      description: 'Thin and light laptop perfect for professionals on the go. M2 chip, 18-hour battery.',
      price: 1199.00,
      imageUrl: 'https://images.unsplash.com/photo-1541807084-5c52b6b3adef?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      categoryId: 'c2',
      isFeatured: true,
      rating: 4.7,
    ),
    Product(
      id: 'p7',
      name: 'ProBuds Wireless',
      description: 'In-ear wireless earbuds with active noise cancellation and 30-hour total battery.',
      price: 129.00,
      imageUrl: 'https://images.unsplash.com/photo-1572536147248-ac59a8abfa4b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      categoryId: 'c3',
      isFeatured: true,
      rating: 4.6,
    ),
    Product(
      id: 'p8',
      name: 'SmartBand Premium',
      description: 'Fitness band with heart rate monitor, sleep tracking, and 10-day battery life.',
      price: 89.99,
      imageUrl: 'https://images.unsplash.com/photo-1575311373937-040b8e1fd5b6?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      categoryId: 'c4',
      isFeatured: false,
      rating: 4.1,
    ),
  ];
}
