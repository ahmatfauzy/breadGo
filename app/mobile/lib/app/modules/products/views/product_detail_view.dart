import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../auth/controllers/auth_controller.dart';
import '../controllers/products_controller.dart';
import '../../../theme/app_theme.dart';

class ProductDetailView extends GetView<ProductsController> {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final id = Get.parameters['id'] ?? '';
    final quantity = 1.obs;

    if (controller.selectedProduct.value?.id != id) {
      controller.fetchProductDetail(id);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        final p = controller.selectedProduct.value;
        if (p == null) {
          return _buildNotFound();
        }
        return _buildContent(p, quantity);
      }),
    );
  }

  Widget _buildNotFound() {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bakery_dining,
                size: 72, color: AppColors.primaryLight),
            SizedBox(height: 16),
            Text(
              'Produk tidak ditemukan',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(dynamic p, RxInt quantity) {
    return Stack(
      children: [
        // ── Scrollable content ──
        CustomScrollView(
          slivers: [
            // ── Hero area ──
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: AppColors.primarySurface,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: _buildHeroImage(p),
              ),
            ),

            // ── Detail content ──
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    _buildCategoryBadge(p.category),
                    const SizedBox(height: 12),

                    // Nama produk
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Harga & Quantity selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rp ${_formatPrice(p.price.toInt())}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        // Quantity controls
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                tooltip: 'Kurangi jumlah',
                                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.remove, size: 18, color: AppColors.primary),
                                onPressed: () {
                                  if (quantity.value > 1) quantity.value--;
                                },
                              ),
                              Obx(() => Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      '${quantity.value}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  )),
                              IconButton(
                                tooltip: 'Tambah jumlah',
                                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.add, size: 18, color: AppColors.primary),
                                onPressed: () {
                                  quantity.value++;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Divider
                    Divider(color: Colors.grey.shade100),
                    const SizedBox(height: 20),

                    // Deskripsi
                    const Text(
                      'Deskripsi',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      p.description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ── Sticky bottom bar ──
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildBottomBar(p, quantity),
        ),
      ],
    );
  }

  Widget _buildHeroImage(dynamic p) {
    return Stack(
      children: [
        // Background dekorasi
        Container(
          color: AppColors.primarySurface,
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.07),
                  ),
                ),
              ),
              Positioned(
                left: -20,
                bottom: 20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.05),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Gambar produk
        Center(
          child: p.imageUrl.isNotEmpty
              ? Image.network(
                  p.imageUrl,
                  height: 220,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, stack) => const Icon(
                    Icons.bakery_dining,
                    size: 130,
                    color: AppColors.primaryLight,
                  ),
                )
              : const Icon(
                  Icons.bakery_dining,
                  size: 130,
                  color: AppColors.primaryLight,
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryBadge(String cat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        _categoryEmoji(cat),
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBottomBar(dynamic p, RxInt quantity) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Total Harga
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Total Harga',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Obx(() => Text(
                    'Rp ${_formatPrice((p.price * quantity.value).toInt())}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  )),
            ],
          ),
          const SizedBox(width: 16),
          // Tombol pesan
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                final authC = Get.find<AuthController>();
                if (!authC.isLoggedIn.value) {
                  Get.snackbar(
                    'Perhatian',
                    'Silakan login terlebih dahulu untuk memesan',
                    backgroundColor: AppColors.primary,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                  );
                  Get.toNamed('/login', arguments: {
                    'redirect': '/checkout',
                    'product': p,
                    'quantity': quantity.value,
                  });
                  return;
                }
                Get.toNamed(
                  '/checkout',
                  arguments: {
                    'product': p,
                    'quantity': quantity.value,
                  },
                );
              },
              icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 20),
              label: const Text('Pesan Sekarang'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _categoryEmoji(String cat) {
    switch (cat) {
      case 'bread':
        return '🍞  Roti';
      case 'cake':
        return '🎂  Kue';
      case 'pastry':
        return '🥐  Pastry';
      default:
        return '🛒  Lainnya';
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }
}
