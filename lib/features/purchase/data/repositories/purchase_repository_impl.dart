import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo/features/purchase/domain/models/purchase_model.dart';
import 'package:rivo/features/purchase/domain/repositories/purchase_repository.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  final SupabaseClient _supabaseClient;

  PurchaseRepositoryImpl({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  
  // lib/features/purchase/data/repositories/purchase_repository_impl.dart
@override
Future<PurchaseResult> purchaseProduct(String productId) async {
  try {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      return const PurchaseResult(
        alreadyPurchased: false,
        errorMessage: 'User not authenticated',
      );
    }

    debugPrint('Calling purchase_product with buyer_id: $userId, product_id: $productId');
    
    final response = await _supabaseClient.rpc<Map<String, dynamic>>(
      'purchase_product',
      params: {
        '_buyer_id': userId,
        '_product_id': productId,
      },
    ).single();

    debugPrint('Raw RPC response: $response');
    
    // Convert response to Map
    final responseMap = Map<String, dynamic>.from(response);
    
    final alreadyPurchased = responseMap['alreadyPurchased'] == true;
    
    return PurchaseResult(
      alreadyPurchased: alreadyPurchased,
      purchase: alreadyPurchased 
          ? null 
          : Purchase(
              id: '', // The server should return this in a real implementation
              buyerId: userId,
              productId: productId,
              status: PurchaseStatus.completed,
              createdAt: DateTime.now(),
            ),
    );
  } on PostgrestException catch (e) {
    debugPrint('Supabase error: ${e.message}');
    return PurchaseResult(
      alreadyPurchased: false,
      errorMessage: 'Failed to complete purchase: ${e.message}',
    );
  } catch (e, stackTrace) {
    debugPrint('Unexpected error: $e\n$stackTrace');
    return PurchaseResult(
      alreadyPurchased: false,
      errorMessage: 'An unexpected error occurred',
    );
  }
}
  

}
