import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/helpers.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final emailC = TextEditingController();
    final passC = TextEditingController();
    final obscure = true.obs;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            collapsedHeight: 0,
            toolbarHeight: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF7A4F2D), Color(0xFF8B5E3C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(48), bottomRight: Radius.circular(48)),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                        child: const Icon(Icons.bakery_dining, size: 44, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      const Text('BreadGo', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                      const SizedBox(height: 4),
                      Text('Roti segar setiap hari', style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8))),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text('Masuk', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  const Text('Selamat datang kembali!', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  const SizedBox(height: 28),

                  _buildLabel('Email'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailC,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan email kamu',
                      prefixIcon: Icon(Icons.email_outlined, color: AppColors.textHint, size: 20),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 18),

                  _buildLabel('Password'),
                  const SizedBox(height: 8),
                  Obx(() => TextField(
                    controller: passC,
                    obscureText: obscure.value,
                    decoration: InputDecoration(
                      hintText: 'Masukkan password kamu',
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textHint, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(obscure.value ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textHint, size: 20),
                        onPressed: () => obscure.value = !obscure.value,
                      ),
                    ),
                  )),
                  const SizedBox(height: 8),

                  // Login button
                  Obx(() => SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value ? null : () async {
                        final result = await controller.login(email: emailC.text.trim(), password: passC.text);
                        if (result.error != null) {
                          showSnack('Login Gagal', result.error!, AppColors.error);
                        } else if (result.needsVerification) {
                          Get.offNamed('/verify-email', arguments: {'email': emailC.text.trim()});
                        } else {
                          final args = Get.arguments as Map<String, dynamic>?;
                          final redirect = args?['redirect'] as String?;
                          final product = args?['product'];
                          if (redirect != null) {
                            Get.offNamed(redirect, arguments: {'product': product});
                          } else {
                            Get.offAllNamed('/home');
                          }
                        }
                      },
                      child: controller.isLoading.value
                          ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                          : const Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                    ),
                  )),
                  const SizedBox(height: 24),

                  // Register link
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Belum punya akun? ', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                        GestureDetector(
                          onTap: () => Get.toNamed('/register'),
                          child: const Text('Daftar Sekarang', style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary));
  }
}
