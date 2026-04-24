// lib/models/order.dart
import 'cart_item.dart';

enum PaymentMethod { cod, bankTransfer }

class OrderModel {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime date;
  String status;
  bool isNotificationRead;
  bool isArchived;

  // Payment
  final PaymentMethod paymentMethod;
  String paymentStatus; // 'Pending', 'Paid', 'Verified'
  String? proofOfTransferPath; // mock filename for transfer slip
  String? customerName;
  String? customerId;

  static const List<String> statusSteps = [
    'Order Placed',
    'Confirmed',
    'Packing',
    'Shipped',
    'Out for Delivery',
    'Delivered',
  ];

  OrderModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.date,
    this.status = 'Order Placed',
    this.isNotificationRead = false,
    this.isArchived = false,
    this.paymentMethod = PaymentMethod.cod,
    this.paymentStatus = 'Pending',
    this.proofOfTransferPath,
    this.customerName,
    this.customerId,
  });

  int get statusIndex =>
      statusSteps.indexOf(status).clamp(0, statusSteps.length - 1);

  bool get isDelivered => status == 'Delivered';
  bool get isCancelled => status == 'Cancelled';
  bool get isActive => !isArchived && !isCancelled;
}
