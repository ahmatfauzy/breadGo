import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

import '../../../services/api_client.dart';
import '../../../models/order_models.dart';

class OrdersController extends GetxController {
  final _api = ApiClient();

  final orders = <OrderResponse>[].obs;
  final selectedOrder = Rxn<OrderResponse>();
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    isLoading.value = true;
    try {
      final res = await _api.get(
        '/orders',
        auth: true,
        fromJsonT: (json) => (json as List)
            .map((e) => OrderResponse.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      if (res.success && res.data != null) {
        orders.value = res.data!;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<OrderResponse?> fetchOrderDetail(String id) async {
    isLoading.value = true;
    try {
      final res = await _api.get(
        '/orders/$id',
        auth: true,
        fromJsonT: (json) => OrderResponse.fromJson(json),
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

  Future<String?> createOrder({
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    required List<OrderItemRequest> items,
    String? paymentProof,
  }) async {
    isSubmitting.value = true;
    try {
      final position = await _getCurrentPosition();
      final req = CreateOrderRequest(
        customerName: customerName,
        customerPhone: customerPhone,
        customerAddress: customerAddress,
        latitude: position.latitude,
        longitude: position.longitude,
        items: items,
        paymentProof: paymentProof,
      );
      final res = await _api.post(
        '/orders',
        auth: true,
        body: req.toJson(),
        fromJsonT: (json) => OrderResponse.fromJson(json),
      );
      if (res.success && res.data != null) {
        orders.insert(0, res.data!);
        return null;
      }
      return res.message ?? 'Gagal membuat pesanan';
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('GPS tidak aktif. Aktifkan lokasi pada perangkat Anda.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak permanen. Buka pengaturan.');
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
    } catch (_) {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 8),
        ),
      );
    }
  }
}
