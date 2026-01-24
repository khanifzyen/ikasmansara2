import 'package:pocketbase/pocketbase.dart';

class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  NetworkException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

// Mapper dari ClientException (PocketBase) ke App-Specific Exception
NetworkException mapPocketBaseError(ClientException e) {
  switch (e.statusCode) {
    case 400:
      // DEBUG MODE: Show Raw Response
      return NetworkException(
        'Bad Request (400):\n${e.response.toString()}',
        400,
      );
    case 401:
      return NetworkException(
        'Sesi Anda telah berakhir. Silakan login kembali.',
        401,
      );
    case 403:
      return NetworkException('Anda tidak memiliki akses ke fitur ini.', 403);
    case 404:
      return NetworkException('Data tidak ditemukan.', 404);
    case 500:
      return NetworkException(
        'Terjadi kesalahan pada server. Coba lagi nanti.',
        500,
      );
    default:
      return NetworkException('Koneksi gagal: $e', e.statusCode);
  }
}
