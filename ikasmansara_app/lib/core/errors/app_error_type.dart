enum AppErrorType {
  network, // Tidak ada internet / Timeout
  authentication, // Token expired / Wrong credentials
  validation, // Input user salah (email invalid, password terlalu pendek)
  notFound, // Data tidak ditemukan (404)
  serverError, // Server down (500)
  unauthorized, // User tidak punya akses (403)
  unknown, // Error yang tidak terduga
}
