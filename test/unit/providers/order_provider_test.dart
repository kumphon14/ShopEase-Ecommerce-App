// test/unit/providers/order_provider_test.dart
//
// Tests OrderProvider pure getter logic: activeOrders, archivedOrders,
// ordersByStatus, statusCounts, paymentStatusCounts, unreadNotificationsCount,
// and _mapDocToOrder() field mapping.
//
// Because _orders and _notifications are private and populated via Firestore
// stream subscriptions, we seed FakeFirebaseFirestore and sign in a
// MockFirebaseAuth user so the authStateChanges() listener triggers
// _listenToOrders() and populates the internal lists.
//
// The _listenToOrders() path requires an authenticated user whose Firestore
// document has role != 'admin' (customer path), so it filters by customerId.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:shopease_ecommerce_app/services/providers/order_provider.dart';
import 'package:shopease_ecommerce_app/models/order.dart';

const _uid = 'user_test_001';

// Build a plain order document map for the 'orders' collection
Map<String, dynamic> _orderDoc({
  required String orderId,
  String status = 'Order Placed',
  bool isArchived = false,
  bool isNotificationRead = false,
  String paymentStatus = 'Pending',
  String paymentMethod = 'cod',
  double totalAmount = 100.0,
  String customerId = _uid,
}) {
  return {
    'orderId': orderId,
    'customerId': customerId,
    'status': status,
    'isArchived': isArchived,
    'isNotificationRead': isNotificationRead,
    'paymentStatus': paymentStatus,
    'paymentMethod': paymentMethod,
    'totalAmount': totalAmount,
    'date': Timestamp.fromDate(DateTime(2024, 1, 1)),
    'items': [],
    'customerName': 'Test User',
    'proofOfTransferPath': null,
  };
}

// Build notification document (same shape as order)
Map<String, dynamic> _notificationDoc({
  required String orderId,
  bool isNotificationRead = false,
  String customerId = _uid,
}) {
  return {
    'orderId': orderId,
    'customerId': customerId,
    'status': 'Confirmed',
    'isNotificationRead': isNotificationRead,
    'isArchived': false,
    'paymentStatus': 'Pending',
    'paymentMethod': 'cod',
    'totalAmount': 50.0,
    'date': Timestamp.fromDate(DateTime(2024, 1, 1)),
    'items': [],
  };
}

/// Seed orders and notifications into [firestore], then build an OrderProvider
/// and wait for stream delivery.
Future<OrderProvider> _makeProvider(
  FakeFirebaseFirestore firestore,
  MockFirebaseAuth auth, {
  List<Map<String, dynamic>> orders = const [],
  List<Map<String, dynamic>> notifications = const [],
}) async {
  // Write customer Firestore role doc
  await firestore.collection('users').doc(_uid).set({'role': 'customer'});

  for (final o in orders) {
    await firestore.collection('orders').add(o);
  }
  for (final n in notifications) {
    await firestore.collection('notifications').add(n);
  }

  final provider = OrderProvider(firestore: firestore, auth: auth);
  // Allow stream snapshot to be delivered
  await Future.delayed(const Duration(milliseconds: 100));
  return provider;
}

void main() {
  group('OrderProvider', () {
    group('activeOrders', () {
      test('returns only active (non-archived, non-cancelled) orders', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: _uid, email: 'user@test.com'),
        );

        final provider = await _makeProvider(fakeFirestore, mockAuth, orders: [
          _orderDoc(orderId: 'o1', status: 'Confirmed'),                    // active
          _orderDoc(orderId: 'o2', status: 'Shipped', isArchived: true),    // archived
          _orderDoc(orderId: 'o3', status: 'Cancelled'),                    // cancelled
        ]);

        expect(provider.activeOrders.length, equals(1));
        expect(provider.activeOrders.first.status, equals('Confirmed'));
      });
    });

    group('archivedOrders', () {
      test('returns orders where isArchived is true', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: _uid, email: 'user@test.com'),
        );

        final provider = await _makeProvider(fakeFirestore, mockAuth, orders: [
          _orderDoc(orderId: 'o1', status: 'Confirmed'),
          _orderDoc(orderId: 'o2', status: 'Shipped', isArchived: true),
        ]);

        expect(provider.archivedOrders.length, equals(1));
      });

      test('includes Delivered orders even if isArchived is false', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: _uid, email: 'user@test.com'),
        );

        final provider = await _makeProvider(fakeFirestore, mockAuth, orders: [
          _orderDoc(orderId: 'o1', status: 'Delivered', isArchived: false),
          _orderDoc(orderId: 'o2', status: 'Confirmed'),
        ]);

        // Delivered → isDelivered == true → included in archivedOrders
        expect(provider.archivedOrders.length, equals(1));
        expect(provider.archivedOrders.first.status, equals('Delivered'));
      });
    });

    group('ordersByStatus', () {
      test('returns only active orders matching the given status', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: _uid, email: 'user@test.com'),
        );

        final provider = await _makeProvider(fakeFirestore, mockAuth, orders: [
          _orderDoc(orderId: 'o1', status: 'Confirmed'),
          _orderDoc(orderId: 'o2', status: 'Confirmed'),
          _orderDoc(orderId: 'o3', status: 'Shipped'),
        ]);

        expect(provider.ordersByStatus('Confirmed').length, equals(2));
      });

      test('returns empty list when no orders match status', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: _uid, email: 'user@test.com'),
        );

        final provider = await _makeProvider(fakeFirestore, mockAuth, orders: [
          _orderDoc(orderId: 'o1', status: 'Confirmed'),
        ]);

        expect(provider.ordersByStatus('Packing'), isEmpty);
      });
    });

    group('statusCounts', () {
      test('returns correct count for each status step', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: _uid, email: 'user@test.com'),
        );

        final provider = await _makeProvider(fakeFirestore, mockAuth, orders: [
          _orderDoc(orderId: 'o1', status: 'Order Placed'),
          _orderDoc(orderId: 'o2', status: 'Confirmed'),
          _orderDoc(orderId: 'o3', status: 'Confirmed'),
          _orderDoc(orderId: 'o4', status: 'Cancelled'),
          _orderDoc(orderId: 'o5', status: 'Delivered', isArchived: true),
        ]);

        final counts = provider.statusCounts;
        expect(counts['Order Placed'], equals(1));
        expect(counts['Confirmed'], equals(2));
        expect(counts['Packing'], equals(0));
        expect(counts['Cancelled'], equals(1));
        expect(counts['Archived'], equals(1)); // Delivered → archivedOrders
      });

      test('statusCounts map contains all statusSteps plus Cancelled and Archived', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: _uid, email: 'user@test.com'),
        );
        final provider = await _makeProvider(fakeFirestore, mockAuth);

        final keys = provider.statusCounts.keys.toSet();
        for (final step in OrderModel.statusSteps) {
          expect(keys.contains(step), isTrue);
        }
        expect(keys.contains('Cancelled'), isTrue);
        expect(keys.contains('Archived'), isTrue);
      });
    });

    group('paymentStatusCounts', () {
      test('returns correct counts for Pending, Paid, and Verified', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: _uid, email: 'user@test.com'),
        );

        final provider = await _makeProvider(fakeFirestore, mockAuth, orders: [
          _orderDoc(orderId: 'o1', paymentStatus: 'Pending'),
          _orderDoc(orderId: 'o2', paymentStatus: 'Pending'),
          _orderDoc(orderId: 'o3', paymentStatus: 'Paid'),
        ]);

        final counts = provider.paymentStatusCounts;
        expect(counts['Pending'], equals(2));
        expect(counts['Paid'], equals(1));
        expect(counts['Verified'], equals(0));
      });
    });

    group('unreadNotificationsCount', () {
      test('counts only unread notifications', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: _uid, email: 'user@test.com'),
        );

        final provider = await _makeProvider(fakeFirestore, mockAuth,
            notifications: [
              _notificationDoc(orderId: 'o1', isNotificationRead: false),
              _notificationDoc(orderId: 'o2', isNotificationRead: false),
              _notificationDoc(orderId: 'o3', isNotificationRead: true),
            ]);

        expect(provider.unreadNotificationsCount, equals(2));
      });

      test('returns 0 when all notifications are read', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: _uid, email: 'user@test.com'),
        );

        final provider = await _makeProvider(fakeFirestore, mockAuth,
            notifications: [
              _notificationDoc(orderId: 'o1', isNotificationRead: true),
            ]);

        expect(provider.unreadNotificationsCount, equals(0));
      });

      test('returns 0 when notification list is empty', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: _uid, email: 'user@test.com'),
        );

        final provider = await _makeProvider(fakeFirestore, mockAuth);

        expect(provider.unreadNotificationsCount, equals(0));
      });
    });

    group('_mapDocToOrder (via Firestore round-trip)', () {
      test('maps all fields correctly from a full document', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: _uid, email: 'user@test.com'),
        );

        final orderData = {
          'orderId': 'order_abc',
          'customerId': _uid,
          'status': 'Shipped',
          'isArchived': false,
          'isNotificationRead': true,
          'paymentStatus': 'Paid',
          'paymentMethod': 'bankTransfer',
          'totalAmount': 250.0,
          'date': Timestamp.fromDate(DateTime(2024, 6, 15)),
          'items': [],
          'customerName': 'Alice',
          'proofOfTransferPath': '/path/to/proof.jpg',
        };
        await fakeFirestore.collection('orders').add(orderData);

        final provider = await _makeProvider(fakeFirestore, mockAuth);

        expect(provider.orders.length, equals(1));
        final order = provider.orders.first;
        expect(order.status, equals('Shipped'));
        expect(order.paymentMethod, equals(PaymentMethod.bankTransfer));
        expect(order.paymentStatus, equals('Paid'));
        expect(order.isNotificationRead, isTrue);
        expect(order.totalAmount, equals(250.0));
        expect(order.customerName, equals('Alice'));
        expect(order.proofOfTransferPath, equals('/path/to/proof.jpg'));
        expect(order.date, equals(DateTime(2024, 6, 15)));
      });

      test('maps paymentMethod cod correctly', () async {
        // Use a completely fresh Firestore + auth instance for this test
        final fakeFirestore = FakeFirebaseFirestore();
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: _uid, email: 'user@test.com'),
        );

        final provider = await _makeProvider(fakeFirestore, mockAuth, orders: [
          _orderDoc(orderId: 'o1', paymentMethod: 'cod'),
        ]);

        expect(provider.orders.isNotEmpty, isTrue);
        expect(provider.orders.first.paymentMethod, equals(PaymentMethod.cod));
      });

      test('maps unknown paymentMethod to cod (fallback)', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: _uid, email: 'user@test.com'),
        );

        final orderData = {
          ...(_orderDoc(orderId: 'o1')),
          'paymentMethod': 'crypto', // unknown
        };
        await fakeFirestore.collection('orders').add(orderData);
        await fakeFirestore.collection('users').doc(_uid).set({'role': 'customer'});

        final provider = OrderProvider(firestore: fakeFirestore, auth: mockAuth);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(provider.orders.first.paymentMethod, equals(PaymentMethod.cod));
      });

      test('uses fallback defaults for missing document fields', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: _uid, email: 'user@test.com'),
        );

        // Document with only customerId and date — everything else missing
        await fakeFirestore.collection('orders').add({
          'customerId': _uid,
          'date': Timestamp.fromDate(DateTime(2024, 1, 1)),
        });
        await fakeFirestore.collection('users').doc(_uid).set({'role': 'customer'});

        final provider = OrderProvider(firestore: fakeFirestore, auth: mockAuth);
        await Future.delayed(const Duration(milliseconds: 100));

        final order = provider.orders.first;
        expect(order.status, equals('Order Placed'));         // fallback
        expect(order.paymentStatus, equals('Pending'));       // fallback
        expect(order.isArchived, isFalse);                   // fallback
        expect(order.isNotificationRead, isFalse);           // fallback
        expect(order.totalAmount, equals(0.0));               // fallback
        expect(order.paymentMethod, equals(PaymentMethod.cod)); // fallback
      });

      test('casts totalAmount from int to double correctly', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: _uid, email: 'user@test.com'),
        );

        await fakeFirestore.collection('orders').add({
          'customerId': _uid,
          'totalAmount': 150, // int, not double
          'date': Timestamp.fromDate(DateTime(2024, 1, 1)),
        });
        await fakeFirestore.collection('users').doc(_uid).set({'role': 'customer'});

        final provider = OrderProvider(firestore: fakeFirestore, auth: mockAuth);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(provider.orders.first.totalAmount, equals(150.0));
        expect(provider.orders.first.totalAmount, isA<double>());
      });
    });

    group('attachProofOfTransfer', () {
      test('throws exception when order document does not exist', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: _uid, email: 'user@test.com'),
        );

        await fakeFirestore.collection('users').doc(_uid).set({'role': 'customer'});
        final provider = OrderProvider(firestore: fakeFirestore, auth: mockAuth);
        await Future.delayed(const Duration(milliseconds: 50));

        expect(
          () async => await provider.attachProofOfTransfer('non_existent_id', '/path/to/proof.jpg'),
          throwsException,
        );
      });
    });

    group('removeProofOfTransfer', () {
      test('throws exception when order document does not exist', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: _uid, email: 'user@test.com'),
        );

        await fakeFirestore.collection('users').doc(_uid).set({'role': 'customer'});
        final provider = OrderProvider(firestore: fakeFirestore, auth: mockAuth);
        await Future.delayed(const Duration(milliseconds: 50));

        expect(
          () async => await provider.removeProofOfTransfer('non_existent_id'),
          throwsException,
        );
      });
    });

    group('updateOrderStatus payload', () {
      test('Delivered status sets isArchived and paymentStatus Verified in Firestore', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: _uid, email: 'user@test.com'),
        );

        await fakeFirestore.collection('users').doc(_uid).set({'role': 'customer'});
        final docRef = await fakeFirestore.collection('orders').add(
          _orderDoc(orderId: 'o1', status: 'Shipped'),
        );

        final provider = OrderProvider(firestore: fakeFirestore, auth: mockAuth);
        await Future.delayed(const Duration(milliseconds: 50));

        await provider.updateOrderStatus(docRef.id, 'Delivered');

        final snap = await fakeFirestore.collection('orders').doc(docRef.id).get();
        final data = snap.data()!;
        expect(data['status'], equals('Delivered'));
        expect(data['isArchived'], isTrue);
        expect(data['paymentStatus'], equals('Verified'));
      });

      test('Non-Delivered status update does not set isArchived or paymentStatus override', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: _uid, email: 'user@test.com'),
        );

        await fakeFirestore.collection('users').doc(_uid).set({'role': 'customer'});
        final docRef = await fakeFirestore.collection('orders').add(
          _orderDoc(orderId: 'o1', status: 'Order Placed'),
        );

        final provider = OrderProvider(firestore: fakeFirestore, auth: mockAuth);
        await Future.delayed(const Duration(milliseconds: 50));

        await provider.updateOrderStatus(docRef.id, 'Confirmed');

        final snap = await fakeFirestore.collection('orders').doc(docRef.id).get();
        final data = snap.data()!;
        expect(data['status'], equals('Confirmed'));
        // isArchived should remain false (not overridden by a non-Delivered update)
        expect(data['isArchived'], isFalse);
      });
    });
  });
}
