import 'package:rivo/core/error/exceptions.dart';
import 'package:rivo/core/utils/logger.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';
import 'package:rivo/features/user_profile/data/datasources/user_profile_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  final SupabaseClient _supabaseClient;

  UserProfileRemoteDataSourceImpl({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  @override
  Future<List<Product>> getUserProducts(String userId) async {
    try {
      Logger.d('Fetching products for user: $userId');
      
      final response = await _supabaseClient
          .from('products')
          .select('*')
          .eq('owner_id', userId)
          .order('created_at', ascending: false);
      
      Logger.d('Raw response received');
      
      final List<Product> products = [];
      for (final item in response) {
        try {
          final product = Product.fromJson(item);
          products.add(product);
        } catch (e, stackTrace) {
          Logger.e('Error parsing product: $e', stackTrace);
          continue;
        }
      }
      
      Logger.d('Successfully parsed ${products.length} products');
      return products;
    } on PostgrestException catch (e) {
      Logger.e('Postgrest error fetching user products: ${e.message}', StackTrace.current);
      throw ServerException(e.message);
    } catch (e, stackTrace) {
      Logger.e('Error fetching user products: $e', stackTrace);
      throw ServerException(e.toString());
    }
  }
}
