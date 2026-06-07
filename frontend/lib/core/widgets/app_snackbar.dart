import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class AppSnackbar {
  static void success(BuildContext context, String message) =>
      _show(context, message, AppColors.success, Icons.check_circle_outline);

  static void error(BuildContext context, String message) =>
      _show(context, message, AppColors.error, Icons.error_outline);

  static void info(BuildContext context, String message) =>
      _show(context, message, AppColors.navy, Icons.info_outline);

  static void _show(BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }
}
