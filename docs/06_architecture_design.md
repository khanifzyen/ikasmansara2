# 06. Detail Implementasi Clean Architecture

Dokumen ini merinci bagaimana **Clean Architecture** diterapkan pada setiap fitur di **IKA SMANSARA Mobile**.
Tujuannya adalah memastikan kode _maintainable_, _testable_, dan _independent_ dari framework UI / Database.

## 1. Konsep Core (The Layers)

Setiap fitur (misal: `auth`, `marketplace`) akan dibagi menjadi 3 lapisan (Layers) yang ketat. Arah dependency selalu **ke dalam** (menuju Domain).

### A. Domain Layer (Inti Bisnis / Inner Layer)

_Hanya murni Dart Code. Tidak boleh ada import Flutter UI, Riverpod, atau Dio/PocketBase._

- **Entities**: Object bisnis murni. Contoh: `User`, `Product`.
- **Repositories (Interface)**: Kontrak abstrak apa yang bisa dilakukan. Contoh: `AuthRepository` (abstract class).
- **Use Cases**: Satu class satu fungsi bisnis spesifik. Contoh: `LoginUser`, `GetProductList`.

### B. Data Layer (Outer Layer)

_Implementasi teknis dari Domain._

- **Models**: Turunan dari Entity dengan kemampuan JSON Serialization. Contoh: `UserModel.fromJson()`.
- **Data Sources**: Kode yang bicara langsung ke API/DB. Contoh: `AuthRemoteDataSource` menembak PocketBase SDK.
- **Repositories (Implementation)**: Implementasi kontrak Domain. Menggabungkan Data Source lokal & remote.

### C. Presentation Layer (Outer Layer)

_UI dan State Management._

- **Providers (Riverpod)**: State Holder. Memanggil UseCase. Contoh: `loginControllerProvider`.
- **Widgets/Screens**: Tampilan UI. Hanya boleh nger-render data dari Provider.

---

## 2. Pemetaan Fitur (Feature Mapping)

Berikut adalah rancangan detail untuk fitur-fitur utama:

### Fitur 1: Authentication (`features/auth`)

_Login, Register (3 Steps), & Forgot Password._

| Layer            | Component  | Nama Class / File               | Tugas                                                                               |
| :--------------- | :--------- | :------------------------------ | :---------------------------------------------------------------------------------- |
| **Domain**       | Entity     | `UserEntity`                    | `id`, `name`, `email`, `role`, `step_progress`.                                     |
|                  | Repository | `AuthRepository`                | `login()`, `registerStep1()`, `registerStep2()`, `registerStep3()`.                 |
|                  | UseCase    | `LoginUser`                     | Logic login standar.                                                                |
|                  | UseCase    | `RegisterAlumni`                | Mengelola state wizard 3 langkah (simpan sementara di memory sebelum submit final). |
| **Data**         | Model      | `AuthResponseModel`             | Token + User Data.                                                                  |
|                  | DataSource | `AuthRemoteDataSource`          | `pb.collection('users').create()`.                                                  |
| **Presentation** | Controller | `LoginController`               | Handle loading state login.                                                         |
|                  | Controller | `RegisterController`            | Menangani PageView 3 step & validasi input per step.                                |
|                  | Screen     | `LoginScreen`, `RegisterScreen` | UI Form.                                                                            |

### Fitur 2: Marketplace (`features/marketplace`)

_Listing Produk, Filter Kategori, & WhatsApp Link._

| Layer            | Component  | Nama Class / File        | Tugas                                                                   |
| :--------------- | :--------- | :----------------------- | :---------------------------------------------------------------------- |
| **Domain**       | Entity     | `ProductEntity`          | `id`, `name`, `price`, `category`, `sellerPhone`.                       |
|                  | Repository | `MarketRepository`       | `getProducts(category, query)`.                                         |
|                  | UseCase    | `GetProducts`            | Filter logic: "Jasa Pro" -> kategori "Jasa".                            |
|                  | UseCase    | `ContactSeller`          | Logic menyusun pesan WA: "Halo, saya tertarik dengan [Nama Produk]...". |
| **Data**         | Model      | `ProductModel`           | JSON parsing.                                                           |
|                  | DataSource | `MarketRemoteDataSource` | `pb.collection('products').getList()`.                                  |
| **Presentation** | Controller | `MarketListController`   | State list produk + filter aktif.                                       |
|                  | Screen     | `MarketScreen`           | GridView + FilterChips (Horizontal Scroll).                             |

### Fitur 3: Directory / Alumni (`features/directory`)

_Pencarian dan detail alumni._

| Layer            | Component  | Nama Class / File           | Tugas                                                   |
| :--------------- | :--------- | :-------------------------- | :------------------------------------------------------ |
| **Domain**       | Entity     | `AlumniEntity`              | `id`, `name`, `angkatan`, `profession`, `avatarUrl`.    |
|                  | Repository | `DirectoryRepository`       | `searchAlumni(query, filter)`, `getAlumniDetail(id)`.   |
|                  | UseCase    | `SearchAlumni`              | Logic pencarian dengan debouncing (di controller).      |
| **Data**         | Model      | `AlumniModel`               | Mapping dari collection `users` (filtered).             |
|                  | DataSource | `DirectoryRemoteDataSource` | `pb.collection('users').getList(filter: 'name~"abc"')`. |
|                  | Repo Impl  | `DirectoryRepositoryImpl`   | Error handling `404 Not Found`.                         |
| **Presentation** | Controller | `DirectoryController`       | State list alumni.                                      |
|                  | Screen     | `DirectoryScreen`           | SearchBar + ListView.                                   |

### Fitur 4: Loker (`features/loker`)

_Informasi lowongan kerja._

| Layer            | Component  | Nama Class / File             | Tugas                                                         |
| :--------------- | :--------- | :---------------------------- | :------------------------------------------------------------ |
| **Domain**       | Entity     | `LokerEntity`                 | `id`, `position`, `company`, `type`, `author`.                |
|                  | UseCase    | `GetLokerList`, `SubmitLoker` | Get active loker. Submit butuh verifikasi (logic di backend). |
| **Data**         | Model      | `LokerModel`                  | Mapping `loker_posts`.                                        |
|                  | DataSource | `LokerRemoteDataSource`       | `pb.collection('loker_posts').getList()`.                     |
| **Presentation** | Controller | `LokerListController`         | Pagination logic for infinite scroll.                         |

### Fitur 5: Donasi (`features/donation`)

_Crowdfunding dengan Progress Bar & Label Urgent._

| Layer            | Component  | Nama Class / File        | Tugas                                                               |
| :--------------- | :--------- | :----------------------- | :------------------------------------------------------------------ |
| **Domain**       | Entity     | `DonationEntity`         | `id`, `title`, `target`, `collected`, `isUrgent`.                   |
|                  | UseCase    | `GetDonationList`        | Hitung `% progress`. Sort by `isUrgent` (Urgent paling atas).       |
|                  | UseCase    | `DonateNow`              | Integrasi Payment Gateway (Midtrans) / Manual Transfer instruction. |
| **Data**         | Model      | `DonationModel`          | JSON Parsing.                                                       |
| **Presentation** | Controller | `DonationListController` | Fetch data.                                                         |
|                  | Widget     | `DonationCard`           | Render Progress Bar (Stack Widget).                                 |

### Fitur 6: Forum (`features/forum`) (NEW)

_Diskusi, Like, & Comment (Sesuai `forum.html`)._

| Layer            | Component  | Nama Class / File             | Tugas                                                                 |
| :--------------- | :--------- | :---------------------------- | :-------------------------------------------------------------------- |
| **Domain**       | Entity     | `PostEntity`, `CommentEntity` | `content`, `author`, `likesCount`, `isLikedByMe`.                     |
|                  | Repository | `ForumRepository`             | `getPosts()`, `toggleLike(postId)`, `addComment(postId, text)`.       |
|                  | UseCase    | `ToggleLikePost`              | Optimistic UI Update (Update lokal dulu baru API request agar cepat). |
| **Data**         | DataSource | `ForumRemoteDataSource`       | `pb.collection('forum_posts')`.                                       |
| **Presentation** | Controller | `ForumController`             | List Posts State.                                                     |
|                  | Widget     | `PostCard`                    | Handle klik Like (Heart Animation).                                   |

---

## 3. Data Flow (Alur Data)

Contoh alur ketika user menekan tombol **Login**:

1.  **UI Event**: `LoginScreen` memanggil `ref.read(loginControllerProvider.notifier).login(email, pass)`.
2.  **Controller**: Set state ke `AsyncLoading()`. Panggil `LoginUser` (UseCase).
3.  **Use Case**: Menerima input, memanggil `AuthRepository.login()`.
4.  **Repository Impl**:
    - Memanggil `AuthRemoteDataSource.login()`.
    - Jika sukses: Terima `UserModel` (JSON), kembalikan sebagai `UserEntity` (Domain).
    - Jika gagal: Tangkap error `ClientException`, kembalikan sebagai `ServerFailure` (Custom Object).
5.  **Controller**:
    - Terima hasil `Either<Failure, UserEntity>`.
    - Jika Entity: Set state `AsyncData()`, navigasi ke Home.
    - Jika Failure: Set state `AsyncError()`, tampilkan Snackbar.

## 4. Aturan Wajib (Strict Rules)

1.  **Dependency Rule**: `Domain` TIDAK BOLEH import `Data` atau `Presentation`.
2.  **Interface Usage**: `UseCase` bicara dengan `AuthRepository` (Interface), bukan `AuthRepositoryImpl`. Dependency Injection (Riverpod) yang akan menyuntikkan implementasinya.
3.  **Failure Handling**: Jangan throw Exception sampai ke UI. Tangkap di Repository, return object `Failure`.
