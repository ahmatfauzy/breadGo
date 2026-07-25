import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/admin_controller.dart';
import '../../products/controllers/products_controller.dart';

class AdminAddProductView extends GetView<AdminController> {
  const AdminAddProductView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameC = TextEditingController();
    final descC = TextEditingController();
    final priceC = TextEditingController();
    final imageUrlC = TextEditingController();
    final categoryC = 'bread'.obs;
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: nameC,
                decoration: InputDecoration(
                  labelText: 'Nama Produk',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descC,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) =>
                    v!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: priceC,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Harga (Rp)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) {
                  if (v!.isEmpty) return 'Harga tidak boleh kosong';
                  if (double.tryParse(v) == null) return 'Harga harus angka';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: imageUrlC,
                decoration: InputDecoration(
                  labelText: 'Image URL (Cloudinary)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) =>
                    v!.isEmpty ? 'Image URL tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              Obx(() => DropdownButtonFormField<String>(
                    initialValue: categoryC.value,
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'bread', child: Text('Bread')),
                      DropdownMenuItem(value: 'cake', child: Text('Cake')),
                    ],
                    onChanged: (val) {
                      if (val != null) categoryC.value = val;
                    },
                  )),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final err = await controller.addProduct(
                      name: nameC.text,
                      description: descC.text,
                      price: double.parse(priceC.text),
                      imageUrl: imageUrlC.text,
                      category: categoryC.value,
                    );
                    if (err != null) {
                      Get.snackbar('Error', err,
                          backgroundColor: Colors.red,
                          colorText: Colors.white);
                    } else {
                      Get.snackbar('Sukses', 'Produk berhasil ditambahkan',
                          backgroundColor: Colors.green,
                          colorText: Colors.white);
                      
                      // Coba refresh daftar produk jika controller-nya aktif
                      if (Get.isRegistered<ProductsController>()) {
                        Get.find<ProductsController>().fetchProducts();
                      }
                      
                      Get.back();
                    }
                  }
                },
                child: const Text('SIMPAN PRODUK',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }),
    );
  }
}
