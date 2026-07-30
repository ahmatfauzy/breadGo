import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/helpers.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameC = TextEditingController();
    final emailC = TextEditingController();
    final passC = TextEditingController();
    final obscure = true.obs;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Brown wave top
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 260,
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

          SingleChildScrollView(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.28, left: 24, right: 24, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text('Daftar', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
                const SizedBox(height: 4),
                const Text('Buat akun untuk mulai memesan', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 28),

                _buildLabel('Nama Lengkap'),
                const SizedBox(height: 8),
                TextField(
                  controller: nameC,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan nama lengkap kamu',
                    prefixIcon: Icon(Icons.person_outline, color: AppColors.textHint, size: 20),
                  ),
                ),
                const SizedBox(height: 18),

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
                        hintText: 'Masukkan password kamu (min 6 karakter)',
                        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textHint, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(obscure.value ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textHint, size: 20),
                          onPressed: () => obscure.value = !obscure.value,
                        ),
                      ),
                    )),
                const SizedBox(height: 32),

                Obx(() => SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value ? null : () async {
                          final name = nameC.text.trim();
                          final email = emailC.text.trim();
                          final pass = passC.text;
                          if (name.isEmpty || email.isEmpty || pass.isEmpty) {
                            showSnack('Error', 'Semua field harus diisi', AppColors.error);
                            return;
                          }
                          if (pass.length < 6) {
                            showSnack('Error', 'Password minimal 6 karakter', AppColors.error);
                            return;
                          }
                          final err = await controller.register(name: name, email: email, password: pass);
                          if (err != null) {
                            showSnack('Daftar Gagal', err, AppColors.error);
                          } else {
                            Get.offNamed('/verify-email', arguments: {'email': emailC.text.trim()});
                          }
                        },
                        child: controller.isLoading.value
                            ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                            : const Text('Daftar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                      ),
                    )),
                const SizedBox(height: 24),

                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Sudah punya akun? ', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: const Text('Masuk', style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w700)),
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
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary));
  }
}
