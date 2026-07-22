part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const PRODUCTS = _Paths.PRODUCTS;
  static const PRODUCT_DETAIL = _Paths.PRODUCT_DETAIL;
  static const CHECKOUT = _Paths.CHECKOUT;
  static const HISTORY = _Paths.HISTORY;
  static const ORDER_DETAIL = _Paths.ORDER_DETAIL;
  static const ADMIN_DASHBOARD = _Paths.ADMIN_DASHBOARD;
  static const ADMIN_ORDER_DETAIL = _Paths.ADMIN_ORDER_DETAIL;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const PRODUCTS = '/products';
  static const PRODUCT_DETAIL = '/products/:id';
  static const CHECKOUT = '/checkout';
  static const HISTORY = '/history';
  static const ORDER_DETAIL = '/orders/:id';
  static const ADMIN_DASHBOARD = '/admin/dashboard';
  static const ADMIN_ORDER_DETAIL = '/admin/orders/:id';
}
