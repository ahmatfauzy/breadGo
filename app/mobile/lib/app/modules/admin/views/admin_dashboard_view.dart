import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../auth/controllers/auth_controller.dart';
import '../../../models/order_models.dart';
import '../../../models/product_models.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/helpers.dart';
import '../controllers/admin_controller.dart';

class AdminDashboardView extends GetView<AdminController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          Obx(() => authC.isAdmin.value
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                      child: Text('${controller.orders.length} pesanan', style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (!authC.isAdmin.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.admin_panel_settings_outlined, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                const Text('Akses Ditolak', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                const Text('Halaman ini khusus untuk Admin BreadGo.', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.offAllNamed('/home'),
                  child: const Text('Kembali ke Home'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            _buildTabBar(),
            Expanded(child: _buildTabContent()),
          ],
        );
      }),
      floatingActionButton: Obx(() => authC.isAdmin.value && controller.selectedTab.value == 1
          ? FloatingActionButton.extended(
              onPressed: () => Get.toNamed('/admin/products/add'),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Tambah Produk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : const SizedBox.shrink()),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          _tabButton('Pesanan', 0),
          const SizedBox(width: 8),
          _tabButton('Produk', 1),
        ],
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    return Obx(() => GestureDetector(
          onTap: () => controller.switchTab(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: controller.selectedTab.value == index ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: controller.selectedTab.value == index ? AppColors.primary : Colors.grey.shade200),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: controller.selectedTab.value == index ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ));
  }

  Widget _buildTabContent() {
    return Obx(() {
      if (controller.selectedTab.value == 0) return _buildOrderSection();
      return _buildProductSection();
    });
  }

  // ─── ORDERS ───────────────────────────────

  Widget _buildOrderSection() {
    return Column(
      children: [
        _buildStatusFilter(),
        Expanded(child: _buildOrderList()),
      ],
    );
  }

  Widget _buildStatusFilter() {
    final statuses = ['', 'pending', 'confirmed', 'delivered', 'cancelled'];
    final labels = ['Semua', 'Pending', 'Confirmed', 'Delivered', 'Cancelled'];
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(statuses.length, (i) {
                final selected = controller.selectedStatus.value == statuses[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(labels[i]),
                    selected: selected,
                    selectedColor: statusColor(statuses[i]),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    onSelected: (_) => controller.filterByStatus(statuses[i]),
                  ),
                );
              }),
            ),
          ),
        ));
  }

  Widget _buildOrderList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.orders.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              const Text('Tidak ada pesanan', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: () => controller.fetchOrders(),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          itemCount: controller.orders.length,
          itemBuilder: (context, index) => _buildOrderCard(controller.orders[index]),
        ),
      );
    });
  }

  Widget _buildOrderCard(AdminOrderResponse order) {
    final color = statusColor(order.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Get.toNamed('/admin/orders/${order.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(
                      order.status == 'delivered' ? Icons.check_circle : order.status == 'cancelled' ? Icons.cancel : Icons.schedule,
                      color: color, size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text('${order.userName} (${order.userEmail})', style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(order.status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Rp ${order.totalAmount.toInt()}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(order.createdAt.substring(0, 10), style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── PRODUCTS ─────────────────────────────

  Widget _buildProductSection() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.products.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              const Text('Belum ada produk', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: () => controller.fetchProducts(),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          itemCount: controller.products.length,
          itemBuilder: (context, index) => _buildProductCard(controller.products[index]),
        ),
      );
    });
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 64, height: 64,
                child: product.imageUrl.isNotEmpty
                    ? Image.network(product.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppColors.primarySurface, child: const Icon(Icons.image, color: AppColors.primaryLight)))
                    : Container(color: AppColors.primarySurface, child: const Icon(Icons.image, color: AppColors.primaryLight)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('Rp ${product.price.toInt()}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primary)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: product.isActive ? AppColors.success.withValues(alpha: 0.1) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.isActive ? 'Aktif' : 'Nonaktif',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: product.isActive ? AppColors.success : Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(product.category, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                  onPressed: () => Get.toNamed('/admin/products/add', arguments: {'product': product}),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () => _confirmDelete(product),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Product product) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Yakin ingin menghapus "${product.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Get.back();
              final err = await controller.deleteProduct(product.id);
              if (err != null) {
                showSnack('Error', err, AppColors.error);
              } else {
                showSnack('Sukses', 'Produk dihapus', AppColors.success);
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
