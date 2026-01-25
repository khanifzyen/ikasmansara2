/// Auth Failure - Error types for authentication operations
library;

import 'package:equatable/equatable.dart';

sealed class AuthFailure extends Equatable {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Invalid credentials (wrong email/password)
class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure() : super('Email atau password salah');
}

/// Email already in use
class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure() : super('Email sudah terdaftar');
}

/// Weak password
class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure()
    : super('Password terlalu lemah. Minimal 8 karakter');
}

/// Network error
class NetworkFailure extends AuthFailure {
  const NetworkFailure()
    : super('Gagal terhubung ke server. Periksa koneksi internet');
}

/// Generic server error
class ServerFailure extends AuthFailure {
  const ServerFailure([super.message = 'Terjadi kesalahan pada server']);
}

/// User not found
class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure() : super('Akun tidak ditemukan');
}

/// Token expired/invalid
class UnauthorizedFailure extends AuthFailure {
  const UnauthorizedFailure()
    : super('Sesi telah berakhir. Silakan login kembali');
}

/// Email not verified
class EmailNotVerifiedFailure extends AuthFailure {
  const EmailNotVerifiedFailure()
    : super('Email belum diverifikasi. Silakan cek inbox email Anda.');
}

/// Validation error from API
class ValidationFailure extends AuthFailure {
  final Map<String, dynamic>? errors;

  const ValidationFailure({this.errors, String message = 'Data tidak valid'})
    : super(message);

  @override
  List<Object?> get props => [message, errors];
}
