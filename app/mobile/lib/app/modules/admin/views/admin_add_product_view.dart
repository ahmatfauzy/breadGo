import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/admin_controller.dart';
import '../../products/controllers/products_controller.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/helpers.dart';
import '../../../models/product_models.dart';

class AdminAddProductView extends StatefulWidget {
  const AdminAddProductView({super.key});

  @override
  State<AdminAddProductView> createState() => _AdminAddProductViewState();
}

class _AdminAddProductViewState extends State<AdminAddProductView> {
  final nameC = TextEditingController();
  final descC = TextEditingController();
  final priceC = TextEditingController();
  final categoryC = 'bread'.obs;
  final formKey = GlobalKey<FormState>();
  final picker = ImagePicker();

  Uint8List? _imageBytes;
  String? _imageName;
  String? _uploadedUrl;
  bool _isUploading = false;

  Product? _editProduct;

  bool get _isEditMode => _editProduct != null;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _editProduct = args?['product'] as Product?;

    if (_isEditMode) {
      nameC.text = _editProduct!.name;
      descC.text = _editProduct!.description;
      priceC.text = _editProduct!.price.toString();
      _uploadedUrl = _editProduct!.imageUrl;
      categoryC.value = _editProduct!.category;
    }
  }

  @override
  void dispose() {
    nameC.dispose();
    descC.dispose();
    priceC.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = picked.name;
        _uploadedUrl = null;
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageBytes == null) return _uploadedUrl;
    setState(() => _isUploading = true);
    try {
      final url = await Get.find<AdminController>()
          .uploadImageBytes(_imageBytes!, _imageName ?? 'image.jpg');
      if (url != null) _uploadedUrl = url;
      return url;
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = Get.find<AdminController>();

    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Produk' : 'Tambah Produk')),
      body: Obx(() {
        if (admin.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: nameC,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
                validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descC,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                validator: (v) => v!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: priceC,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Harga (Rp)'),
                validator: (v) {
                  if (v!.isEmpty) return 'Harga tidak boleh kosong';
                  if (double.tryParse(v) == null) return 'Harga harus angka';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Image picker
              _buildLabel('Gambar Produk'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: _imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: Image.memory(_imageBytes!, fit: BoxFit.cover, width: double.infinity,
                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 48)),
                        )
                      : _uploadedUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: Image.network(_uploadedUrl!, fit: BoxFit.cover, width: double.infinity,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 48)),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                Text('Tap untuk pilih gambar', style: TextStyle(color: Colors.grey.shade500)),
                              ],
                            ),
                ),
              ),
              if (_isUploading)
                const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator()),
              if (_uploadedUrl != null && _imageBytes == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('Gambar saat ini: $_uploadedUrl',
                      style: const TextStyle(color: AppColors.textHint, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              const SizedBox(height: 16),

              // Category
              Obx(() => DropdownButtonFormField<String>(
                    value: categoryC.value,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: const [
                      DropdownMenuItem(value: 'bread', child: Text('Bread')),
                      DropdownMenuItem(value: 'cake', child: Text('Cake')),
                    ],
                    onChanged: (val) {
                      if (val != null) categoryC.value = val;
                    },
                  )),
              const SizedBox(height: 32),

              // Submit
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  final url = await _uploadImage();
                  if (url == null) {
                    showSnack('Error', 'Gagal upload gambar', AppColors.error);
                    return;
                  }

                  String? err;
                  if (_isEditMode) {
                    err = await admin.updateProduct(
                      id: _editProduct!.id,
                      name: nameC.text,
                      description: descC.text,
                      price: double.parse(priceC.text),
                      imageUrl: url,
                      category: categoryC.value,
                    );
                  } else {
                    err = await admin.addProduct(
                      name: nameC.text,
                      description: descC.text,
                      price: double.parse(priceC.text),
                      imageUrl: url,
                      category: categoryC.value,
                    );
                  }

                  if (err != null) {
                    showSnack('Error', err, AppColors.error);
                  } else {
                    showSnack('Sukses', _isEditMode ? 'Produk diperbarui' : 'Produk berhasil ditambahkan', AppColors.success);
                    if (Get.isRegistered<ProductsController>()) {
                      Get.find<ProductsController>().fetchProducts();
                    }
                    Get.find<AdminController>().fetchProducts();
                    Get.offAllNamed('/admin/dashboard');
                  }
                },
                child: Text(_isEditMode ? 'SIMPAN PERUBAHAN' : 'SIMPAN PRODUK',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary));
  }
}
