# 07. Rencana Kerja 7-Hari (Sprint Plan)

Dokumen ini adalah **Battle Plan** untuk menyelesaikan aplikasi IKA SMANSARA dalam waktu 7 hari kerja efektif.
Setiap hari memiliki target output yang jelas (Definition of Done).

## 📅 Roadmap Mingguan

| Hari | Fokus Utama | Target Fitur | Output |
| :--- | :--- | :--- | :--- |
| **Day 1** | **Foundation** | Setup Project, Theme, Navigation, Auth | Aplikasi bisa jalan, Pindah halaman, Login/Register. |
| **Day 2** | **Core Data** | Home Dashboard, E-KTA, Profile | Tampilan Home dinamis, Kartu Anggota render sesuai data user. |
| **Day 3** | **Alumni Data** | Direktori Alumni, Search | Bisa cari teman seangkatan, Detail profil user lain. |
| **Day 4** | **Commerce** | Marketplace (List, Detail, Filter) | Listing Produk dengan kategori, tombol WA connect. |
| **Day 5** | **Content** | Loker & Berita Sekolah | Feed Loker filterable, Baca berita detail. |
| **Day 6** | **Engagement** | Donasi & Forum (Simple) | Progress bar donasi, Thread diskusi sederhana. |
| **Day 7** | **Finalization** | Bugfix, Release APK, Demo Script | APK siap install, Data dummy "cantik" untuk demo. |

---

## 📝 Detail Harian

### Day 1: Foundation & Authentication
*   **Backend**:
    *   Setup PocketBase di Laptop/VPS.
    *   Create Collection `users` sesuai Schema.
*   **Frontend**:
    *   `flutter create`.
    *   Setup `GoRouter` dengan Shell (BottomNav).
    *   Implementasi `AppTheme` (Warna/Font).
    *   Slicing: Login Screen, Register Screen.
    *   Logic: `AuthRepository` (Login/Logout/CheckSession).

### Day 2: Home & User Profile (E-KTA)
*   **Backend**: Update `users` schema (tambah field angkatan, phone).
*   **Frontend**:
    *   Slicing: `HomeScreen` header, `MemberCard` widget.
    *   Slicing: `ProfileScreen` (Edit Profile simple).
    *   Logic: `UserProvider` (Fetch current user data).

### Day 3: Directory & Networking
*   **Backend**: Generate 50 dummy users (beda angkatan) untuk tes search.
*   **Frontend**:
    *   Slicing: `DirectoryScreen` (List user).
    *   Fitur: Search Bar (Filter by Name/Angkatan).
    *   Logic: `DirectoryRepository` (Fetch list users with filter).

### Day 4: Marketplace (Ekonomi Sirkular)
*   **Backend**: Create Collection `products`. Isi 10 dummy produk.
*   **Frontend**:
    *   Slicing: `MarketScreen` (Grid View), `ProductCard`.
    *   Fitur: Filter Chips (Kuliner/Jasa).
    *   Logic: Klik tombol beli -> `launchUrl` ke WhatsApp.

### Day 5: Loker & News
*   **Backend**: Create Collection `loker_posts` & `news`.
*   **Frontend**:
    *   Slicing: `LokerScreen` (ListView card).
    *   Slicing: `NewsDetailScreen`.
    *   Logic: Filter Loker (Fulltime/Parttime).

### Day 6: Donasi & Forum
*   **Backend**: Collection `donations`, `threads`.
*   **Frontend**:
    *   Slicing: `DonationCard` dengan LinearProgressIndicator.
    *   Slicing: `ForumList`.
    *   Logic: Hitung persentase donasi (Terkumpul / Target * 100).

### Day 7: Polishing & Demo Prep
*   **Quality Check**:
    *   Cek overflow pixel di HP layar kecil.
    *   Cek loading state (tambah Shimmer/Skeleton).
*   **Demo Data**: Pastikan foto-foto dummy terlihat profesional (Unsplash).
*   **Build**: `flutter build apk --release`.

> [!IMPORTANT]
> **Strategy Kecepatan**:
> Jangan habiskan waktu di animasi rumit. Fokus fungsi jalan dulu, baru percantik UI jika sisa waktu. Gunakan library standar Material 3/Cupertino.
