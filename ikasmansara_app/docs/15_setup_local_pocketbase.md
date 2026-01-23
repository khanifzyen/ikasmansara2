# 🛠️ Panduan Setup PocketBase Local

Panduan ini akan menuntun kamu untuk menjalankan PocketBase di komputer lokal untuk keperluan Development & Testing, sebelum menggunakan server produksi dari dosen.

## 1. Download & Install PocketBase

1.  Download **PocketBase** untuk Windows (64-bit) dari website resmi:
    - [https://github.com/pocketbase/pocketbase/releases](https://github.com/pocketbase/pocketbase/releases)
    - Pilih file zip: `pocketbase_X.XX.X_windows_amd64.zip`
2.  Extract (unzip) file tersebut ke dalam folder project backend (misal: buat folder baru `ikasmansara_backend` di luar folder flutter, atau di mana saja yang kamu suka).
3.  Di dalam folder tersebut, ada 1 file `pocketbase.exe`.

## 2. Menjalankan Server

1.  Buka **Terminal** (PowerShell atau CMD) di folder tempat `pocketbase.exe` berada.
2.  Jalankan perintah:
    ```powershell
    ./pocketbase serve
    ```
3.  Kamu akan melihat output seperti ini:
    ```
    > Server started at: http://127.0.0.1:8090
    > REST API: http://127.0.0.1:8090/api/
    > Admin UI: http://127.0.0.1:8090/_/
    ```
    **JANGAN TUTUP TERMINAL INI** selama kamu sedang testing aplikasi.

## 3. Setup Database (Import Schema)

1.  Buka browser dan buka **Admin UI**: [http://127.0.0.1:8090/\_/](http://127.0.0.1:8090/_/)
2.  Buat akun Admin pertama kali (masukkan email & password bebas, misal `admin@test.com` / `1234567890`).
3.  Setelah masuk Dashboard:
    - Klik menu **Settings** (icon gerigi di kiri bawah).
    - Klik menu **Sync** -> **Import collections**.
    - Klik tombol **Load from JSON file**.
    - Pilih file **`pb_schema.json`** yang sudah saya buatkan di root folder project `ikasmansara_app` kamu.
    - Klik **Import** (atau Merge).

✅ **Sukses!** Sekarang semua collection (`users`, `products`, `jobs`, `campaigns`, `posts`, `comments`) sudah otomatis terbuat dengan struktur yang benar.

## 4. Konfigurasi Flutter untuk Local Dev

Agar aplikasi Flutter di Emulator Android bisa mengakses PocketBase lokal komputer kamu, kita perlu setting URL khusus.

1.  Buka file `.env` di project Flutter kamu.
2.  Ubah `POCKETBASE_URL` menjadi:

    ```env
    # URL khusus Android Emulator untuk akses Localhost komputer
    POCKETBASE_URL=http://10.0.2.2:8090
    ```

    > **Catatan Penting**:
    >
    > - Jika pakai **Android Emulator**: Gunakan `http://10.0.2.2:8090`
    > - Jika pakai **iOS Simulator**: Gunakan `http://127.0.0.1:8090`
    > - Jika pakai **HP Fisik**: Gunakan IP LAN komputer kamu (misal: `http://192.168.1.5:8090`) dan HP harus satu WiFi.

## 5. Testing

1.  Matikan aplikasi flutter (Stop).
2.  Jalankan ulang: `flutter run`.
3.  Coba Register akun baru di aplikasi.
4.  Cek di Admin UI PocketBase (menu Collections -> users), data user baru harusnya muncul di sana.

## 6. Testing dengan HP Fisik (Real Device) 📱

Jika kamu ingin install aplikasi di HP beneran (bukan emulator), setup-nya sedikit berbeda karena HP kamu tidak bisa "melihat" `localhost` komputer kamu secara langsung.

### Syarat Wajib:

- Laptop/PC dan HP harus connect ke **WiFi yang SAMA**.
- Firewall Windows tidak memblokir port 8090 (biasanya aman, kalau gagal matikan firewall sebentar).

### Langkah 1: Cari IP Address Laptop

1.  Buka Terminal (CMD/PowerShell).
2.  Ketik `ipconfig` lalu Enter.
3.  Cari bagian `IPv4 Address`. Biasanya angkanya **192.168.x.x** (contoh: `192.168.1.10`).

### Langkah 2: Jalankan PocketBase dengan Mode Publik

Perintah `./pocketbase serve` biasa hanya bisa diakses laptop sendiri. Gunakan perintah ini sebagai gantinya:

```powershell
./pocketbase serve --http="0.0.0.0:8090"
```

_(Ini artinya: "Izinkan siapa saja di jaringan ini mengakses saya di port 8090")_

### Langkah 3: Update .env Flutter

Ganti URL di `.env` menggunakan IP Laptop yang kamu temukan tadi.

```env
# Contoh jika IP laptop kamu 192.168.1.10
POCKETBASE_URL=http://192.168.1.10:8090
```

### Langkah 4: Run ke HP

Colok HP ke laptop (USB Debugging on), lalu jalankan:

```bash
flutter run -d <id_hp_kamu>
```

## 7. Pindah ke Production (Nanti)

Jika server dosen sudah siap, kamu tinggal:

1.  Buka file `.env` lagi.
2.  Ganti URL ke URL dosen:
    ```env
    POCKETBASE_URL=https://ikasmansara.pockethost.io  <-- Contoh
    ```
3.  Restart aplikasi. Selesai!

---

💡 **Tips**: Kamu bisa mengisi "Dummy Data" (Data palsu) langsung lewat Admin UI PocketBase agar saat testing aplikasi tidak kosong melompong.
