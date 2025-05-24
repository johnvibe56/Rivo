import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo/features/product_feed/domain/models/product_feed_state.dart';
import 'package:rivo/features/product_feed/domain/repositories/product_feed_repository.dart';
import 'package:rivo/features/product_feed/data/repositories/product_feed_repository_impl.dart';

class ProductFeedNotifier extends StateNotifier<ProductFeedState> {
  final ProductFeedRepository repository;

  ProductFeedNotifier({required this.repository}) : super(const ProductFeedState());

  Future<void> loadInitialProducts() async {
    if (state.isLoading || state.isLoadingMore) return;

    state = state.copyWith(
      status: ProductFeedStatus.loading,
      currentPage: 1,
      hasReachedEnd: false,
      errorMessage: null,
    );

    await _fetchProducts();
  }

  Future<void> loadMoreProducts() async {
    if (state.isLoading || state.isLoadingMore || state.hasReachedEnd) return;

    state = state.copyWith(
      status: ProductFeedStatus.loadingMore,
      errorMessage: null,
    );

    await _fetchProducts();
  }

  Future<void> refresh() async {
    if (state.isLoading || state.isLoadingMore) return;

    state = state.copyWith(
      status: ProductFeedStatus.loading,
      currentPage: 1,
      hasReachedEnd: false,
      errorMessage: null,
    );

    await _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final result = await repository.getProducts(
        page: state.currentPage,
        limit: state.itemsPerPage,
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            status: ProductFeedStatus.failure,
            errorMessage: failure.message,
          );
        },
        (newProducts) {
          final allProducts = state.currentPage == 1
              ? newProducts
              : [...state.products, ...newProducts];

          state = state.copyWith(
            status: ProductFeedStatus.success,
            products: allProducts,
            currentPage: state.currentPage + 1,
            hasReachedEnd: newProducts.length < state.itemsPerPage,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: ProductFeedStatus.failure,
        errorMessage: 'An unexpected error occurred',
      );
    }
  }
}

final productFeedNotifierProvider =
    StateNotifierProvider<ProductFeedNotifier, ProductFeedState>((ref) {
  final repository = ProductFeedRepositoryImpl();
  return ProductFeedNotifier(repository: repository)..loadInitialProducts();
});
