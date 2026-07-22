import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/order_models.dart';
import '../controllers/admin_controller.dart';

class AdminDashboardView extends GetView<AdminController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Column(
        children: [
          _buildStatusFilter(),
          Expanded(child: _buildOrderList()),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    final statuses = ['', 'pending', 'confirmed', 'delivered', 'cancelled'];
    final labels = ['Semua', 'Pending', 'Confirmed', 'Delivered', 'Cancelled'];
    return Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: List.generate(statuses.length, (i) {
              final selected =
                  controller.selectedStatus.value == statuses[i];
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text(labels[i], style: const TextStyle(fontSize: 12)),
                  selected: selected,
                  onSelected: (_) =>
                      controller.filterByStatus(statuses[i]),
                ),
              );
            }),
          ),
        ));
  }

  Widget _buildOrderList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.orders.isEmpty) {
        return const Center(child: Text('Tidak ada pesanan'));
      }
      return RefreshIndicator(
        onRefresh: () => controller.fetchOrders(),
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: controller.orders.length,
          itemBuilder: (context, index) {
            final order = controller.orders[index];
            return _buildOrderCard(order);
          },
        ),
      );
    });
  }

  Widget _buildOrderCard(AdminOrderResponse order) {
    final statusColors = {
      'pending': Colors.orange,
      'confirmed': Colors.blue,
      'delivered': Colors.green,
      'cancelled': Colors.red,
    };
    final color = statusColors[order.status] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: () => Get.toNamed('/admin/orders/${order.id}'),
        title: Text(order.customerName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${order.userName} (${order.userEmail})',
                style: const TextStyle(fontSize: 12)),
            Text('Rp ${order.totalAmount.toInt()}',
                style: TextStyle(color: Colors.green.shade700)),
          ],
        ),
        trailing: Chip(
          label: Text(order.status,
              style: const TextStyle(color: Colors.white, fontSize: 11)),
          backgroundColor: color,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
