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
      debugPrint('[$_tag] Fetching products from remote data source (page: $page, limit: $limit)');
      final products = await remoteDataSource.getProducts(page: page, limit: limit);
      
      if (products.isEmpty) {
        debugPrint('[$_tag] No products found for page $page');
        return const Right([]);
      }
      
      // Log the raw data for debugging (only first page to avoid log spam)
      if (page == 1) {
        debugPrint('[$_tag] Raw products data from remote source (first 2):');
        for (var product in products.take(2)) {
          debugPrint('[$_tag] - ${product.id}: ${product.title}');
        }
      }
      
      try {
        // Products are already converted to Product model in the data source
        debugPrint('✅ [$_tag] Successfully fetched ${products.length} products for page $page');
        return Right(products);
      } catch (e, stackTrace) {
        debugPrint('❌ [$_tag] Failed to process products: $e');
        debugPrint('❌ [$_tag] Stack trace: $stackTrace');
        return const Left(ServerFailure('Failed to parse products data'));
      }
    } on ServerException catch (e, stackTrace) {
      debugPrint('❌ [$_tag] ServerException in getProducts: ${e.message}');
      debugPrint('❌ [$_tag] Stack trace: $stackTrace');
      return Left(ServerFailure(e.message, stackTrace));
    } catch (e, stackTrace) {
      debugPrint('❌ [$_tag] Unexpected error in getProducts: $e');
      debugPrint('❌ [$_tag] Stack trace: $stackTrace');
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
    } on ServerException catch (e, stackTrace) {
      debugPrint('❌ [$_tag] ServerException in getProductById: ${e.message}');
      debugPrint('❌ [$_tag] Stack trace: $stackTrace');
      
      // Handle case when product is not found
      if (e.message.contains('not found') || e.message.contains('no rows returned')) {
        debugPrint('ℹ️ [$_tag] Product not found: $id');
        return const Right(null);
      }
      return Left(ServerFailure(e.message, stackTrace));
    } on PostgrestException catch (e) {
      // Handle PostgREST specific errors
      if (e.code == 'PGRST116' || e.message.contains('no rows returned')) {
        debugPrint('ℹ️ [$_tag] Product not found (PostgREST): $id');
        return const Right(null);
      }
      debugPrint('❌ [$_tag] PostgrestException in getProductById: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      debugPrint('❌ [$_tag] Unexpected error in getProductById: $e');
      debugPrint('❌ [$_tag] Stack trace: $stackTrace');
      return Left(ServerFailure('Failed to load product: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Product>> createProduct(Product product) async {
    try {
      debugPrint('[$_tag] Creating product: ${product.id}');
      final createdProductData = await remoteDataSource.createProduct(product);
      final createdProduct = Product.fromJson(createdProductData);
      debugPrint('✅ [$_tag] Successfully created product: ${createdProduct.id}');
      return Right(createdProduct);
    } on ServerException catch (e, stackTrace) {
      debugPrint('❌ [$_tag] ServerException in createProduct: ${e.message}');
      debugPrint('❌ [$_tag] Stack trace: $stackTrace');
      return Left(ServerFailure(e.message, stackTrace));
    } catch (e, stackTrace) {
      debugPrint('❌ [$_tag] Unexpected error in createProduct: $e');
      debugPrint('❌ [$_tag] Stack trace: $stackTrace');
      return Left(ServerFailure('Failed to create product: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Product>> updateProduct(Product product) async {
    try {
      debugPrint('[$_tag] Updating product: ${product.id}');
      final updatedProductData = await remoteDataSource.updateProduct(product);
      final updatedProduct = Product.fromJson(updatedProductData);
      debugPrint('✅ [$_tag] Successfully updated product: ${product.id}');
      return Right(updatedProduct);
    } on ServerException catch (e, stackTrace) {
      debugPrint('❌ [$_tag] ServerException in updateProduct: ${e.message}');
      debugPrint('❌ [$_tag] Stack trace: $stackTrace');
      return Left(ServerFailure(e.message, stackTrace));
    } catch (e, stackTrace) {
      debugPrint('❌ [$_tag] Unexpected error in updateProduct: $e');
      debugPrint('❌ [$_tag] Stack trace: $stackTrace');
      return Left(ServerFailure('Failed to update product: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    final stopwatch = Stopwatch()..start();
    debugPrint('🚀 [ProductRepository] Starting to delete product ID: $id');
    
    try {
      // 1. Validate input
      debugPrint('🔍 [ProductRepository] Validating product ID');
      if (id.isEmpty) {
        const error = 'Cannot delete product: Invalid product ID';
        debugPrint('❌ [ProductRepository] $error');
        return const Left(ServerFailure('Cannot delete product: Invalid product ID'));
      }
      debugPrint('✅ [ProductRepository] Product ID is valid');

      // 2. Check if product exists
      debugPrint('🔍 [ProductRepository] Checking if product exists');
      final productResult = await getProductById(id);
      
      return productResult.fold(
        (failure) {
          debugPrint('❌ [ProductRepository] Failed to verify product existence: $failure');
          return Left(failure);
        },
        (product) async {
          if (product == null) {
            debugPrint('❌ [ProductRepository] Product not found with ID: $id');
            return const Left(ServerFailure('Product not found'));
          }
          
          // 3. Remove product from all wishlists first
          debugPrint('🔄 [ProductRepository] Removing product from all wishlists');
          try {
            final wishlistResult = await removeProductFromAllWishlists(id);
            wishlistResult.fold(
              (failure) => debugPrint('⚠️ [ProductRepository] Warning: ${failure.message}'),
              (_) => debugPrint('✅ [ProductRepository] Successfully removed product from all wishlists'),
            );
          } catch (e, stackTrace) {
            debugPrint('⚠️ [ProductRepository] Non-critical error removing from wishlists: $e');
            debugPrint('Stack trace: $stackTrace');
            // Continue with deletion even if wishlist removal fails
          }

          // 4. Delete the product
          debugPrint('🗑️ [ProductRepository] Deleting product ID: $id');
          await remoteDataSource.deleteProduct(id);
          debugPrint('✅ [ProductRepository] Successfully deleted product ID: $id');
          
          return const Right(null);
        },
      );
    } on ServerException catch (e, stackTrace) {
      final error = 'Server error: ${e.message}';
      debugPrint('🌐 [ProductRepository] $error');
      debugPrint('🌐 [ProductRepository] Stack trace: $stackTrace');
      return Left(ServerFailure(e.message, stackTrace));
    } on NetworkException catch (e, stackTrace) {
      final error = 'Network error: ${e.message}';
      debugPrint('🌐 [ProductRepository] $error');
      debugPrint('🌐 [ProductRepository] Stack trace: $stackTrace');
      return Left(NetworkFailure(e.message));
    } catch (e, stackTrace) {
      final error = 'Unexpected error: $e';
      debugPrint('💥 [ProductRepository] $error');
      debugPrint('💥 [ProductRepository] Stack trace: $stackTrace');
      return const Left(ServerFailure('An unexpected error occurred while deleting the product'));
    } finally {
      stopwatch.stop();
      debugPrint('⏱️ [ProductRepository] Total deleteProduct execution time: ${stopwatch.elapsedMilliseconds}ms');
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProductsByUser(String userId) async {
    try {
      debugPrint('[$_tag] Fetching products for user ID: $userId');
      final products = await remoteDataSource.getProductsByUser(userId);
      debugPrint('✅ [$_tag] Found ${products.length} products for user: $userId');
      return Right(products);
    } on ServerException catch (e, stackTrace) {
      debugPrint('❌ [$_tag] ServerException in getProductsByUser: ${e.message}');
      debugPrint('❌ [$_tag] Stack trace: $stackTrace');
      return Left(ServerFailure(e.message, stackTrace));
    } catch (e, stackTrace) {
      debugPrint('❌ [$_tag] Unexpected error in getProductsByUser: $e');
      debugPrint('❌ [$_tag] Stack trace: $stackTrace');
      return Left(ServerFailure('Failed to load user products: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleLike(String productId, String userId) async {
    try {
      debugPrint('[$_tag] Toggling like for product: $productId, user: $userId');
      await remoteDataSource.toggleLike(productId, userId);
      debugPrint('[$_tag] Successfully toggled like for product: $productId');
      return const Right(null);
    } on ServerException catch (e, _) {
      debugPrint('[$_tag] ServerException in toggleLike: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      debugPrint('[$_tag] Unexpected error in toggleLike: $e');
      debugPrint('[$_tag] Stack trace: $stackTrace');
      return Left(ServerFailure('Failed to toggle like: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleSave(String productId, String userId) async {
    try {
      debugPrint('[$_tag] Toggling save for product: $productId, user: $userId');
      await remoteDataSource.toggleSave(productId, userId);
      debugPrint('[$_tag] Successfully toggled save for product: $productId');
      return const Right(null);
    } on ServerException catch (e, _) {
      debugPrint('[$_tag] ServerException in toggleSave: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      debugPrint('[$_tag] Unexpected error in toggleSave: $e');
      debugPrint('[$_tag] Stack trace: $stackTrace');
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
