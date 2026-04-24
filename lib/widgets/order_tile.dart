import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../core/theme/app_theme.dart';
import '../utils/currency_utils.dart';

class OrderTile extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;

  const OrderTile({
    super.key,
    required this.order,
    this.onTap,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'Order Placed':
        return const Color(0xFF636E72);
      case 'Confirmed':
        return AppTheme.accentColor;
      case 'Packing':
        return AppTheme.primaryColor;
      case 'Shipped':
        return Colors.blue;
      case 'Out for Delivery':
        return AppTheme.secondaryColor;
      case 'Delivered':
        return AppTheme.successColor;
      case 'Cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.textMediumColor;
    }
  }

  Color _paymentStatusColor(String status) {
    switch (status) {
      case 'Verified':
        return AppTheme.successColor;
      case 'Paid':
        return AppTheme.primaryColor;
      case 'Pending':
        return const Color(0xFFE67E22);
      default:
        return AppTheme.textMediumColor;
    }
  }

  String _paymentMethodLabel(PaymentMethod method) {
    return method == PaymentMethod.bankTransfer
        ? 'Bank Transfer'
        : 'Cash on Delivery';
  }

  Color _paymentMethodColor(PaymentMethod method) {
    return method == PaymentMethod.bankTransfer
        ? AppTheme.primaryColor
        : const Color(0xFF7F8C8D);
  }

  bool get _hasSlip {
    final path = order.proofOfTransferPath;
    return path != null && path.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);
    final paymentColor = _paymentStatusColor(order.paymentStatus);
    final methodColor = _paymentMethodColor(order.paymentMethod);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order.id.substring(0, 8).toUpperCase()}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppTheme.textDarkColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM dd, yyyy').format(order.date),
                            style: const TextStyle(
                              color: AppTheme.textMediumColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyUtils.format(order.totalAmount),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            order.status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (order.statusIndex + 1) /
                        OrderModel.statusSteps.length,
                    backgroundColor: AppTheme.backgroundColor,
                    color: statusColor,
                    minHeight: 4,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${order.items.length} item(s)',
                      style: const TextStyle(
                        color: AppTheme.textMediumColor,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Step ${order.statusIndex + 1} of ${OrderModel.statusSteps.length}',
                      style: const TextStyle(
                        color: AppTheme.textMediumColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        label: _paymentMethodLabel(order.paymentMethod),
                        color: methodColor,
                        icon: order.paymentMethod == PaymentMethod.bankTransfer
                            ? Icons.account_balance_outlined
                            : Icons.payments_outlined,
                      ),
                      _InfoChip(
                        label: 'Payment: ${order.paymentStatus}',
                        color: paymentColor,
                        icon: order.paymentStatus == 'Verified'
                            ? Icons.verified_outlined
                            : order.paymentStatus == 'Paid'
                                ? Icons.check_circle_outline
                                : Icons.hourglass_bottom_outlined,
                      ),
                      if (order.paymentMethod == PaymentMethod.bankTransfer)
                        _InfoChip(
                          label: _hasSlip ? 'Slip Uploaded' : 'No Slip',
                          color: _hasSlip
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                          icon: _hasSlip
                              ? Icons.receipt_long_outlined
                              : Icons.upload_file_outlined,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Divider(color: AppTheme.textLightColor.withValues(alpha: 0.2), height: 1),
                const SizedBox(height: 12),
                ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppTheme.textDarkColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${item.quantity} x ${CurrencyUtils.format(item.product.price)}',
                        style: const TextStyle(
                          color: AppTheme.textMediumColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _InfoChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}