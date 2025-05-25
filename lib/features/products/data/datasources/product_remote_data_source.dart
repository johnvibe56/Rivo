import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo/core/error/exceptions.dart';
import 'package:rivo/core/utils/logger.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';

class ProductRemoteDataSource {
  final SupabaseClient _supabaseClient;
  static const String _tag = 'ProductRemoteDataSource';

  ProductRemoteDataSource() : _supabaseClient = Supabase.instance.client;

  static const String _table = 'products';

  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      Logger.d('Fetching products from Supabase...', tag: _tag);
      
      final stopwatch = Stopwatch()..start();
      final response = await _supabaseClient
          .from(_table)
          .select('*')
          .order('created_at', ascending: false);
          
      stopwatch.stop();
      Logger.d('Supabase query took ${stopwatch.elapsedMilliseconds}ms', tag: _tag);
      
      final products = List<Map<String, dynamic>>.from(response);
      Logger.d('Successfully fetched ${products.length} products', tag: _tag);
      
      if (products.isNotEmpty) {
        // Log first 3 products to avoid too much output
        for (var i = 0; i < (products.length > 3 ? 3 : products.length); i++) {
          final p = products[i];
          Logger.d('Product ${i + 1} - ID: ${p['id']}, Title: ${p['title']}', tag: _tag);
        }
      } else {
        Logger.d('No products found in the database', tag: _tag);
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
      Logger.d('Creating new product: ${product.title}', tag: _tag);
      Logger.d('Product data: ${product.toJson()}', tag: _tag);
      
      final response = await _supabaseClient
          .from(_table)
          .insert(product.toJson())
          .select()
          .single();
      
      Logger.d('Successfully created product with ID: ${response['id']}', tag: _tag);
      return response;
    } on PostgrestException catch (e) {
      Logger.e('Failed to create product: ${e.message}', StackTrace.current, tag: _tag);
      throw ServerException(e.message);
    } catch (e, stackTrace) {
      Logger.e('Unexpected error creating product: $e', stackTrace, tag: _tag);
      throw ServerException('Failed to create product');
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
      
      await _supabaseClient
          .from(_table)
          .delete()
          .eq('id', id);
      
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
