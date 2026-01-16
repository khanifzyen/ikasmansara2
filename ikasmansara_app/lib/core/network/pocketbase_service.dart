import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_endpoints.dart';

class PocketBaseService {
  // Singleton Pattern
  static final PocketBaseService _instance = PocketBaseService._internal();
  factory PocketBaseService() => _instance;
  PocketBaseService._internal();

  // PocketBase Client Instance
  late final PocketBase pb;

  // Initialize (dipanggil di main.dart)
  Future<void> init() async {
    final baseUrl = dotenv.get(
      'POCKETBASE_URL',
      fallback: 'http://127.0.0.1:8090',
    );

    // Configure timeout
    pb = PocketBase(baseUrl);

    // Auto-refresh token jika sudah ada session
    if (pb.authStore.isValid) {
      await _refreshToken();
    }
  }

  // Token Refresh (Auto-called setiap request jika token hampir expired)
  Future<void> _refreshToken() async {
    try {
      await pb.collection(ApiEndpoints.users).authRefresh();
    } catch (e) {
      // Jika refresh gagal, clear auth
      pb.authStore.clear();
    }
  }

  // Helper: Get Current User
  RecordModel? get currentUser => pb.authStore.record;

  // Helper: Check if Authenticated
  bool get isAuthenticated => pb.authStore.isValid;

  // Logout
  void logout() {
    pb.authStore.clear();
  }
}
