# 🚀 IKA SMANSARA Mobile - Development Task List

**Project**: IKA SMANSARA (Alumni Network Mobile App)  
**Tech Stack**: Flutter 3.27+ | PocketBase | Riverpod | GoRouter  
**Documentation**: `docs/01-14` (13 files)  
**UI Reference**: `lofi/` (31 HTML files)

---

## Phase 1: Environment & Project Setup 🔧

### 1.1 Development Environment

- [ ] Install Flutter 3.27+ (verify: `flutter --version`)
- [ ] Install Dart 3.x

### 1.2 Project Initialization

- [ ] Run `flutter create --org com.ikasmansara --project-name ikasmansara_mobile ikasmansara_app`
- [ ] Add all dependencies ke `pubspec.yaml` (ref: `docs/02_tech_stack.md`)
  - [ ] `flutter_riverpod`, `riverpod_annotation`
  - [ ] `go_router`
  - [ ] `pocketbase`, `dio`
  - [ ] `google_fonts`, `lucide_icons`
  - [ ] `flutter_dotenv`, `shared_preferences`, `flutter_secure_storage`
  - [ ] `image_picker`, `flutter_image_compress`
  - [ ] `cached_network_image`, `shimmer`
  - [ ] `intl`
  - [ ] Dev: `riverpod_generator`, `build_runner`, `custom_lint`, `riverpod_lint`
- [ ] Run `flutter pub get`
- [ ] Create `.env` file dengan `POCKETBASE_URL=http://127.0.0.1:8090`
- [ ] Add `.env` ke `.gitignore`

### 1.3 Folder Structure Setup

- [ ] Create folder structure sesuai `docs/05_project_rules.md`:
  ```
  lib/
  ├── core/
  │   ├── constants/
  │   ├── errors/
  │   ├── theme/
  │   ├── router/
  │   ├── network/
  │   └── utils/
  ├── common_widgets/
  │   ├── buttons/
  │   ├── inputs/
  │   ├── cards/
  │   └── layout/
  └── features/
      ├── auth/
      ├── onboard/
      ├── home/
      ├── directory/
      ├── marketplace/
      ├── loker/
      ├── donation/
      ├── forum/
      └── profile/
  ```

---

## Phase 2: Core Infrastructure 🏗️

### 2.1 Network Layer (PocketBase Service)

- [ ] Create `core/network/pocketbase_service.dart` (ref: `docs/10_service_layer.md`)
- [ ] Create `core/network/api_endpoints.dart` (collection names)
- [ ] Create `core/network/network_exceptions.dart` (error mapper)
- [ ] Create provider `pocketBaseServiceProvider`
- [ ] Initialize PocketBase di `main.dart`

### 2.2 Error Handling

- [ ] Create `core/errors/app_error_type.dart` (enum)
- [ ] Create `core/errors/app_exception.dart` (ref: `docs/11_error_handling.md`)
- [ ] Create `core/errors/error_logger.dart`

### 2.3 Design System (Theme)

- [ ] Create `core/theme/app_colors.dart` (ref: `docs/03_design_system.md`)
- [ ] Create `core/theme/app_text_styles.dart` (Poppins & Inter)
- [ ] Create `core/theme/app_theme.dart` (ThemeData config)
- [ ] Update `app.dart` untuk pakai `AppTheme.lightTheme`

### 2.4 Routing

- [ ] Create `core/router/router.dart` dengan GoRouter
- [ ] Define initial routes: `/splash`, `/login`, `/home`
- [ ] Wire up router ke `app.dart`

### 2.5 Constants & Utilities

- [ ] Create `core/constants/assets_path.dart` (paths gambar)
- [ ] Create `core/utils/validators.dart` (email, password, phone - ref: `docs/09`)
- [ ] Create `core/utils/formatters.dart` (currency, date)

---

## Phase 3: Atomic Components (Design System) 🧱

### 3.1 Buttons

- [ ] Create `common_widgets/buttons/primary_button.dart`
- [ ] Create `common_widgets/buttons/outline_button.dart`
- [ ] Create `common_widgets/buttons/scale_button.dart` (interaction effect)

### 3.2 Inputs

- [ ] Create `common_widgets/inputs/custom_text_field.dart`
- [ ] Create `common_widgets/inputs/search_bar.dart`
- [ ] Create `common_widgets/inputs/dropdown_field.dart`

### 3.3 Cards

- [ ] Create `common_widgets/cards/standard_card.dart`
- [ ] Create `common_widgets/cards/member_card.dart` (untuk Directory)
- [ ] Create `common_widgets/cards/product_card.dart` (untuk Market)
- [ ] Create `common_widgets/cards/job_card.dart` (untuk Loker)
- [ ] Create `common_widgets/cards/campaign_card.dart` (untuk Donation)
- [ ] Create `common_widgets/cards/post_card.dart` (untuk Forum)

### 3.4 Layout Components

- [ ] Create `common_widgets/layout/bottom_nav_bar.dart`
- [ ] Create `common_widgets/layout/filter_chips.dart` (horizontal scroll)
- [ ] Create `common_widgets/layout/empty_state.dart`
- [ ] Create `common_widgets/layout/loading_shimmer.dart`

---

## Phase 4: Feature Implementation 🎯

### 4.1 Onboarding & Splash

- [ ] **Domain**: Create `features/onboard/domain/entities/user_role.dart` (enum)
- [ ] **Presentation**: Create `features/onboard/presentation/splash_screen.dart`
- [ ] **Presentation**: Create `features/onboard/presentation/role_selection_screen.dart` (ref: `lofi/role-selection.html`)
- [ ] Add routes: `/splash`, `/role-selection`

### 4.2 Authentication (Login & Register)

- [ ] **Domain**: Create `features/auth/domain/entities/user_entity.dart`
- [ ] **Domain**: Create `features/auth/domain/repositories/auth_repository.dart` (interface)
- [ ] **Domain**: Create `features/auth/domain/usecases/login_user.dart`
- [ ] **Domain**: Create `features/auth/domain/usecases/register_alumni.dart`
- [ ] **Data**: Create `features/auth/data/models/user_model.dart`
- [ ] **Data**: Create `features/auth/data/datasources/auth_remote_data_source.dart`
- [ ] **Data**: Create `features/auth/data/repositories/auth_repository_impl.dart`
- [ ] **Presentation**: Create `features/auth/presentation/login_controller.dart`
- [ ] **Presentation**: Create `features/auth/presentation/login_screen.dart` (ref: `lofi/login.html`)
- [ ] **Presentation**: Create `features/auth/presentation/register_controller.dart`
- [ ] **Presentation**: Create `features/auth/presentation/register_screen.dart` (3-step wizard, ref: `lofi/register-alumni.html`)
- [ ] Add routes: `/login`, `/register`
- [ ] Test Login Flow

### 4.3 Home Dashboard

- [ ] **Presentation**: Create `features/home/presentation/home_controller.dart`
- [ ] **Presentation**: Create `features/home/presentation/home_screen.dart` (ref: `lofi/home.html`)
  - [ ] E-KTA Card Preview (gradient card)
  - [ ] Action Grid (2x4: Direktori, Market, Loker, Donasi, Forum, E-KTA, Berita, Tentang)
  - [ ] Donation Slider (horizontal scroll)
  - [ ] News Section
- [ ] **Presentation**: Create `features/home/presentation/widgets/ekta_card_preview.dart`
- [ ] **Presentation**: Create `features/home/presentation/widgets/action_grid.dart`
- [ ] Add route: `/home`
- [ ] Integrate Bottom Navigation Bar (5 items)

### 4.4 Directory (Alumni Search)

- [ ] **Domain**: Create `features/directory/domain/entities/alumni_entity.dart`
- [ ] **Domain**: Create `features/directory/domain/repositories/directory_repository.dart`
- [ ] **Domain**: Create `features/directory/domain/usecases/search_alumni.dart`
- [ ] **Data**: Create `features/directory/data/models/alumni_model.dart`
- [ ] **Data**: Create `features/directory/data/datasources/directory_remote_data_source.dart`
- [ ] **Data**: Create `features/directory/data/repositories/directory_repository_impl.dart`
- [ ] **Presentation**: Create `features/directory/presentation/directory_controller.dart` (dengan debounce search)
- [ ] **Presentation**: Create `features/directory/presentation/directory_screen.dart` (ref: `lofi/directory.html`)
  - [ ] Search Bar
  - [ ] Filter Chips (Angkatan, Pekerjaan, Domisili)
  - [ ] Alumni List (member cards)
- [ ] **Presentation**: Create `features/directory/presentation/alumni_detail_screen.dart`
- [ ] Add routes: `/directory`, `/directory/:id`

### 4.5 Marketplace

- [ ] **Domain**: Create `features/marketplace/domain/entities/product_entity.dart`
- [ ] **Domain**: Create `features/marketplace/domain/repositories/product_repository.dart`
- [ ] **Domain**: Create `features/marketplace/domain/usecases/get_products.dart`
- [ ] **Domain**: Create `features/marketplace/domain/usecases/contact_seller.dart` (WhatsApp link)
- [ ] **Data**: Create `features/marketplace/data/models/product_model.dart`
- [ ] **Data**: Create `features/marketplace/data/datasources/product_remote_data_source.dart`
- [ ] **Data**: Create `features/marketplace/data/repositories/product_repository_impl.dart`
- [ ] **Presentation**: Create `features/marketplace/presentation/market_list_controller.dart`
- [ ] **Presentation**: Create `features/marketplace/presentation/market_screen.dart` (ref: `lofi/market.html`)
  - [ ] Search Bar
  - [ ] Category Chips
  - [ ] Product Grid (2 columns)
  - [ ] FAB (Jual Produk)
- [ ] **Presentation**: Create `features/marketplace/presentation/product_detail_screen.dart` (ref: `lofi/market-detail.html`)
- [ ] **Presentation**: Create `features/marketplace/presentation/add_product_screen.dart` (dengan image upload)
- [ ] Add routes: `/market`, `/market/:id`, `/market/add`

### 4.6 Job Portal (Loker)

- [ ] **Domain**: Create `features/loker/domain/entities/job_entity.dart`
- [ ] **Domain**: Create `features/loker/domain/repositories/job_repository.dart`
- [ ] **Domain**: Create `features/loker/domain/usecases/get_jobs.dart`
- [ ] **Data**: Create `features/loker/data/models/job_model.dart`
- [ ] **Data**: Create `features/loker/data/datasources/job_remote_data_source.dart`
- [ ] **Data**: Create `features/loker/data/repositories/job_repository_impl.dart`
- [ ] **Presentation**: Create `features/loker/presentation/loker_list_controller.dart`
- [ ] **Presentation**: Create `features/loker/presentation/loker_screen.dart` (ref: `lofi/loker.html`)
  - [ ] Search Bar
  - [ ] Filter Chips (Fulltime, Internship, Remote)
  - [ ] Job List
- [ ] **Presentation**: Create `features/loker/presentation/job_detail_screen.dart` (ref: `lofi/loker-detail.html`)
- [ ] **Presentation**: Create `features/loker/presentation/post_job_screen.dart`
- [ ] Add routes: `/loker`, `/loker/:id`, `/loker/post`

### 4.7 Donation Campaigns

- [ ] **Domain**: Create `features/donation/domain/entities/campaign_entity.dart`
- [ ] **Domain**: Create `features/donation/domain/repositories/donation_repository.dart`
- [ ] **Domain**: Create `features/donation/domain/usecases/get_campaigns.dart`
- [ ] **Data**: Create `features/donation/data/models/campaign_model.dart`
- [ ] **Data**: Create `features/donation/data/datasources/donation_remote_data_source.dart`
- [ ] **Data**: Create `features/donation/data/repositories/donation_repository_impl.dart`
- [ ] **Presentation**: Create `features/donation/presentation/donation_list_controller.dart`
- [ ] **Presentation**: Create `features/donation/presentation/donation_screen.dart` (ref: `lofi/donation.html`)
  - [ ] Campaign Cards (dengan progress bar & urgent badge)
- [ ] **Presentation**: Create `features/donation/presentation/campaign_detail_screen.dart` (ref: `lofi/donation-detail.html`)
- [ ] Add routes: `/donation`, `/donation/:id`

### 4.8 Forum (Social Feed)

- [ ] **Domain**: Create `features/forum/domain/entities/post_entity.dart`
- [ ] **Domain**: Create `features/forum/domain/repositories/forum_repository.dart`
- [ ] **Domain**: Create `features/forum/domain/usecases/get_posts.dart`
- [ ] **Domain**: Create `features/forum/domain/usecases/toggle_like_post.dart` (optimistic UI)
- [ ] **Data**: Create `features/forum/data/models/post_model.dart`
- [ ] **Data**: Create `features/forum/data/datasources/forum_remote_data_source.dart`
- [ ] **Data**: Create `features/forum/data/repositories/forum_repository_impl.dart`
- [ ] **Presentation**: Create `features/forum/presentation/forum_controller.dart`
- [ ] **Presentation**: Create `features/forum/presentation/forum_screen.dart` (ref: `lofi/forum.html`)
  - [ ] Category Chips
  - [ ] Post Cards (like/comment counts)
  - [ ] FAB (Create Post)
- [ ] **Presentation**: Create `features/forum/presentation/create_post_screen.dart`
- [ ] **Presentation**: Create `features/forum/presentation/post_detail_screen.dart` (dengan comments)
- [ ] Add routes: `/forum`, `/forum/:id`, `/forum/create`

### 4.9 Profile & E-KTA

- [ ] **Domain**: Create `features/profile/domain/entities/profile_entity.dart`
- [ ] **Domain**: Create `features/profile/domain/repositories/profile_repository.dart`
- [ ] **Domain**: Create `features/profile/domain/usecases/get_user_profile.dart`
- [ ] **Data**: Create `features/profile/data/models/profile_model.dart`
- [ ] **Data**: Create `features/profile/data/datasources/profile_remote_data_source.dart`
- [ ] **Data**: Create `features/profile/data/repositories/profile_repository_impl.dart`
- [ ] **Presentation**: Create `features/profile/presentation/profile_controller.dart`
- [ ] **Presentation**: Create `features/profile/presentation/profile_screen.dart` (ref: `lofi/profile.html`)
- [ ] **Presentation**: Create `features/profile/presentation/edit_profile_screen.dart`
- [ ] **Presentation**: Create `features/profile/presentation/ekta_screen.dart` (fullscreen digital card, ref: `lofi/ekta.html`)
- [ ] Add routes: `/profile`, `/profile/edit`, `/ekta`

---

## Phase 5: Testing 🧪

### 5.1 Unit Tests (Domain Layer)

- [ ] Test `LoginUser` UseCase (success & error)
- [ ] Test `GetProducts` UseCase
- [ ] Test `SearchAlumni` UseCase
- [ ] Test Error Mapping (`mapPocketBaseError`)

### 5.2 Widget Tests

- [ ] Test `LoginScreen` (form validation)
- [ ] Test `PrimaryButton` (loading state)
- [ ] Test `CustomTextField` (validation errors)
- [ ] Test `MemberCard` (render correctly)

### 5.3 Integration Tests

- [ ] Test Login → Home flow
- [ ] Test Search Alumni flow
- [ ] Test Add Product flow

---

## Phase 6: Polish & Deployment 🚢

### 6.1 UI Polish

- [ ] Add loading shimmers untuk semua list (Directory, Market, Loker)
- [ ] Add empty states untuk semua list
- [ ] Add error retry buttons
- [ ] Verify semua warna sesuai `docs/03_design_system.md`
- [ ] Verify semua font sizes sesuai design system

### 6.2 Performance

- [ ] Add `const` constructor di semua widget yang possible
- [ ] Optimize ListView dengan `builder` (jangan `ListView.children`)
- [ ] Add `RepaintBoundary` untuk complex widgets
- [ ] Test memory leaks dengan `flutter analyze`

### 6.3 Security

- [ ] Verify `.env` tidak di-commit
- [ ] Verify token disimpan di `flutter_secure_storage`
- [ ] Verify HTTPS enforced (production)

### 6.4 Deployment Preparation

- [ ] Set app name & icon (gunakan `flutter_launcher_icons`)
- [ ] Set bundle ID: `com.ikasmansara.app`
- [ ] Build APK: `flutter build apk --release`
- [ ] Test APK di real device

---

## Progress Tracker

**Total Tasks**: ~80  
**Completed**: 0  
**In Progress**: 0  
**Blocked**: 0

**Current Sprint**: Phase 1 (Environment Setup)  
**Next Milestone**: Phase 4.2 (Login Feature)

---

> [!IMPORTANT] > **Setiap task harus di-check baru lanjut ke task berikutnya.**  
> Jangan skip task karena bisa menyebabkan dependency error di tahap selanjutnya.
