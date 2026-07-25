import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../auth/controllers/auth_controller.dart';
import '../../../models/product_models.dart';
import '../../../models/order_models.dart';
import '../controllers/orders_controller.dart';
import '../../../theme/app_theme.dart';

class CheckoutView extends GetView<OrdersController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final product = args?['product'] as Product?;
    final initialQty = (args?['quantity'] as int?) ?? 1;

    final authC = Get.find<AuthController>();

    final nameC = TextEditingController(text: authC.profile.value?.name ?? '');
    final phoneC = TextEditingController();
    final addressC = TextEditingController();
    final qtyC = TextEditingController(text: '$initialQty');
    final noteC = TextEditingController();

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.textHint),
              const SizedBox(height: 16),
              const Text('Tidak ada produk yang dipilih',
                  style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.offAllNamed('/products'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Pilih Produk'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout Pesanan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product summary card
            Card(
              elevation: 2,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: product.imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => const Icon(
                                  Icons.bakery_dining,
                                  color: AppColors.primary,
                                  size: 32,
                                ),
                              ),
                            )
                          : const Icon(Icons.bakery_dining, color: AppColors.primary, size: 32),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rp ${_formatPrice(product.price.toInt())} / pcs',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Data Pengiriman & Pemesan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Customer Name
            TextField(
              controller: nameC,
              decoration: InputDecoration(
                labelText: 'Nama Penerima',
                prefixIcon: const Icon(Icons.person_outlined, color: AppColors.textHint),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            // Phone
            TextField(
              controller: phoneC,
              decoration: InputDecoration(
                labelText: 'No. Telepon / WhatsApp',
                prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.textHint),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),

            // Delivery Address
            TextField(
              controller: addressC,
              decoration: InputDecoration(
                labelText: 'Alamat Lengkap Pengiriman',
                prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.textHint),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),

            // Quantity & Note
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: qtyC,
                    decoration: InputDecoration(
                      labelText: 'Jumlah',
                      prefixIcon: const Icon(Icons.format_list_numbered, color: AppColors.textHint),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: noteC,
                    decoration: InputDecoration(
                      labelText: 'Catatan (Opsional)',
                      prefixIcon: const Icon(Icons.note_outlined, color: AppColors.textHint),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // GPS notice box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.gps_fixed, size: 22, color: AppColors.primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Koordinat GPS rumah/lokasi Anda akan direkam secara otomatis dari smartphone saat membuat pesanan.',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit Order Button
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () async {
                            final name = nameC.text.trim();
                            final phone = phoneC.text.trim();
                            final address = addressC.text.trim();
                            final qty = int.tryParse(qtyC.text.trim()) ?? 1;

                            if (name.isEmpty || phone.isEmpty || address.isEmpty) {
                              Get.snackbar(
                                'Perhatian',
                                'Silakan lengkapi Nama, No. Telepon, dan Alamat',
                                backgroundColor: AppColors.error,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.TOP,
                                borderRadius: 12,
                                margin: const EdgeInsets.all(16),
                              );
                              return;
                            }
                            if (qty <= 0) {
                              Get.snackbar(
                                'Perhatian',
                                'Jumlah pesanan minimal 1',
                                backgroundColor: AppColors.error,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.TOP,
                                borderRadius: 12,
                                margin: const EdgeInsets.all(16),
                              );
                              return;
                            }

                            final items = [
                              OrderItemRequest(
                                productId: product.id,
                                quantity: qty,
                              )
                            ];

                            try {
                              final err = await controller.createOrder(
                                customerName: name,
                                customerPhone: phone,
                                customerAddress: address,
                                items: items,
                              );
                              if (err != null) {
                                Get.snackbar(
                                  'Gagal',
                                  err,
                                  backgroundColor: AppColors.error,
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.TOP,
                                  borderRadius: 12,
                                  margin: const EdgeInsets.all(16),
                                );
                              } else {
                                Get.snackbar(
                                  'Berhasil',
                                  'Pesanan berhasil dibuat dan tercatat!',
                                  backgroundColor: const Color(0xFF43A047),
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.TOP,
                                  borderRadius: 12,
                                  margin: const EdgeInsets.all(16),
                                );
                                Get.offAllNamed('/history');
                              }
                            } catch (e) {
                              Get.snackbar(
                                'Error GPS',
                                e.toString().replaceAll('Exception: ', ''),
                                backgroundColor: AppColors.error,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.TOP,
                                borderRadius: 12,
                                margin: const EdgeInsets.all(16),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isSubmitting.value
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              ),
                              SizedBox(width: 12),
                              Text('Mengambil GPS & Membuat Pesanan...'),
                            ],
                          )
                        : const Text(
                            'Kirim Pesanan (GPS)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }
}
