import 'package:dartz/dartz.dart';
import 'package:rivo/core/error/failures.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';

abstract class ProductFeedRepository {
  Future<Either<Failure, List<Product>>> getProducts({
    required int page,
    required int limit,
  });
}
