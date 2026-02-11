/// App Constants - IKA SMANSARA
library;

class AppConstants {
  AppConstants._();

  // App Info
  static const String schoolName = 'SMA Negeri 1 Jepara';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Ikatan Alumni SMA Negeri 1 Jepara';

  // PocketBase
  static const String pocketBaseUrl = 'https://pb-ikasmansara.pasarjepara.com';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String onboardingKey = 'onboarding_completed';

  // Pagination
  static const int pageSize = 20;

  // App Links
  static const String privacyPolicyUrl =
      'https://ikasmansara.com/privacy-policy';
  static const String termsConditionsUrl = 'https://ikasmansara.com/terms';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
