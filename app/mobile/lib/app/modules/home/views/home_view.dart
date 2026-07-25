import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../auth/controllers/auth_controller.dart';
import '../../products/controllers/products_controller.dart';
import '../../../theme/app_theme.dart';

class HomeView extends GetView {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();
    final prodC = Get.find<ProductsController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => prodC.fetchProducts(),
        child: CustomScrollView(
          slivers: [
            // ── Brown AppBar (pinned, no expandedHeight issues) ──
            _buildSliverAppBar(authC),

            // ── Greeting + Search (putih dengan rounded top) ──
            SliverToBoxAdapter(child: _buildGreetingAndSearch(authC)),

            // ── Banner Promo ──
            SliverToBoxAdapter(child: _buildPromoBanner()),

            // ── Kategori ──
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                'Kategori',
                null,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              ),
            ),
            SliverToBoxAdapter(child: _buildCategories(prodC)),

            // ── Produk Unggulan ──
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                'Produk Unggulan',
                () => Get.toNamed('/products'),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              ),
            ),

            // ── Grid Produk ──
            Obx(() {
              if (prodC.isLoading.value && prodC.products.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary),
                  ),
                );
              }
              if (prodC.products.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              final items = prodC.products.length > 4
                  ? prodC.products.sublist(0, 4)
                  : prodC.products;
              return SliverPadding(
                padding:
                    const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.76,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _buildProductCard(items[i]),
                    childCount: items.length,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(authC),
    );
  }

  // ═══════════════════════════════════════════
  // SLIVER APPBAR  (pinned, no flexible space)
  // ═══════════════════════════════════════════
  Widget _buildSliverAppBar(AuthController authC) {
    return const SliverAppBar(
      pinned: true,
      floating: false,
      backgroundColor: AppColors.primary,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Text(
        'BreadGo',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 22,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // GREETING + SEARCH  (di bawah appbar, white dengan rounded top dari brown)
  // ═══════════════════════════════════════════
  Widget _buildGreetingAndSearch(AuthController authC) {
    return Container(
      color: AppColors.primary, // sambungan warna coklat dari appbar
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting text
            Obx(() {
              final name = authC.profile.value?.name.split(' ').first;
              return Text(
                name != null
                    ? 'Hei, $name! 👋'
                    : 'Halo, selamat datang! 👋',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              );
            }),
            const SizedBox(height: 4),
            const Text(
              'Mau beli roti apa hari ini?',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            // Search bar
            GestureDetector(
              onTap: () => Get.toNamed('/products'),
              child: Container(
                height: 50,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search,
                        color: AppColors.textHint, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Cari roti, kue, pastry...',
                      style: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // PROMO BANNER  (aesthetic only, tanpa fitur diskon)
  // ═══════════════════════════════════════════
  Widget _buildPromoBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            colors: [Color(0xFF7A4F2D), Color(0xFFC48B5F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -18,
              top: -18,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            Positioned(
              right: 55,
              bottom: -25,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Roti Segar\nSetiap Hari!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => Get.toNamed('/products'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Pesan Sekarang',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.bakery_dining,
                    size: 80,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // SECTION HEADER
  // ═══════════════════════════════════════════
  Widget _buildSectionHeader(
    String title,
    VoidCallback? onSeeAll, {
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // KATEGORI
  // ═══════════════════════════════════════════
  Widget _buildCategories(ProductsController prodC) {
    final categories = [
      {'emoji': '🍞', 'label': 'Roti', 'value': 'bread'},
      {'emoji': '🎂', 'label': 'Kue', 'value': 'cake'},
      {'emoji': '🥐', 'label': 'Pastry', 'value': 'pastry'},
      {'emoji': '🛒', 'label': 'Semua', 'value': ''},
    ];

    return SizedBox(
      height: 92,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final cat = categories[i];
          return GestureDetector(
            onTap: () {
              prodC.filterByCategory(cat['value']!);
              Get.toNamed('/products');
            },
            child: Column(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      cat['emoji']!,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  cat['label']!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════
  // PRODUCT CARD
  // ═══════════════════════════════════════════
  Widget _buildProductCard(dynamic product) {
    return GestureDetector(
      onTap: () => Get.toNamed('/products/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar produk
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20)),
                    child: product.imageUrl.isNotEmpty
                        ? Image.network(
                            product.imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) =>
                                _productImagePlaceholder(),
                          )
                        : _productImagePlaceholder(),
                  ),
                  // Category badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _categoryLabel(product.category),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${_formatPrice(product.price.toInt())}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productImagePlaceholder() {
    return Container(
      width: double.infinity,
      color: AppColors.primarySurface,
      child: const Center(
        child: Icon(Icons.bakery_dining,
            size: 52, color: AppColors.primaryLight),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // BOTTOM NAV BAR
  // ═══════════════════════════════════════════
  Widget _buildBottomNav(AuthController authC) {
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
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                  Icons.home_rounded, 'Home', true, () {}),
              _buildNavItem(Icons.store_rounded, 'Katalog', false,
                  () => Get.toNamed('/products')),
              _buildNavItem(Icons.receipt_long_rounded, 'Pesanan', false,
                  () => Get.toNamed('/history')),
              _buildNavItem(
                Icons.person_rounded,
                'Profil',
                false,
                () => _showProfileBottomSheet(authC),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: active ? AppColors.primary : AppColors.textHint,
              size: 24,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight:
                  active ? FontWeight.w700 : FontWeight.w500,
              color:
                  active ? AppColors.primary : AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // PROFILE BOTTOM SHEET
  // ═══════════════════════════════════════════
  void _showProfileBottomSheet(AuthController authC) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // User info header
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
                          if (p != null)
                            const SizedBox(height: 2),
                          if (p != null)
                            Text(
                              p.email,
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
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
                return _buildSheetItem(Icons.login_rounded, 'Login', () {
                  Get.back();
                  Get.toNamed('/login');
                });
              }
              return const SizedBox.shrink();
            }),
            Obx(() => authC.isAdmin.value
                ? _buildSheetItem(
                    Icons.admin_panel_settings_rounded,
                    'Admin Dashboard',
                    () {
                      Get.back();
                      Get.toNamed('/admin/dashboard');
                    },
                  )
                : const SizedBox.shrink()),
            Obx(() => authC.isLoggedIn.value
                ? _buildSheetItem(
                    Icons.logout_rounded,
                    'Logout',
                    () async {
                      await authC.logout();
                      Get.back();
                    },
                    color: AppColors.error,
                  )
                : const SizedBox.shrink()),
            const SizedBox(height: 24),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildSheetItem(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    final c = color ?? AppColors.textPrimary;
    return ListTile(
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
    );
  }

  // ═══════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════
  String _categoryLabel(String cat) {
    switch (cat) {
      case 'bread':
        return 'Roti';
      case 'cake':
        return 'Kue';
      case 'pastry':
        return 'Pastry';
      default:
        return 'Lainnya';
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }
}
