# Gap Analysis: Admin Events Implementation vs Lofi Design

## 📊 Executive Summary

| Aspek | Status | Coverage |
|-------|--------|----------|
| **Halaman List Events** | ✅ Implemented | ~80% |
| **Event Detail/Dashboard** | ⚠️ Partial | ~20% |
| **Event Creation Wizard** | ❌ Missing | 0% |
| **Event Edit Form** | ❌ Missing | 0% |
| **Ticket Management** | ❌ Missing | 0% |
| **Participant Management** | ❌ Missing | 0% |
| **Financial Dashboard** | ❌ Missing | 0% |
| **Sub-Events Management** | ❌ Missing | 0% |
| **Sponsorship Management** | ❌ Missing | 0% |
| **Donation Integration** | ❌ Missing | 0% |

---

## 1. Halaman List Events (`admin_events_page.dart`)

### ✅ Sudah Diimplementasikan

| Fitur | Status | Notes |
|-------|--------|-------|
| Filter Chips | ✅ | Semua, Aktif, Upcoming, Past, Draft |
| List/Card View | ✅ | Menampilkan title, date, location, status badge |
| Refresh Button | ✅ | Di AppBar |
| Navigation ke Detail | ✅ | Tap card → detail page |
| Status Badge | ✅ | Color-coded (active, draft, completed) |
| Infinite Scroll | ❌ | Belum ada (perlu seperti users page) |

### ❌ Belum Diimplementasikan

| Fitur Lofi | Deskripsi | Priority |
|------------|-----------|----------|
| FAB Tambah Event | Floating button → wizard | 🔴 High |
| Search Bar | Cari event by title | 🟡 Medium |
| Date Range Filter | Filter by tanggal | 🟡 Medium |
| Desktop Table View | Tabel lengkap untuk desktop | 🟢 Low |

---

## 2. Event Detail Page (`admin_event_detail_page.dart`)

### ✅ Sudah Diimplementasikan

| Fitur | Status | Notes |
|-------|--------|-------|
| Basic Info Display | ✅ | Title, date, time, location, description |
| Banner Image | ✅ | Cached network image |
| Status Toggle | ✅ | Active ↔ Draft |
| Delete Event | ✅ | Dengan konfirmasi dialog |
| Back Navigation | ✅ | AppBar leading |

### ❌ Belum Diimplementasikan (Lofi: Event Dashboard)

Lofi design memiliki **Event Dashboard** yang jauh lebih komprehensif dengan **6 tabs**:

#### Tab 0: Deskripsi (Edit Mode) ✨ NEW
| Fitur | Deskripsi | Priority |
|-------|-----------|----------|
| Edit Judul Event | Input field untuk judul | 🔴 High |
| Edit Tanggal & Waktu | Date/time picker | 🔴 High |
| Edit Lokasi | Input field untuk lokasi | 🔴 High |
| Edit Deskripsi | **HTML Editor (Quill)** dengan formatting | 🔴 High |
| Upload Banner | File upload untuk banner event | 🔴 High |
| Status Event | Dropdown (draft/active/completed) | 🔴 High |
| Simpan Perubahan | Update event data | 🔴 High |
| Hapus Event | Delete dengan konfirmasi | 🟡 Medium |

#### Tab 1: Peserta (Participants)
| Fitur | Deskripsi | Priority |
|-------|-----------|----------|
| Stats Cards | Pendaftar, Pemasukan, Pengeluaran, Saldo | 🔴 High |
| Participant Table | List peserta dengan booking ID, nama, tiket, status | 🔴 High |
| Payment Status | Lunas/Pending badge | 🔴 High |
| Proof Upload | View/upload bukti bayar | 🟡 Medium |
| Manual Booking | Modal tambah peserta manual | 🟡 Medium |
| Export Data | Export ke Excel/CSV | 🟢 Low |

#### Tab 2: Keuangan (Financial)
| Fitur | Deskripsi | Priority |
|-------|-----------|----------|
| Summary Cards | Total pemasukan, pengeluaran, saldo | 🔴 High |
| Income Accordion | Breakdown: Peserta, Sponsor, Donasi | 🔴 High |
| Expense Accordion | List pengeluaran dengan kategori | 🔴 High |
| Add Expense | Form tambah pengeluaran | 🟡 Medium |
| Expense Proof | Upload bukti pengeluaran | 🟡 Medium |

#### Tab 3: Sub-Events
| Fitur | Deskripsi | Priority |
|-------|-----------|----------|
| Sub-Event List | Nama, kuota, lokasi, registered count | 🟡 Medium |
| Registration Management | Kelola pendaftar per sub-event | 🟡 Medium |
| Edit Settings | Link ke edit sub-event | 🟡 Medium |

#### Tab 4: Sponsor
| Fitur | Deskripsi | Priority |
|-------|-----------|----------|
| Total Sponsor Amount | Summary dana sponsor | 🟡 Medium |
| Sponsor List | Logo, nama, tier, nominal | 🟡 Medium |
| Add Sponsor | Form tambah sponsor | 🟡 Medium |
| Edit Sponsorship Tiers | Kelola paket sponsor | 🟡 Medium |

#### Tab 5: Donasi
| Fitur | Deskripsi | Priority |
|-------|-----------|----------|
| Progress Card | Amount terkumpul vs target | 🟡 Medium |
| Progress Bar | Visual progress | 🟡 Medium |
| Donor List | List donatur terbaru | 🟡 Medium |
| Edit Donation Settings | Kelola pengaturan donasi | 🟡 Medium |

---

## 3. Event Creation Wizard (`event-wizard.html`)

### ❌ Belum Ada Sama Sekali

Lofi design memiliki **5-Step Wizard** untuk create event:

| Step | Nama | Fitur | Priority |
|------|------|-------|----------|
| 1 | Konfigurasi | Setup booking ID format, ticket ID format | 🔴 High |
| 2 | Info Dasar | Title, date, time, location, description, banner | 🔴 High |
| 3 | Tiket | Dynamic ticket types, harga, kuota, opsi (ukuran kaos) | 🔴 High |
| 4 | Fitur | Toggle sub-events, sponsorship, open donasi | 🟡 Medium |
| 5 | Review | Preview & publish/draft/schedule | 🟡 Medium |

**Komponen yang Dibutuhkan:**
- Stepper UI (progress indicator)
- Form validation per step
- Data persistence antar step
- Preview mode
- Draft save functionality

---

## 4. Event Edit Form (`event-form.html`)

### ❌ Belum Ada Sama Sekali

Lofi design memiliki **Tabbed Edit Form**:

| Tab | Konten | Priority |
|-----|--------|----------|
| Info Dasar | Edit title, date, time, location, description, banner, status | 🔴 High |
| Tiket | Manage ticket types, harga, kuota, includes, opsi | 🔴 High |
| Sub-Events | Dynamic list kegiatan pendukung | 🟡 Medium |
| Sponsor & Donasi | Tier sponsorship + donation settings | 🟡 Medium |

---

## 5. Database Schema Coverage

### ✅ Sudah Ada di Database (dari SKEMA.md)

| Collection | Fields | Status |
|------------|--------|--------|
| `events` | title, code, date, time, location, description, banner, status | ✅ Complete |
| `events` | enable_sponsorship, enable_donation, donation_target | ✅ Complete |
| `events` | booking_id_format, ticket_id_format, counters | ✅ Complete |
| `event_tickets` | event, name, price, quota, sold, includes, image | ✅ Complete |
| `event_ticket_options` | ticket, name, choices (JSON) | ✅ Complete |
| `event_sub_events` | event, name, description, quota, registered, location | ✅ Complete |
| `event_sponsors` | event, tier_name, price, benefits, logo, company_name | ✅ Complete |
| `event_bookings` | booking_id, event, user, metadata, total_price, payment_status | ✅ Complete |
| `event_booking_tickets` | booking, ticket, quantity, options, subtotal | ✅ Complete |
| `event_sub_event_registrations` | booking_ticket, sub_event | ✅ Complete |

**Kesimpulan:** Database schema sudah lengkap dan siap digunakan!

### ❌ Belum Ada Data Source/Repository untuk:

| Entity | Collections | Priority |
|--------|-------------|----------|
| Tickets | event_tickets, event_ticket_options | 🔴 High |
| Sub-Events | event_sub_events, event_sub_event_registrations | 🟡 Medium |
| Sponsors | event_sponsors | 🟡 Medium |
| Bookings | event_bookings, event_booking_tickets | 🔴 High |
| Donations | donation_transactions (filter by event) | 🟡 Medium |

---

## 6. Prioritas Implementasi

### 🔴 Phase 1: Core Event Management (High Priority)

1. **Event Creation Wizard** (Step 1-3)
   - [ ] Konfigurasi ID format
   - [ ] Info dasar event
   - [ ] Ticket management (CRUD tickets & options)

2. **Event Edit Form** (Tab 1-2)
   - [ ] Edit info dasar
   - [ ] Edit tickets

3. **Event Dashboard - Tab Peserta**
   - [ ] Stats cards (pendaftar, pemasukan)
   - [ ] Participant table
   - [ ] Payment status management

### 🟡 Phase 2: Advanced Features (Medium Priority)

4. **Event Dashboard - Tab Keuangan**
   - [ ] Financial summary
   - [ ] Income/expense tracking

5. **Wizard Step 4 & Event Edit Tab 3-4**
   - [ ] Sub-events management
   - [ ] Sponsorship management
   - [ ] Donation integration

6. **Additional Features**
   - [ ] Manual booking
   - [ ] QR code check-in
   - [ ] Export data

### 🟢 Phase 3: Polish (Low Priority)

7. **UX Improvements**
   - [ ] Search & advanced filters
   - [ ] Desktop table view
   - [ ] Drag-and-drop reordering
   - [ ] Bulk actions

---

## 7. Rekomendasi Arsitektur

### Data Layer
```
features/admin/events/
├── data/
│   ├── datasources/
│   │   ├── admin_events_remote_data_source.dart ✅ (existing)
│   │   ├── admin_tickets_remote_data_source.dart ❌ (new)
│   │   ├── admin_bookings_remote_data_source.dart ❌ (new)
│   │   ├── admin_sub_events_remote_data_source.dart ❌ (new)
│   │   └── admin_sponsors_remote_data_source.dart ❌ (new)
│   └── repositories/ (implement corresponding repos)
```

### Presentation Layer
```
features/admin/events/presentation/
├── pages/
│   ├── admin_events_page.dart ✅ (existing)
│   ├── admin_event_detail_page.dart ✅ (existing, needs major refactor)
│   ├── admin_event_wizard_page.dart ❌ (new - 5 steps)
│   ├── admin_event_edit_page.dart ❌ (new - tabbed form)
│   └── admin_event_dashboard_page.dart ❌ (new - 5 tabs)
├── widgets/
│   ├── event_wizard_step_*.dart ❌ (5 step widgets)
│   ├── event_dashboard_tab_*.dart ❌ (5 tab widgets)
│   ├── ticket_form_widget.dart ❌ (reusable ticket form)
│   ├── participant_table_widget.dart ❌
│   └── financial_summary_widget.dart ❌
└── bloc/
    ├── admin_events_bloc.dart ✅ (existing)
    ├── event_wizard_bloc.dart ❌ (new)
    ├── event_tickets_bloc.dart ❌ (new)
    └── event_bookings_bloc.dart ❌ (new)
```

---

## 8. Estimasi Effort

| Phase | Tasks | Estimated Time |
|-------|-------|----------------|
| Phase 1 | Wizard (3 steps) + Edit Form (2 tabs) + Dashboard (1 tab) | 5-7 days |
| Phase 2 | Dashboard (4 tabs) + Advanced features | 4-5 days |
| Phase 3 | Polish & UX improvements | 2-3 days |
| **Total** | | **11-15 days** |

---

## 9. Next Steps

1. **Review & Approval**: User review gap analysis ini
2. **Create Implementation Plan**: Detail technical plan untuk Phase 1
3. **Setup Data Layer**: Buat data sources & repositories untuk tickets, bookings
4. **Build Wizard**: Implementasi event creation wizard (5 steps)
5. **Build Dashboard**: Refactor detail page menjadi comprehensive dashboard
