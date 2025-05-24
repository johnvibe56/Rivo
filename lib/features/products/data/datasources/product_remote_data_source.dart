import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';

class ProductRemoteDataSource {
  final SupabaseClient _supabaseClient;

  ProductRemoteDataSource() : _supabaseClient = Supabase.instance.client;

  static const String _table = 'products';

  Future<List<Map<String, dynamic>>> getProducts() async {
    final response = await _supabaseClient
        .from(_table)
        .select()
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
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
    final response = await _supabaseClient
        .from(_table)
        .insert(product.toJson())
        .select()
        .single();
    
    return response;
  }

  Future<Map<String, dynamic>> updateProduct(Product product) async {
    final response = await _supabaseClient
        .from(_table)
        .update(product.toJson())
        .eq('id', product.id)
        .select()
        .single();
    
    return response;
  }

  Future<void> deleteProduct(String id) async {
    await _supabaseClient
        .from(_table)
        .delete()
        .eq('id', id);
  }

  Future<List<Map<String, dynamic>>> getProductsByUser(String userId) async {
    final response = await _supabaseClient
        .from(_table)
        .select()
        .eq('owner_id', userId)
        .order('created_at', ascending: false);
    
    return response;
  }

  Future<void> toggleLike(String productId, String userId) async {
    await _supabaseClient.rpc('toggle_array_item', params: {
      'table_name': _table,
      'column_name': 'liked_by',
      'row_id': productId,
      'item': userId,
    });
  }

  Future<void> toggleSave(String productId, String userId) async {
    await _supabaseClient.rpc('toggle_array_item', params: {
      'table_name': _table,
      'column_name': 'saved_by',
      'row_id': productId,
      'item': userId,
    });
  }
}
