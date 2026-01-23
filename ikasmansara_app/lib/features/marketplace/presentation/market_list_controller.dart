import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ikasmansara_app/features/marketplace/domain/entities/product_entity.dart';
import 'package:ikasmansara_app/features/marketplace/domain/usecases/get_products.dart';
import 'providers/marketplace_providers.dart';

class MarketListState extends Equatable {
  final AsyncValue<List<ProductEntity>> products;
  final String searchQuery;
  final String? selectedCategory;

  const MarketListState({
    required this.products,
    this.searchQuery = '',
    this.selectedCategory,
  });

  MarketListState copyWith({
    AsyncValue<List<ProductEntity>>? products,
    String? searchQuery,
    String? selectedCategory,
  }) {
    return MarketListState(
      products: products ?? this.products,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object?> get props => [products, searchQuery, selectedCategory];
}

class MarketListController extends StateNotifier<MarketListState> {
  final GetProducts _getProducts;

  MarketListController(this._getProducts)
    : super(const MarketListState(products: AsyncValue.loading())) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    // Only set loading if not already loading? Or always?
    // Usually purely refreshing, we might keep data.
    // For now, strict:
    state = state.copyWith(products: const AsyncValue.loading());
    try {
      final products = await _getProducts(
        category: state.selectedCategory,
        query: state.searchQuery,
      );
      state = state.copyWith(products: AsyncValue.data(products));
    } catch (e, st) {
      state = state.copyWith(products: AsyncValue.error(e, st));
    }
  }

  void search(String query) {
    if (state.searchQuery == query) return;
    state = state.copyWith(searchQuery: query);
    loadProducts();
  }

  void setCategory(String? category) {
    final newCategory = (category == 'Semua') ? null : category;

    if (state.selectedCategory == newCategory) return;

    // Reset state with new category
    state = MarketListState(
      products: const AsyncValue.loading(),
      searchQuery: state.searchQuery,
      selectedCategory: newCategory,
    );

    _loadProductsInternal();
  }

  Future<void> _loadProductsInternal() async {
    try {
      final products = await _getProducts(
        category: state.selectedCategory,
        query: state.searchQuery,
      );
      state = state.copyWith(products: AsyncValue.data(products));
    } catch (e, st) {
      state = state.copyWith(products: AsyncValue.error(e, st));
    }
  }
}

final marketListControllerProvider =
    StateNotifierProvider.autoDispose<MarketListController, MarketListState>((
      ref,
    ) {
      final getProducts = ref.watch(getProductsProvider);
      return MarketListController(getProducts);
    });
