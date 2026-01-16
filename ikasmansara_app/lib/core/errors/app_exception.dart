import '../network/network_exceptions.dart';
import 'app_error_type.dart';

class AppException implements Exception {
  final String message;
  final AppErrorType type;
  final int? statusCode;
  final dynamic originalError; // Untuk debugging

  const AppException({
    required this.message,
    required this.type,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => message;

  // Factory untuk mapping dari berbagai error source
  factory AppException.fromNetworkException(dynamic error) {
    if (error is NetworkException) {
      return AppException(
        message: error.message,
        type: _mapStatusCodeToType(error.statusCode),
        statusCode: error.statusCode,
        originalError: error,
      );
    }
    return AppException(
      message: 'Terjadi kesalahan yang tidak diketahui',
      type: AppErrorType.unknown,
      originalError: error,
    );
  }

  static AppErrorType _mapStatusCodeToType(int? code) {
    switch (code) {
      case 400:
        return AppErrorType.validation;
      case 401:
        return AppErrorType.authentication;
      case 403:
        return AppErrorType.unauthorized;
      case 404:
        return AppErrorType.notFound;
      case 500:
      case 502:
      case 503:
        return AppErrorType.serverError;
      default:
        return AppErrorType.network;
    }
  }
}
