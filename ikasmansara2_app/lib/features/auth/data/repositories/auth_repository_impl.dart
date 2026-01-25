/// Auth Repository Implementation
library;

import 'package:pocketbase/pocketbase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  bool get isAuthenticated => _remoteDataSource.isAuthenticated;

  @override
  Future<AuthResult<UserEntity>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      if (user == null) {
        return (data: null, failure: const UserNotFoundFailure());
      }
      return (data: user.toEntity(), failure: null);
    } catch (e) {
      return (data: null, failure: _mapException(e));
    }
  }

  @override
  Future<AuthResult<UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      await _remoteDataSource.saveAuth();
      return (data: user.toEntity(), failure: null);
    } catch (e) {
      return (data: null, failure: _mapException(e));
    }
  }

  @override
  Future<AuthResult<UserEntity>> registerAlumni(
    RegisterAlumniParams params,
  ) async {
    try {
      final user = await _remoteDataSource.register(
        email: params.email,
        password: params.password,
        passwordConfirm: params.passwordConfirm,
        name: params.name,
        phone: params.phone,
        role: 'alumni',
        angkatan: params.angkatan,
        jobStatus: params.jobStatus?.toApiValue(),
        company: params.company,
        domisili: params.domisili,
      );
      return (data: user.toEntity(), failure: null);
    } catch (e) {
      return (data: null, failure: _mapException(e));
    }
  }

  @override
  Future<AuthResult<UserEntity>> registerPublic(
    RegisterPublicParams params,
  ) async {
    try {
      final user = await _remoteDataSource.register(
        email: params.email,
        password: params.password,
        passwordConfirm: params.passwordConfirm,
        name: params.name,
        phone: '',
        role: 'public',
      );
      return (data: user.toEntity(), failure: null);
    } catch (e) {
      return (data: null, failure: _mapException(e));
    }
  }

  @override
  Future<AuthResult<void>> logout() async {
    try {
      await _remoteDataSource.logout();
      return (data: null, failure: null);
    } catch (e) {
      return (data: null, failure: _mapException(e));
    }
  }

  @override
  Future<AuthResult<UserEntity>> refreshAuth() async {
    try {
      final user = await _remoteDataSource.refreshAuth();
      await _remoteDataSource.saveAuth();
      return (data: user.toEntity(), failure: null);
    } catch (e) {
      return (data: null, failure: _mapException(e));
    }
  }

  /// Map PocketBase exceptions to domain failures
  AuthFailure _mapException(dynamic e) {
    if (e is ClientException) {
      final response = e.response;
      final statusCode = e.statusCode;

      // Handle specific error codes
      if (statusCode == 400) {
        final data = response['data'];
        if (data != null && data is Map) {
          // Email already exists
          if (data['email'] != null) {
            final emailError = data['email'];
            if (emailError is Map &&
                emailError['code'] ==
                    'validation_invalid_email_already_exists') {
              return const EmailAlreadyInUseFailure();
            }
          }
          // Password too weak
          if (data['password'] != null) {
            return const WeakPasswordFailure();
          }
          return ValidationFailure(errors: Map<String, dynamic>.from(data));
        }
        return const InvalidCredentialsFailure();
      }

      if (statusCode == 401) {
        return const UnauthorizedFailure();
      }

      if (statusCode == 404) {
        return const UserNotFoundFailure();
      }

      return ServerFailure(
        e.response['message']?.toString() ?? 'Terjadi kesalahan',
      );
    }

    // Network error
    if (e.toString().contains('SocketException') ||
        e.toString().contains('Connection refused')) {
      return const NetworkFailure();
    }

    return ServerFailure(e.toString());
  }
}
