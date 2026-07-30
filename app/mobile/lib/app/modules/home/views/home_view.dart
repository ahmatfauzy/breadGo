import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../auth/controllers/auth_controller.dart';
import '../../products/controllers/products_controller.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/app_bottom_nav.dart';

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
            _buildSliverAppBar(),
            SliverToBoxAdapter(child: _buildGreetingAndSearch(authC)),
            SliverToBoxAdapter(child: _buildPromoBanner()),
            SliverToBoxAdapter(
              child: _buildSectionHeader('Kategori', null, padding: const EdgeInsets.fromLTRB(20, 20, 20, 12)),
            ),
            SliverToBoxAdapter(child: _buildCategories(prodC)),
            SliverToBoxAdapter(
              child: _buildSectionHeader('Produk Unggulan', () => Get.toNamed('/products'), padding: const EdgeInsets.fromLTRB(20, 24, 20, 12)),
            ),
            Obx(() {
              if (prodC.isLoading.value && prodC.products.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                );
              }
              if (prodC.products.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              final items = prodC.products.length > 4 ? prodC.products.sublist(0, 4) : prodC.products;
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
      bottomNavigationBar: const AppBottomNav(currentRoute: '/home'),
    );
  }

  Widget _buildSliverAppBar() {
    return const SliverAppBar(
      pinned: true,
      floating: false,
      backgroundColor: AppColors.primary,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Text(
        'BreadGo',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22, letterSpacing: -0.5),
      ),
    );
  }

  Widget _buildGreetingAndSearch(AuthController authC) {
    return Container(
      color: AppColors.primary,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              final name = authC.profile.value?.name.split(' ').first;
              return Text(
                name != null ? 'Hei, $name! 👋' : 'Halo, selamat datang! 👋',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.3),
              );
            }),
            const SizedBox(height: 4),
            const Text('Mau beli roti apa hari ini?', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => Get.toNamed('/products'),
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: AppColors.textHint, size: 20),
                    const SizedBox(width: 10),
                    const Text('Cari roti, kue, pastry...', style: TextStyle(color: AppColors.textHint, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(colors: [Color(0xFF7A4F2D), Color(0xFFC48B5F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.28), blurRadius: 18, offset: const Offset(0, 8))],
        ),
        child: Stack(
          children: [
            Positioned(right: -18, top: -18, child: Container(width: 110, height: 110, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.07)))),
            Positioned(right: 55, bottom: -25, child: Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)))),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Roti Segar\nSetiap Hari!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, height: 1.25, letterSpacing: -0.3)),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => Get.toNamed('/products'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                            child: const Text('Pesan Sekarang', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.bakery_dining, size: 80, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onSeeAll, {EdgeInsets padding = EdgeInsets.zero}) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.3)),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: const Text('Lihat Semua', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

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
                  width: 62, height: 62,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Center(child: Text(cat['emoji']!, style: const TextStyle(fontSize: 28))),
                ),
                const SizedBox(height: 7),
                Text(cat['label']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(dynamic product) {
    return GestureDetector(
      onTap: () => Get.toNamed('/products/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: product.imageUrl.isNotEmpty
                        ? Image.network(product.imageUrl, width: double.infinity, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => _placeholder())
                        : _placeholder(),
                  ),
                  Positioned(
                    top: 10, left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(8)),
                      child: Text(categoryLabel(product.category), style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(product.description, style: const TextStyle(color: AppColors.textHint, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text('Rp ${formatPrice(product.price.toInt())}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      color: AppColors.primarySurface,
      child: const Center(child: Icon(Icons.bakery_dining, size: 52, color: AppColors.primaryLight)),
    );
  }
}
