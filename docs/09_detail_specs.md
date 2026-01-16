# 09. Spesifikasi Teknis Detail (Micro-Specs)

Dokumen ini mengisi "Gap" antara Prototype HTML (`lofi`) dan Aplikasi Production Ready. HTML tidak memiliki logic validasi atau error handling, jadi kita definisikan di sini.

## 1. Validasi Input (Form Rules)

Agar UX pengguna mulus, validasi dilakukan secara **Real-time** (saat mengetik) atau **On-Submit**.

| Fitur        | Field      | Aturan Validasi (Rules)                          | Pesan Error (Bahasa Indonesia)            |
| :----------- | :--------- | :----------------------------------------------- | :---------------------------------------- |
| **Register** | `email`    | `RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')`    | "Format email tidak valid."               |
|              | `password` | Min 8 chars, 1 Uppercase.                        | "Minimal 8 karakter & 1 huruf besar."     |
|              | `phone`    | Numeric only, Min 10, Max 14. Start '0' or '62'. | "Nomor WhatsApp tidak valid."             |
|              | `angkatan` | Year between 1960 - Current Year.                | "Tahun angkatan tidak masuk akal."        |
| **Loker**    | `url`      | Valid URL format (http/https).                   | "Link pendaftaran harus diawali http://". |
| **Donasi**   | `amount`   | Min Rp 10.000.                                   | "Donasi minimal Rp 10.000 ya kak."        |

## 2. Empty States & Error Handling UI

HTML `lofi` hanya menunjukkan "Happy Path" (Saat data ada). Kita perlu state untuk kondisi ini:

### A. Network Error / Server Down

- **Tampilan**: Gambar ilustrasi "Koneksi Terputus".
- **Action**: Tombol "Coba Lagi" (Retry Button).
- **Toast**: "Gagal terhubung ke server. Periksa internetmu."

### B. Empty Data (Data Kosong)

- **Directory**: "Alumni tidak ditemukan" (Jika search result 0).
- **Loker**: "Belum ada lowongan baru saat ini."
- **Market**: "Produk kategori ini belum tersedia."

### C. Loading States (Shimmer)

- Jangan gunakan _Circular Progress_ biasa untuk layout List/Grid.
- **Directory**: Skeleton List (Avatar bulat + 2 baris teks).
- **Market**: Skeleton Grid (Kotak gambar + teks harga).

## 3. Aset & Media Paths

Lokasi aset statis yang akan digunakan dalam aplikasi (ditaruh di `assets/images/`).

- `assets/images/logo_ikasmansara.png` (Logo App)
- `assets/images/placeholder_avatar.png` (Default user avatar)
- `assets/images/placeholder_product.png` (Default product image)
- `assets/images/pattern_ekta.png` (Background Kartu E-KTA)
- `assets/images/empty_state.svg` (Ilustrasi data kosong)

## 4. Logic "Hidden" (Yang tidak ada di HTML)

Hal-hal yang harus di-handle di background:

1.  **Session Management**: Auto-login jika token masih valid (Persist Token).
2.  **Debounce Search**: Pencarian direktori harus menunggu 500ms setelah user berhenti mengetik, baru request ke server (Hemat API Call).

## 5. Image Upload & Compression Flow

**Use Case**: Upload foto profil, foto produk, foto dokumentasi donasi.

### A. Library yang Digunakan

```yaml
# pubspec.yaml
dependencies:
  image_picker: ^1.0.0 # Pick image dari galeri/kamera
  flutter_image_compress: ^2.0.0 # Compress gambar
```

### B. Flow Upload (Step-by-step)

```dart
// 1. Pick Image
final ImagePicker picker = ImagePicker();
final XFile? image = await picker.pickImage(
  source: ImageSource.gallery,
  maxWidth: 1080, // Pre-resize
);

// 2. Compress (Max 500KB)
final compressedBytes = await FlutterImageCompress.compressWithFile(
  image.path,
  quality: 70,       // 0-100 (70 = balance antara ukuran & kualitas)
  minWidth: 1080,
  minHeight: 1080,
);

// 3. Convert to MultipartFile (untuk PocketBase)
final multipartFile = MultipartFile.fromBytes(
  compressedBytes,
  filename: 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg',
);

// 4. Upload ke PocketBase
final formData = {
  'name': productName,
  'price': price,
  'image': multipartFile, // Field name sesuai PocketBase schema
};

await pb.collection('products').create(body: formData);
```

### C. Progress Indicator (Optional)

Jika ukuran file besar (>1MB after compress), tampilkan progress:

```dart
float uploadProgress = 0.0;

await pb.collection('products').create(
  body: formData,
  onProgress: (sent, total) {
    setState(() {
      uploadProgress = sent / total;
    });
  },
);
```

### D. Validasi Ukuran File

```dart
if (compressedBytes.length > 500 * 1024) { // 500KB
  throw Exception('Ukuran gambar terlalu besar. Maksimal 500KB.');
}
```

### E. Error Handling

```dart
try {
  await uploadImage();
} on PlatformException catch (e) {
  if (e.code == 'photo_access_denied') {
    // User menolak akses galeri
    showDialog('Izinkan akses galeri di pengaturan');
  }
} catch (e) {
  showSnackbar('Upload gagal: ${e.toString()}');
}
```

---

> [!IMPORTANT]
> Developer wajib membaca dokumen ini sebelum membuat Controller/Form apapun.
