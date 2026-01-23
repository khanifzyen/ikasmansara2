# 12. Riverpod Patterns & Best Practices

Dokumen ini mengajarkan **kapan pakai provider apa** dan **bagaimana implement common patterns** dengan Riverpod.

---

## 1. Riverpod Provider Types (Quick Reference)

| Provider Type           | Use Case                             | Example                  |
| :---------------------- | :----------------------------------- | :----------------------- |
| `Provider`              | Static/Constant Data                 | `configProvider`         |
| `StateProvider`         | Simple State (1 variable)            | `counterProvider`        |
| `FutureProvider`        | One-time Async Fetch (no mutation)   | `getUserProfileProvider` |
| `StreamProvider`        | Real-time Data (WebSocket, Firebase) | `chatMessagesProvider`   |
| `NotifierProvider`      | Mutable State + Logic (Complex)      | `authStateProvider`      |
| `AsyncNotifierProvider` | Async Mutable State (Most Common)    | `productListProvider`    |

---

## 2. Pattern 1: Simple Async Data Fetch

**Use Case**: Fetch data dari API sekali (misal: User Profile).

### Code Example:

```dart
@riverpod
class UserProfile extends _$UserProfile {
  @override
  Future<UserEntity> build() async {
    // Fetch dari repository
    final repo = ref.read(userRepositoryProvider);
    return await repo.getCurrentUserProfile();
  }

  // Method untuk refresh
  Future<void> refresh() async {
    state = const AsyncLoading();
    final repo = ref.read(userRepositoryProvider);
    state = await AsyncValue.guard(() => repo.getCurrentUserProfile());
  }
}
```

### UI Consumption:

```dart
final profileState = ref.watch(userProfileProvider);

profileState.when(
  data: (user) => Text('Hello, ${user.name}'),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);
```

---

## 3. Pattern 2: Pagination (Infinite Scroll)

**Use Case**: List produk/alumni dengan load more.

### State Model:

```dart
class PaginatedState<T> {
  final List<T> items;
  final bool hasMore;
  final bool isLoadingMore;

  PaginatedState({
    required this.items,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  PaginatedState<T> copyWith({List<T>? items, bool? hasMore, bool? isLoadingMore}) {
    return PaginatedState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
```

### Controller:

```dart
@riverpod
class ProductList extends _$ProductList {
  int _currentPage = 1;
  final int _perPage = 20;

  @override
  Future<PaginatedState<ProductEntity>> build() async {
    return await _fetchPage(1);
  }

  Future<PaginatedState<ProductEntity>> _fetchPage(int page) async {
    final repo = ref.read(productRepositoryProvider);
    final result = await repo.getProducts(page: page, perPage: _perPage);

    return PaginatedState(
      items: result.items,
      hasMore: result.totalItems > page * _perPage,
    );
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasMore || currentState.isLoadingMore) {
      return;
    }

    // Set loading more
    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    _currentPage++;
    final newPage = await _fetchPage(_currentPage);

    // Merge items
    state = AsyncValue.data(
      currentState.copyWith(
        items: [...currentState.items, ...newPage.items],
        hasMore: newPage.hasMore,
        isLoadingMore: false,
      ),
    );
  }
}
```

### UI (with ScrollController):

```dart
final _scrollController = ScrollController();

@override
void initState() {
  super.initState();
  _scrollController.addListener(_onScroll);
}

void _onScroll() {
  if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
    ref.read(productListProvider.notifier).loadMore();
  }
}
```

---

## 4. Pattern 3: Optimistic UI Update (Like Button)

**Use Case**: User like post, UI langsung update tanpa tunggu server response. Rollback jika gagal.

### Controller:

```dart
@riverpod
class ForumPost extends _$ForumPost {
  @override
  Future<PostEntity> build(String postId) async {
    final repo = ref.read(forumRepositoryProvider);
    return await repo.getPost(postId);
  }

  Future<void> toggleLike() async {
    final currentPost = state.value;
    if (currentPost == null) return;

    // 1. Optimistic Update
    final userId = ref.read(currentUserProvider).value?.id ?? '';
    final isLiked = currentPost.likedBy.contains(userId);

    final optimisticPost = currentPost.copyWith(
      likedBy: isLiked
          ? currentPost.likedBy.where((id) => id != userId).toList()
          : [...currentPost.likedBy, userId],
    );

    state = AsyncValue.data(optimisticPost);

    // 2. Call API
    try {
      final repo = ref.read(forumRepositoryProvider);
      await repo.toggleLike(currentPost.id, userId);
    } catch (e) {
      // 3. Rollback if error
      state = AsyncValue.data(currentPost);
      rethrow;
    }
  }
}
```

---

## 5. Pattern 4: Search with Debouncing

**Use Case**: Search bar yang memanggil API setelah user berhenti mengetik (500ms).

### Controller:

```dart
import 'dart:async';

@riverpod
class AlumniSearch extends _$AlumniSearch {
  Timer? _debounceTimer;

  @override
  Future<List<AlumniEntity>> build() async {
    return []; // Initial empty
  }

  void search(String query) {
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    state = const AsyncLoading();

    final repo = ref.read(directoryRepositoryProvider);
    final result = await AsyncValue.guard(() => repo.searchAlumni(query));

    state = result;
  }
}
```

### UI:

```dart
TextField(
  onChanged: (value) {
    ref.read(alumniSearchProvider.notifier).search(value);
  },
);
```

---

## 6. Pattern 5: Form State Management

**Use Case**: Multi-step form (Register Alumni 3 Step).

### State:

```dart
class RegisterFormState {
  final String email;
  final String password;
  final String name;
  final String angkatan;
  final int currentStep;

  RegisterFormState({
    this.email = '',
    this.password = '',
    this.name = '',
    this.angkatan = '',
    this.currentStep = 0,
  });

  RegisterFormState copyWith({...}) { /* implement */ }
}
```

### Controller:

```dart
@riverpod
class RegisterForm extends _$RegisterForm {
  @override
  RegisterFormState build() {
    return RegisterFormState();
  }

  void updateStep1(String email, String password) {
    state = state.copyWith(email: email, password: password, currentStep: 1);
  }

  void nextStep() {
    state = state.copyWith(currentStep: state.currentStep + 1);
  }

  Future<void> submitFinal() async {
    // Submit semua data
    final repo = ref.read(authRepositoryProvider);
    await repo.register(
      email: state.email,
      password: state.password,
      name: state.name,
      angkatan: state.angkatan,
    );
  }
}
```

---

## 7. Pattern 6: Dependent Providers (Auto-refetch)

**Use Case**: Product List bergantung pada Category filter.

```dart
@riverpod
class SelectedCategory extends _$SelectedCategory {
  @override
  String build() => 'Semua'; // Default

  void select(String category) {
    state = category;
  }
}

@riverpod
class ProductList extends _$ProductList {
  @override
  Future<List<ProductEntity>> build() async {
    // Watch category (auto-refetch jika category berubah)
    final category = ref.watch(selectedCategoryProvider);

    final repo = ref.read(productRepositoryProvider);
    return await repo.getProducts(category: category);
  }
}
```

**Effect**: Setiap kali `selectedCategoryProvider` berubah, `productListProvider` otomatis refetch.

---

## 8. Best Practices Checklist

Saat membuat Provider baru:

- [ ] Gunakan `AsyncNotifierProvider` untuk data async yang bisa berubah.
- [ ] Gunakan `FutureProvider` hanya untuk data read-only sekali fetch.
- [ ] Jangan pernah mutate state langsung. Selalu pakai `copyWith()`.
- [ ] Untuk list, buat `PaginatedState` wrapper.
- [ ] Untuk search, selalu pakai debouncing.
- [ ] Untuk optimistic update, simpan state lama untuk rollback.

---

> [!TIP] > **Code Gen is Your Friend**  
> Selalu pakai `@riverpod` annotation + `build_runner` untuk auto-generate provider. Jangan manual tulis `StateNotifierProvider`.
