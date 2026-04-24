// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../services/providers/auth_provider.dart';
import '../../services/providers/wishlist_provider.dart';
import '../../services/providers/order_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final wishlist = Provider.of<WishlistProvider>(context);
    final orders = Provider.of<OrderProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            automaticallyImplyLeading: false,
            backgroundColor: AppTheme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          auth.isAuthenticated && auth.username.isNotEmpty
                              ? auth.username[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        auth.isAuthenticated ? auth.username : 'Guest User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        auth.isAuthenticated ? auth.email : 'Not signed in',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // Stats row
                if (auth.isAuthenticated) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Row(
                      children: [
                        _StatBadge(
                          label: 'Orders',
                          value: '${orders.orders.length}',
                          icon: Icons.receipt_long_outlined,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 12),
                        _StatBadge(
                          label: 'Wishlist',
                          value: '${wishlist.items.length}',
                          icon: Icons.favorite_border,
                          color: AppTheme.secondaryColor,
                        ),
                        const SizedBox(width: 12),
                        _StatBadge(
                          label: 'Pending',
                          value:
                              '${orders.orders.where((o) => o.status != 'Delivered' && o.status != 'Cancelled').length}',
                          icon: Icons.local_shipping_outlined,
                          color: AppTheme.warningColor,
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Menu items
                _MenuSection(
                  title: 'My Account',
                  items: [
                    _MenuItem(
                      icon: Icons.history,
                      label: 'Order History',
                      trailing: auth.isAuthenticated
                          ? Text(
                              '${orders.orders.length}',
                              style: const TextStyle(
                                  color: AppTheme.textMediumColor,
                                  fontSize: 13),
                            )
                          : null,
                      onTap: () {
                        if (auth.isAuthenticated) {
                          Navigator.pushNamed(context, AppRoutes.orderHistory);
                        } else {
                          Navigator.pushNamed(context, AppRoutes.login);
                        }
                      },
                    ),
                    _MenuItem(
                      icon: Icons.favorite_border,
                      label: 'My Wishlist',
                      trailing: Text(
                        '${wishlist.items.length} items',
                        style: const TextStyle(
                            color: AppTheme.textMediumColor, fontSize: 13),
                      ),
                      onTap: () {
                        if (auth.isAuthenticated) {
                          Navigator.pushNamed(context, AppRoutes.wishlist);
                        } else {
                          Navigator.pushNamed(context, AppRoutes.login);
                        }
                      },
                    ),
                    _MenuItem(
                      icon: Icons.person_outline,
                      label: 'Edit Profile',
                      onTap: () {
                        if (auth.isAuthenticated) {
                          Navigator.pushNamed(context, AppRoutes.editProfile);
                        } else {
                          Navigator.pushNamed(context, AppRoutes.login);
                        }
                      },
                    ),
                    _MenuItem(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      trailing: orders.unreadNotificationsCount > 0
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${orders.unreadNotificationsCount}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          : null,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.notifications),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Auth section
                if (auth.isAuthenticated)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await auth.logout();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(
                              context, AppRoutes.landing);
                        }
                      },
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('Sign Out'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                        side: const BorderSide(
                            color: AppTheme.errorColor, width: 1.5),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.login),
                      icon: const Icon(Icons.login, size: 18),
                      label: const Text('Login to Your Account'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBadge({
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
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textMediumColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppTheme.textMediumColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  color: AppTheme.primaryColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: AppTheme.textDarkColor,
                ),
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right,
                  color: AppTheme.textLightColor, size: 20),
          ],
        ),
      ),
    );
  }
}
