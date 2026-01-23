# 08. Lofi HTML to Flutter Widget Mapping

Dokumen ini adalah panduan teknis untuk menerjemahkan setiap elemen HTML/CSS dari prototype `lofi` menjadi kode Flutter yang **Pixel-Perfect**.

## 1. Global Layout & Structure

| HTML / CSS Class | Flutter Widget Equivalent | Properti Kunci |
| :--- | :--- | :--- |
| `body` (background) | `Scaffold` | `backgroundColor: AppColors.background` (`#F9FAFB`) |
| `.app-container` | `SafeArea` + `ConstrainedBox` | `maxWidth: 480` (If web), else default mobile view. |
| `.h-scroll` | `SingleChildScrollView` | `scrollDirection: Axis.horizontal`, `padding: EdgeInsets.symmetric(horizontal: 24)`. |
| `.fade-in` | `Animate` (flutter_animate) | `.fadeIn(duration: 500ms)`. |
| `.section-header` | `Row` | `mainAxisAlignment: MainAxisAlignment.spaceBetween`. |
| `.bottom-nav` | `Container` + `Row` | `decoration: BoxDecoration(color: Colors.white, boxShadow: [...])`. **Jangan** gunakan `BottomNavigationBar` native jika ingin custom style persis `lofi`. Gunakan Custom Widget. |

---

## 2. Component Mapping

### A. E-KTA Card (`home.html`, `ekta.html`)
*   **HTML**: `.member-card` / `.kta-card`
*   **Flutter Tree**:
    ```dart
    Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF006A4E), Color(0xFF004D38)], // Primary to Dark
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Color(0xFF006A4E).withOpacity(0.2), blurRadius: 20, offset: Offset(0, 10))
        ],
      ),
      child: Stack(
        children: [
           Positioned(right: -20, bottom: -20, child: Icon(Icons.school, size: 100, color: Colors.white10)), // Pattern
           Column(...) // Content
        ]
      )
    )
    ```

### B. Menu Grid (`home.html`)
*   **HTML**: `.menu-grid`, `.menu-icon`
*   **Flutter Tree**:
    ```dart
    GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        Column(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: AppColors.bgGrey, borderRadius: BorderRadius.circular(16)),
              child: Icon(LucideIcons.wallet, color: AppColors.primary),
            ),
            Text("Donasi", style: AppTextIds.caption)
          ]
        )
      ]
    )
    ```

### C. Donation Progress (`donation.html`)
*   **HTML**: `.progress-track`, `.progress-value`
*   **Flutter Tree**:
    ```dart
    Stack(
      children: [
        Container(height: 8, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10))),
        FractionallySizedBox(
          widthFactor: 0.7, // 70%
          child: Container(height: 8, decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(10))),
        )
      ]
    )
    ```
    *Catatan: Jangan pakai `LinearProgressIndicator` bawaan jika ingin radius bulat sempurna di kedua layer.*

### D. Input Fields (`login.html`, `register.html`)
*   **HTML**: `.input-group`, `input`
*   **Flutter Tree**:
    ```dart
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Label", style: ...),
        SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.bgGrey, // #F9FAFB
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200])),
            enabledBorder: ...,
            focusedBorder: ...,
            contentPadding: EdgeInsets.all(14),
          )
        )
      ]
    )
    ```

### E. Steps Registration (`register-alumni.html`)
*   **HTML**: `.progress-bar`, `.form-step`
*   **Flutter**:
    *   State Management: `ref.watch(registerStepProvider)`
    *   **Animation**: Gunakan `AnimatedSwitcher` untuk transisi antar step (`fadeIn` / `slideX`).
    *   **Radio Group**: Gunakan `InkWell` + `Container` dengan border kondisional.
        ```dart
        Container(
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFFEEFBF6) : Colors.transparent,
            border: Border.all(color: isSelected ? AppColors.primary : Colors.grey[300]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text("Swasta"),
        )
        ```

---

## 3. Asset & Icon Strategy

*   **Images**: Gunakan `CachedNetworkImage` untuk semua URL gambar (Unsplash/UI Avatars) agar performa smooth seperti HTML native.
*   **Icons**: Gunakan package `lucide_icons` untuk meniru style SVG stroke tipis di `lofi`.
    *   `🔍` -> `LucideIcons.search`
    *   `🎓` -> `LucideIcons.graduationCap`
    *   `💼` -> `LucideIcons.briefcase`
    *   `🛍️` -> `LucideIcons.shoppingBag`

## 4. Interaction Specs
*   **Active State**: Tombol `ScaleButton` (scale 0.98 saat ditekan) untuk meniru CSS `.btn-primary:active { transform: scale(0.98); }`.
*   **Shimmer Loading**: Semua data async (List Alumni, Produk) harus menggunakan Shimmer Effect `baseColor: Colors.grey[300]` sebelum data muncul, jangan pakai `CircularProgressIndicator` biasa agar terlihat premium.
