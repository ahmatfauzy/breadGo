import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/auth/controllers/auth_controller.dart';
import '../theme/app_theme.dart';

class AppBottomNav extends StatelessWidget {
  final String currentRoute;

  const AppBottomNav({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_rounded, 'Home', currentRoute == '/home', () => Get.offAllNamed('/home')),
              _navItem(Icons.store_rounded, 'Katalog', currentRoute == '/products', () => Get.toNamed('/products')),
              _navItem(Icons.receipt_long_rounded, 'Pesanan', currentRoute == '/history', () => Get.toNamed('/history')),
              _navItem(
                Icons.person_rounded,
                'Profil',
                false,
                () => _showProfileSheet(authC),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: active ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: active ? AppColors.primary : AppColors.textHint, size: 24),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? AppColors.primary : AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileSheet(AuthController authC) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              final p = authC.profile.value;
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        p != null ? p.name[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p?.name ?? 'Guest',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          if (p != null) const SizedBox(height: 2),
                          if (p != null)
                            Text(p.email, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            Obx(() {
              if (!authC.isLoggedIn.value) {
                return _sheetItem(Icons.login_rounded, 'Login', () {
                  Get.back();
                  Get.toNamed('/login');
                });
              }
              return const SizedBox.shrink();
            }),
            Obx(() => authC.isAdmin.value
                ? _sheetItem(Icons.admin_panel_settings_rounded, 'Admin Dashboard', () {
                    Get.back();
                    Get.toNamed('/admin/dashboard');
                  })
                : const SizedBox.shrink()),
            Obx(() => authC.isLoggedIn.value
                ? _sheetItem(Icons.logout_rounded, 'Logout', () async {
                    await authC.logout();
                    Get.back();
                  }, color: AppColors.error)
                : const SizedBox.shrink()),
            const SizedBox(height: 24),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _sheetItem(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    final c = color ?? AppColors.textPrimary;
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (color ?? AppColors.primary).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: c, size: 20),
        ),
        title: Text(title, style: TextStyle(color: c, fontSize: 15, fontWeight: FontWeight.w600)),
        onTap: onTap,
        horizontalTitleGap: 16,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      ),
    );
  }
}
