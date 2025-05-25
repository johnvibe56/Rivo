import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo/core/utils/logger.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';

class ProductRemoteDataSource {
  final SupabaseClient _supabaseClient;
  final Logger _logger = Logger(tag: 'ProductRemoteDataSource');

  ProductRemoteDataSource() : _supabaseClient = Supabase.instance.client;

  static const String _table = 'products';

  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      _logger.d('Fetching products from Supabase...');
      print(' [DEBUG] ProductRemoteDataSource: Fetching products from Supabase...');
      
      // Get current user ID for debugging
      final currentUser = _supabaseClient.auth.currentUser;
      print(' [DEBUG] Current user: ${currentUser?.id}');
      
      print(' [DEBUG] Executing Supabase query...');
      final stopwatch = Stopwatch()..start();
      
      final response = await _supabaseClient
          .from(_table)
          .select('*')
          .order('created_at', ascending: false);
          
      stopwatch.stop();
      
      print(' [DEBUG] Supabase query took ${stopwatch.elapsedMilliseconds}ms');
      
      if (response == null) {
        _logger.e('No response from Supabase');
        throw ServerException('No response from server');
      }
      
      final products = List<Map<String, dynamic>>.from(response);
      
      print(' [DEBUG] Successfully fetched ${products.length} products from Supabase');
      
      if (products.isEmpty) {
        print(' [DEBUG] No products found in the database');
      } else {
        // Print details of all products for debugging
        print(' [DEBUG] Products found in database:');
        for (var i = 0; i < products.length; i++) {
          final p = products[i];
          print('  ${i + 1}. ID: ${p['id']}');
          print('     Title: "${p['title']}"');
          print('     Created: ${p['created_at']}');
          print('     Owner ID: ${p['owner_id']}');
          print('     Liked by: ${p['liked_by']} (type: ${p['liked_by']?.runtimeType})');
          print('     Saved by: ${p['saved_by']} (type: ${p['saved_by']?.runtimeType})');
        }
      }
      
      return products;
    } on PostgrestException catch (e) {
      _logger.e('Supabase error: ${e.message}');
      throw ServerException(e.message);
    } catch (e, stackTrace) {
      _logger.e('Failed to fetch products', error: e, stackTrace: stackTrace);
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
      Logger.d('➕ Creating new product: ${product.title}');
      Logger.d('Product data: ${product.toJson()}');
      
      final response = await _supabaseClient
          .from(_table)
          .insert(product.toJson())
          .select()
          .single();
      
      Logger.d('✅ Successfully created product with ID: ${response['id']}');
      return response;
    } catch (e, stackTrace) {
      Logger.e(e, stackTrace, tag: 'createProduct');
      rethrow;
    }
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
