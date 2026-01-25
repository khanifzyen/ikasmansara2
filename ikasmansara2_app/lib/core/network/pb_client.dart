/// PocketBase Client Wrapper
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pocketbase/pocketbase.dart';
import '../constants/app_constants.dart';

class PBClient {
  static PBClient? _instance;
  late final PocketBase _pb;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  PBClient._() {
    _pb = PocketBase(AppConstants.pocketBaseUrl);
  }

  static PBClient get instance {
    _instance ??= PBClient._();
    return _instance!;
  }

  PocketBase get pb => _pb;

  /// Check if user is authenticated
  bool get isAuthenticated => _pb.authStore.isValid;

  /// Get current user record
  RecordModel? get currentUser => _pb.authStore.record;

  /// Get auth token
  String get token => _pb.authStore.token;

  /// Initialize auth from stored token
  Future<void> initAuth() async {
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);
      if (token != null && token.isNotEmpty) {
        // Restore auth state
        _pb.authStore.save(token, null);
        // Refresh auth to validate token
        await _pb.collection('users').authRefresh();
      }
    } catch (e) {
      // Token invalid, clear storage
      await clearAuth();
    }
  }

  /// Save auth token to secure storage
  Future<void> saveAuth() async {
    if (_pb.authStore.isValid) {
      await _storage.write(
        key: AppConstants.tokenKey,
        value: _pb.authStore.token,
      );
    }
  }

  /// Clear auth from storage and memory
  Future<void> clearAuth() async {
    _pb.authStore.clear();
    await _storage.delete(key: AppConstants.tokenKey);
  }

  /// Login with email and password
  Future<RecordAuth> login(String email, String password) async {
    final authData = await _pb
        .collection('users')
        .authWithPassword(email, password);
    await saveAuth();
    return authData;
  }

  /// Register new user
  Future<RecordModel> register({
    required String email,
    required String password,
    required String passwordConfirm,
    required String name,
    required String phone,
    required String role,
    int? angkatan,
  }) async {
    final body = {
      'email': email,
      'password': password,
      'passwordConfirm': passwordConfirm,
      'name': name,
      'phone': phone,
      'role': role,
      if (angkatan != null) 'angkatan': angkatan,
      'is_verified': false,
    };

    return await _pb.collection('users').create(body: body);
  }

  /// Logout
  Future<void> logout() async {
    await clearAuth();
  }
}
