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

        final statusColor = _statusColor(order.status);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusHeader(order, statusColor),
              const SizedBox(height: 20),
              const Text('Informasi Pesanan',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723))),
              const SizedBox(height: 12),
              _buildInfoCard([
                _infoRow('ID Pesanan', '#${order.id.substring(0, 8)}'),
                _infoRow('Tanggal', order.createdAt),
                _infoRow('Total', 'Rp ${order.totalAmount.toInt()}'),
              ]),
              const SizedBox(height: 20),
              const Text('Data Pemesan',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723))),
              const SizedBox(height: 12),
              _buildInfoCard([
                _infoRow('Nama', order.customerName),
                _infoRow('Telepon', order.customerPhone),
                _infoRow('Alamat', order.customerAddress),
                _infoRow('GPS', '${order.latitude}, ${order.longitude}'),
              ]),
              const SizedBox(height: 20),
              const Text('Item Pesanan',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723))),
              const SizedBox(height: 12),
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: order.items.map((item) {
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5E3C).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.bakery_dining,
                            size: 20, color: Color(0xFF8B5E3C)),
                      ),
                      title: Text(item.productName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3E2723))),
                      subtitle: Text('${item.quantity} x Rp ${item.price.toInt()}',
                          style: TextStyle(color: Colors.grey.shade600)),
                      trailing: Text(
                        'Rp ${(item.quantity * item.price).toInt()}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8B5E3C)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      }),
    );
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

  Widget _buildStatusHeader(dynamic order, Color color) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                order.status == 'delivered'
                    ? Icons.check_circle
                    : order.status == 'cancelled'
                        ? Icons.cancel
                        : Icons.schedule,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.status.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.status == 'pending'
                        ? 'Menunggu konfirmasi'
                        : order.status == 'confirmed'
                            ? 'Pesanan dikonfirmasi'
                            : order.status == 'delivered'
                                ? 'Pesanan telah sampai'
                                : 'Pesanan dibatalkan',
                    style: TextStyle(
                      color: Colors.grey.shade600,
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

  Widget _buildInfoCard(List<Widget> rows) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: rows),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  color: Color(0xFF3E2723),
                  fontWeight: FontWeight.w500,
                  fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
