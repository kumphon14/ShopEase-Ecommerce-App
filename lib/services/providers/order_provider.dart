import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/order.dart';
import '../../models/cart_item.dart';
import '../../models/product.dart';

class OrderProvider with ChangeNotifier {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  List<OrderModel> _orders = [];
  List<OrderModel> _notifications = [];

  List<OrderModel> get activeOrders =>
      _orders.where((o) => o.isActive).toList();

  List<OrderModel> get archivedOrders =>
      _orders.where((o) => o.isArchived || o.isDelivered).toList();

  List<OrderModel> get orders => [..._orders];
  List<OrderModel> get notifications => [..._notifications];

  List<OrderModel> ordersByStatus(String status) =>
      _orders.where((o) => o.status == status && o.isActive).toList();

  Map<String, int> get statusCounts {
    final counts = <String, int>{};
    for (final step in [...OrderModel.statusSteps, 'Cancelled', 'Archived']) {
      if (step == 'Archived') {
        counts[step] = archivedOrders.length;
      } else {
        counts[step] = _orders.where((o) => o.status == step).length;
      }
    }
    return counts;
  }

  Map<String, int> get paymentStatusCounts => {
        'Pending': _orders.where((o) => o.paymentStatus == 'Pending').length,
        'Paid': _orders.where((o) => o.paymentStatus == 'Paid').length,
        'Verified': _orders.where((o) => o.paymentStatus == 'Verified').length,
      };

  int get unreadNotificationsCount =>
      _notifications.where((o) => !o.isNotificationRead).length;

  OrderProvider({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _listenToOrders(user);
        _listenToNotifications(user.uid);
      } else {
        _orders = [];
        _notifications = [];
        notifyListeners();
      }
    });
  }

  Future<void> _listenToOrders(User user) async {
    final doc = await _firestore.collection('users').doc(user.uid).get();
    final isAdmin = doc.data()?['role'] == 'admin';

    Query query =
        _firestore.collection('orders').orderBy('date', descending: true);

    if (!isAdmin) {
      query = query.where('customerId', isEqualTo: user.uid);
    }

    query.snapshots().listen((snapshot) {
      _orders = snapshot.docs.map((doc) => _mapDocToOrder(doc)).toList();
      notifyListeners();
    });
  }

  void _listenToNotifications(String uid) {
    _firestore
        .collection('notifications')
        .where('customerId', isEqualTo: uid)
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      _notifications = snapshot.docs.map((doc) => _mapDocToOrder(doc)).toList();
      notifyListeners();
    });
  }

  OrderModel _mapDocToOrder(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>? ?? {});
    final itemsList = (data['items'] as List<dynamic>?) ?? [];

    final items = itemsList.map((item) {
      final itemMap = item as Map<String, dynamic>;
      return CartItem(
        id: itemMap['id'] ?? '',
        quantity: itemMap['quantity'] ?? 1,
        product: Product(
          id: itemMap['productId'] ?? '',
          name: itemMap['productName'] ?? '',
          description: '',
          price: (itemMap['price'] ?? 0).toDouble(),
          imageUrl: itemMap['imageUrl'] ?? '',
          categoryId: '',
          rating: (itemMap['rating'] ?? 4.0).toDouble(),
        ),
      );
    }).toList();

    return OrderModel(
      id: data['orderId'] ?? doc.id,
      items: items,
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'Order Placed',
      isNotificationRead: data['isNotificationRead'] ?? false,
      isArchived: data['isArchived'] ?? false,
      paymentMethod: data['paymentMethod'] == 'bankTransfer'
          ? PaymentMethod.bankTransfer
          : PaymentMethod.cod,
      paymentStatus: data['paymentStatus'] ?? 'Pending',
      proofOfTransferPath: data['proofOfTransferPath'],
      customerName: data['customerName'],
      customerId: data['customerId'],
    );
  }

  Future<String> addOrder(
    List<CartItem> cartProducts,
    double total, {
    PaymentMethod paymentMethod = PaymentMethod.cod,
    String? customerName,
    String? customerId,
  }) async {
    final uid = _auth.currentUser?.uid ?? customerId ?? 'USR001';

    final itemsData = cartProducts
        .map((item) => {
              'id': item.id,
              'productId': item.product.id,
              'productName': item.product.name,
              'price': item.product.price,
              'imageUrl': item.product.imageUrl,
              'quantity': item.quantity,
              'rating': item.product.rating,
            })
        .toList();

    final docRef = await _firestore.collection('orders').add({
      'items': itemsData,
      'totalAmount': total,
      'date': Timestamp.now(),
      'status': 'Order Placed',
      'isNotificationRead': false,
      'isArchived': false,
      'paymentMethod':
          paymentMethod == PaymentMethod.bankTransfer ? 'bankTransfer' : 'cod',
      'paymentStatus': 'Pending',
      'customerName': customerName,
      'customerId': uid,
      'proofOfTransferPath': null,
    });

    return docRef.id;
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final updates = <String, dynamic>{
      'status': newStatus,
    };

    if (newStatus == 'Delivered') {
      updates['isArchived'] = true;
      updates['paymentStatus'] = 'Verified';
    }

    await _firestore.collection('orders').doc(orderId).update(updates);

    OrderModel? matchedOrder;
    try {
      matchedOrder = _orders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      matchedOrder = null;
    }

    await _firestore.collection('notifications').add({
      'orderId': orderId,
      'status': newStatus,
      'date': FieldValue.serverTimestamp(),
      'isNotificationRead': false,
      'customerId': matchedOrder?.customerId,
      'items': [],
      'totalAmount': matchedOrder?.totalAmount ?? 0,
      'paymentMethod': matchedOrder?.paymentMethod == PaymentMethod.bankTransfer
          ? 'bankTransfer'
          : 'cod',
      'paymentStatus': matchedOrder?.paymentStatus ?? 'Pending',
      'isArchived': false,
    });
  }

  Future<void> updatePaymentStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'paymentStatus': status,
    });
  }

  Future<void> attachProofOfTransfer(String orderId, String filePath) async {
    try {
      final orderRef = _firestore.collection('orders').doc(orderId);
      final orderSnap = await orderRef.get();

      if (!orderSnap.exists) {
        throw Exception('Order not found');
      }

      await orderRef.update({
        'proofOfTransferPath': filePath,
        'paymentStatus': 'Paid',
      });
    } catch (e) {
      if (kDebugMode) {
        print('attachProofOfTransfer error: $e');
      }
      rethrow;
    }
  }

  Future<void> removeProofOfTransfer(String orderId) async {
    try {
      final orderRef = _firestore.collection('orders').doc(orderId);
      final orderSnap = await orderRef.get();

      if (!orderSnap.exists) {
        throw Exception('Order not found');
      }

      await orderRef.update({
        'proofOfTransferPath': null,
        'paymentStatus': 'Pending',
      });
    } catch (e) {
      if (kDebugMode) {
        print('removeProofOfTransfer error: $e');
      }
      rethrow;
    }
  }

  Future<void> archiveOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'isArchived': true,
    });
  }

  Future<void> restoreOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'isArchived': false,
    });
  }

  Future<void> markAllNotificationsRead() async {
    for (final notif in _notifications) {
      if (!notif.isNotificationRead) {
        await _firestore.collection('notifications').doc(notif.id).update({
          'isNotificationRead': true,
        });
      }
    }
  }
}