import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../auth/controllers/auth_controller.dart';
import '../../../models/product_models.dart';
import '../../../models/order_models.dart';
import '../../../services/api_client.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/helpers.dart';
import '../controllers/orders_controller.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final nameC = TextEditingController();
  final phoneC = TextEditingController();
  final addressC = TextEditingController();
  final qtyC = TextEditingController();
  final noteC = TextEditingController();
  final picker = ImagePicker();

  Uint8List? _paymentBytes;
  String? _paymentFileName;
  String? _paymentProofUrl;
  bool _isUploadingPayment = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    qtyC.text = '${(args?['quantity'] as int?) ?? 1}';
  }

  @override
  void dispose() {
    nameC.dispose();
    phoneC.dispose();
    addressC.dispose();
    qtyC.dispose();
    noteC.dispose();
    super.dispose();
  }

  Future<void> _pickPaymentProof() async {
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _paymentBytes = bytes;
        _paymentFileName = picked.name;
        _paymentProofUrl = null;
      });
    }
  }

  Future<String?> _uploadPaymentProof() async {
    if (_paymentBytes == null) return null;
    setState(() => _isUploadingPayment = true);
    try {
      final res = await ApiClient().uploadFile('/upload', bytes: _paymentBytes!, filename: _paymentFileName ?? 'payment.jpg', auth: true);
      if (res.success && res.data != null) {
        _paymentProofUrl = res.data!['url'] as String?;
        return _paymentProofUrl;
      }
      return null;
    } finally {
      setState(() => _isUploadingPayment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final product = args?['product'] as Product?;
    final authC = Get.find<AuthController>();
    final ordersC = Get.find<OrdersController>();

    if (nameC.text.isEmpty) nameC.text = authC.profile.value?.name ?? '';

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.textHint),
              const SizedBox(height: 16),
              const Text('Tidak ada produk yang dipilih', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.offAllNamed('/products'),
                child: const Text('Pilih Produk'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Checkout Pesanan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product summary
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(14)),
                      child: product.imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(product.imageUrl, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.bakery_dining, color: AppColors.primary, size: 32)),
                            )
                          : const Icon(Icons.bakery_dining, color: AppColors.primary, size: 32),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
                          const SizedBox(height: 4),
                          Text('Rp ${formatPrice(product.price.toInt())} / pcs',
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Customer info
            const Text('Data Pengiriman & Pemesan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            TextField(
              controller: nameC,
              decoration: const InputDecoration(
                labelText: 'Nama Penerima',
                prefixIcon: Icon(Icons.person_outlined, color: AppColors.textHint),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneC,
              decoration: const InputDecoration(
                labelText: 'No. Telepon / WhatsApp',
                prefixIcon: Icon(Icons.phone_outlined, color: AppColors.textHint),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressC,
              decoration: const InputDecoration(
                labelText: 'Alamat Lengkap Pengiriman',
                prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.textHint),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: qtyC,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah',
                      prefixIcon: Icon(Icons.format_list_numbered, color: AppColors.textHint),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: noteC,
                    decoration: const InputDecoration(
                      labelText: 'Catatan (Opsional)',
                      prefixIcon: Icon(Icons.note_outlined, color: AppColors.textHint),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Payment proof
            const Text('Upload Bukti Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: _paymentBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Stack(
                        children: [
                          Image.memory(_paymentBytes!, fit: BoxFit.cover, width: double.infinity, height: 160,
                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 48)),
                          Positioned(
                            top: 8, right: 8,
                            child: GestureDetector(
                              onTap: () => setState(() { _paymentBytes = null; _paymentProofUrl = null; }),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.close, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : GestureDetector(
                      onTap: _pickPaymentProof,
                      child: Container(
                        height: 120,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey.shade400),
                            const SizedBox(height: 6),
                            Text('Tap untuk upload bukti bayar', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
            ),
            if (_isUploadingPayment)
              const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator()),
            if (_paymentProofUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('Bukti bayar siap ✓', style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w500)),
              ),
            const SizedBox(height: 20),

            // GPS info
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
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: ordersC.isSubmitting.value
                        ? null
                        : () async {
                            final name = nameC.text.trim();
                            final phone = phoneC.text.trim();
                            final address = addressC.text.trim();
                            final qty = int.tryParse(qtyC.text.trim()) ?? 1;

                            if (name.isEmpty || phone.isEmpty || address.isEmpty) {
                              showSnack('Perhatian', 'Silakan lengkapi Nama, No. Telepon, dan Alamat', AppColors.error);
                              return;
                            }
                            if (qty <= 0) {
                              showSnack('Perhatian', 'Jumlah pesanan minimal 1', AppColors.error);
                              return;
                            }
                            if (_paymentBytes == null && _paymentProofUrl == null) {
                              showSnack('Perhatian', 'Silakan upload bukti pembayaran terlebih dahulu', AppColors.error);
                              return;
                            }

                            final paymentUrl = await _uploadPaymentProof();
                            if (paymentUrl == null) {
                              showSnack('Error', 'Gagal upload bukti bayar', AppColors.error);
                              return;
                            }

                            final items = [OrderItemRequest(productId: product.id, quantity: qty)];
                            try {
                              final err = await ordersC.createOrder(
                                customerName: name,
                                customerPhone: phone,
                                customerAddress: address,
                                items: items,
                                paymentProof: paymentUrl,
                              );
                              if (err != null) {
                                showSnack('Gagal', err, AppColors.error);
                              } else {
                                showSnack('Berhasil', 'Pesanan berhasil dibuat! Admin akan memverifikasi pembayaran kamu.', AppColors.success);
                                Get.offAllNamed('/history');
                              }
                            } catch (e) {
                              showSnack('Error GPS', e.toString().replaceAll('Exception: ', ''), AppColors.error);
                            }
                          },
                    child: ordersC.isSubmitting.value
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                              SizedBox(width: 12),
                              Text('Memproses Pesanan...'),
                            ],
                          )
                        : const Text('Kirim Pesanan & Upload Bukti Bayar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
