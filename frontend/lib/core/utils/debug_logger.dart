import 'package:flutter/foundation.dart';

class DebugLogger {
  static void log(String tag, String message) {
    if (kDebugMode) debugPrint('[$tag] $message');
  }

  static void error(String tag, dynamic error, [StackTrace? stack]) {
    if (kDebugMode) {
      debugPrint('[$tag] ERROR: $error');
      if (stack != null) debugPrint(stack.toString());
    }
  }
}
