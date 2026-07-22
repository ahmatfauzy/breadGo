import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameC = TextEditingController();
    final emailC = TextEditingController();
    final passC = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameC,
              decoration: const InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailC,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passC,
              decoration: const InputDecoration(
                labelText: 'Password (min 6 karakter)',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                            final name = nameC.text.trim();
                            final email = emailC.text.trim();
                            final pass = passC.text;
                            if (name.isEmpty ||
                                email.isEmpty ||
                                pass.isEmpty) {
                              Get.snackbar('Error',
                                  'Semua field harus diisi',
                                  backgroundColor: Colors.red.shade100);
                              return;
                            }
                            if (pass.length < 6) {
                              Get.snackbar('Error',
                                  'Password minimal 6 karakter',
                                  backgroundColor: Colors.red.shade100);
                              return;
                            }
                            final err = await controller.register(
                              name: name,
                              email: email,
                              password: pass,
                            );
                            if (err != null) {
                              Get.snackbar('Error', err,
                                  backgroundColor: Colors.red.shade100);
                            } else {
                              Get.offAllNamed('/home');
                            }
                          },
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator()
                        : const Text('Daftar'),
                  ),
                )),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Sudah punya akun? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
