import 'package:get/get.dart';

import '../../auth/controllers/auth_controller.dart';
import '../../products/controllers/products_controller.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<ProductsController>(() => ProductsController(), fenix: true);
  }
}
