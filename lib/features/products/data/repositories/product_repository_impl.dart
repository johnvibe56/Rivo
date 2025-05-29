import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo/core/error/exceptions.dart';
import 'package:rivo/core/error/failures.dart';
import 'package:rivo/features/products/data/datasources/product_remote_data_source.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';
import 'package:rivo/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  static const String _tag = 'ProductRepository';
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Product>>> getProducts({int page = 1, int limit = 10}) async {
    try {
      final products = await remoteDataSource.getProducts(page: page, limit: limit);
      
      if (products.isEmpty) {
        return const Right([]);
      }
      
      try {
        // Products are already converted to Product model in the data source
        return Right(products);
      } catch (e) {
        return const Left(ServerFailure('Failed to parse products data'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to load products: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Product?>> getProductById(String id) async {
    try {
      debugPrint('[$_tag] Fetching product by ID: $id');
      final productData = await remoteDataSource.getProductById(id);
      final product = Product.fromJson(productData);
      debugPrint('✅ [$_tag] Successfully fetched product: ${product.id}');
      return Right(product);
    } on ServerException catch (e) {
      debugPrint('❌ [$_tag] ServerException in getProductById: ${e.message}');
      
      // Handle case when product is not found
      if (e.message.contains('not found') || e.message.contains('no rows returned')) {
        debugPrint('ℹ️ [$_tag] Product not found: $id');
        return const Right(null);
      }
      return Left(ServerFailure(e.message));
    } on PostgrestException catch (e) {
      // Handle PostgREST specific errors
      if (e.code == 'PGRST116' || e.message.contains('no rows returned')) {
        debugPrint('ℹ️ [$_tag] Product not found (PostgREST): $id');
        return const Right(null);
      }
      debugPrint('❌ [$_tag] PostgrestException in getProductById: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('❌ [$_tag] Unexpected error in getProductById: $e');
      return Left(ServerFailure('Failed to load product: ${e.toString()}'));
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
      return Left(ServerFailure('Failed to create product: ${e.toString()}'));
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
      return Left(ServerFailure('Failed to update product: ${e.toString()}'));
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
      return Left(ServerFailure('Failed to delete product: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProductsByUser(String userId) async {
    try {
      final productsData = await remoteDataSource.getProductsByUser(userId);
      final products = productsData.map((json) => Product.fromJson(json)).toList();
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to load user products: ${e.toString()}'));
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
      return Left(ServerFailure('Failed to toggle like: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleSave(String productId, String userId) async {
    try {
      final isSaved = await remoteDataSource.toggleSave(productId, userId);
      return Right(isSaved);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to toggle save: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> removeProductFromAllWishlists(String productId) async {
    const String tag = 'ProductRepository';
    final stopwatch = Stopwatch()..start();
    
    if (productId.isEmpty) {
      const error = 'Cannot remove product from wishlists: Empty product ID';
      debugPrint('❌ [$tag] $error');
      return const Left(ServerFailure('Cannot remove product from wishlists: Empty product ID'));
    }

    try {
      debugPrint('🔄 [$tag] Starting to remove product $productId from all wishlists');
      
      // Get the Supabase client instance
      final supabase = Supabase.instance.client;
      
      // First, check if there are any wishlist entries for this product
      debugPrint('🔍 [$tag] Checking for wishlist entries for product $productId');
      final wishlistResponse = await supabase
          .from('wishlist')
          .select('id, user_id')
          .eq('product_id', productId);
      
      // Ensure we have a list of wishlist entries
      final wishlistEntries = (wishlistResponse as List<dynamic>?) ?? [];
      debugPrint('🔍 [$tag] Found ${wishlistEntries.length} wishlist entries for product $productId');
      
      if (wishlistEntries.isEmpty) {
        debugPrint('ℹ️ [$tag] No wishlist entries found for product $productId - nothing to remove');
        return const Right(null);
      }
      
      // Log details about the wishlist entries we're about to delete
      for (var i = 0; i < wishlistEntries.length; i++) {
        final entry = wishlistEntries[i];
        debugPrint('📝 [$tag] Wishlist entry ${i + 1}: user_id=${entry['user_id']}');
      }
      
      // Delete all wishlist entries for this product
      debugPrint('🗑️ [$tag] Removing ${wishlistEntries.length} wishlist entries for product $productId');
      
      // Use a transaction to ensure all deletes are atomic
      await supabase.rpc<Map<String, dynamic>>('delete_product_wishlists', params: {'p_product_id': productId});
      
      // Verify the deletion was successful
      final verifyResponse = await supabase
          .from('wishlist')
          .select('id')
          .eq('product_id', productId)
          .maybeSingle();
      
      if (verifyResponse != null) {
        final error = 'Failed to remove all wishlist entries for product $productId';
        debugPrint('❌ [$tag] $error');
        return Left(ServerFailure(error));
      }
      
      debugPrint('✅ [$tag] Successfully removed product $productId from ${wishlistEntries.length} wishlists in ${stopwatch.elapsedMilliseconds}ms');
      return const Right(null);
      
    } on PostgrestException catch (e, stackTrace) {
      final error = 'Database error removing product $productId from wishlists: ${e.message}';
      debugPrint('❌ [$tag] $error');
      debugPrint('❌ [$tag] Stack trace: $stackTrace');
      return Left(ServerFailure(error));
    } on ServerException catch (e, stackTrace) {
      final error = 'Server error removing product $productId from wishlists: ${e.message}';
      debugPrint('❌ [$tag] $error');
      debugPrint('❌ [$tag] Stack trace: $stackTrace');
      return Left(ServerFailure(error));
    } catch (e, stackTrace) {
      final error = 'Unexpected error removing product $productId from wishlists: $e';
      debugPrint('❌ [$tag] $error');
      debugPrint('❌ [$tag] Stack trace: $stackTrace');
      return Left(ServerFailure(error));
    } finally {
      stopwatch.stop();
    }
  }
}
