import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/products_controller.dart';

class ProductDetailView extends GetView<ProductsController> {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final id = Get.parameters['id'] ?? '';
    final product = controller.selectedProduct.value;

    if (product == null || product.id != id) {
      controller.fetchProductDetail(id);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final p = controller.selectedProduct.value;
        if (p == null) {
          return const Center(child: Text('Produk tidak ditemukan'));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.brown.shade100,
                child: Center(
                  child: Icon(Icons.bakery_dining,
                      size: 80, color: Colors.brown.shade700),
                ),
              ),
              const SizedBox(height: 16),
              Text(p.name,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(p.category == 'bread' ? 'Roti' : 'Kue',
                  style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 12),
              Text('Rp ${p.price.toInt()}',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.green.shade700)),
              const SizedBox(height: 16),
              const Text('Deskripsi',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 4),
              Text(p.description,
                  style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/checkout', arguments: {
                    'product': p,
                  }),
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Pesan Sekarang'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
