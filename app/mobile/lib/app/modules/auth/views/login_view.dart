import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../../../theme/app_theme.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final emailC = TextEditingController();
    final passC = TextEditingController();
    final obscure = true.obs;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Brown wave top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 260,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7A4F2D), Color(0xFF8B5E3C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(48),
                  bottomRight: Radius.circular(48),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bakery_dining,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'BreadGo',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Roti segar setiap hari',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main content card
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.28,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Masuk',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Selamat datang kembali!',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 28),

                // Email field
                _buildLabel('Email'),
                const SizedBox(height: 8),
                TextField(
                  controller: emailC,
                  decoration: InputDecoration(
                    hintText: 'Masukkan email kamu',
                    prefixIcon: const Icon(Icons.email_outlined,
                        color: AppColors.textHint, size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF8F4F1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 18),

                // Password field
                _buildLabel('Password'),
                const SizedBox(height: 8),
                Obx(() => TextField(
                      controller: passC,
                      obscureText: obscure.value,
                      decoration: InputDecoration(
                        hintText: 'Masukkan password kamu',
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: AppColors.textHint, size: 20),
                        suffixIcon: IconButton(
                          tooltip: obscure.value ? 'Tampilkan password' : 'Sembunyikan password',
                          icon: Icon(
                            obscure.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textHint,
                            size: 20,
                          ),
                          onPressed: () => obscure.value = !obscure.value,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8F4F1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
                      ),
                    )),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Lupa password?',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Login button
                Obx(() => SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () async {
                                final err = await controller.login(
                                  email: emailC.text.trim(),
                                  password: passC.text,
                                );
                                if (err != null) {
                                  Get.snackbar(
                                    'Login Gagal',
                                    err,
                                    backgroundColor: AppColors.error,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.TOP,
                                    borderRadius: 14,
                                    margin: const EdgeInsets.all(16),
                                  );
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Masuk',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                      ),
                    )),
                const SizedBox(height: 24),

                // Or divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade200)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'atau',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade200)),
                  ],
                ),
                const SizedBox(height: 24),

                // Register link
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Belum punya akun? ',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed('/register'),
                        child: const Text(
                          'Daftar Sekarang',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}
