import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/admin_controller.dart';

class AdminOrderDetailView extends GetView<AdminController> {
  const AdminOrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final id = Get.parameters['id'] ?? '';

    if (controller.selectedOrder.value?.id != id) {
      controller.fetchOrderDetail(id);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan (Admin)')),
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
              _buildInfoRow('ID', order.id.substring(0, 8)),
              _buildInfoRow('Status', order.status.toUpperCase()),
              _buildInfoRow('Total', 'Rp ${order.totalAmount.toInt()}'),
              _buildInfoRow('Tanggal', order.createdAt),
              const SizedBox(height: 16),
              const Text('Data User',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              _buildInfoRow('Nama', order.userName),
              _buildInfoRow('Email', order.userEmail),
              const SizedBox(height: 16),
              const Text('Data Pemesan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              _buildInfoRow('Nama', order.customerName),
              _buildInfoRow('Telepon', order.customerPhone),
              _buildInfoRow('Alamat', order.customerAddress),
              _buildInfoRow('GPS', '${order.latitude}, ${order.longitude}'),
              const SizedBox(height: 16),
              const Text('Item',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ...order.items.map((item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.productName),
                    subtitle: Text(
                        '${item.quantity} x Rp ${item.price.toInt()}'),
                    trailing: Text(
                        'Rp ${(item.quantity * item.price).toInt()}',
                        style: TextStyle(color: Colors.green.shade700)),
                  )),
              const SizedBox(height: 16),
              const Text('Update Status',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              _buildStatusButtons(order),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatusButtons(dynamic order) {
    final statuses = ['pending', 'confirmed', 'delivered', 'cancelled'];
    return Wrap(
      spacing: 8,
      children: statuses.map((status) {
        final isCurrent = order.status == status;
        return ChoiceChip(
          label: Text(status),
          selected: isCurrent,
          onSelected: isCurrent
              ? null
              : (_) async {
                  final err = await controller.updateOrderStatus(
                    orderId: order.id,
                    status: status,
                  );
                  if (err != null) {
                    Get.snackbar('Error', err,
                        backgroundColor: Colors.red.shade100);
                  } else {
                    Get.snackbar('Sukses', 'Status diupdate',
                        backgroundColor: Colors.green.shade100);
                  }
                },
        );
      }).toList(),
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
