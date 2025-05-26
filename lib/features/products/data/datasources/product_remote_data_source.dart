import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo/core/error/exceptions.dart';
import 'package:rivo/core/utils/logger.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';

class ProductRemoteDataSource {
  final SupabaseClient _supabaseClient;
  static const String _tag = 'ProductRemoteDataSource';

  ProductRemoteDataSource() : _supabaseClient = Supabase.instance.client;

  static const String _table = 'products';

  Future<List<Map<String, dynamic>>> getProducts({int page = 1, int limit = 10}) async {
    try {
      Logger.d('Fetching products from Supabase (page: $page, limit: $limit)...', tag: _tag);
      
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
      Logger.d('Supabase query took ${stopwatch.elapsedMilliseconds}ms', tag: _tag);
      
      final products = List<Map<String, dynamic>>.from(response);
      Logger.d('Successfully fetched ${products.length} products for page $page', tag: _tag);
      
      if (products.isNotEmpty && page == 1) {
        // Only log first page products to avoid too much output
        for (var i = 0; i < (products.length > 3 ? 3 : products.length); i++) {
          final p = products[i];
          Logger.d('Product ${i + 1} - ID: ${p['id']}, Title: ${p['title']}', tag: _tag);
        }
      } else if (products.isEmpty) {
        Logger.d('No more products found in the database', tag: _tag);
      }
      
      return products;
    } on PostgrestException catch (e) {
      Logger.e('Supabase error: ${e.message}', StackTrace.current, tag: _tag);
      throw ServerException(e.message);
    } catch (e, stackTrace) {
      Logger.e('Failed to fetch products: $e', stackTrace, tag: _tag);
      throw ServerException('Failed to load products');
    }
  }

  Future<Map<String, dynamic>> getProductById(String id) async {
    final response = await _supabaseClient
        .from(_table)
        .select()
        .eq('id', id)
        .single();
    
    return response;
  }

  Future<Map<String, dynamic>> createProduct(Product product) async {
    try {
      Logger.d('Creating product: ${product.title}', tag: _tag);
      
      // Get current user ID
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        Logger.e('No authenticated user found', StackTrace.current, tag: _tag);
        throw const ServerException('User not authenticated');
      }
      
      final productData = product.toJson()..['owner_id'] = currentUser.id;
      
      final response = await _supabaseClient
          .from(_table)
          .insert(productData)
          .select()
          .single();
          
      Logger.d('Successfully created product with ID: ${response['id']}', tag: _tag);
      return response;
    } on PostgrestException catch (e) {
      Logger.e('Failed to create product: ${e.message}', StackTrace.current, tag: _tag);
      throw ServerException(e.message);
    } catch (e, stackTrace) {
      Logger.e('Unexpected error creating product: $e', stackTrace, tag: _tag);
      throw const ServerException('Failed to create product');
    }
  }

  Future<Map<String, dynamic>> updateProduct(Product product) async {
    try {
      Logger.d('Updating product ID: ${product.id}', tag: _tag);
      
      final response = await _supabaseClient
          .from(_table)
          .update(product.toJson())
          .eq('id', product.id)
          .select()
          .single();
      
      Logger.d('Successfully updated product ID: ${product.id}', tag: _tag);
      return response;
    } on PostgrestException catch (e) {
      Logger.e('Failed to update product: ${e.message}', StackTrace.current, tag: _tag);
      throw ServerException(e.message);
    } catch (e, stackTrace) {
      Logger.e('Unexpected error updating product: $e', stackTrace, tag: _tag);
      throw ServerException('Failed to update product');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      Logger.d('Deleting product ID: $id', tag: _tag);
      
      // First, get the product to get the image URL
      final product = await _supabaseClient
          .from(_table)
          .select('image_url')
          .eq('id', id)
          .single();
      
      // Delete the product from the database
      await _supabaseClient
          .from(_table)
          .delete()
          .eq('id', id);
      
      // If the product had an image, delete it from storage
      final imageUrl = product['image_url'] as String?;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          // Extract the file path from the URL
          final uri = Uri.parse(imageUrl);
          final pathSegments = uri.pathSegments;
          if (pathSegments.length >= 3) {
            // The path is typically: /storage/v1/object/public/bucket-name/path/to/file
            final bucket = pathSegments[3];
            final filePath = pathSegments.sublist(4).join('/');
            
            await _supabaseClient.storage
                .from(bucket)
                .remove([filePath]);
                
            Logger.d('Successfully deleted image: $filePath', tag: _tag);
          }
        } catch (e, stackTrace) {
          // Log the error but don't fail the operation
          Logger.e('Failed to delete product image: $e', stackTrace, tag: _tag);
        }
      }
      
      Logger.d('Successfully deleted product ID: $id', tag: _tag);
    } on PostgrestException catch (e) {
      Logger.e('Failed to delete product: ${e.message}', StackTrace.current, tag: _tag);
      throw ServerException(e.message);
    } catch (e, stackTrace) {
      Logger.e('Unexpected error deleting product: $e', stackTrace, tag: _tag);
      throw ServerException('Failed to delete product');
    }
  }

  Future<List<Map<String, dynamic>>> getProductsByUser(String userId) async {
    try {
      Logger.d('Fetching products for user ID: $userId', tag: _tag);
      
      final response = await _supabaseClient
          .from(_table)
          .select()
          .eq('owner_id', userId)
          .order('created_at', ascending: false);
      
      Logger.d('Found ${response.length} products for user ID: $userId', tag: _tag);
      return response;
    } on PostgrestException catch (e) {
      Logger.e('Failed to fetch user products: ${e.message}', StackTrace.current, tag: _tag);
      throw ServerException(e.message);
    } catch (e, stackTrace) {
      Logger.e('Unexpected error fetching user products: $e', stackTrace, tag: _tag);
      throw ServerException('Failed to fetch user products');
    }
  }

  Future<void> toggleLike(String productId, String userId) async {
    try {
      Logger.d('Toggling like for product ID: $productId, user ID: $userId', tag: _tag);
      
      await _supabaseClient.rpc('toggle_array_item', params: {
        'table_name': _table,
        'column_name': 'liked_by',
        'row_id': productId,
        'item': userId,
      });
      
      Logger.d('Successfully toggled like for product ID: $productId', tag: _tag);
    } on PostgrestException catch (e) {
      Logger.e('Failed to toggle like: ${e.message}', StackTrace.current, tag: _tag);
      throw ServerException(e.message);
    } catch (e, stackTrace) {
      Logger.e('Unexpected error toggling like: $e', stackTrace, tag: _tag);
      throw ServerException('Failed to toggle like');
    }
  }

  Future<void> toggleSave(String productId, String userId) async {
    try {
      Logger.d('Toggling save for product ID: $productId, user ID: $userId', tag: _tag);
      
      await _supabaseClient.rpc('toggle_array_item', params: {
        'table_name': _table,
        'column_name': 'saved_by',
        'row_id': productId,
        'item': userId,
      });
      
      Logger.d('Successfully toggled save for product ID: $productId', tag: _tag);
    } on PostgrestException catch (e) {
      Logger.e('Failed to toggle save: ${e.message}', StackTrace.current, tag: _tag);
      throw ServerException(e.message);
    } catch (e, stackTrace) {
      Logger.e('Unexpected error toggling save: $e', stackTrace, tag: _tag);
      throw ServerException('Failed to toggle save');
    }
  }
}
