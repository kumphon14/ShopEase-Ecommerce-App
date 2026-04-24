// test/unit/models/order_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/models/order.dart';
import 'package:shopease_ecommerce_app/models/cart_item.dart';
import 'package:shopease_ecommerce_app/models/product.dart';

OrderModel _makeOrder({
  String id = 'o1',
  String status = 'Order Placed',
  bool isArchived = false,
  bool isNotificationRead = false,
  String paymentStatus = 'Pending',
  PaymentMethod paymentMethod = PaymentMethod.cod,
  String? proofOfTransferPath,
  String? customerName,
  String? customerId,
}) {
  return OrderModel(
    id: id,
    items: [],
    totalAmount: 100.0,
    date: DateTime(2024, 1, 1),
    status: status,
    isArchived: isArchived,
    isNotificationRead: isNotificationRead,
    paymentStatus: paymentStatus,
    paymentMethod: paymentMethod,
    proofOfTransferPath: proofOfTransferPath,
    customerName: customerName,
    customerId: customerId,
  );
}

void main() {
  group('OrderModel', () {
    group('constructor defaults', () {
      test('status defaults to Order Placed', () {
        final order = OrderModel(
          id: 'o1',
          items: [],
          totalAmount: 0.0,
          date: DateTime.now(),
        );
        expect(order.status, equals('Order Placed'));
      });

      test('paymentStatus defaults to Pending', () {
        final order = OrderModel(
          id: 'o1',
          items: [],
          totalAmount: 0.0,
          date: DateTime.now(),
        );
        expect(order.paymentStatus, equals('Pending'));
      });

      test('isNotificationRead defaults to false', () {
        final order = OrderModel(
          id: 'o1',
          items: [],
          totalAmount: 0.0,
          date: DateTime.now(),
        );
        expect(order.isNotificationRead, isFalse);
      });

      test('isArchived defaults to false', () {
        final order = OrderModel(
          id: 'o1',
          items: [],
          totalAmount: 0.0,
          date: DateTime.now(),
        );
        expect(order.isArchived, isFalse);
      });

      test('paymentMethod defaults to PaymentMethod.cod', () {
        final order = OrderModel(
          id: 'o1',
          items: [],
          totalAmount: 0.0,
          date: DateTime.now(),
        );
        expect(order.paymentMethod, equals(PaymentMethod.cod));
      });

      test('proofOfTransferPath defaults to null', () {
        final order = OrderModel(
          id: 'o1',
          items: [],
          totalAmount: 0.0,
          date: DateTime.now(),
        );
        expect(order.proofOfTransferPath, isNull);
      });

      test('customerName defaults to null', () {
        final order = OrderModel(
          id: 'o1',
          items: [],
          totalAmount: 0.0,
          date: DateTime.now(),
        );
        expect(order.customerName, isNull);
      });
    });

    group('PaymentMethod enum', () {
      test('PaymentMethod has cod and bankTransfer values', () {
        expect(PaymentMethod.values, contains(PaymentMethod.cod));
        expect(PaymentMethod.values, contains(PaymentMethod.bankTransfer));
      });

      test('PaymentMethod has exactly 2 values', () {
        expect(PaymentMethod.values.length, equals(2));
      });
    });

    group('statusSteps', () {
      test('has exactly 6 elements', () {
        expect(OrderModel.statusSteps.length, equals(6));
      });

      test('first element is Order Placed', () {
        expect(OrderModel.statusSteps.first, equals('Order Placed'));
      });

      test('last element is Delivered', () {
        expect(OrderModel.statusSteps.last, equals('Delivered'));
      });

      test('contains all expected steps in order', () {
        expect(OrderModel.statusSteps, equals([
          'Order Placed',
          'Confirmed',
          'Packing',
          'Shipped',
          'Out for Delivery',
          'Delivered',
        ]));
      });

      test('all step strings are non-empty', () {
        for (final step in OrderModel.statusSteps) {
          expect(step, isNotEmpty);
        }
      });
    });

    group('statusIndex', () {
      test('returns 0 for Order Placed', () {
        expect(_makeOrder(status: 'Order Placed').statusIndex, equals(0));
      });

      test('returns 1 for Confirmed', () {
        expect(_makeOrder(status: 'Confirmed').statusIndex, equals(1));
      });

      test('returns 2 for Packing', () {
        expect(_makeOrder(status: 'Packing').statusIndex, equals(2));
      });

      test('returns 3 for Shipped', () {
        expect(_makeOrder(status: 'Shipped').statusIndex, equals(3));
      });

      test('returns 4 for Out for Delivery', () {
        expect(_makeOrder(status: 'Out for Delivery').statusIndex, equals(4));
      });

      test('returns 5 for Delivered', () {
        expect(_makeOrder(status: 'Delivered').statusIndex, equals(5));
      });

      test('returns 0 for Cancelled (not in statusSteps — clamps to 0)', () {
        expect(_makeOrder(status: 'Cancelled').statusIndex, equals(0));
      });

      test('returns 0 for empty string (not in statusSteps — clamps to 0)', () {
        expect(_makeOrder(status: '').statusIndex, equals(0));
      });

      test('returns 0 for arbitrary unknown status string', () {
        expect(_makeOrder(status: 'Refunded').statusIndex, equals(0));
      });
    });

    group('isDelivered', () {
      test('returns true when status is Delivered', () {
        expect(_makeOrder(status: 'Delivered').isDelivered, isTrue);
      });

      test('returns false when status is Confirmed', () {
        expect(_makeOrder(status: 'Confirmed').isDelivered, isFalse);
      });

      test('returns false when status is Order Placed', () {
        expect(_makeOrder(status: 'Order Placed').isDelivered, isFalse);
      });

      test('returns false when status is Cancelled', () {
        expect(_makeOrder(status: 'Cancelled').isDelivered, isFalse);
      });
    });

    group('isCancelled', () {
      test('returns true when status is Cancelled', () {
        expect(_makeOrder(status: 'Cancelled').isCancelled, isTrue);
      });

      test('returns false when status is Delivered', () {
        expect(_makeOrder(status: 'Delivered').isCancelled, isFalse);
      });

      test('returns false when status is Order Placed', () {
        expect(_makeOrder(status: 'Order Placed').isCancelled, isFalse);
      });
    });

    group('isActive', () {
      test('returns true when isArchived is false and status is not Cancelled', () {
        expect(_makeOrder(status: 'Confirmed', isArchived: false).isActive, isTrue);
      });

      test('returns false when isArchived is true', () {
        expect(_makeOrder(isArchived: true).isActive, isFalse);
      });

      test('returns false when status is Cancelled', () {
        expect(_makeOrder(status: 'Cancelled').isActive, isFalse);
      });

      test('returns false when isArchived is true and status is Delivered', () {
        final order = _makeOrder(status: 'Delivered', isArchived: true);
        expect(order.isDelivered, isTrue);
        expect(order.isActive, isFalse);
      });

      test('returns true for Order Placed with no archiving or cancellation', () {
        expect(_makeOrder(status: 'Order Placed', isArchived: false).isActive, isTrue);
      });
    });

    group('items field', () {
      test('stores CartItem list correctly', () {
        final product = Product(
          id: 'p1', name: 'Test', description: '', price: 10.0,
          imageUrl: '', categoryId: 'c1',
        );
        final item = CartItem(id: 'ci1', product: product, quantity: 2);
        final order = OrderModel(
          id: 'o1',
          items: [item],
          totalAmount: 20.0,
          date: DateTime.now(),
        );
        expect(order.items.length, equals(1));
        expect(order.items.first.product.id, equals('p1'));
      });
    });
  });
}
