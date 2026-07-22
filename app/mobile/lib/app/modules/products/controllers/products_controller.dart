import 'package:get/get.dart';

import '../../../services/api_client.dart';
import '../../../models/product_models.dart';

class ProductsController extends GetxController {
  final _api = ApiClient();

  final products = <Product>[].obs;
  final isLoading = false.obs;
  final selectedProduct = Rxn<Product>();
  final selectedCategory = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts({String? category, String? search}) async {
    isLoading.value = true;
    try {
      final params = <String, String>{};
      if (category != null && category.isNotEmpty) params['category'] = category;
      if (search != null && search.isNotEmpty) params['search'] = search;

      final res = await _api.get(
        '/products',
        queryParams: params.isNotEmpty ? params : null,
        fromJsonT: (json) => (json as List)
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      if (res.success && res.data != null) {
        products.value = res.data!;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<Product?> fetchProductDetail(String id) async {
    isLoading.value = true;
    try {
      final res = await _api.get(
        '/products/$id',
        fromJsonT: (json) => Product.fromJson(json),
      );
      if (res.success && res.data != null) {
        selectedProduct.value = res.data;
        return res.data;
      }
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
    fetchProducts(category: category.isEmpty ? null : category);
  }

  void search(String query) {
    fetchProducts(search: query.isEmpty ? null : query);
  }
}
