import 'package:rivo/features/purchase/domain/models/purchase_model.dart';

abstract class PurchaseRepository {
  /// Purchases a product by its ID
  /// 
  /// Returns a [PurchaseResult] indicating success or failure
  /// 
  /// Throws [Exception] if there's an error during the purchase process
  Future<PurchaseResult> purchaseProduct(String productId);
}
