# Admin Panel Implementation Plan

## Goal
Rewrite the existing `lofi-admin` prototype (HTML/CSS/JS) into a production-ready **Single Page Application (SPA)** using **Vue 3 + Vite**. The design and UX will strictly reference `lofi-admin` but implemented with a scalable architecture.

## Architecture & Tech Stack

*   **Framework**: Vue 3 (Composition API)
*   **Build Tool**: Vite
*   **Language**: JavaScript (ES Modules)
*   **Routing**: Vue Router
*   **State Management**: Pinia (for Auth & Global Settings)
*   **Backend Integration**: PocketBase JS SDK
*   **Styling**: 
    *   Base: CSS Variables from `lofi-admin/style.css` (migrated to global CSS).
    *   Optimization: Scoped CSS per component or utility classes.
*   **Icons**: Copy SVG/Emoji or use a lightweight library (e.g., Lucide Vue / Heroicons) matching `lofi-admin` aesthetics.

## Folder Structure

```text
/admin-panel/
├── public/                 # Static assets (favicons, robots.txt)
├── src/
│   ├── assets/             
│   │   ├── css/            # Global styles (base.css, variables.css)
│   │   └── images/         
│   ├── components/         # Reusable UI Components
│   │   ├── common/         # Buttons, Cards, Badges, Modals
│   │   ├── layout/         # Sidebar, Header, MobileNav
│   │   └── dashboard/      # StatsCard, RecentActivity
│   ├── views/              # Page Components (mapped to routes)
│   │   ├── Dashboard.vue
│   │   ├── Events/
│   │   │   ├── EventList.vue
│   │   │   └── EventDetail.vue
│   │   ├── Finance/        # Donations & Transactions
│   │   └── Users/
│   ├── router/             # Vue Router Configuration
│   ├── stores/             # Pinia Stores (auth.js, ui.js)
│   ├── services/           # API wrapper (pocketbase.js)
│   ├── utils/              # Formatters (currency, date)
│   ├── App.vue             # Root Component
│   └── main.js             # Entry Point
├── index.html              
├── vite.config.js
└── package.json
```

## Migration Strategy (Phase by Phase)

### Phase 1: Setup & Foundation
1.  Initialize Vite Project `admin-panel` in root.
2.  Install dependencies: `vue`, `vue-router`, `pinia`, `pocketbase`.
3.  Migrate `style.css` variables and base styles to `src/assets/css/main.css`.
4.  Setup `App.vue` with a Layout System (Sidebar + Content Area).

### Phase 2: Core Components & Dashboard
1.  **Layout Components**:
    *   `Sidebar.vue`: Desktop navigation.
    *   `Header.vue`: Top bar with breadcrumbs/title.
    *   `MobileNav.vue`: Bottom navigation for mobile.
2.  **Dashboard View (`index.html` equivalent)**:
    *   `StatsCard.vue`: Reusable component for the top stats grid.
    *   `RecentActivity.vue`: List view for dashboard.

### Phase 3: Feature Implementation (Detailed)

#### A. Events (`event-dashboard.html`, `event-form.html`, `event-wizard.html`)
*   **Views**:
    *   `EventList.vue`: Grid/List view of events.
    *   `EventDetail.vue`: Dashboard view for a specific event (Stats, Participants Tab, Finance Tab).
    *   `EventForm.vue`: Create/Edit event page.
    *   `EventWizard.vue`: Complex multi-step wizard for creating new events.
*   **Key Components**:
    *   `ParticipantTable.vue`: Sortable table with "Manual Booking" & "Status Update" modals.
    *   `ScannerModal.vue`: QR Code scanner integration (html5-qrcode).
    *   `FinanceSummary.vue`: Income/Expense accordion lists.
    *   `SubeventList.vue` & `SponsorList.vue`.
*   **Data Integration**: `events`, `event_bookings`, `event_tickets`, `event_accounts`.

#### B. Finance & Donations (`donations.html`, `donations-detail.html`, `donation-transactions.html`)
*   **Views**:
    *   `DonationDashboard.vue`: Overview stats (Total, Spending, Balance) and recent activity.
    *   `DonationList.vue`: List of donation programs/campaigns.
    *   `DonationDetail.vue`: Detail view of a specific campaign.
    *   `TransactionList.vue`: Global list of all financial transactions (Income/Expense).
*   **Components**:
    *   `DonationProgressCard.vue`: Visual progress bar for campaigns.
    *   `TransactionTable.vue`: Reusable table for financial logs.
*   **Data Integration**: `event_donations`, `event_financial_transactions`.

#### C. Users (`users.html`, `user-detail.html`, `user-form.html`)
*   **Views**:
    *   `UserList.vue`: Searchable list of users.
    *   `UserDetail.vue`: Profile view, history of bookings/donations.
    *   `UserForm.vue`: Add/Edit user (Admin override).
*   **Components**:
    *   `UserCard.vue`: Card view for mobile/grid.
    *   `VerificationBadge.vue`: Visual indicator for alumni verification status.
*   **Data Integration**: `users`, `alumni_verifications`.

#### D. Content Management (News, Forum, Locker, Market, Memory)
*   **News (`news.html`, `news-form.html`)**:
    *   CRUD Views for News/Articles.
    *   Rich Text Editor component integration.
*   **Forum (`forum.html`, `forum-detail.html`)**:
    *   Moderation view for forum threads and replies.
    *   Ability to Pin/Delete/Hide threads.
*   **Loker (`loker.html`, `loker-detail.html`)**:
    *   Job posting approval dashboard.
    *   Job detail view.
*   **Market (`market.html`, `market-detail.html`)**:
    *   Product listing moderation.
    *   Product detail view.
*   **Memory (`memory.html`)**:
    *   Gallery management (Album organization).
    *   Photo upload/delete.

### Phase 4: Integration & Security
1.  **Auth Store (Pinia)**:
    *   Implement `login`, `logout` actions using `pb.authStore`.
    *   Persist auth state to `localStorage`.
    *   Role-based checks (`isAdmin`).
2.  **Navigation Guards**:
    *   Global `router.beforeEach` to redirect unauthenticated users to Login.
3.  **API Services**:
    *   Create dedicated service files (e.g., `services/eventService.js`, `services/userService.js`) to decouple API logic from UI components.
4.  **Error Handling**:
    *   Global toast notification for API errors.

### Phase 5: Production Polish
1.  **Performance**: Enable lazy loading for route components.
2.  **PWA**: Add manifest and service worker for "Install to Home Screen" capability.
3.  **Build**: Optimize Vite build configuration for production deployment.

## Detailed Task Checklist

### 1. Setup & Config
- [ ] Initialize Vite Project (`npm create vite@latest admin-panel -- --template vue`)
- [ ] Install dependencies (`vue-router`, `pinia`, `pocketbase`, `date-fns`)
- [ ] Setup `vite.config.js` (alias `@` to `/src`)
- [ ] Configure TailwindCSS (Optional) or setup CSS Variables from `lofi-admin`

### 2. Layout Framework
- [ ] Create `MainLayout.vue`
- [ ] Create `Sidebar.vue` (Desktop)
- [ ] Create `Header.vue` (Mobile toggle + Page Title)
- [ ] Create `MobileNav.vue` (Sticky bottom)
- [ ] Implement responsive behavior (Sidebar toggle)

### 3. Dashboard Module
- [ ] `DashboardView.vue`: Fetch counts for Users, Events, Donations, News.
- [ ] `StatsCard.vue`: Reusable component.
- [ ] `ActivityList.vue`: Fetch from `activity_logs` collection.

### 4. Event Module
- [ ] **Event List**: Table/Grid of events with status indicators.
- [ ] **Event Form**: Create/Edit event basic info.
- [ ] **Event Wizard**: Step-by-step creation (Info -> Tickets -> Subevent).
- [ ] **Event Detail Dashboard**:
    - [ ] Stats Header (Participants, Income, Expense, Balance).
    - [ ] **Participant Tab**:
        - [ ] Table with filters (Paid, Pending).
        - [ ] Connection to `event_bookings`.
        - [ ] **Manual Booking Modal**: Form to `create` record in `event_bookings`.
        - [ ] **Row Actions**: View Detail, Approve/Reject.
    - [ ] **Finance Tab**:
        - [ ] Income List (from `event_financial_transactions`).
        - [ ] Expense List (CRUD `event_financial_transactions`).
    - [ ] **Scanner Modal**: Integration with `html5-qrcode`.

### 5. Finance Module
- [ ] **Donation Dashboard**: Charts/Graphs of donation trends.
- [ ] **Donation List**: CRUD `event_donations` (Programs).
- [ ] **Transaction Log**: Global view of all financial movement.

### 6. User Module
- [ ] **User Table**: List users with Pagination.
- [ ] **User Detail**: View profile, assigned roles.
- [ ] **Verification Queue**: Special filter for users waiting for alignment verification.

### 7. Content Modules
- [ ] **News**: CRUD `posts`.
- [ ] **Forum**: List threads (`forum_threads`), moderator actions (Delete/Ban).
- [ ] **Jobs (Loker)**: Approval list for `job_postings`.
- [ ] **Market**: Product list (`market_products`).
- [ ] **Gallery**: Album & Photo management.

### 8. Authentication
- [ ] `LoginView.vue`: Email/Password form.
- [ ] Integration with PocketBase Admin Auth or User Auth (with admin role check).
