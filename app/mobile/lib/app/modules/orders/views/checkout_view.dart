import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/product_models.dart';
import '../../../models/order_models.dart';
import '../controllers/orders_controller.dart';

class CheckoutView extends GetView<OrdersController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final product = args?['product'] as Product?;

    final nameC = TextEditingController();
    final phoneC = TextEditingController();
    final addressC = TextEditingController();
    final qtyC = TextEditingController(text: '1');
    final noteC = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product != null) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 50,
                  height: 50,
                  color: Colors.brown.shade100,
                  child: Icon(Icons.bakery_dining, color: Colors.brown.shade700),
                ),
                title: Text(product.name),
                subtitle: Text('Rp ${product.price.toInt()}'),
              ),
              const Divider(),
            ],
            const Text('Data Pemesan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: nameC,
              decoration: const InputDecoration(
                labelText: 'Nama Penerima',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneC,
              decoration: const InputDecoration(
                labelText: 'No. Telepon',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressC,
              decoration: const InputDecoration(
                labelText: 'Alamat Pengiriman',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            if (product != null) ...[
              const SizedBox(height: 12),
              TextField(
                controller: qtyC,
                decoration: const InputDecoration(
                  labelText: 'Jumlah',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: noteC,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            Text('* Koordinat GPS akan diambil otomatis',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 16),
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () async {
                            final name = nameC.text.trim();
                            final phone = phoneC.text.trim();
                            final address = addressC.text.trim();
                            if (name.isEmpty ||
                                phone.isEmpty ||
                                address.isEmpty) {
                              Get.snackbar('Error',
                                  'Semua field harus diisi',
                                  backgroundColor: Colors.red.shade100);
                              return;
                            }

                            final items = product != null
                                ? [
                                    OrderItemRequest(
                                      productId: product.id,
                                      quantity:
                                          int.tryParse(qtyC.text) ?? 1,
                                    )
                                  ]
                                : <OrderItemRequest>[];

                            try {
                              final err = await controller.createOrder(
                                customerName: name,
                                customerPhone: phone,
                                customerAddress: address,
                                items: items,
                              );
                              if (err != null) {
                                Get.snackbar('Error', err,
                                    backgroundColor: Colors.red.shade100);
                              } else {
                                Get.snackbar('Sukses',
                                    'Pesanan berhasil dibuat!',
                                    backgroundColor: Colors.green.shade100);
                                Get.offAllNamed('/history');
                              }
                            } catch (e) {
                              Get.snackbar('Error', e.toString(),
                                  backgroundColor: Colors.red.shade100);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.brown,
                      foregroundColor: Colors.white,
                    ),
                    child: controller.isSubmitting.value
                        ? const CircularProgressIndicator()
                        : const Text('Buat Pesanan'),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
