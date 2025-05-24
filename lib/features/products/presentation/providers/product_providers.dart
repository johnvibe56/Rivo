import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final ProductRepository _repository;
  
  ProductListNotifier(this._repository) : super(const AsyncValue.loading()) {
    getProducts();
  }

  Future<void> getProducts() async {
    state = const AsyncValue.loading();
    final result = await _repository.getProducts();
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current) as AsyncValue<List<Product>>,
      (products) => AsyncValue.data(products),
    );
  }

  Future<void> refresh() async {
    await getProducts();
  }
}

// Provider for the product list notifier
final productListNotifierProvider = StateNotifierProvider<ProductListNotifier, AsyncValue<List<Product>>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return ProductListNotifier(repository);
});

// State Notifier for managing a single product state
class ProductNotifier extends StateNotifier<AsyncValue<Product>> {
  final ProductRepository _repository;
  
  ProductNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> getProduct(String id) async {
    state = const AsyncValue.loading();
    final result = await _repository.getProductById(id);
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current) as AsyncValue<Product>,
      (product) => AsyncValue.data(product),
    );
  }

  Future<void> refresh(String id) async {
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
  final ProductRepository _repository;
  
  UserProductsNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> getProductsByUser(String userId) async {
    state = const AsyncValue.loading();
    final result = await _repository.getProductsByUser(userId);
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current) as AsyncValue<List<Product>>,
      (products) => AsyncValue.data(products),
    );
  }

  Future<void> refresh(String userId) async {
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
