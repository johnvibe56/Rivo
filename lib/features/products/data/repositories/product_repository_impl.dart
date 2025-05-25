import 'package:dartz/dartz.dart';
import 'package:rivo/core/error/exceptions.dart';
import 'package:rivo/core/error/failures.dart';
import 'package:rivo/core/utils/logger.dart';
import 'package:rivo/features/products/data/datasources/product_remote_data_source.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';
import 'package:rivo/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  static const String _tag = 'ProductRepository';
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      Logger.d('Fetching products from remote data source', tag: _tag);
      final products = await remoteDataSource.getProducts();
      
      // Log the raw data for debugging
      Logger.d('Raw products data from remote source (first 2):', tag: _tag);
      for (var product in products.take(2)) {
        Logger.d('- ${product['id']}: ${product['title']}', tag: _tag);
      }
      
      try {
        // Convert each product JSON to Product model
        final productList = products.map((e) {
          try {
            return Product.fromJson(e);
          } catch (e, stackTrace) {
            Logger.e('Failed to parse product: $e', stackTrace, tag: _tag);
            Logger.e('Product data: $e', stackTrace, tag: _tag);
            rethrow;
          }
        }).toList();
        
        Logger.d('Successfully parsed ${productList.length} products', tag: _tag);
        return Right(productList);
      } catch (e, stackTrace) {
        Logger.e('Failed to parse products: $e', stackTrace, tag: _tag);
        return Left(ServerFailure('Failed to parse products data'));
      }
    } on ServerException catch (e, stackTrace) {
      Logger.e('ServerException in getProducts: ${e.message}', stackTrace, tag: _tag);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      Logger.e('Unexpected error in getProducts: $e', stackTrace, tag: _tag);
      return Left(ServerFailure('Failed to load products: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductById(String id) async {
    try {
      Logger.d('Fetching product by ID: $id', tag: _tag);
      final product = await remoteDataSource.getProductById(id);
      Logger.d('Successfully fetched product: ${product['id']}', tag: _tag);
      return Right(Product.fromJson(product));
    } on ServerException catch (e, stackTrace) {
      Logger.e('ServerException in getProductById: ${e.message}', stackTrace, tag: _tag);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      Logger.e('Unexpected error in getProductById: $e', stackTrace, tag: _tag);
      return Left(ServerFailure('Failed to load product: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Product>> createProduct(Product product) async {
    try {
      Logger.d('Creating new product: ${product.title}', tag: _tag);
      final createdProduct = await remoteDataSource.createProduct(product);
      Logger.d('Successfully created product: ${createdProduct['id']}', tag: _tag);
      return Right(Product.fromJson(createdProduct));
    } on ServerException catch (e, stackTrace) {
      Logger.e('ServerException in createProduct: ${e.message}', stackTrace, tag: _tag);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      Logger.e('Unexpected error in createProduct: $e', stackTrace, tag: _tag);
      return Left(ServerFailure('Failed to create product: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Product>> updateProduct(Product product) async {
    try {
      Logger.d('Updating product ID: ${product.id}', tag: _tag);
      final updatedProduct = await remoteDataSource.updateProduct(product);
      Logger.d('Successfully updated product: ${product.id}', tag: _tag);
      return Right(Product.fromJson(updatedProduct));
    } on ServerException catch (e, stackTrace) {
      Logger.e('ServerException in updateProduct: ${e.message}', stackTrace, tag: _tag);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      Logger.e('Unexpected error in updateProduct: $e', stackTrace, tag: _tag);
      return Left(ServerFailure('Failed to update product: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      Logger.d('Deleting product ID: $id', tag: _tag);
      await remoteDataSource.deleteProduct(id);
      Logger.d('Successfully deleted product: $id', tag: _tag);
      return const Right(null);
    } on ServerException catch (e, stackTrace) {
      Logger.e('ServerException in deleteProduct: ${e.message}', stackTrace, tag: _tag);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      Logger.e('Unexpected error in deleteProduct: $e', stackTrace, tag: _tag);
      return Left(ServerFailure('Failed to delete product: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProductsByUser(String userId) async {
    try {
      Logger.d('Fetching products for user ID: $userId', tag: _tag);
      final products = await remoteDataSource.getProductsByUser(userId);
      final productList = products.map((e) => Product.fromJson(e)).toList();
      Logger.d('Found ${productList.length} products for user: $userId', tag: _tag);
      return Right(productList);
    } on ServerException catch (e, stackTrace) {
      Logger.e('ServerException in getProductsByUser: ${e.message}', stackTrace, tag: _tag);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      Logger.e('Unexpected error in getProductsByUser: $e', stackTrace, tag: _tag);
      return Left(ServerFailure('Failed to load user products: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleLike(String productId, String userId) async {
    try {
      Logger.d('Toggling like for product: $productId, user: $userId', tag: _tag);
      await remoteDataSource.toggleLike(productId, userId);
      Logger.d('Successfully toggled like for product: $productId', tag: _tag);
      return const Right(null);
    } on ServerException catch (e, stackTrace) {
      Logger.e('ServerException in toggleLike: ${e.message}', stackTrace, tag: _tag);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      Logger.e('Unexpected error in toggleLike: $e', stackTrace, tag: _tag);
      return Left(ServerFailure('Failed to toggle like: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleSave(String productId, String userId) async {
    try {
      Logger.d('Toggling save for product: $productId, user: $userId', tag: _tag);
      await remoteDataSource.toggleSave(productId, userId);
      Logger.d('Successfully toggled save for product: $productId', tag: _tag);
      return const Right(null);
    } on ServerException catch (e, stackTrace) {
      Logger.e('ServerException in toggleSave: ${e.message}', stackTrace, tag: _tag);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      Logger.e('Unexpected error in toggleSave: $e', stackTrace, tag: _tag);
      return Left(ServerFailure('Failed to toggle save: ${e.toString()}'));
    }
  }
}
