import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/helpers.dart';

class VerifyView extends StatefulWidget {
  const VerifyView({super.key});

  @override
  State<VerifyView> createState() => _VerifyViewState();
}

class _VerifyViewState extends State<VerifyView> {
  final codeController = TextEditingController();

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final email = args?['email'] as String? ?? '';
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Verifikasi Email')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // Icon
            Center(
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: AppColors.primarySurface, shape: BoxShape.circle),
                child: const Icon(Icons.email_outlined, size: 40, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Cek Email Kamu', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text('Kode verifikasi telah dikirim ke', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            Text(email, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 32),

            _buildLabel('Kode Verifikasi'),
            const SizedBox(height: 8),
            TextField(
              controller: codeController,
              maxLength: 6,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 12, color: AppColors.textPrimary),
              decoration: InputDecoration(
                counterText: '',
                hintText: '000000',
                hintStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 12, color: Colors.grey.shade300),
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              ),
            ),
            const SizedBox(height: 24),

            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: auth.isLoading.value || codeController.text.length < 6
                        ? null
                        : () async {
                            final err = await auth.verifyEmail(email: email, code: codeController.text.trim());
                            if (err != null) {
                              showSnack('Verifikasi Gagal', err, AppColors.error);
                            } else {
                              Get.offAllNamed('/home');
                            }
                          },
                    child: auth.isLoading.value
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : const Text('Verifikasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                  ),
                )),
            const SizedBox(height: 16),

            Center(
              child: Obx(() => TextButton(
                    onPressed: auth.isLoading.value ? null : () async {
                      final err = await auth.resendCode(email: email);
                      if (err != null) {
                        showSnack('Gagal', err, AppColors.error);
                      } else {
                        showSnack('Berhasil', 'Kode baru telah dikirim', AppColors.success);
                      }
                    },
                    child: const Text('Kirim ulang kode', style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600)),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary));
  }
}
