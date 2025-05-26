import 'package:dartz/dartz.dart';
import 'package:rivo/core/error/failures.dart';

abstract class WishlistRepository {
  Future<Either<Failure, void>> toggleWishlistItem(String productId, String userId);
  Future<Either<Failure, bool>> isProductInWishlist(String productId, String userId);
  Future<Either<Failure, List<String>>> getWishlistedProductIds(String userId);
}
