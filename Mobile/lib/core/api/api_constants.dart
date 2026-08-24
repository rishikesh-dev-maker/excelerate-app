import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    // Android Emulator vs iOS Simulator check
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'http://10.0.2.2:3000';
      }
    } catch (_) {}
    return 'http://127.0.0.1:3000';
  }

  static const Duration timeout = Duration(seconds: 15);

  // Feature flag for testing failures
  static bool simulateFailure = false;
}
