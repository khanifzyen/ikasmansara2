/// Failure Classes for Error Handling
library;

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Server/Network Failures
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Tidak ada koneksi internet'});
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message = 'Koneksi timeout, coba lagi'});
}

/// Authentication Failures
class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message = 'Sesi Anda telah berakhir'});
}

/// Validation Failures
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({required super.message, this.fieldErrors});

  @override
  List<Object?> get props => [message, fieldErrors];
}

/// Cache/Storage Failures
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Gagal mengakses data lokal'});
}

/// Not Found
class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Data tidak ditemukan'});
}

/// Unknown Failure
class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'Terjadi kesalahan, coba lagi'});
}
