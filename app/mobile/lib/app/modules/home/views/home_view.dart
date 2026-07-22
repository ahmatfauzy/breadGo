import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../auth/controllers/auth_controller.dart';
import '../../products/controllers/products_controller.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();
    final prodC = Get.find<ProductsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('BreadGo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag),
            onPressed: () {
              if (authC.isLoggedIn.value) {
                Get.toNamed('/history');
              } else {
                Get.toNamed('/login');
              }
            },
          ),
          Obx(() => authC.isAdmin.value
              ? IconButton(
                  icon: const Icon(Icons.admin_panel_settings),
                  onPressed: () => Get.toNamed('/admin/dashboard'),
                )
              : const SizedBox.shrink()),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Obx(() {
              final p = authC.profile.value;
              return DrawerHeader(
                decoration: BoxDecoration(color: Colors.brown),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.brown.shade300,
                      child: Text(
                        p != null ? p.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                            fontSize: 24, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(p?.name ?? 'Guest',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    Text(p?.email ?? '',
                        style:
                            const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              );
            }),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Katalog Produk'),
              onTap: () {
                Get.back();
                Get.toNamed('/products');
              },
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Beranda'),
              onTap: () => Get.back(),
            ),
            Obx(() {
              if (!authC.isLoggedIn.value) {
                return ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('Login'),
                  onTap: () {
                    Get.back();
                    Get.toNamed('/login');
                  },
                );
              }
              return ListTile(
                leading: const Icon(Icons.receipt_long),
                title: const Text('Riwayat Pesanan'),
                onTap: () {
                  Get.back();
                  Get.toNamed('/history');
                },
              );
            }),
            Obx(() => authC.isAdmin.value
                ? ListTile(
                    leading: const Icon(Icons.admin_panel_settings),
                    title: const Text('Admin Dashboard'),
                    onTap: () {
                      Get.back();
                      Get.toNamed('/admin/dashboard');
                    },
                  )
                : const SizedBox.shrink()),
            const Divider(),
            Obx(() => authC.isLoggedIn.value
                ? ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: () async {
                      await authC.logout();
                      Get.back();
                    },
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
      body: Obx(() {
        if (prodC.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (prodC.products.isEmpty) {
          prodC.fetchProducts();
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: () => prodC.fetchProducts(),
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: prodC.products.length,
            itemBuilder: (context, index) {
              final product = prodC.products[index];
              return GestureDetector(
                onTap: () => Get.toNamed('/products/${product.id}'),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.brown.shade50,
                          child: Center(
                            child: Icon(Icons.bakery_dining,
                                size: 52, color: Colors.brown.shade400),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(product.description,
                                style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 6),
                            Text('Rp ${product.price.toInt()}',
                                style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
