# 02. Spesifikasi Teknologi (Tech Stack)

## 1. Frontend: Flutter
*   **Versi**: Flutter 3.27+ (Latest Stable)
*   **Bahasa**: Dart 3.x
*   **Alasan Pemilihan**:
    *   **Single Codebase**: Target Android & iOS sekaligus.
    *   **Performa Native**: Rendering 60/120fps imp (Skia/Impeller).
    *   **Ekosistem Matang**: Library UI & State management sangat lengkap.

## 2. Backend: PocketBase
*   **Basis**: Go (Golang) + SQLite (Embedded WAL mode)
*   **Fitur Utama**:
    *   **Auth Built-in**: Email/Pass, OAuth2 (Google/Facebook).
    *   **Realtime**: Subscriptions untuk Chat/Notifikasi via SSE (Server Sent Events).
    *   **Admin Dashboard**: UI siap pakai untuk kelola data (User, Content).
    *   **Portable**: Single binary file executable. Mudah di-deploy di VPS murah ($5/mo).

## 3. State Management: Riverpod
*   **Library**: `flutter_riverpod` + `riverpod_annotation`
*   **Pendekatan**:
    *   **Code Generation**: Menggunakan `@riverpod` untuk mengurangi boilerplate.
    *   **AsyncValue**: Menangani state Loading/Error/Data secara aman.
    *   **Dependency Injection**: Memisahkan Logic dari UI (Testable Code).

## 4. Library Pendukung Utama
| Kategori | Library | Kegunaan |
| :--- | :--- | :--- |
| **Routing** | `go_router` | Navigasi deklaratif, deep linking, auth redirection. |
| **Networking** | `dio` | HTTP Client, Interceptors, File Upload. |
| **Local Storage** | `shared_preferences` | Simpan token sesi / tema ringan. |
| **UI Components** | `google_fonts` | Typography (Inter/Poppins). |
| **Icons** | `lucide_icons` | Set ikon modern & konsisten. |
