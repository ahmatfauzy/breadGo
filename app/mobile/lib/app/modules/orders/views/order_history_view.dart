import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/order_models.dart';
import '../controllers/orders_controller.dart';

class OrderHistoryView extends GetView<OrdersController> {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pesanan')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.orders.isEmpty) {
          return const Center(child: Text('Belum ada pesanan'));
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
      }),
    );
  }

  Widget _buildOrderCard(OrderResponse order) {
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
        onTap: () => Get.toNamed('/orders/${order.id}'),
        title: Text(order.id.substring(0, 8),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order.customerName),
            Text('Rp ${order.totalAmount.toInt()}',
                style: TextStyle(color: Colors.green.shade700)),
          ],
        ),
        trailing: Chip(
          label: Text(order.status,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
          backgroundColor: color,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
