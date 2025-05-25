import 'package:dartz/dartz.dart';
import 'package:rivo/core/error/exceptions.dart';
import 'package:rivo/core/error/failures.dart';
import 'package:rivo/features/products/data/datasources/product_remote_data_source.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';
import 'package:rivo/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      print('🔄 [DEBUG] ProductRepositoryImpl: Fetching products from remote data source');
      final products = await remoteDataSource.getProducts();
      
      // Log the raw data for debugging
      print('📦 [DEBUG] Raw products data from remote source:');
      for (var product in products.take(2)) { // Log first 2 products to avoid too much output
        print('  - ${product['id']}: ${product['title']}');
      }
      
      try {
        // Convert each product JSON to Product model
        final productList = products.map((e) {
          try {
            return Product.fromJson(e);
          } catch (e, stackTrace) {
            print('❌ [ERROR] Failed to parse product: $e');
            print('Product data: $e');
            print(stackTrace);
            rethrow;
          }
        }).toList();
        
        print('✅ [DEBUG] Successfully parsed ${productList.length} products');
        return Right(productList);
      } catch (e, stackTrace) {
        print('❌ [ERROR] Failed to parse products: $e');
        print(stackTrace);
        return Left(ServerFailure('Failed to parse products data'));
      }
    } on ServerException catch (e, stackTrace) {
      print('❌ [ERROR] ServerException in getProducts: ${e.message}');
      print(stackTrace);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      print('❌ [ERROR] Unexpected error in getProducts: $e');
      print(stackTrace);
      return Left(ServerFailure('Failed to load products: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductById(String id) async {
    try {
      final product = await remoteDataSource.getProductById(id);
      return Right(Product.fromJson(product));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to load product'));
    }
  }

  @override
  Future<Either<Failure, Product>> createProduct(Product product) async {
    try {
      final createdProduct = await remoteDataSource.createProduct(product);
      return Right(Product.fromJson(createdProduct));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to create product'));
    }
  }

  @override
  Future<Either<Failure, Product>> updateProduct(Product product) async {
    try {
      final updatedProduct = await remoteDataSource.updateProduct(product);
      return Right(Product.fromJson(updatedProduct));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to update product'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      await remoteDataSource.deleteProduct(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to delete product'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProductsByUser(String userId) async {
    try {
      final products = await remoteDataSource.getProductsByUser(userId);
      return Right(products.map((e) => Product.fromJson(e)).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to load user products'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleLike(String productId, String userId) async {
    try {
      await remoteDataSource.toggleLike(productId, userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to toggle like'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleSave(String productId, String userId) async {
    try {
      await remoteDataSource.toggleSave(productId, userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to toggle save'));
    }
  }
}
