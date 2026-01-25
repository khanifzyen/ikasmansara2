/// App Constants - IKA SMANSARA
library;

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  // App Info
  static const String schoolName = 'SMA Negeri 1 Jepara';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Ikatan Alumni SMA Negeri 1 Jepara';

  // PocketBase
  static String get pocketBaseUrl =>
      dotenv.env['POCKETBASE_URL'] ?? 'http://127.0.0.1:8090';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String onboardingKey = 'onboarding_completed';

  // Pagination
  static const int pageSize = 20;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
