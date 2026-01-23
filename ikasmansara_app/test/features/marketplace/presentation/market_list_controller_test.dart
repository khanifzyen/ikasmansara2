import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikasmansara_app/features/marketplace/domain/entities/product_entity.dart';
import 'package:ikasmansara_app/features/marketplace/domain/usecases/get_products.dart';
import 'package:ikasmansara_app/features/marketplace/presentation/market_list_controller.dart';
import 'package:ikasmansara_app/features/marketplace/presentation/providers/marketplace_providers.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'market_list_controller_test.mocks.dart';

@GenerateNiceMocks([MockSpec<GetProducts>()])
void main() {
  late MockGetProducts mockGetProducts;
  late ProviderContainer container;

  setUp(() {
    mockGetProducts = MockGetProducts();
    container = ProviderContainer(
      overrides: [getProductsProvider.overrideWithValue(mockGetProducts)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('Initial state should be loading and trigger loadProducts', () async {
    // Arrange
    when(
      mockGetProducts.call(category: null, query: ''),
    ).thenAnswer((_) async => []);

    // Act
    // final controller = container.read(marketListControllerProvider.notifier);
    final state = container.read(marketListControllerProvider);

    // Assert
    expect(state.products, const AsyncLoading<List<ProductEntity>>());

    // Verify initial load started
    verify(mockGetProducts.call(category: null, query: '')).called(1);

    // Manually trigger and await to ensure state settles
    await container.read(marketListControllerProvider.notifier).loadProducts();

    final currentState = container.read(marketListControllerProvider);
    expect(currentState.products, isA<AsyncData>());
    expect(currentState.products.value, isEmpty);
  });

  test('search should update query and trigger loadProducts', () async {
    // Arrange
    when(
      mockGetProducts.call(category: null, query: 'kuliner'),
    ).thenAnswer((_) async => []);

    final controller = container.read(marketListControllerProvider.notifier);

    // Act
    controller.search('kuliner');

    // Assert
    expect(container.read(marketListControllerProvider).searchQuery, 'kuliner');
    await Future.delayed(Duration.zero);
    verify(mockGetProducts.call(category: null, query: 'kuliner')).called(1);
  });

  test('setCategory should update category and trigger loadProducts', () async {
    // Arrange
    when(
      mockGetProducts.call(category: 'Makanan', query: ''),
    ).thenAnswer((_) async => []);

    final controller = container.read(marketListControllerProvider.notifier);

    // Act
    controller.setCategory('Makanan');

    // Assert
    expect(
      container.read(marketListControllerProvider).selectedCategory,
      'Makanan',
    );
    await Future.delayed(Duration.zero);
    verify(mockGetProducts.call(category: 'Makanan', query: '')).called(1);
  });
}
