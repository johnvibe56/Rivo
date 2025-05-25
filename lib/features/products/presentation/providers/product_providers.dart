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

  Future<void> getProducts() async {
    try {
      Logger.d('Starting to fetch products...', tag: _tag);
      state = const AsyncValue.loading();
      
      Logger.d('Calling repository.getProducts()', tag: _tag);
      final stopwatch = Stopwatch()..start();
      final result = await _repository.getProducts();
      stopwatch.stop();
      
      Logger.d('getProducts took ${stopwatch.elapsedMilliseconds}ms', tag: _tag);
      
      // Handle the Either result properly
      return result.fold(
        (failure) {
          final errorMsg = 'Failed to fetch products: ${failure.toString()}';
          Logger.e(errorMsg, StackTrace.current, tag: _tag);
          
          // Create a proper AsyncValue.error
          state = AsyncValue<List<Product>>.error(
            failure,
            StackTrace.current,
          );
          
          // Return a completed future
          return Future.value();
        },
        (products) {
          final successMsg = 'Successfully fetched ${products.length} products';
          Logger.d(successMsg, tag: _tag);
          
          if (products.isEmpty) {
            Logger.d('No products found in the repository', tag: _tag);
          } else {
            // Log details of products for debugging (limited to 5 to avoid log spam)
            final productsToLog = products.take(5).toList();
            Logger.d('First ${productsToLog.length} products:', tag: _tag);
            for (var i = 0; i < productsToLog.length; i++) {
              final p = productsToLog[i];
              Logger.d('${i + 1}. ID: ${p.id}, Title: "${p.title}"', tag: _tag);
            }
            if (products.length > 5) {
              Logger.d('... and ${products.length - 5} more products', tag: _tag);
            }
          }
          
          // Update state with the fetched products
          state = AsyncValue.data(products);
          
          // Return a completed future
          return Future.value();
        },
      );
    } catch (e, stackTrace) {
      final errorMsg = 'Unexpected error in getProducts: $e';
      Logger.e(errorMsg, stackTrace, tag: _tag);
      
      // Create a proper AsyncValue.error
      state = AsyncValue<List<Product>>.error(
        e,
        stackTrace,
      );
      
      // Re-throw the error to be handled by the caller if needed
      return Future.error(e, stackTrace);
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
