import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo/core/utils/logger.dart';
import 'package:rivo/features/products/data/datasources/product_remote_data_source.dart';
import 'package:rivo/features/products/data/repositories/product_repository_impl.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';
import 'package:rivo/features/products/domain/repositories/product_repository.dart';

// Remote Data Source
final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  return ProductRemoteDataSource();
});

// Repository
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final remoteDataSource = ref.watch(productRemoteDataSourceProvider);
  return ProductRepositoryImpl(remoteDataSource: remoteDataSource);
});

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
      Logger.d('Starting to fetch products...', tag: _tag);
      state = const AsyncValue.loading();
      
      _currentPage = 0;
      _hasReachedMax = false;
      
      Logger.d('Calling repository.getProducts()', tag: _tag);
      final stopwatch = Stopwatch()..start();
      final result = await _repository.getProducts(page: 1, limit: _itemsPerPage);
      stopwatch.stop();
      
      Logger.d('getProducts took ${stopwatch.elapsedMilliseconds}ms', tag: _tag);
      
      return result.fold(
        (failure) {
          final errorMsg = 'Failed to fetch products: ${failure.toString()}';
          Logger.e(errorMsg, StackTrace.current, tag: _tag);
          state = AsyncValue.error(failure, StackTrace.current) as AsyncValue<List<Product>>;
          return Future.error(failure);
        },
        (products) async {
          Logger.d('Successfully fetched ${products.length} products', tag: _tag);
          _currentPage = 1;
          _hasReachedMax = products.length < _itemsPerPage;
          
          state = AsyncValue.data(products);
          return Future.value();
        },
      );
    } catch (e, stackTrace) {
      final errorMsg = 'Unexpected error in getProducts: $e';
      Logger.e(errorMsg, stackTrace, tag: _tag);
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
      Logger.d('Loading more products, page ${_currentPage + 1}', tag: _tag);
      final currentProducts = state.valueOrNull ?? [];
      
      final result = await _repository.getProducts(
        page: _currentPage + 1,
        limit: _itemsPerPage,
      );

      await result.fold(
        (failure) {
          Logger.e('Failed to load more products: ${failure.toString()}', 
                  StackTrace.current, tag: _tag);
          return Future.error(failure);
        },
        (newProducts) {
          Logger.d('Successfully loaded ${newProducts.length} more products', tag: _tag);
          
          if (newProducts.isEmpty) {
            _hasReachedMax = true;
            return Future.value();
          }
          
          _currentPage++;
          _hasReachedMax = newProducts.length < _itemsPerPage;
          
          state = AsyncValue.data([...currentProducts, ...newProducts]);
          return Future.value();
        },
      );
    } catch (e, stackTrace) {
      Logger.e('Error in loadMore: $e', stackTrace, tag: _tag);
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refresh() => getProducts();
}

// Provider for the product list notifier
final productListNotifierProvider = StateNotifierProvider<ProductListNotifier, AsyncValue<List<Product>>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return ProductListNotifier(repository);
});

// State Notifier for managing a single product state
class ProductNotifier extends StateNotifier<AsyncValue<Product>> {
  static const String _tag = 'ProductNotifier';
  final ProductRepository _repository;
  
  ProductNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> getProduct(String id) async {
    try {
      Logger.d('Fetching product with ID: $id', tag: _tag);
      state = const AsyncValue.loading();
      final result = await _repository.getProductById(id);
      
      result.fold(
        (failure) {
          Logger.e('Failed to fetch product: ${failure.toString()}', StackTrace.current, tag: _tag);
          state = AsyncValue.error(failure, StackTrace.current) as AsyncValue<Product>;
        },
        (product) {
          Logger.d('Successfully fetched product: ${product.id}', tag: _tag);
          state = AsyncValue.data(product);
        },
      );
    } catch (e, stackTrace) {
      Logger.e('Unexpected error in getProduct: $e', stackTrace, tag: _tag);
      state = AsyncValue.error(e, stackTrace) as AsyncValue<Product>;
      rethrow;
    }
  }

  Future<void> refresh(String id) async {
    Logger.d('Refreshing product with ID: $id', tag: _tag);
    await getProduct(id);
  }
}

// Provider for the product notifier
final productNotifierProvider = StateNotifierProvider.family<ProductNotifier, AsyncValue<Product>, String>((ref, id) {
  final repository = ref.watch(productRepositoryProvider);
  final notifier = ProductNotifier(repository);
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
      Logger.d('Fetching products for user ID: $userId', tag: _tag);
      state = const AsyncValue.loading();
      final result = await _repository.getProductsByUser(userId);
      
      result.fold(
        (failure) {
          Logger.e('Failed to fetch user products: ${failure.toString()}', StackTrace.current, tag: _tag);
          state = AsyncValue.error(failure, StackTrace.current) as AsyncValue<List<Product>>;
        },
        (products) {
          Logger.d('Successfully fetched ${products.length} products for user: $userId', tag: _tag);
          state = AsyncValue.data(products);
        },
      );
    } catch (e, stackTrace) {
      Logger.e('Unexpected error in getProductsByUser: $e', stackTrace, tag: _tag);
      state = AsyncValue.error(e, stackTrace) as AsyncValue<List<Product>>;
      rethrow;
    }
  }

  Future<void> refresh(String userId) async {
    Logger.d('Refreshing products for user ID: $userId', tag: _tag);
    await getProductsByUser(userId);
  }
}

// Provider for the user products notifier
final userProductsNotifierProvider = StateNotifierProvider.family<UserProductsNotifier, AsyncValue<List<Product>>, String>(
  (ref, userId) {
    final repository = ref.watch(productRepositoryProvider);
    final notifier = UserProductsNotifier(repository);
    notifier.getProductsByUser(userId);
    return notifier;
  },
);
