import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../services/providers/auth_provider.dart';
import '../../services/providers/product_provider.dart';
import '../../services/providers/order_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final products = Provider.of<ProductProvider>(context).products;
    final orders = Provider.of<OrderProvider>(context).orders;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFF2D3436),
            automaticallyImplyLeading: false,
            expandedHeight: 140,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2D3436), Color(0xFF636E72)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.admin_panel_settings,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Admin Dashboard',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'ShopEase Control Panel',
                                      style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.white70,
                              ),
                              onPressed: () async {
                                await auth.logout();
                                if (context.mounted) {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.landing,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  Row(
                    children: [
                      _StatCard(
                        label: 'Products',
                        value: '${products.length}',
                        icon: Icons.inventory_2_outlined,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'Orders',
                        value: '${orders.length}',
                        icon: Icons.receipt_long_outlined,
                        color: AppTheme.successColor,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'Revenue',
                        value: orders.isEmpty
                            ? '\$0'
                            : '\$${orders.fold(0.0, (s, o) => s + o.totalAmount).toStringAsFixed(0)}',
                        icon: Icons.attach_money,
                        color: AppTheme.warningColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Menu section title
                  const Text(
                    'Management',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDarkColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dashboard actions
                  _DashCard(
                    title: 'Manage Products',
                    subtitle: 'Edit, delete and rate products',
                    icon: Icons.inventory,
                    iconColor: AppTheme.primaryColor,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.manageProducts,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DashCard(
                    title: 'Add New Product',
                    subtitle: 'Create a new product listing',
                    icon: Icons.add_box_outlined,
                    iconColor: AppTheme.successColor,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.addProduct,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DashCard(
                    title: 'Manage Orders',
                    subtitle: 'Update order status, filters & archive',
                    icon: Icons.receipt_long,
                    iconColor: AppTheme.warningColor,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.manageOrders,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DashCard(
                    title: 'Manage Categories',
                    subtitle: 'Add, Edit, and Delete categories dynamically',
                    icon: Icons.category_outlined,
                    iconColor: const Color(0xFF6C5CE7),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.manageCategories,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DashCard(
                    title: 'Bank & Payment Details',
                    subtitle: 'Update account info, PromptPay & QR code',
                    icon: Icons.account_balance_outlined,
                    iconColor: const Color(0xFF00B894),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.manageBankDetails,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textMediumColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _DashCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDarkColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMediumColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppTheme.textLightColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}