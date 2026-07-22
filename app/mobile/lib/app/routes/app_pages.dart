import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/products/bindings/products_binding.dart';
import '../modules/products/views/products_view.dart';
import '../modules/products/views/product_detail_view.dart';
import '../modules/orders/bindings/orders_binding.dart';
import '../modules/orders/views/checkout_view.dart';
import '../modules/orders/views/order_history_view.dart';
import '../modules/orders/views/order_detail_view.dart';
import '../modules/admin/bindings/admin_binding.dart';
import '../modules/admin/views/admin_dashboard_view.dart';
import '../modules/admin/views/admin_order_detail_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.PRODUCTS,
      page: () => const ProductsView(),
      binding: ProductsBinding(),
    ),
    GetPage(
      name: _Paths.PRODUCT_DETAIL,
      page: () => const ProductDetailView(),
      binding: ProductsBinding(),
    ),
    GetPage(
      name: _Paths.CHECKOUT,
      page: () => const CheckoutView(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: _Paths.HISTORY,
      page: () => const OrderHistoryView(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: _Paths.ORDER_DETAIL,
      page: () => const OrderDetailView(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: _Paths.ADMIN_DASHBOARD,
      page: () => const AdminDashboardView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: _Paths.ADMIN_ORDER_DETAIL,
      page: () => const AdminOrderDetailView(),
      binding: AdminBinding(),
    ),
  ];
}
