import 'package:rivo/core/error/exceptions.dart';
import 'package:rivo/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WishlistRemoteDataSource {
  final SupabaseClient _supabaseClient;
  static const String _table = 'wishlist';

  WishlistRemoteDataSource() : _supabaseClient = Supabase.instance.client;

  static const String _tag = 'WishlistRemoteDataSource';
  
  Future<void> toggleWishlistItem(String productId, String userId) async {
    Logger.d('toggleWishlistItem - productId: $productId, userId: $userId', tag: _tag);
    try {
      // First check if the item exists in the wishlist
      Logger.d('Checking if item exists in wishlist...', tag: _tag);
      final existingItem = await _supabaseClient
          .from(_table)
          .select()
          .eq('product_id', productId)
          .eq('user_id', userId);
          
      if (existingItem.isNotEmpty) {
        // Item exists, so remove it
        Logger.d('Item found, removing from wishlist...', tag: _tag);
        await _supabaseClient
            .from(_table)
            .delete()
            .eq('product_id', productId)
            .eq('user_id', userId);
        Logger.d('Successfully removed item from wishlist', tag: _tag);
      } else {
        // Item doesn't exist, so add it
        Logger.d('Item not found, adding to wishlist...', tag: _tag);
        await _supabaseClient.from(_table).insert({
          'product_id': productId,
          'user_id': userId,
        });
        Logger.d('Successfully added item to wishlist', tag: _tag);
      }
    } catch (e, stackTrace) {
      Logger.e('Error in toggleWishlistItem: $e', stackTrace, tag: _tag);
      throw ServerException(e.toString(), stackTrace);
    }
  }

  Future<bool> isProductInWishlist(String productId, String userId) async {
    Logger.d('isProductInWishlist - productId: $productId, userId: $userId', tag: _tag);
    try {
      final response = await _supabaseClient
          .from(_table)
          .select()
          .eq('product_id', productId)
          .eq('user_id', userId);

      final isInWishlist = response.isNotEmpty;
      Logger.d('isProductInWishlist result: $isInWishlist', tag: _tag);
      return isInWishlist;
    } catch (e, stackTrace) {
      Logger.e('Error in isProductInWishlist: $e', stackTrace, tag: _tag);
      throw ServerException(e.toString(), stackTrace);
    }
  }

  Future<List<String>> getWishlistedProductIds(String userId) async {
    Logger.d('getWishlistedProductIds - userId: $userId', tag: _tag);
    try {
      final response = await _supabaseClient
          .from(_table)
          .select('product_id')
          .eq('user_id', userId);

      final productIds = response.map((item) => item['product_id'] as String).toList();
      Logger.d('Found ${productIds.length} wishlisted products', tag: _tag);
      return productIds;
    } catch (e, stackTrace) {
      Logger.e('Error in getWishlistedProductIds: $e', stackTrace, tag: _tag);
      throw ServerException(e.toString(), stackTrace);
    }
  }
}
