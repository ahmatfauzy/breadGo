import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../theme/app_theme.dart';
import '../../../utils/helpers.dart';
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

        final color = statusColor(order.status);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusHeader(order, color),
              const SizedBox(height: 20),
              const Text('Informasi Pesanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              _buildInfoCard([
                _infoRow('ID Pesanan', '#${order.id.substring(0, 8)}'),
                _infoRow('Tanggal', order.createdAt),
                _infoRow('Total', 'Rp ${order.totalAmount.toInt()}'),
              ]),
              const SizedBox(height: 20),
              const Text('Data Pemesan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              _buildInfoCard([
                _infoRow('Nama', order.customerName),
                _infoRow('Telepon', order.customerPhone),
                _infoRow('Alamat', order.customerAddress),
                _infoRow('GPS', '${order.latitude}, ${order.longitude}', onTap: () async {
                  final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${order.latitude},${order.longitude}');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                }),
              ]),
              const SizedBox(height: 20),
              const Text('Item Pesanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: order.items.map((item) => ListTile(
                    leading: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.bakery_dining, size: 20, color: AppColors.primary),
                    ),
                    title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                    subtitle: Text('${item.quantity} x Rp ${item.price.toInt()}', style: const TextStyle(color: AppColors.textSecondary)),
                    trailing: Text('Rp ${(item.quantity * item.price).toInt()}', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                  )).toList(),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatusHeader(dynamic order, Color color) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(
                order.status == 'delivered' ? Icons.check_circle : order.status == 'cancelled' ? Icons.cancel : Icons.schedule,
                color: color, size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.status.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    order.status == 'pending' ? 'Menunggu konfirmasi' : order.status == 'confirmed' ? 'Pesanan dikonfirmasi' : order.status == 'delivered' ? 'Pesanan telah sampai' : 'Pesanan dibatalkan',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(padding: const EdgeInsets.all(16), child: Column(children: rows)),
    );
  }

  Widget _infoRow(String label, String value, {VoidCallback? onTap}) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 13))),
        ],
      ),
    );
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: row);
    }
    return row;
  }
}
