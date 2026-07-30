import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_theme.dart';

String formatPrice(int price) {
  return price.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
}

String categoryLabel(String cat) {
  switch (cat) {
    case 'bread':
      return 'Roti';
    case 'cake':
      return 'Kue';
    case 'pastry':
      return 'Pastry';
    default:
      return 'Lainnya';
  }
}

String categoryEmoji(String cat) {
  switch (cat) {
    case 'bread':
      return '🍞  Roti';
    case 'cake':
      return '🎂  Kue';
    case 'pastry':
      return '🥐  Pastry';
    default:
      return '🛒  Lainnya';
  }
}

Color statusColor(String status) => AppColors.statusColor(status);

/// Show consistent snackbar across the app.
void showSnack(String title, String message, Color bgColor) {
  Get.snackbar(
    title,
    message,
    backgroundColor: bgColor,
    colorText: Colors.white,
    snackPosition: SnackPosition.TOP,
    borderRadius: 12,
    margin: const EdgeInsets.all(16),
  );
}
