import 'package:dartz/dartz.dart';
import 'package:rivo/core/error/failures.dart';
import 'package:rivo/features/purchase_history/domain/models/purchase_with_product_model.dart';

abstract class PurchaseHistoryRepository {
  /// Fetches the purchase history for the current user
  /// Returns a list of [PurchaseWithProduct] on success
  /// Returns a [Failure] on error
  Future<Either<Failure, List<PurchaseWithProduct>>> getPurchaseHistory();
}
