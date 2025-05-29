import 'package:rivo/core/error/exceptions.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductRemoteDataSource {
  final SupabaseClient _supabaseClient;
  final String _table = 'products';

  ProductRemoteDataSource() : _supabaseClient = Supabase.instance.client;

  Future<List<Product>> getProducts({int page = 1, int limit = 10}) async {
    try {
      // First, try to get products with profiles join
      try {
        final response = await _supabaseClient
            .from(_table)
            .select('*, profiles!left(*)')
            .order('created_at', ascending: false)
            .range((page - 1) * limit, page * limit - 1);

        return response.map((json) => Product.fromJson(json)).toList();
      } on PostgrestException {
        // If join fails, try without the join
        final response = await _supabaseClient
            .from(_table)
            .select('*')
            .order('created_at', ascending: false)
            .range((page - 1) * limit, page * limit - 1);

        return response.map((json) => Product.fromJson(json)).toList();
      }
    } on PostgrestException catch (e) {
      throw ServerException(e.message, StackTrace.current);
    } catch (e, stackTrace) {
      throw ServerException('Failed to fetch products', stackTrace);
    }
  }

  Future<Map<String, dynamic>> getProductById(String id) async {
    try {
      
      // First try with profiles join
      try {
        final response = await _supabaseClient
            .from(_table)
            .select('*, profiles!left(*)')
            .eq('id', id)
            .single();

        return response;
      } on PostgrestException {
        // If join fails, try without it
        final response = await _supabaseClient
            .from(_table)
            .select('*')
            .eq('id', id)
            .single();

        return response;
      }
    } on PostgrestException catch (e) {
      throw ServerException(e.message, StackTrace.current);
    } catch (e, stackTrace) {
      throw ServerException('Failed to fetch product', stackTrace);
    }
  }

  Future<Map<String, dynamic>> createProduct(Product product) async {
    try {
      final response = await _supabaseClient
          .from(_table)
          .insert(product.toJson())
          .select()
          .single();

      return response;
    } on PostgrestException catch (e) {
      throw ServerException(e.message, StackTrace.current);
    } catch (e, stackTrace) {
      throw ServerException('Failed to create product', stackTrace);
    }
  }

  Future<Map<String, dynamic>> updateProduct(Product product) async {
    try {
      final response = await _supabaseClient
          .from(_table)
          .update(product.toJson())
          .eq('id', product.id)
          .select()
          .single();

      return response;
    } on PostgrestException catch (e) {
      throw ServerException(e.message, StackTrace.current);
    } catch (e, stackTrace) {
      throw ServerException('Failed to update product', stackTrace);
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _supabaseClient
          .from(_table)
          .delete()
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, StackTrace.current);
    } catch (e, stackTrace) {
      throw ServerException('Failed to delete product', stackTrace);
    }
  }

  Future<List<Map<String, dynamic>>> getProductsByUser(String userId) async {
    try {
      final response = await _supabaseClient
          .from(_table)
          .select('*')
          .eq('owner_id', userId)
          .order('created_at', ascending: false);

      return response;
    } on PostgrestException catch (e) {
      throw ServerException(e.message, StackTrace.current);
    } catch (e, stackTrace) {
      throw ServerException('Failed to fetch user products', stackTrace);
    }
  }

  Future<bool> toggleLike(String productId, String userId) async {
    try {
      // Check if the like already exists
      final existingLike = await _supabaseClient
          .from('likes')
          .select()
          .eq('product_id', productId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingLike != null) {
        // Unlike
        await _supabaseClient
            .from('likes')
            .delete()
            .eq('product_id', productId)
            .eq('user_id', userId);
        return false;
      } else {
        // Like
        await _supabaseClient
            .from('likes')
            .insert({
              'product_id': productId,
              'user_id': userId,
              'created_at': DateTime.now().toIso8601String(),
            });
        return true;
      }
    } on PostgrestException catch (e) {
      throw ServerException(e.message, StackTrace.current);
    } catch (e, stackTrace) {
      throw ServerException('Failed to toggle like', stackTrace);
    }
  }

  Future<bool> toggleSave(String productId, String userId) async {
    try {
      // Check if the save already exists
      final existingSave = await _supabaseClient
          .from('saves')
          .select()
          .eq('product_id', productId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingSave != null) {
        // Unsave
        await _supabaseClient
            .from('saves')
            .delete()
            .eq('product_id', productId)
            .eq('user_id', userId);
        return false;
      } else {
        // Save
        await _supabaseClient
            .from('saves')
            .insert({
              'product_id': productId,
              'user_id': userId,
              'created_at': DateTime.now().toIso8601String(),
            });
        return true;
      }
    } on PostgrestException catch (e) {
      throw ServerException(e.message, StackTrace.current);
    } catch (e, stackTrace) {
      throw ServerException('Failed to toggle save', stackTrace);
    }
  }
}
