import 'package:get/get.dart';

import '../../../services/api_client.dart';
import '../../../models/order_models.dart';

class AdminController extends GetxController {
  final _api = ApiClient();

  final orders = <AdminOrderResponse>[].obs;
  final selectedOrder = Rxn<AdminOrderResponse>();
  final isLoading = false.obs;
  final selectedStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
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
}
