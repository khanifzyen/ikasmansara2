import 'package:pocketbase/pocketbase.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../../../core/network/pocketbase_service.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> registerAlumni({
    required String name,
    required String email,
    required String password,
    required String phone,
    required int graduationYear,
  });
  Future<void> logout();
  bool isAuthenticated();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final PocketBaseService _pbService;

  AuthRemoteDataSourceImpl(this._pbService);

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final authData = await _pbService.pb
          .collection('users')
          .authWithPassword(email, password);
      return UserModel.fromRecord(authData.record);
    } on ClientException catch (e) {
      throw mapPocketBaseError(e);
    }
  }

  @override
  Future<UserModel> registerAlumni({
    required String name,
    required String email,
    required String password,
    required String phone,
    required int graduationYear,
  }) async {
    try {
      // 1. Create User
      final body = {
        'email': email,
        'emailVisibility': true,
        'password': password,
        'passwordConfirm': password,
        'name': name,
        'role': 'alumni',
        'phone': phone,
        'angkatan': graduationYear,
        'verified': false, // Default false until admin approves
      };

      final record = await _pbService.pb.collection('users').create(body: body);

      // 2. Auto Login after register (Optional, usually wait for email verification)
      // For now, return the created user model without login
      return UserModel.fromRecord(record);
    } on ClientException catch (e) {
      throw mapPocketBaseError(e);
    }
  }

  @override
  Future<void> logout() async {
    _pbService.pb.authStore.clear();
  }

  @override
  bool isAuthenticated() {
    return _pbService.pb.authStore.isValid;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    if (!_pbService.pb.authStore.isValid) return null;
    final record = _pbService.pb.authStore.record;
    if (record == null) return null;

    // Refresh to get latest data
    try {
      final freshRecord = await _pbService.pb
          .collection('users')
          .getOne(record.id);
      return UserModel.fromRecord(freshRecord);
    } catch (e) {
      return null;
    }
  }
}
