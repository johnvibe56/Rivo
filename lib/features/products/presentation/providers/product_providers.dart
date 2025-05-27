import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rivo/core/error/exceptions.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';
import 'package:rivo/features/products/domain/repositories/product_repository.dart';
import 'package:rivo/features/products/presentation/providers/product_repository_provider.dart';
import 'package:rivo/features/products/presentation/providers/delete_product_provider.dart';

// Note: The productRepositoryProvider is now defined in product_repository_provider.dart
// and includes the required NetworkInfo dependency.

// State Notifier for managing product list state
class ProductListNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  static const String _tag = 'ProductListNotifier';
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
      debugPrint('[$_tag] Loading initial batch of products');
      state = const AsyncValue.loading();
      
      _currentPage = 0;
      _hasReachedMax = false;
      
      debugPrint('[$_tag] Calling repository.getProducts()');
      final stopwatch = Stopwatch()..start();
      final result = await _repository.getProducts(page: 1, limit: _itemsPerPage);
      stopwatch.stop();
      
      debugPrint('[$_tag] getProducts took ${stopwatch.elapsedMilliseconds}ms');
      
      return result.fold(
        (failure) {
          final errorMsg = 'Failed to fetch products: ${failure.toString()}';
          debugPrint('❌ [$_tag] $errorMsg');
          debugPrint('❌ [$_tag] Stack trace: ${StackTrace.current}');
          state = AsyncValue<List<Product>>.error(failure, StackTrace.current);
          return Future<void>.error(failure);
        },
        (products) async {
          debugPrint('[$_tag] Loaded ${products.length} products');
          _currentPage = 1;
          _hasReachedMax = products.length < _itemsPerPage;
          
          state = AsyncValue.data(products);
          return Future.value();
        },
      );
    } catch (e, stackTrace) {
      final errorMsg = 'Unexpected error in getProducts: $e';
      debugPrint('❌ [$_tag] $errorMsg');
      debugPrint('❌ [$_tag] Stack trace: $stackTrace');
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
      debugPrint('[$_tag] Loading more products, page ${_currentPage + 1}');
      final currentProducts = state.valueOrNull ?? [];
      
      final result = await _repository.getProducts(
        page: _currentPage + 1,
        limit: _itemsPerPage,
      );

      await result.fold(
        (failure) {
          debugPrint('❌ [$_tag] Failed to load more products: ${failure.toString()}');
          return Future<void>.error(failure);
        },
        (newProducts) {
          debugPrint('[$_tag] Loaded ${newProducts.length} more products');
          
          if (newProducts.isEmpty) {
            _hasReachedMax = true;
            return Future<void>.value();
          }
          
          _currentPage++;
          _hasReachedMax = newProducts.length < _itemsPerPage;
          
          state = AsyncValue<List<Product>>.data([...currentProducts, ...newProducts]);
          return Future<void>.value();
        },
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [$_tag] Error in loadMore: $e');
      debugPrint('❌ [$_tag] Stack trace: $stackTrace');
      rethrow;
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
  static const String _tag = 'ProductNotifier';
  final ProductRepository _repository;
  final Ref _ref;
  bool _isDisposed = false;
  
  void _log(String message, {bool isError = false}) {
    if (isError) {
      debugPrint('❌ [$_tag] $message');
    } else {
      debugPrint('ℹ️ [$_tag] $message');
    }
  }
  
  ProductNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    _isDisposed = false;
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// Helper method to safely update state only if not disposed
  void _safeSetState(AsyncValue<Product> newState) {
    if (!_isDisposed) {
      state = newState;
    } else {
      debugPrint('⚠️ [$_tag] Not updating state - notifier is disposed');
    }
  }

  Future<void> getProduct(String id) async {
    if (id.isEmpty) return;
    
    // Check if this product was already deleted
    try {
      final isDeleted = _ref.read(deletedProductsProvider).contains(id);
      if (isDeleted) {
        _log('Skipping fetch for deleted product: $id');
        state = const AsyncValue.data(null);
        return;
      }
    } catch (e) {
      _log('Error checking deleted products: $e');
    }
    
    state = const AsyncValue.loading();
    _log('Loading product with ID: $id');
    
    try {
      final result = await _repository.getProductById(id);
      
      if (_isDisposed) {
        debugPrint('⚠️ [$_tag] Notifier disposed during getProduct for ID: $id');
        return;
      }
      
      result.fold(
        (failure) {
          debugPrint('❌ [$_tag] Failed to fetch product: ${failure.toString()}');
          _safeSetState(AsyncValue.error(failure, StackTrace.current));
        },
        (product) {
          if (product == null) {
            debugPrint('❌ [$_tag] Product not found with ID: $id');
            _safeSetState(AsyncValue.error(
              const NotFoundException('Product not found'),
              StackTrace.current,
            ));
          } else {
            debugPrint('✅ [$_tag] Successfully loaded product: ${product.id}');
            _safeSetState(AsyncValue.data(product));
          }
        },
      );
    } catch (e, stackTrace) {
      if (_isDisposed) {
        debugPrint('⚠️ [$_tag] Notifier disposed during error handling for ID: $id');
        return;
      }
      debugPrint('❌ [$_tag] Unexpected error in getProduct: $e');
      debugPrint('❌ [$_tag] Stack trace: $stackTrace');
      _safeSetState(AsyncValue.error(e, stackTrace));
    }
  }

  Future<void> refresh(String id) async {
    if (_isDisposed) {
      debugPrint('⚠️ [$_tag] Notifier is disposed, skipping refresh for ID: $id');
      return;
    }
    debugPrint('🔄 [$_tag] Refreshing product with ID: $id');
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
  static const String _tag = 'UserProductsNotifier';
  final ProductRepository _repository;
  
  UserProductsNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> getProductsByUser(String userId) async {
    try {
      debugPrint('[$_tag] Loading products for user ID: $userId');
      state = const AsyncValue.loading();
      final result = await _repository.getProductsByUser(userId);
      
      result.fold(
        (failure) {
          debugPrint('❌ [$_tag] Failed to fetch user products: ${failure.toString()}');
          state = AsyncValue<List<Product>>.error(failure, StackTrace.current);
        },
        (products) {
          debugPrint('[$_tag] Loaded ${products.length} products for user: $userId');
          state = AsyncValue.data(products);
        },
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [$_tag] Unexpected error in getProductsByUser: $e');
      debugPrint('❌ [$_tag] Stack trace: $stackTrace');
      state = AsyncValue<List<Product>>.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> refresh(String userId) async {
    debugPrint('[$_tag] Refreshing products for user ID: $userId');
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
