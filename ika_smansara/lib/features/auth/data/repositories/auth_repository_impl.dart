/// Auth Repository Implementation
library;

import 'package:pocketbase/pocketbase.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  bool get isAuthenticated => _remoteDataSource.isAuthenticated;

  @override
  Future<AuthResult<UserEntity>> getCurrentUser() async {
    log.withContext(
      'AuthRepository',
      LogLevel.debug,
      'Getting current user...',
    );

    try {
      try {
        final user = await _remoteDataSource.getCurrentUser();
        if (user != null) {
          log.withContext(
            'AuthRepository',
            LogLevel.info,
            'User found, caching...',
          );
          await _localDataSource.cacheUser(user);
          return (data: user.toEntity(), failure: null);
        }
      } catch (e) {
        log.withContext(
          'AuthRepository',
          LogLevel.warning,
          'Remote get current user failed',
          error: e,
        );
      }

      // Fallback to local cache
      log.withContext(
        'AuthRepository',
        LogLevel.debug,
        'Trying local cache...',
      );
      final localUser = await _localDataSource.getLastUser();
      if (localUser != null) {
        log.withContext(
          'AuthRepository',
          LogLevel.info,
          'Using cached user data',
        );
        return (data: localUser.toEntity(), failure: null);
      }

      log.withContext('AuthRepository', LogLevel.warning, 'No user found');
      return (data: null, failure: const UserNotFoundFailure());
    } catch (e) {
      log.withContext(
        'AuthRepository',
        LogLevel.error,
        'Get current user failed',
        error: e,
      );
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

      // Check if email is verified (system field)
      if (!user.verified) {
        log.withContext(
          'AuthRepository',
          LogLevel.warning,
          'Email not verified for ${user.email}',
        );
        await _remoteDataSource.logout();
        return (data: null, failure: const EmailNotVerifiedFailure());
      }

      log.withContext(
        'AuthRepository',
        LogLevel.info,
        'Login successful for ${user.email}',
      );
      await _remoteDataSource.saveAuth();
      await _localDataSource.cacheUser(user);
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
      log.withContext(
        'AuthRepository',
        LogLevel.info,
        'Registering alumni: ${params.email}',
      );

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

      log.withContext(
        'AuthRepository',
        LogLevel.info,
        'Alumni registered successfully: ${user.id}',
      );

      // Request verification email
      log.withContext(
        'AuthRepository',
        LogLevel.debug,
        'Requesting verification email for: ${params.email}',
      );
      await _remoteDataSource.requestVerification(params.email);

      return (data: user.toEntity(), failure: null);
    } catch (e) {
      log.withContext(
        'AuthRepository',
        LogLevel.error,
        'Register alumni failed',
        error: e,
      );
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
        phone: params.phone,
        role: 'public',
      );

      // Request verification email
      await _remoteDataSource.requestVerification(params.email);

      return (data: user.toEntity(), failure: null);
    } catch (e) {
      return (data: null, failure: _mapException(e));
    }
  }

  @override
  Future<AuthResult<void>> logout() async {
    try {
      await _remoteDataSource.logout();
      await _localDataSource.clearUser();
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
      await _localDataSource.cacheUser(user);
      return (data: user.toEntity(), failure: null);
    } catch (e) {
      return (data: null, failure: _mapException(e));
    }
  }

  @override
  Future<AuthResult<void>> requestPasswordReset(String email) async {
    try {
      await _remoteDataSource.requestPasswordReset(email);
      return (data: null, failure: null);
    } catch (e) {
      return (data: null, failure: _mapException(e));
    }
  }

  /// Map PocketBase exceptions to domain failures
  AuthFailure _mapException(dynamic e) {
    log.withContext(
      'AuthRepository',
      LogLevel.error,
      'Mapping exception',
      error: e,
    );

    if (e is ClientException) {
      log.withContext(
        'AuthRepository',
        LogLevel.warning,
        'ClientException: ${e.statusCode}',
      );
      final response = e.response;
      final statusCode = e.statusCode;

      // Handle specific error codes
      if (statusCode == 400) {
        final data = response['data'];
        if (data != null && data is Map && data.isNotEmpty) {
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
