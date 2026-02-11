/// PocketBase Client Wrapper
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pocketbase/pocketbase.dart';
import '../constants/app_constants.dart';
import '../utils/app_logger.dart';

class PBClient {
  static PBClient? _instance;
  late final PocketBase _pb;
  late final FlutterSecureStorage _storage;

  PBClient._() {
    _pb = PocketBase(AppConstants.pocketBaseUrl);
    _storage = const FlutterSecureStorage();
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
      final token = await _safeRead();
      if (token != null && token.isNotEmpty) {
        _pb.authStore.save(token, null);
        await _pb.collection('users').authRefresh();
      }
    } catch (e) {
      log.withContext(
        'PBClient',
        LogLevel.warning,
        'Auth refresh failed, clearing storage',
        error: e,
      );
      await _safeClear();
    }
  }

  /// Save auth token to secure storage
  Future<void> saveAuth() async {
    if (_pb.authStore.isValid) {
      await _safeWrite(_pb.authStore.token);
    }
  }

  /// Clear auth from storage and memory
  Future<void> clearAuth() async {
    _pb.authStore.clear();
    await _safeClear();
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
    await _safeClear();
  }

  /// Safely read from storage with libsecret error handling
  Future<String?> _safeRead() async {
    try {
      return await _storage.read(key: AppConstants.tokenKey);
    } on PlatformException catch (e) {
      if (_isLibsecretError(e)) {
        log.warning(
          'Libsecret not available on Linux, token may not persist',
          error: e,
          context: 'PBClient',
        );
        return null;
      }
      rethrow;
    }
  }

  /// Safely write to storage with libsecret error handling
  Future<void> _safeWrite(String value) async {
    try {
      await _storage.write(key: AppConstants.tokenKey, value: value);
    } on PlatformException catch (e) {
      if (_isLibsecretError(e)) {
        log.warning(
          'Libsecret not available on Linux, token will not persist',
          error: e,
          context: 'PBClient',
        );
      } else {
        rethrow;
      }
    }
  }

  /// Safely clear storage with libsecret error handling
  Future<void> _safeClear() async {
    try {
      await _storage.delete(key: AppConstants.tokenKey);
    } on PlatformException catch (e) {
      if (_isLibsecretError(e)) {
        log.debug(
          'Libsecret error during clear, ignoring on Linux',
          error: e,
          context: 'PBClient',
        );
      } else {
        rethrow;
      }
    }
  }

  /// Check if PlatformException is from libsecret
  bool _isLibsecretError(PlatformException e) {
    if (kIsWeb) return false;
    if (!Platform.isLinux) return false;

    final message = e.message?.toLowerCase() ?? '';
    return message.contains('libsecret') || message.contains('keyring');
  }
}
