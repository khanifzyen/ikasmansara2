# 03. Design System & UI/UX Guidelines

Dokumen ini berisi spesifikasi desain **Pixel-Perfect** berdasarkan analisis prototype `lofi` (HTML/CSS).
Semua implementasi UI di Flutter **WAJIB** mengikuti panduan ini.

## 1. Identitas Visual

### 🎨 Color Palette
Menggunakan kombinasi warna "Eco-Friendly but Professional".

| Token | Hex Code | Usage |
| :--- | :--- | :--- |
| **Primary** | `#006A4E` | Emerald Green. Brand identity, Buttons, Active text, Navbar Active. |
| **Primary Dark** | `#004D38` | Button Hover/Active state, Gradient starts. |
| **Secondary** | `#F9A825` | Golden Yellow. Accents, FAB, Price text, Badges. |
| **Background** | `#F9FAFB` | Light Grey (Tailwind Gray-50). Main scaffold background. |
| **Surface** | `#FFFFFF` | White. Cards, Modals, Navbar background. |
| **Text Dark** | `#1F2937` | Gray 900. Headers, Main Titles. |
| **Text Grey** | `#6B7280` | Gray 500. Subtitles, Meta info, Placeholders. |
| **Error** | `#EF4444` | Red. Logout button, Error states, Urgent Badges. |

### 🔠 Typography
Menggunakan **Google Fonts**:
*   **Headings**: `Poppins` (Weights: 500, 600, 700)
*   **Body**: `Inter` (Weights: 300, 400, 500, 600)

| Style Name | Font Family | Size | Weight | Usage |
| :--- | :--- | :--- | :--- | :--- |
| **H1** | Poppins | `28px` | Bold (700) | Login Welcome, Hero Titles. |
| **H2** | Poppins | `20px` | SemiBold (600) | Profile Name, Feature Headers. |
| **H3** | Poppins | `18px` | Medium (500) | Page Titles (AppBar), Section Headers. |
| **H4** | Inter | `16px` | SemiBold (600) | Button Text, Card Titles. |
| **Body Large** | Inter | `14px` | Regular (400) | Main Content, Inputs. |
| **Body Small** | Inter | `12px` | Regular (400) | Meta info, Chips, Sub-labels. |
| **Caption** | Inter | `10px` | Medium (500) | Navigation Labels, Badges. |

---

## 2. Core UI Variables

### 📐 Spacing & Radius
*   **Card Radius**: `16px` (Modern Soft Round).
*   **Input Radius**: `12px`.
*   **Button Radius**: `12px` or `16px`.
*   **Chip Radius**: `20px` (Fully Rounded).
*   **Modal Radius**: `24px` (Top-Left, Top-Right).
*   **Module Padding**: `24px` (Horizontal standard margin).
*   **Gap Standard**: `16px` (Between vertical items).

### 🌑 Shadows (Elevation)
*   **Soft Shadow**: `0 4px 20px rgba(0, 0, 0, 0.05)` (Hero Elements).
*   **Card Shadow**: `0 2px 8px rgba(0, 0, 0, 0.04)` (List Items).
*   **FAB Shadow**: `0 4px 12px rgba(249, 168, 37, 0.4)` (Colored Shadow).

---

## 3. Komponen Utama (Atomic Widgets)

### 🔘 Buttons
1.  **Primary Button**:
    *   H: `56px` (Padding V: `16px`).
    *   Color: `Primary` (`#006A4E`).
    *   Text: `white`, `16px`, `SemiBold`.
    *   Radius: `12px`.
2.  **Outline Button**:
    *   Border: `2px solid Primary`.
    *   Color: `transparent`.
    *   Text: `Primary`.
3.  **Floating Action Button (FAB)**:
    *   Size: `56x56px`.
    *   Color: `Secondary` (`#F9A825`).
    *   Icon: White `24px`.
    *   Position: Bottom-Right (`20px`).

### 📝 Input Fields
*   **Background**: `#F9FAFB` (Gray-50).
*   **Border**: `1px solid #E5E7EB` (Gray-200). Focus: `Primary`.
*   **Height**: `50-52px`.
*   **Icon**: Prefix Icon required for Search/Auth (Color: `#9CA3AF`).

### 🗂 Cards
1.  **Standard List Card** (e.g., Loker, Forum):
    *   Padding: `16px`.
    *   Bg: `White`.
    *   Shadow: `Card Shadow`.
    *   Content: Header (Avatar/Logo) + Title + Meta + Footer.
2.  **Grid Card** (e.g., Market):
    *   Image Height: `140px` (Cover).
    *   Content Padding: `10px`.
3.  **Campaign Card** (Donasi):
    *   Includes `LinearProgressIndicator` (Height `8px`, Radius `10px`).
    *   Color: Track `#E5E7EB`, Value `Secondary`.

### 🧭 Navigation
1.  **Bottom Navigation Bar**:
    *   Height: `~70px-80px` (Safe Area included).
    *   Bg: `White` with Top Shadow.
    *   Items: Icon (`24px`) + Label (`10px`).
    *   Active: Icon filled/stroke `Primary`.
    *   Inactive: `#9CA3AF`.
    *   **Menu Lainnya**: Triggers `Side Drawer` / `Modal`.
2.  **Tab Chips** (Filter):
    *   Container: Horizontal Scroll.
    *   Item: Padding `8px 16px`.
    *   Active: Bg `#EEFBF6` (Primary Light), Text `Primary`.
    *   Inactive: Bg `#F3F4F6`, Text `Text Grey`.

### 🖼️ Icons
Gunakan **Lucide Icons** (Flutter package: `lucide_icons`) karena style `lofi` menggunakan SVG `stroke-width=2` yang bersih.
*   `Home` -> `Home`
*   `Search` -> `Search`
*   `Loker` -> `Briefcase`
*   `Donasi` -> `Heart` / `HandHeart`
*   `Profile` -> `User`
*   `Menu` -> `Menu` / `MoreHorizontal`
