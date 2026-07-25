import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/modules/auth/controllers/auth_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/services/api_client.dart';
import 'app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient().init();
  Get.put(AuthController(), permanent: true);

  runApp(
    GetMaterialApp(
      title: 'BreadGo',
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
    ),
  );
}
