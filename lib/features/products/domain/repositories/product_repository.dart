import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../models/product_model.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts({int page = 1, int limit = 10});
  Future<Either<Failure, Product?>> getProductById(String id);
  Future<Either<Failure, Product>> createProduct(Product product);
  Future<Either<Failure, Product>> updateProduct(Product product);
  Future<Either<Failure, void>> deleteProduct(String id);
  Future<Either<Failure, List<Product>>> getProductsByUser(String userId);
  Future<Either<Failure, void>> toggleLike(String productId, String userId);
  Future<Either<Failure, void>> toggleSave(String productId, String userId);
  
  /// Removes a product from all users' wishlists
  /// This should be called when a product is deleted
  Future<Either<Failure, void>> removeProductFromAllWishlists(String productId);
}
