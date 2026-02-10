# Ringkasan Sesi Refinement Admin Event

Sesi ini berfokus pada penyempurnaan fitur Manajemen Peserta dan Statistik Event pada Dashboard Admin.

## Perubahan Utama

1.  **Sinkronisasi Data Profil (Nama, HP, Angkatan)**
    - Data peserta yang mendaftar melalui aplikasi kini secara otomatis disinkronkan dengan profil user terbaru (`users.phone`, `users.angkatan`).
    - Pendaftaran manual tetap menggunakan data koordinator yang diinput.

2.  **Logika Harga & Akurasi Tiket**
    - Kolom **Total** pada tabel peserta kini memprioritaskan `subtotal` dengan fallback ke `total_price`.
    - Perhitungan jumlah tiket kini menghitung total kuantitas dari semua item tiket dalam satu booking (untuk pendaftaran aplikasi).

3.  **Statistik Live Real-time**
    - Kartu statistik **Pendaftar** dan **Pemasukan** pada halaman detail event kini mengambil data asli dari PocketBase (hanya menghitung booking dengan status 'paid').

4.  **Kolom Catatan (Catatan/Pilihan Tiket)**
    - Menambahkan kolom **Catatan** yang menampilkan pilihan tiket (misal: ukuran kaos) untuk pendaftaran aplikasi, atau catatan khusus untuk pendaftaran manual.

5.  **Kolom Tanggal Pembayaran**
    - Menambahkan kolom **Tgl Bayar** setelah Status untuk memudahkan pelacakan waktu transaksi lunas.

6.  **Peningkatkan Fitur Tambah Peserta Manual**
    - Menambahkan form **Total Biaya** (masuk ke `subtotal` dan `total_price`).
    - Menambahkan pilihan **Channel Pendaftaran** (Manual Transfer / Manual Cash).
    - Biaya layanan (`service_fee`) otomatis diset ke **0**.
    - Status default diset ke **Pending**.

7.  **Penyesuaian Tema**
    - Mengubah pengaturan default aplikasi ke **Light Mode** (mengabaikan preferensi sistem/auto).

8.  **Perbaikan Hook Ticket Generation**
    - Memperbaiki `pb_hooks/ticket_generation.pb.js` agar lebih robust dan null-safe saat memproses `metadata`.
    - Menangani kasus di mana PocketBase mengembalikan byte array bertipe `"null"` yang sebelumnya menyebabkan hook terhenti (crash), sehingga pembuatan tiket untuk pendaftaran manual kini berjalan lancar.

9.  **Pembaruan Dokumentasi**
    - Memperbarui `docs/pb_hooks.md` dengan detail teknis terbaru mengenai logika hook, termasuk penanganan *null-safety* dan jalur ganda pembuatan tiket.

10. **Fitur Lihat Tiket & Printing (Baru)**
    - Menambahkan tombol **Lihat Tiket** di tabel (Desktop) dan card (Mobile) pendaftar berstatus 'paid'.
    - Implementasi modal **Ticket Preview** dengan desain ala struk kertas (thermal print).
    - Format QR Code: `id_database:kode_tiket`.
    - Dukungan **Share All** (mengirim semua foto tiket sekaligus) dan **Print All** (antrian cetak ke printer Bluetooth).
    - Logika dinamis: Untuk manual, NAMA menggunakan nama koordinator dan OPSI menggunakan catatan booking.

11. **Perbaikan Bug & Lint**
    - Memperbaiki error `BlocProvider.of()` dengan menangani *context shadowing* pada dialog.
    - Membersihkan peringatan *deprecated* API dan asinkron *BuildContext*.

12. **Perbaikan Verifikasi Tiket (QR Scan)**
    - Menyelesaikan masalah error 404 saat scan tiket dengan memperbarui **API Rules** pada koleksi `event_booking_tickets`.
    - Rule baru: `booking.user = @request.auth.id || @request.auth.role = "admin"`. Ini memastikan pemilik tiket dan admin dapat melakukan verifikasi, sementara akses publik tetap dibatasi.

13. **Refaktorisasi Link Eksternal ke ENV**
    - Memindahkan URL **Kebijakan Privasi** dan **Syarat & Ketentuan** dari kode hardcoded ke file `.env`.
    - Menambahkan getter pada `AppConstants` untuk pembacaan dinamis. Hal ini memudahkan perubahan link di masa depan (misal: saat migrasi ke website resmi) tanpa perlu mengubah kode sumber.

14. **Dokumen Legal Baru**
    - Membuat draft dokumen **[Privacy Policy](file:///mnt/data1/www/ikasmansara2/docs/privacy_policy.md)** dan **[Terms & Conditions](file:///mnt/data1/www/ikasmansara2/docs/terms.md)** sesuai dengan konteks aplikasi IKA SMANSARA.

15. **Penyelarasan Brand (SMANSARA)**
    - Memperbarui penyebutan nama organisasi dari "SMANSA" menjadi "SMANSARA" pada halaman pemilihan role dan registrasi alumni untuk konsistensi brand.

## Operasi Git
- Melakukan pendataan seluruh perubahan file (`git add .`).
- Melakukan commit dengan label "poin-poin" yang merangkum pekerjaan sesi ini.
- Melakukan push ke repository.

16. **Responsive Alumni Dashboard**
    - Mengimplementasikan layout responsif pada `MainShell` dan `HomePage`.
    - **Desktop (Width ≥ 800px)**: Menggunakan `NavigationRail` (sidebar) di sebelah kiri dan layout multikolom untuk konten dashboard.
    - **Mobile**: Mempertahankan `BottomNavigationBar` dan layout single-column yang familiar.
    - Menyesuaikan `GridView` pada menu akses cepat agar tampilan desktop lebih proporsional (`childAspectRatio: 1.5`).
