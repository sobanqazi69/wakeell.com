import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class AppLoader {
  static OverlayEntry? _entry;

  static void show(BuildContext context) {
    if (_entry != null) return;
    _entry = OverlayEntry(
      builder: (_) => Container(
        color: Colors.black45,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.cyan),
        ),
      ),
    );
    Overlay.of(context).insert(_entry!);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}
