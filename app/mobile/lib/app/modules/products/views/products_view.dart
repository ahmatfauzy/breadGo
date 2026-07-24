import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/product_models.dart';
import '../controllers/products_controller.dart';

class ProductsView extends GetView<ProductsController> {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Roti'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Cari Produk',
            onPressed: () => _showSearch(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(child: _buildProductGrid()),
        ],
      ),
    );
  }

  void _showSearch(BuildContext context) {
    final searchC = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cari Produk'),
        content: TextField(
          controller: searchC,
          decoration: const InputDecoration(hintText: 'Nama produk...'),
          autofocus: true,
          onSubmitted: (v) {
            controller.search(v);
            Get.back();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              controller.search(searchC.text);
              Get.back();
            },
            child: const Text('Cari'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['', 'bread', 'cake'];
    final labels = ['Semua', 'Roti', 'Kue'];
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: List.generate(categories.length, (i) {
              final selected = controller.selectedCategory.value == categories[i];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(labels[i]),
                  selected: selected,
                  onSelected: (_) => controller.filterByCategory(categories[i]),
                ),
              );
            }),
          ),
        ));
  }

  Widget _buildProductGrid() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.products.isEmpty) {
        return const Center(child: Text('Tidak ada produk'));
      }
      return GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: controller.products.length,
        itemBuilder: (context, index) {
          final product = controller.products[index];
          return _buildProductCard(product);
        },
      );
    });
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () => Get.toNamed('/products/${product.id}'),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                color: Colors.brown.shade100,
                child: Center(
                  child: Icon(Icons.bakery_dining,
                      size: 48, color: Colors.brown.shade700),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('Rp ${product.price.toInt()}',
                      style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
