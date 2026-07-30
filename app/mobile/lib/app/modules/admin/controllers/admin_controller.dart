import 'package:get/get.dart';

import '../../../services/api_client.dart';
import '../../../models/order_models.dart';
import '../../../models/product_models.dart';

class AdminController extends GetxController {
  final _api = ApiClient();

  final orders = <AdminOrderResponse>[].obs;
  final selectedOrder = Rxn<AdminOrderResponse>();
  final isLoading = false.obs;
  final isUploading = false.obs;
  final selectedStatus = ''.obs;
  final products = <Product>[].obs;
  final selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
    fetchProducts();
  }

  void switchTab(int index) {
    selectedTab.value = index;
    if (index == 0) fetchOrders();
    if (index == 1) fetchProducts();
  }

  Future<void> fetchOrders({String? status}) async {
    isLoading.value = true;
    try {
      final params = <String, String>{};
      if (status != null && status.isNotEmpty) params['status'] = status;

      final res = await _api.get(
        '/admin/orders',
        auth: true,
        queryParams: params.isNotEmpty ? params : null,
        fromJsonT: (json) => (json as List)
            .map((e) =>
                AdminOrderResponse.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      if (res.success && res.data != null) {
        orders.value = res.data!;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<AdminOrderResponse?> fetchOrderDetail(String id) async {
    isLoading.value = true;
    try {
      final res = await _api.get(
        '/admin/orders/$id',
        auth: true,
        fromJsonT: (json) => AdminOrderResponse.fromJson(json),
      );
      if (res.success && res.data != null) {
        selectedOrder.value = res.data;
        return res.data;
      }
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final req = UpdateOrderStatusRequest(status: status);
    final res = await _api.patch(
      '/orders/$orderId/status',
      auth: true,
      body: req.toJson(),
    );
    if (res.success) {
      await fetchOrders();
      await fetchOrderDetail(orderId);
      return null;
    }
    return res.message ?? 'Gagal update status';
  }

  void filterByStatus(String status) {
    selectedStatus.value = status;
    fetchOrders(status: status.isEmpty ? null : status);
  }

  Future<String?> uploadImageBytes(List<int> bytes, String filename) async {
    isUploading.value = true;
    try {
      final res = await _api.uploadFile(
        '/upload',
        bytes: bytes,
        filename: filename,
        auth: true,
      );
      if (res.success && res.data != null) {
        return res.data!['url'] as String?;
      }
      return res.message ?? 'Gagal upload gambar';
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> fetchProducts() async {
    final res = await _api.get(
      '/admin/products',
      auth: true,
      fromJsonT: (json) => (json as List)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    if (res.success && res.data != null) {
      products.value = res.data!;
    }
  }

  Future<String?> addProduct({
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required String category,
  }) async {
    isLoading.value = true;
    try {
      final req = {
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'category': category,
      };
      final res = await _api.post(
        '/products',
        auth: true,
        body: req,
      );
      if (res.success) {
        return null;
      }
      return res.message ?? 'Gagal menambahkan produk';
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> updateProduct({
    required String id,
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required String category,
  }) async {
    isLoading.value = true;
    try {
      final req = {
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'category': category,
      };
      final res = await _api.put(
        '/products/$id',
        auth: true,
        body: req,
      );
      if (res.success) return null;
      return res.message ?? 'Gagal mengupdate produk';
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> deleteProduct(String id) async {
    final res = await _api.delete(
      '/products/$id',
      auth: true,
    );
    if (res.success) {
      await fetchProducts();
      return null;
    }
    return res.message ?? 'Gagal menghapus produk';
  }
}
