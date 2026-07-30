import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/admin_controller.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/helpers.dart';
import '../../../services/api_client.dart';

class AdminOrderDetailView extends GetView<AdminController> {
  const AdminOrderDetailView({super.key});

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
              const Text('Data User', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              _buildInfoCard([
                _infoRow('Nama', order.userName),
                _infoRow('Email', order.userEmail),
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
              const Text('Bukti Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: order.paymentProof != null && order.paymentProof!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          order.paymentProof!,
                          headers: ApiClient().token != null ? {'Authorization': 'Bearer ${ApiClient().token}'} : null,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: 250,
                          errorBuilder: (_, __, ___) => Container(
                            padding: const EdgeInsets.all(40),
                            alignment: Alignment.center,
                            child: const Text('Gagal memuat bukti bayar', style: TextStyle(color: AppColors.error)),
                          ),
                        ),
                      )
                    : const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: Text('Belum ada bukti pembayaran', style: TextStyle(color: AppColors.textHint))),
                      ),
              ),
              const SizedBox(height: 20),
              const Text('Item', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
                    subtitle: Text('${item.quantity} x Rp ${item.price.toInt()}'),
                    trailing: Text('Rp ${(item.quantity * item.price).toInt()}', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Update Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              _buildStatusButtons(order),
              const SizedBox(height: 24),
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
                  Text('${order.userName} - ${order.customerName}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButtons(dynamic order) {
    final statuses = [
      {'status': 'pending', 'label': 'Pending', 'color': AppColors.pending},
      {'status': 'confirmed', 'label': 'Confirm', 'color': AppColors.confirmed},
      {'status': 'delivered', 'label': 'Deliver', 'color': AppColors.delivered},
      {'status': 'cancelled', 'label': 'Cancel', 'color': AppColors.cancelled},
    ];
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: statuses.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: s['color'] as Color,
                  side: BorderSide(color: (s['color'] as Color).withValues(alpha: 0.5)),
                  backgroundColor: order.status == s['status'] ? (s['color'] as Color).withValues(alpha: 0.1) : null,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: order.status == s['status']
                    ? null
                    : () async {
                        final err = await controller.updateOrderStatus(
                          orderId: order.id,
                          status: s['status'] as String,
                        );
                        if (err != null) {
                          showSnack('Error', err, AppColors.error);
                        } else {
                          showSnack('Sukses', 'Status diupdate', AppColors.success);
                        }
                      },
                child: Text(
                  s['label'] as String,
                  style: TextStyle(fontWeight: order.status == s['status'] ? FontWeight.bold : FontWeight.normal),
                ),
              ),
            ),
          )).toList(),
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
