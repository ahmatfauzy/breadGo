import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../auth/controllers/auth_controller.dart';
import '../../../models/order_models.dart';
import '../controllers/admin_controller.dart';
import '../../../theme/app_theme.dart';

class AdminDashboardView extends GetView<AdminController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          Obx(() => authC.isAdmin.value
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${controller.orders.length} pesanan',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
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
                const Text(
                  'Akses Ditolak',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Halaman ini khusus untuk Admin BreadGo.',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.offAllNamed('/home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Kembali ke Home'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            _buildStatusFilter(),
            Expanded(child: _buildOrderList()),
          ],
        );
      }),
      floatingActionButton: Obx(() => authC.isAdmin.value
          ? FloatingActionButton.extended(
              onPressed: () => Get.toNamed('/admin/products/add'),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Tambah Produk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : const SizedBox.shrink()),
    );
  }

  Widget _buildStatusFilter() {
    final statuses = ['', 'pending', 'confirmed', 'delivered', 'cancelled'];
    final labels = ['Semua', 'Pending', 'Confirmed', 'Delivered', 'Cancelled'];
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(statuses.length, (i) {
                final selected =
                    controller.selectedStatus.value == statuses[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(labels[i]),
                    selected: selected,
                    selectedColor: _chipColor(statuses[i]),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF3E2723),
                      fontSize: 12,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    onSelected: (_) =>
                        controller.filterByStatus(statuses[i]),
                  ),
                );
              }),
            ),
          ),
        ));
  }

  Color _chipColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFFF9800);
      case 'confirmed':
        return const Color(0xFF2196F3);
      case 'delivered':
        return const Color(0xFF43A047);
      case 'cancelled':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFF8B5E3C);
    }
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
              const Text(
                'Tidak ada pesanan',
                style: TextStyle(fontSize: 16, color: Color(0xFF8D6E63)),
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: () => controller.fetchOrders(),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
          itemCount: controller.orders.length,
          itemBuilder: (context, index) {
            final order = controller.orders[index];
            return _buildOrderCard(order);
          },
        ),
      );
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFFF9800);
      case 'confirmed':
        return const Color(0xFF2196F3);
      case 'delivered':
        return const Color(0xFF43A047);
      case 'cancelled':
        return const Color(0xFFE53935);
      default:
        return Colors.grey;
    }
  }

  Widget _buildOrderCard(AdminOrderResponse order) {
    final color = _statusColor(order.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Get.toNamed('/admin/orders/${order.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      order.status == 'delivered'
                          ? Icons.check_circle
                          : order.status == 'cancelled'
                              ? Icons.cancel
                              : Icons.schedule,
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.customerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E2723),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${order.userName} (${order.userEmail})',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rp ${order.totalAmount.toInt()}',
                    style: const TextStyle(
                      color: Color(0xFF8B5E3C),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    order.createdAt.substring(0, 10),
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
