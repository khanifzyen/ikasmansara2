import 'package:flutter/foundation.dart';
import 'app_exception.dart';

class ErrorLogger {
  static void log(AppException error) {
    // Development: Print ke console
    if (kDebugMode) {
      print('❌ ERROR: ${error.type} - ${error.message}');
      print('   Original: ${error.originalError}');
    }

    // Production: Kirim ke Sentry atau Crashlytics (Nanti)
    // Sentry.captureException(error.originalError);
  }
}
