import 'package:flutter/foundation.dart';
import 'package:rivo/core/error/exceptions.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductRemoteDataSource {
  final SupabaseClient _supabaseClient;
  final String _table = 'products';
  final String _tag = 'ProductRemoteDataSource';

  ProductRemoteDataSource() : _supabaseClient = Supabase.instance.client;

  Future<List<Product>> getProducts({int page = 1, int limit = 10}) async {
    try {
      debugPrint('[$_tag] Fetching products (page: $page, limit: $limit)');
      
      // First, try to get products with user_profiles join
      try {
        final response = await _supabaseClient
            .from(_table)
            .select('*, user_profiles!left(*)')
            .order('created_at', ascending: false)
            .range((page - 1) * limit, page * limit - 1);

        debugPrint('✅ [$_tag] Successfully fetched ${response.length} products with user profiles');
        return response.map((json) => Product.fromJson(json)).toList();
      } on PostgrestException catch (e) {
        debugPrint('⚠️ [$_tag] Could not fetch with user_profiles join, trying without: ${e.message}');
        
        // If join fails, try without the join
        final response = await _supabaseClient
            .from(_table)
            .select('*')
            .order('created_at', ascending: false)
            .range((page - 1) * limit, page * limit - 1);

        debugPrint('✅ [$_tag] Successfully fetched ${response.length} products without user profiles');
        return response.map((json) => Product.fromJson(json)).toList();
      }
    } on PostgrestException catch (e) {
      debugPrint('❌ [$_tag] Failed to fetch products: ${e.message}');
      throw ServerException(e.message, StackTrace.current);
    } catch (e, stackTrace) {
      debugPrint('❌ [$_tag] Unexpected error fetching products: $e');
      throw ServerException('Failed to fetch products', stackTrace);
    }
  }

  Future<Map<String, dynamic>> getProductById(String id) async {
    try {
      debugPrint('[$_tag] Fetching product by ID: $id');
      
      // First try with user_profiles join
      try {
        final response = await _supabaseClient
            .from(_table)
            .select('*, user_profiles!left(*)')
            .eq('id', id)
            .single();

        debugPrint('✅ [$_tag] Successfully fetched product with user profile: $id');
        return response;
      } on PostgrestException catch (e) {
        debugPrint('⚠️ [$_tag] Could not fetch with user_profiles join, trying without: ${e.message}');
        
        // If join fails, try without it
        final response = await _supabaseClient
            .from(_table)
            .select('*')
            .eq('id', id)
            .single();

        debugPrint('✅ [$_tag] Successfully fetched product without user profile: $id');
        return response;
      }
    } on PostgrestException catch (e) {
      debugPrint('❌ [$_tag] Failed to fetch product: ${e.message}');
      throw ServerException(e.message, StackTrace.current);
    } catch (e, stackTrace) {
      debugPrint('❌ [$_tag] Unexpected error fetching product: $e');
      throw ServerException('Failed to fetch product', stackTrace);
    }
  }

  Future<Map<String, dynamic>> createProduct(Product product) async {
    try {
      debugPrint('[$_tag] Creating product: ${product.id}');
      
      final response = await _supabaseClient
          .from(_table)
          .insert(product.toJson())
          .select()
          .single();

      debugPrint('✅ [$_tag] Successfully created product: ${product.id}');
      return response;
    } on PostgrestException catch (e) {
      debugPrint('❌ [$_tag] Failed to create product: ${e.message}');
      throw ServerException(e.message, StackTrace.current);
    } catch (e, stackTrace) {
      debugPrint('❌ [$_tag] Unexpected error creating product: $e');
      throw ServerException('Failed to create product', stackTrace);
    }
  }

  Future<Map<String, dynamic>> updateProduct(Product product) async {
    try {
      debugPrint('[$_tag] Updating product: ${product.id}');
      
      final response = await _supabaseClient
          .from(_table)
          .update(product.toJson())
          .eq('id', product.id)
          .select()
          .single();

      debugPrint('✅ [$_tag] Successfully updated product: ${product.id}');
      return response;
    } on PostgrestException catch (e) {
      debugPrint('❌ [$_tag] Failed to update product: ${e.message}');
      throw ServerException(e.message, StackTrace.current);
    } catch (e, stackTrace) {
      debugPrint('❌ [$_tag] Unexpected error updating product: $e');
      throw ServerException('Failed to update product', stackTrace);
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      debugPrint('[$_tag] Deleting product: $id');
      
      await _supabaseClient
          .from(_table)
          .delete()
          .eq('id', id);

      debugPrint('✅ [$_tag] Successfully deleted product: $id');
    } on PostgrestException catch (e) {
      debugPrint('❌ [$_tag] Failed to delete product: ${e.message}');
      throw ServerException(e.message, StackTrace.current);
    } catch (e, stackTrace) {
      debugPrint('❌ [$_tag] Unexpected error deleting product: $e');
      throw ServerException('Failed to delete product', stackTrace);
    }
  }

  Future<List<Product>> getProductsByUser(String userId) async {
    try {
      debugPrint('[$_tag] Fetching products for user ID: $userId');
      
      final response = await _supabaseClient
          .from(_table)
          .select('*, user_profiles!inner(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      debugPrint('✅ [$_tag] Successfully fetched ${response.length} products for user ID: $userId');
      return response.map((json) => Product.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      debugPrint('❌ [$_tag] Failed to fetch user products: ${e.message}');
      debugPrint('❌ [$_tag] Stack trace: ${StackTrace.current}');
      throw ServerException(e.message, StackTrace.current);
    } catch (e, stackTrace) {
      debugPrint('❌ [$_tag] Unexpected error fetching user products: $e');
      debugPrint('❌ [$_tag] Stack trace: $stackTrace');
      throw ServerException('Failed to fetch user products', stackTrace);
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
      throw ServerException(e.message, StackTrace.current);
    } catch (e, stackTrace) {
      debugPrint('❌ [$_tag] Unexpected error toggling like: $e');
      debugPrint('❌ [$_tag] Stack trace: $stackTrace');
      throw ServerException('Failed to toggle like', stackTrace);
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
      throw ServerException(e.message, StackTrace.current);
    } catch (e, stackTrace) {
      debugPrint('❌ [$_tag] Unexpected error toggling save: $e');
      debugPrint('❌ [$_tag] Stack trace: $stackTrace');
      throw ServerException('Failed to toggle save', stackTrace);
    }
  }
}
