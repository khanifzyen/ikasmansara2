/// Auth Remote Data Source - PocketBase auth API
library;

import 'package:pocketbase/pocketbase.dart';
import '../../../../core/network/pb_client.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final PBClient _pbClient;

  AuthRemoteDataSource(this._pbClient);

  PocketBase get _pb => _pbClient.pb;

  /// Get current user from auth store
  RecordModel? get currentUserRecord => _pbClient.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _pbClient.isAuthenticated;

  /// Login with email and password
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final authData = await _pb
        .collection('users')
        .authWithPassword(email, password);
    return UserModel.fromRecord(authData.record);
  }

  /// Register new user
  Future<UserModel> register({
    required String email,
    required String password,
    required String passwordConfirm,
    required String name,
    required String phone,
    required String role,
    int? angkatan,
    String? jobStatus,
    String? company,
    String? domisili,
  }) async {
    final body = <String, dynamic>{
      'email': email,
      'password': password,
      'passwordConfirm': passwordConfirm,
      'name': name,
      'phone': phone,
      'role': role,
      'is_verified': false,
    };

    if (angkatan != null) body['angkatan'] = angkatan;
    if (jobStatus != null) body['job_status'] = jobStatus;
    if (company != null && company.isNotEmpty) body['company'] = company;
    if (domisili != null && domisili.isNotEmpty) body['domisili'] = domisili;

    final record = await _pb.collection('users').create(body: body);
    return UserModel.fromRecord(record);
  }

  /// Get current user model
  Future<UserModel?> getCurrentUser() async {
    if (!isAuthenticated || currentUserRecord == null) {
      return null;
    }

    // Refresh to get latest user data
    try {
      final authData = await _pb.collection('users').authRefresh();
      return UserModel.fromRecord(authData.record);
    } catch (e) {
      // If refresh fails, return cached user
      return UserModel.fromRecord(currentUserRecord!);
    }
  }

  /// Refresh authentication
  Future<UserModel> refreshAuth() async {
    final authData = await _pb.collection('users').authRefresh();
    return UserModel.fromRecord(authData.record);
  }

  /// Clear auth
  Future<void> logout() async {
    await _pbClient.clearAuth();
  }

  /// Request verification email
  Future<void> requestVerification(String email) async {
    await _pb.collection('users').requestVerification(email);
  }

  /// Request password reset email
  Future<void> requestPasswordReset(String email) async {
    await _pb.collection('users').requestPasswordReset(email);
  }

  /// Save auth to secure storage
  Future<void> saveAuth() async {
    await _pbClient.saveAuth();
  }
}
