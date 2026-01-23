# 04. Struktur Data (Schema Database)

Implementasi menggunakan **PocketBase** Collections.

## 1. Collection: `users` (System)

Menyimpan data akun login & profil dasar.

| Field              | Type   | Required | Details                                                                   |
| :----------------- | :----- | :------- | :------------------------------------------------------------------------ |
| `id`               | System | Yes      | Primary Key 15 chars.                                                     |
| `email`            | Email  | Yes      | Login ID.                                                                 |
| `name`             | Text   | Yes      | Nama Lengkap (Sesuai Ijazah).                                             |
| `avatar`           | File   | No       | Foto Profil ( jpg/png).                                                   |
| `angkatan`         | Number | Yes      | Tahun Lulus. Input di `register-alumni.html` Step 2.                      |
| `wali_kelas`       | Text   | No       | Wali Kelas Terakhir. Input di `register-alumni.html` Step 2.              |
| `phone`            | Text   | No       | WhatsApp. Input di `register-alumni.html` Step 1.                         |
| `password`         | -      | -        | Built-in PocketBase Auth.                                                 |
| `role`             | Select | Yes      | `['alumni', 'public', 'admin']`. Dari `role-selection.html`.              |
| `job_type`         | Select | Yes      | `['Swasta', 'PNS', 'BUMN', 'Wirausaha', 'Mahasiswa', 'Lainnya']`. Step 3. |
| `company`          | Text   | Yes      | Nama Instansi / Perusahaan. Step 3.                                       |
| `position`         | Text   | Yes      | Jabatan (e.g. Manager, Staff). Ditampilkan di `directory.html`.           |
| `domicile`         | Text   | Yes      | Kota Domisili. Step 3 & Filter Directory.                                 |
| `verification_doc` | File   | No       | Foto Ijazah/Rapor. Step 2 (Optional).                                     |
| `is_verified`      | Bool   | No       | Admin Approval Status.                                                    |

> [!NOTE] > **Data Source**: Schema ini disusun berdasarkan input form pada `register-alumni.html` (3 Steps) dan tampilan `directory.html`.

**API Rules**:

- `list/view`: `@request.auth.id != ""` (Authenticated Users).
- `update`: `id = @request.auth.id` (User edit profile sendiri).
- `create`: Public (Register).

## 2. Collection: `products` (Marketplace)

Barang atau jasa yang dijual alumni.

| Field         | Type     | Required | Details                                                                                |
| :------------ | :------- | :------- | :------------------------------------------------------------------------------------- |
| `seller_id`   | Relation | Yes      | Relasi ke `users`.                                                                     |
| `name`        | Text     | Yes      | Nama Produk/Jasa.                                                                      |
| `description` | Text     | No       | Deskripsi detail.                                                                      |
| `price`       | Number   | Yes      | Harga dalam Rupiah. Jika 0 = "Hubungi Penjual".                                        |
| `category`    | Select   | Yes      | `['Kuliner', 'Jasa', 'Fashion', 'Properti', 'Lainnya']`. (Filter Chips `market.html`). |
| `location`    | Text     | No       | Lokasi Barang (e.g. "Jepara", "Kudus").                                                |
| `image`       | File     | No       | Foto Produk (Single).                                                                  |
| `whatsapp`    | Text     | No       | No WA khusus (Optional, default use user phone).                                       |

**API Rules**:

- `list/view`: Public (Masyarakat boleh beli).
- `create`: Verified Alumni only.
- `update/delete`: Creator only.

## 3. Collection: `loker_posts` (Lowongan Kerja)

Info karir dari alumni untuk alumni.

| Field          | Type     | Required | Details                                                                    |
| :------------- | :------- | :------- | :------------------------------------------------------------------------- |
| `author_id`    | Relation | Yes      | Relasi ke `users` (Poster).                                                |
| `title`        | Text     | Yes      | Posisi (e.g. "Senior Staff").                                              |
| `company`      | Text     | Yes      | Nama Perusahaan.                                                           |
| `type`         | Select   | Yes      | `['Fulltime', 'Internship', 'Freelance', 'Remote']`. (Chips `loker.html`). |
| `location`     | Text     | Yes      | Lokasi (e.g. "Jakarta Selatan").                                           |
| `salary_range` | Text     | No       | (e.g. "8jt - 12jt").                                                       |
| `description`  | Text     | No       | Kualifikasi & Jobdesk.                                                     |
| `link`         | Url      | No       | Link pendaftaran / Email.                                                  |
| `is_active`    | Bool     | Yes      | Status lowongan.                                                           |

## 4. Collection: `donations` (Program Sosial)

| Field              | Type   | Required | Details                                             |
| :----------------- | :----- | :------- | :-------------------------------------------------- |
| `title`            | Text   | Yes      | Judul Campaign.                                     |
| `image`            | File   | No       | Banner 16:9.                                        |
| `target_amount`    | Number | No       | Target Rp (e.g. 50000000).                          |
| `collected_amount` | Number | No       | Terkumpul saat ini. Update via backend logic.       |
| `donor_count`      | Number | No       | Jumlah donatur.                                     |
| `is_urgent`        | Bool   | Yes      | Menampilkan label "URGENT" merah (`donation.html`). |
| `deadline`         | Date   | No       | Batas waktu donasi.                                 |
| `description`      | Text   | No       | Cerita / Latar belakang penggalangan dana.          |

**API Rules**:

- `list/view`: Public.
- `create/update`: Admin only.
