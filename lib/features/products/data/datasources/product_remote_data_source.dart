import 'package:flutter/foundation.dart';
import 'package:rivo/core/error/exceptions.dart';
import 'package:rivo/core/network/network_info.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductRemoteDataSource {
  final SupabaseClient _supabaseClient;
  final NetworkInfo _networkInfo;
  static const String _tag = 'ProductRemoteDataSource';

  ProductRemoteDataSource({required NetworkInfo networkInfo})
      : _networkInfo = networkInfo,
        _supabaseClient = Supabase.instance.client;

  static const String _table = 'products';

  Future<List<Map<String, dynamic>>> getProducts({int page = 1, int limit = 10}) async {
    try {
      debugPrint('[$_tag] Fetching products from Supabase (page: $page, limit: $limit)...');
      
      final stopwatch = Stopwatch()..start();
      
      // Calculate range for pagination
      final from = (page - 1) * limit;
      final to = from + limit - 1;
      
      final response = await _supabaseClient
          .from(_table)
          .select('*')
          .order('created_at', ascending: false)
          .range(from, to);
          
      stopwatch.stop();
      debugPrint('[$_tag] Supabase query took ${stopwatch.elapsedMilliseconds}ms');
      
      final products = List<Map<String, dynamic>>.from(response);
      debugPrint('[$_tag] Successfully fetched ${products.length} products for page $page');
      
      if (products.isNotEmpty && page == 1) {
        // Only log first page products to avoid too much output
        for (var i = 0; i < (products.length > 3 ? 3 : products.length); i++) {
          final p = products[i];
          debugPrint('[$_tag] Product ${i + 1} - ID: ${p['id']}, Title: ${p['title']}');
        }
      } else if (products.isEmpty) {
        debugPrint('[$_tag] No more products found in the database');
      }
      
      return products;
    } on PostgrestException catch (e) {
      debugPrint('❌ [$_tag] Supabase error: ${e.message}');
      debugPrint('❌ [$_tag] Stack trace: ${StackTrace.current}');
      throw ServerException(e.message, StackTrace.current);
    } catch (e, stackTrace) {
      debugPrint('❌ [$_tag] Failed to fetch products: $e');
      debugPrint('❌ [$_tag] Stack trace: $stackTrace');
      throw ServerException('Failed to load products', stackTrace);
    }
  }

  Future<Map<String, dynamic>> getProductById(String id) async {
    try {
      debugPrint('[$_tag] Fetching product by ID: $id');
      final response = await _supabaseClient
          .from(_table)
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) {
        debugPrint('❌ [$_tag] Product not found with ID: $id');
        throw NotFoundException('Product not found', StackTrace.current);
      }
      
      debugPrint('✅ [$_tag] Successfully fetched product: $id');
      return response;
    } on PostgrestException catch (e) {
      debugPrint('❌ [$_tag] Database error fetching product: ${e.message}');
      if (e.code == 'PGRST116' || e.message.contains('No rows returned')) {
        throw NotFoundException('Product not found', StackTrace.current);
      }
      rethrow;
    } catch (e) {
      debugPrint('❌ [$_tag] Error fetching product: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createProduct(Product product) async {
    try {
      debugPrint('[$_tag] Creating product: ${product.title}');
      
      // Get current user ID
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        debugPrint('❌ [$_tag] No authenticated user found');
        debugPrint('❌ [$_tag] Stack trace: ${StackTrace.current}');
        throw ServerException('User not authenticated', StackTrace.current);
      }
      
      final productData = product.toJson()..['owner_id'] = currentUser.id;
      
      final response = await _supabaseClient
          .from(_table)
          .insert(productData)
          .select()
          .single();
          
      debugPrint('✅ [$_tag] Successfully created product with ID: ${response['id']}');
      return response;
    } on PostgrestException catch (e) {
      debugPrint('❌ [$_tag] Failed to create product: ${e.message}');
      debugPrint('❌ [$_tag] Stack trace: ${StackTrace.current}');
      throw ServerException(e.message, StackTrace.current);
    } catch (e, stackTrace) {
      debugPrint('❌ [$_tag] Unexpected error creating product: $e');
      debugPrint('❌ [$_tag] Stack trace: $stackTrace');
      throw ServerException('Failed to create product', stackTrace);
    }
  }

  Future<Map<String, dynamic>> updateProduct(Product product) async {
    try {
      debugPrint('[$_tag] Updating product ID: ${product.id}');
      
      final response = await _supabaseClient
          .from(_table)
          .update(product.toJson())
          .eq('id', product.id)
          .select()
          .single();
      
      debugPrint('✅ [$_tag] Successfully updated product ID: ${product.id}');
      return response;
    } on PostgrestException catch (e) {
      debugPrint('❌ [$_tag] Failed to update product: ${e.message}');
      debugPrint('❌ [$_tag] Stack trace: ${StackTrace.current}');
      throw ServerException(e.message, StackTrace.current);
    } catch (e, stackTrace) {
      debugPrint('❌ [$_tag] Unexpected error updating product: $e');
      debugPrint('❌ [$_tag] Stack trace: $stackTrace');
      throw ServerException('Failed to update product', stackTrace);
    }
  }

  Future<void> deleteProduct(String id) async {
    debugPrint('🚀 [ProductRemoteDataSource] Starting product deletion for ID: $id');
    final operationStartTime = DateTime.now();
    
    try {
      // 1. Check network connection
      debugPrint('🔌 [1/6] Checking network connection...');
      if (!await _networkInfo.isConnected) {
        const error = 'No internet connection';
        debugPrint('❌ [ProductRemoteDataSource] $error');
        throw ServerException(error, StackTrace.current);
      }
      debugPrint('✅ [1/6] Network connection verified');

      // 2. Check if the product exists
      debugPrint('🔍 [2/6] Fetching product details for ID: $id');
      final productFetchStartTime = DateTime.now();
      final productResponse = await _supabaseClient
          .from(_table)
          .select('id, image_url, owner_id, title')
          .eq('id', id)
          .maybeSingle();
          
      final fetchDuration = DateTime.now().difference(productFetchStartTime);
      debugPrint('📥 [2/6] Product check completed in ${fetchDuration.inMilliseconds}ms');
      
      if (productResponse == null) {
        final message = 'Product with ID $id not found, considering delete successful';
        debugPrint('ℹ️ [ProductRemoteDataSource] $message');
        return;
      }

      // Log product details for debugging
      final productTitle = productResponse['title'] ?? 'Untitled';
      debugPrint('📋 [ProductRemoteDataSource] Deleting product: $productTitle (ID: $id)');

      // 3. Verify authentication
      debugPrint('🔑 [3/6] Verifying authentication...');
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        const error = 'User not authenticated';
        debugPrint('❌ [ProductRemoteDataSource] $error');
        throw ServerException(error, StackTrace.current);
      }
      debugPrint('✅ [3/6] User authenticated: $userId');

      // 4. Verify ownership
      debugPrint('🔒 [4/6] Verifying product ownership...');
      final ownerId = productResponse['owner_id'] as String?;
      if (ownerId != userId) {
        final error = 'User $userId is not the owner of product $id (owner: $ownerId)';
        debugPrint('❌ [ProductRemoteDataSource] $error');
        throw ServerException('You do not have permission to delete this product', StackTrace.current);
      }
      debugPrint('✅ [4/6] Ownership verified');

      // 5. Delete the product from the database
      debugPrint('🗑️ [5/6] Starting database deletion for product: $id');
      final deleteStartTime = DateTime.now();
      
      try {
        // Execute the delete operation
        await _supabaseClient
            .from(_table)
            .delete()
            .eq('id', id);
            
        final deleteDuration = DateTime.now().difference(deleteStartTime);
        debugPrint('✅ [5/6] Successfully deleted product from database in ${deleteDuration.inMilliseconds}ms');
      } on PostgrestException catch (e) {
        debugPrint('❌ [ProductRemoteDataSource] Database error during deletion: ${e.message}');
        debugPrint('❌ [ProductRemoteDataSource] Details: ${e.details}');
        debugPrint('❌ [ProductRemoteDataSource] Hint: ${e.hint}');
        debugPrint('❌ [ProductRemoteDataSource] Code: ${e.code}');
        throw ServerException('Failed to delete product from database: ${e.message}', StackTrace.current);
      } catch (e, stackTrace) {
        debugPrint('❌ [ProductRemoteDataSource] Unexpected error during product deletion: $e');
        debugPrint('❌ [ProductRemoteDataSource] Stack trace: $stackTrace');
        throw ServerException('An unexpected error occurred while deleting the product', stackTrace);
      }
      
      // 6. Delete the associated image if it exists
      debugPrint('🖼️ [6/6] Checking for associated images to delete');
      final imageUrl = productResponse['image_url'] as String?;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          debugPrint('   📂 Attempting to delete image: $imageUrl');
          final imageDeletionStartTime = DateTime.now();
          
          // Extract the file path from the URL
          final uri = Uri.parse(imageUrl);
          final pathSegments = uri.pathSegments;
          
          // The first segment is the bucket name, the rest is the file path
          if (pathSegments.length > 1) {
            final bucket = pathSegments[0];
            final filePath = pathSegments.sublist(1).join('/');
            
            debugPrint('   📁 Deleting file from bucket: $bucket, path: $filePath');
            try {
              await _supabaseClient.storage.from(bucket).remove([filePath]);
              final imageDeleteDuration = DateTime.now().difference(imageDeletionStartTime);
              debugPrint('   ✅ Successfully deleted image in ${imageDeleteDuration.inMilliseconds}ms');
            } catch (e) {
              debugPrint('⚠️ [ProductRemoteDataSource] Failed to delete image: $e');
            }
          } else {
            debugPrint('⚠️ [ProductRemoteDataSource] Could not parse image URL for deletion: $imageUrl');
          }
        } catch (e) {
          debugPrint('⚠️ [ProductRemoteDataSource] Failed to delete image: $e');
          // Don't rethrow - we still want to complete the product deletion even if image deletion fails
        }
      } else {
        debugPrint('ℹ️ [ProductRemoteDataSource] No image to delete for product: $id');
      }
      
      final endTime = DateTime.now();
      final duration = endTime.difference(operationStartTime);
      debugPrint('⏱️ [ProductRemoteDataSource] Product deletion completed in ${duration.inMilliseconds}ms');
    } on PostgrestException catch (e) {
      debugPrint('❌ [ProductRemoteDataSource] Database error: ${e.message}');
      debugPrint('❌ [ProductRemoteDataSource] Error details: ${e.details}');
      debugPrint('❌ [ProductRemoteDataSource] Error hint: ${e.hint}');
      debugPrint('❌ [ProductRemoteDataSource] Error code: ${e.code}');
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('❌ [ProductRemoteDataSource] Unexpected error: $e');
      debugPrint('❌ [ProductRemoteDataSource] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getProductsByUser(String userId) async {
    try {
      debugPrint('[$_tag] Fetching products for user ID: $userId');
      
      final response = await _supabaseClient
          .from(_table)
          .select()
          .eq('owner_id', userId)
          .order('created_at', ascending: false);
      
      debugPrint('✅ [$_tag] Found ${response.length} products for user ID: $userId');
      return response;
    } on PostgrestException catch (e) {
      debugPrint('❌ [$_tag] Failed to fetch user products: ${e.message}');
      debugPrint('❌ [$_tag] Stack trace: ${StackTrace.current}');
      throw ServerException(e.message);
    } catch (e, stackTrace) {
      debugPrint('❌ [$_tag] Unexpected error fetching user products: $e');
      debugPrint('❌ [$_tag] Stack trace: $stackTrace');
      throw const ServerException('Failed to fetch user products');
    }
  }

  Future<void> toggleLike(String productId, String userId) async {
    try {
      debugPrint('[$_tag] Toggling like for product ID: $productId, user ID: $userId');
      
      await _supabaseClient.rpc<Map<String, dynamic>>('toggle_array_item', params: {
        'table_name': _table,
        'column_name': 'liked_by',
        'row_id': productId,
        'item': userId,
      });
      
      debugPrint('✅ [$_tag] Successfully toggled like for product ID: $productId');
    } on PostgrestException catch (e) {
      debugPrint('❌ [$_tag] Failed to toggle like: ${e.message}');
      debugPrint('❌ [$_tag] Stack trace: ${StackTrace.current}');
      throw ServerException(e.message);
    } catch (e, stackTrace) {
      debugPrint('❌ [$_tag] Unexpected error toggling like: $e');
      debugPrint('❌ [$_tag] Stack trace: $stackTrace');
      throw const ServerException('Failed to toggle like');
    }
  }

  Future<void> toggleSave(String productId, String userId) async {
    try {
      debugPrint('[$_tag] Toggling save for product ID: $productId, user ID: $userId');
      
      await _supabaseClient.rpc<Map<String, dynamic>>('toggle_array_item', params: {
        'table_name': _table,
        'column_name': 'saved_by',
        'row_id': productId,
        'item': userId,
      });
      
      debugPrint('✅ [$_tag] Successfully toggled save for product ID: $productId');
    } on PostgrestException catch (e) {
      debugPrint('❌ [$_tag] Failed to toggle save: ${e.message}');
      debugPrint('❌ [$_tag] Stack trace: ${StackTrace.current}');
      throw ServerException(e.message);
    } catch (e, stackTrace) {
      debugPrint('❌ [$_tag] Unexpected error toggling save: $e');
      debugPrint('❌ [$_tag] Stack trace: $stackTrace');
      throw const ServerException('Failed to toggle save');
    }
  }
}
