import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../auth/controllers/auth_controller.dart';
import '../../../models/order_models.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/app_bottom_nav.dart';
import '../controllers/orders_controller.dart';

class OrderHistoryView extends GetView<OrdersController> {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Riwayat Pesanan')),
      body: Obx(() {
        if (!authC.isLoggedIn.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: AppColors.textHint),
                const SizedBox(height: 16),
                const Text('Silakan login untuk melihat riwayat pesanan', style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/login', arguments: {'redirect': '/history'}),
                  icon: const Icon(Icons.login),
                  label: const Text('Masuk Ke Akun'),
                ),
              ],
            ),
          );
        }

        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (controller.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textHint),
                const SizedBox(height: 16),
                const Text('Belum ada pesanan', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/products'),
                  icon: const Icon(Icons.store),
                  label: const Text('Mulai Belanja'),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => controller.fetchOrders(),
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: controller.orders.length,
            itemBuilder: (context, index) => _buildOrderCard(controller.orders[index]),
          ),
        );
      }),
      bottomNavigationBar: const AppBottomNav(currentRoute: '/history'),
    );
  }

  Widget _buildOrderCard(OrderResponse order) {
    final color = statusColor(order.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Get.toNamed('/orders/${order.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                child: Center(
                  child: Icon(
                    order.status == 'delivered' ? Icons.check_circle : order.status == 'cancelled' ? Icons.cancel : Icons.schedule,
                    color: color, size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pesanan #${order.id.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(order.customerName, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text('Rp ${order.totalAmount.toInt()}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(order.status.toUpperCase(), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
