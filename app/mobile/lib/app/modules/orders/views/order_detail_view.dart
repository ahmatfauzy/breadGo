import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/orders_controller.dart';

class OrderDetailView extends GetView<OrdersController> {
  const OrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final id = Get.parameters['id'] ?? '';

    if (controller.selectedOrder.value?.id != id) {
      controller.fetchOrderDetail(id);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final order = controller.selectedOrder.value;
        if (order == null) {
          return const Center(child: Text('Pesanan tidak ditemukan'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('ID Pesanan', order.id.substring(0, 8)),
              _buildInfoRow('Status', order.status.toUpperCase()),
              _buildInfoRow('Total', 'Rp ${order.totalAmount.toInt()}'),
              _buildInfoRow('Tanggal', order.createdAt),
              const SizedBox(height: 16),
              const Text('Data Pemesan',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              _buildInfoRow('Nama', order.customerName),
              _buildInfoRow('Telepon', order.customerPhone),
              _buildInfoRow('Alamat', order.customerAddress),
              _buildInfoRow('GPS',
                  '${order.latitude}, ${order.longitude}'),
              const SizedBox(height: 16),
              const Text('Item Pesanan',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ...order.items.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.productName),
                  subtitle: Text(
                      '${item.quantity} x Rp ${item.price.toInt()}'),
                  trailing: Text(
                      'Rp ${(item.quantity * item.price).toInt()}',
                      style:
                          TextStyle(color: Colors.green.shade700)),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 100,
              child: Text(label,
                  style: TextStyle(color: Colors.grey.shade600))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
