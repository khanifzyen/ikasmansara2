/// Auth Repository - Interface for authentication operations
library;

import '../entities/user_entity.dart';
import '../failures/auth_failure.dart';

/// Result type for auth operations
typedef AuthResult<T> = ({T? data, AuthFailure? failure});

/// Parameters for alumni registration
class RegisterAlumniParams {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String passwordConfirm;
  final int angkatan;
  final JobStatus? jobStatus;
  final String? company;
  final String? domisili;

  const RegisterAlumniParams({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirm,
    required this.angkatan,
    this.jobStatus,
    this.company,
    this.domisili,
  });
}

/// Parameters for public registration
class RegisterPublicParams {
  final String name;
  final String email;
  final String password;
  final String passwordConfirm;

  const RegisterPublicParams({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirm,
  });
}

/// Auth Repository Interface
abstract class AuthRepository {
  /// Get current authenticated user
  Future<AuthResult<UserEntity>> getCurrentUser();

  /// Check if user is authenticated
  bool get isAuthenticated;

  /// Login with email and password
  Future<AuthResult<UserEntity>> login({
    required String email,
    required String password,
  });

  /// Register new alumni user
  Future<AuthResult<UserEntity>> registerAlumni(RegisterAlumniParams params);

  /// Register new public user
  Future<AuthResult<UserEntity>> registerPublic(RegisterPublicParams params);

  /// Logout current user
  Future<AuthResult<void>> logout();

  /// Refresh auth token
  Future<AuthResult<UserEntity>> refreshAuth();

  /// Request password reset email
  Future<AuthResult<void>> requestPasswordReset(String email);
}
