import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rivo/features/products/domain/models/product_model.dart';
import 'package:rivo/features/products/presentation/providers/delete_product_provider.dart';
import 'package:rivo/features/products/domain/repositories/product_repository.dart';
import 'package:rivo/features/products/presentation/providers/product_repository_provider.dart';

// Note: The productRepositoryProvider is now defined in product_repository_provider.dart
// and includes the required NetworkInfo dependency.

// State Notifier for managing product list state
class ProductListNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final ProductRepository _repository;
  
  ProductListNotifier(this._repository) : super(const AsyncValue.loading()) {
    getProducts();
  }

  int _currentPage = 0;
  bool _hasReachedMax = false;
  bool _isLoading = false;
  static const int _itemsPerPage = 10;

  Future<void> getProducts() async {
    if (_isLoading) return;
    
    try {
      _isLoading = true;
      state = const AsyncValue.loading();
      
      _currentPage = 0;
      _hasReachedMax = false;
      
      final result = await _repository.getProducts(page: 1, limit: _itemsPerPage);
      
      return result.fold(
        (failure) {
          state = AsyncValue<List<Product>>.error(failure, StackTrace.current);
          return Future<void>.error(failure);
        },
        (products) {
          _currentPage = 1;
          _hasReachedMax = products.length < _itemsPerPage;
          state = AsyncValue.data(products);
          return Future<void>.value();
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue<List<Product>>.error(e, stackTrace);
      return Future.error(e, stackTrace);
    } finally {
      _isLoading = false;
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || _hasReachedMax) return;
    _isLoading = true;

    try {
      final currentProducts = state.valueOrNull ?? [];
      
      final result = await _repository.getProducts(
        page: _currentPage + 1,
        limit: _itemsPerPage,
      );

      await result.fold(
        (failure) => Future<void>.error(failure),
        (newProducts) {
          if (newProducts.isEmpty) {
            _hasReachedMax = true;
            return Future<void>.value();
          }
          
          _currentPage++;
          _hasReachedMax = newProducts.length < _itemsPerPage;
          
          final updatedProducts = [...currentProducts, ...newProducts];
          state = AsyncValue.data(updatedProducts);
          return Future<void>.value();
        },
      );
    } catch (e, stackTrace) {
      return Future.error(e, stackTrace);
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refresh() => getProducts();
}

// Provider for the product list notifier
final productListNotifierProvider = StateNotifierProvider<ProductListNotifier, AsyncValue<List<Product>>>((ref) {
  final repository = ref.watch(productRepositoryRefProvider);
  return ProductListNotifier(repository);
});

// State Notifier for managing a single product state
class ProductNotifier extends StateNotifier<AsyncValue<Product?>> {
  final ProductRepository _repository;
  final Ref _ref;
  
  ProductNotifier(this._repository, this._ref) : super(const AsyncValue.loading());

  void _log(String message) {
    // Using debugPrint for better logging in Flutter
    // ignore: avoid_print
    debugPrint('ProductNotifier: $message');
  }

  Future<void> getProduct(String id) async {
    if (id.isEmpty) return;
    
    // Check if the product is marked as deleted
    final isDeleted = _ref.read(deletedProductsProvider).contains(id);
    if (isDeleted) {
      state = const AsyncValue.data(null);
      return;
    }
    
    state = const AsyncValue.loading();
    
    try {
      final result = await _repository.getProductById(id);
      
      await result.fold(
        (failure) {
          _log('Failed to get product: ${failure.message}');
          state = AsyncValue.error(failure, StackTrace.current);
          return Future<void>.value();
        },
        (product) {
          if (product == null) {
            _log('Product not found');
            state = AsyncValue.error('Product not found', StackTrace.current);
          } else {
            _log('Successfully loaded product: ${product.id}');
            state = AsyncValue.data(product);
          }
          return Future<void>.value();
        },
      );
    } catch (e, stackTrace) {
      _log('Unexpected error: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh(String id) async {
    await getProduct(id);
  }
}

// Provider for the product notifier
final productNotifierProvider = StateNotifierProvider.family<ProductNotifier, AsyncValue<Product?>, String>((ref, id) {
  final repository = ref.watch(productRepositoryRefProvider);
  final notifier = ProductNotifier(repository, ref);
  notifier.getProduct(id);
  return notifier;
});

// State Notifier for managing user's products
class UserProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final ProductRepository _repository;
  
  UserProductsNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> getProductsByUser(String userId) async {
    try {
      state = const AsyncValue.loading();
      final result = await _repository.getProductsByUser(userId);
      
      result.fold(
        (failure) => state = AsyncValue<List<Product>>.error(failure, StackTrace.current),
        (products) => state = AsyncValue.data(products),
      );
    } catch (e, stackTrace) {
      state = AsyncValue<List<Product>>.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> refresh(String userId) async {
    await getProductsByUser(userId);
  }
}

// Provider for the user products notifier
final userProductsNotifierProvider = StateNotifierProvider.family<UserProductsNotifier, AsyncValue<List<Product>>, String>(
  (ref, userId) {
    final repository = ref.watch(productRepositoryRefProvider);
    final notifier = UserProductsNotifier(repository);
    notifier.getProductsByUser(userId);
    return notifier;
  },
);
