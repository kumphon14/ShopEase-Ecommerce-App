// lib/screens/admin/manage_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/order.dart';
import '../../services/providers/order_provider.dart';
import '../../utils/currency_utils.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';

  static const List<String> _filters = [
    'All',
    'Order Placed',
    'Confirmed',
    'Packing',
    'Shipped',
    'Out for Delivery',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders) {
    if (_selectedFilter == 'All') return orders;
    return orders.where((o) => o.status == _selectedFilter).toList();
  }

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

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final activeOrders = _filterOrders(orderProvider.activeOrders);
    final archivedOrders = orderProvider.archivedOrders;
    final counts = orderProvider.statusCounts;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (_, _) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            title: const Text(
              'Order Management',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.textMediumColor,
              indicatorColor: AppTheme.primaryColor,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Active'),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${orderProvider.activeOrders.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Archive'),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.textMediumColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${archivedOrders.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // ── Tab 1: Active Orders ─────────────────────────────
            Column(
              children: [
                // Dashboard stats
                _StatusDashboard(counts: counts, statusColor: _statusColor),

                // Filter chips
                SizedBox(
                  height: 52,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    children: _filters.map((f) {
                      final isSelected = _selectedFilter == f;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFilter = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : AppTheme.textLightColor.withValues(
                                      alpha: 0.3,
                                    ),
                            ),
                          ),
                          child: Text(
                            '$f${f == 'All' ? '' : ' (${counts[f] ?? 0})'}',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textDarkColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Active orders list
                Expanded(
                  child: activeOrders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.receipt_long_outlined,
                                size: 56,
                                color: AppTheme.textLightColor,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No orders found',
                                style: TextStyle(
                                  color: AppTheme.textMediumColor,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: activeOrders.length,
                          itemBuilder: (_, i) => _OrderCard(
                            key: ValueKey<String>(
                              'shopease.admin.orderCard.${activeOrders[i].id}',
                            ),
                            order: activeOrders[i],
                            statusColor: _statusColor,
                            onStatusChanged: (newStatus) =>
                                orderProvider.updateOrderStatus(
                                  activeOrders[i].id,
                                  newStatus,
                                ),
                            onPaymentStatusChanged: (s) => orderProvider
                                .updatePaymentStatus(activeOrders[i].id, s),
                            onArchive: () =>
                                orderProvider.archiveOrder(activeOrders[i].id),
                          ),
                        ),
                ),
              ],
            ),

            // ── Tab 2: Archived Orders ────────────────────────────
            archivedOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.archive_outlined,
                          size: 64,
                          color: AppTheme.textLightColor,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No archived orders',
                          style: TextStyle(
                            color: AppTheme.textMediumColor,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Delivered orders will appear here.',
                          style: TextStyle(color: AppTheme.textMediumColor),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: archivedOrders.length,
                    itemBuilder: (_, i) => _ArchivedOrderCard(
                      order: archivedOrders[i],
                      statusColor: _statusColor,
                      onRestore: () =>
                          orderProvider.restoreOrder(archivedOrders[i].id),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

// ─── Status Dashboard ─────────────────────────────────────────────────────────

class _StatusDashboard extends StatelessWidget {
  final Map<String, int> counts;
  final Color Function(String) statusColor;

  const _StatusDashboard({required this.counts, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    final dashItems = [
      ('Order Placed', 'Placed', Icons.receipt_outlined),
      ('Confirmed', 'Confirmed', Icons.check_circle_outline),
      ('Packing', 'Packing', Icons.inventory_2_outlined),
      ('Shipped', 'Shipped', Icons.local_shipping_outlined),
      ('Out for Delivery', 'Delivery', Icons.delivery_dining),
      ('Cancelled', 'Cancelled', Icons.cancel_outlined),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: SizedBox(
        height: 104,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: dashItems.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final statusKey = dashItems[i].$1;
            final shortLabel = dashItems[i].$2;
            final icon = dashItems[i].$3;
            final count = counts[statusKey] ?? 0;
            final color = statusColor(statusKey);

            return Container(
              width: 92,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.18)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$count',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shortLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textMediumColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Order Card (Active) ──────────────────────────────────────────────────────

class _OrderCard extends StatefulWidget {
  final OrderModel order;
  final Color Function(String) statusColor;
  final void Function(String) onStatusChanged;
  final void Function(String) onPaymentStatusChanged;
  final VoidCallback onArchive;

  const _OrderCard({
    super.key,
    required this.order,
    required this.statusColor,
    required this.onStatusChanged,
    required this.onPaymentStatusChanged,
    required this.onArchive,
  });

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final color = widget.statusColor(order.status);
    final payColor = order.paymentStatus == 'Verified'
        ? AppTheme.successColor
        : order.paymentStatus == 'Paid'
        ? Colors.blue
        : AppTheme.warningColor;

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
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.id,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: AppTheme.textMediumColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              order.customerName ?? 'Customer',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppTheme.textDarkColor,
                              ),
                            ),
                            Text(
                              'ID: ${order.customerId ?? '-'}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textMediumColor,
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
                              color: AppTheme.primaryColor,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _StatusBadge(label: order.status, color: color),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        order.paymentMethod == PaymentMethod.cod
                            ? Icons.payments_outlined
                            : Icons.account_balance_outlined,
                        size: 14,
                        color: AppTheme.textMediumColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        order.paymentMethod == PaymentMethod.cod
                            ? 'COD'
                            : 'Bank Transfer',
                        style: const TextStyle(
                          color: AppTheme.textMediumColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusBadge(
                        label: order.paymentStatus,
                        color: payColor,
                        small: true,
                      ),
                      if (order.proofOfTransferPath != null) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.attach_file,
                          size: 12,
                          color: AppTheme.successColor,
                        ),
                        const Text(
                          'slip',
                          style: TextStyle(
                            color: AppTheme.successColor,
                            fontSize: 11,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        DateFormat('dd MMM yy · HH:mm').format(order.date),
                        style: const TextStyle(
                          color: AppTheme.textMediumColor,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        color: AppTheme.textMediumColor,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expanded detail
          if (_expanded) ...[
            const Divider(height: 1),
            // Products table
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Items',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppTheme.textDarkColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Table header
                  _TableRow(
                    pid: 'Product ID',
                    name: 'Name',
                    qty: 'Qty',
                    unit: 'Unit',
                    total: 'Total',
                    isHeader: true,
                  ),
                  const Divider(height: 8),
                  ...order.items.map(
                    (item) => _TableRow(
                      pid: item.product.id,
                      name: item.product.name,
                      qty: '${item.quantity}',
                      unit: CurrencyUtils.format(item.product.price),
                      total: CurrencyUtils.format(
                        item.product.price * item.quantity,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Status update buttons
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Update Status',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppTheme.textMediumColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...OrderModel.statusSteps
                          .where((s) => s != order.status)
                          .map(
                            (status) => _OutlineChip(
                              key: ValueKey<String>(
                                'shopease.admin.orderStatus.${order.id}.$status',
                              ),
                              label: status,
                              color: widget.statusColor(status),
                              onTap: () => widget.onStatusChanged(status),
                            ),
                          ),
                      _OutlineChip(
                        key: ValueKey<String>(
                          'shopease.admin.orderStatus.${order.id}.Cancelled',
                        ),
                        label: 'Cancelled',
                        color: AppTheme.errorColor,
                        onTap: () => widget.onStatusChanged('Cancelled'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Payment Status',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppTheme.textMediumColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Pending', 'Paid', 'Verified']
                        .where((s) => s != order.paymentStatus)
                        .map(
                          (s) => _OutlineChip(
                            key: ValueKey<String>(
                              'shopease.admin.paymentStatus.${order.id}.$s',
                            ),
                            label: s,
                            color: s == 'Verified'
                                ? AppTheme.successColor
                                : s == 'Paid'
                                ? Colors.blue
                                : AppTheme.warningColor,
                            onTap: () => widget.onPaymentStatusChanged(s),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  // Archive button
                  OutlinedButton.icon(
                    onPressed: widget.onArchive,
                    icon: const Icon(Icons.archive_outlined, size: 16),
                    label: const Text('Archive Order'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textMediumColor,
                      side: const BorderSide(color: AppTheme.textLightColor),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Archived Order Card ──────────────────────────────────────────────────────

class _ArchivedOrderCard extends StatelessWidget {
  final OrderModel order;
  final Color Function(String) statusColor;
  final VoidCallback onRestore;

  const _ArchivedOrderCard({
    required this.order,
    required this.statusColor,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.textLightColor.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.done_all,
                color: AppTheme.successColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.id,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: AppTheme.textMediumColor,
                    ),
                  ),
                  Text(
                    order.customerName ?? 'Customer',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${order.items.length} item(s) · ${CurrencyUtils.format(order.totalAmount)}',
                    style: const TextStyle(
                      color: AppTheme.textMediumColor,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy').format(order.date),
                    style: const TextStyle(
                      color: AppTheme.textMediumColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusBadge(
                  label: order.status,
                  color: statusColor(order.status),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onRestore,
                  child: const Text(
                    'Restore',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool small;

  const _StatusBadge({
    required this.label,
    required this.color,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 10,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: small ? 10 : 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _OutlineChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _OutlineChip({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final String pid;
  final String name;
  final String qty;
  final String unit;
  final String total;
  final bool isHeader;

  const _TableRow({
    required this.pid,
    required this.name,
    required this.qty,
    required this.unit,
    required this.total,
    this.isHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = isHeader
        ? const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 11,
            color: AppTheme.textMediumColor,
          )
        : const TextStyle(fontSize: 11, color: AppTheme.textDarkColor);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              pid,
              style: style,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              name,
              style: style,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          SizedBox(
            width: 24,
            child: Text(qty, style: style, textAlign: TextAlign.center),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 52,
            child: Text(unit, style: style, textAlign: TextAlign.right),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 56,
            child: Text(
              total,
              style: style.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
