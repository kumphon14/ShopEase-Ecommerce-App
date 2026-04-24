// lib/screens/profile/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../services/providers/order_provider.dart';
import '../../core/routes/app_routes.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Mark all as read when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false)
          .markAllNotificationsRead();
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Order Placed': return const Color(0xFF636E72);
      case 'Confirmed': return AppTheme.accentColor;
      case 'Packing': return AppTheme.primaryColor;
      case 'Shipped': return Colors.blue;
      case 'Out for Delivery': return AppTheme.secondaryColor;
      case 'Delivered': return AppTheme.successColor;
      case 'Cancelled': return AppTheme.errorColor;
      default: return AppTheme.textMediumColor;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Order Placed': return Icons.receipt_outlined;
      case 'Confirmed': return Icons.check_circle_outline;
      case 'Packing': return Icons.inventory_2_outlined;
      case 'Shipped': return Icons.local_shipping_outlined;
      case 'Out for Delivery': return Icons.delivery_dining_outlined;
      case 'Delivered': return Icons.done_all;
      case 'Cancelled': return Icons.cancel_outlined;
      default: return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = orderProvider.notifications;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
      ),
      body: orders.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none,
                      size: 80, color: AppTheme.textLightColor),
                  const SizedBox(height: 16),
                  const Text('No notifications yet',
                      style: TextStyle(
                          color: AppTheme.textMediumColor, fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (_, i) {
                final order = orders[i];
                final color = _statusColor(order.status);
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: order.isNotificationRead
                        ? null
                        : Border.all(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                  ),
                  child: ListTile(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.orderHistory),
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_statusIcon(order.status),
                          color: color, size: 22),
                    ),
                    title: Text(
                      'Order #${order.id.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                color: AppTheme.textMediumColor,
                                fontSize: 13),
                            children: [
                              const TextSpan(text: 'Status updated to '),
                              TextSpan(
                                text: order.status,
                                style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM dd, hh:mm a').format(order.date),
                          style: const TextStyle(
                              color: AppTheme.textLightColor, fontSize: 11),
                        ),
                      ],
                    ),
                    trailing: !order.isNotificationRead
                        ? Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
