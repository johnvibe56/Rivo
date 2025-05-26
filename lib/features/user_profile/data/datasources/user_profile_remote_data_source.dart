import 'package:rivo/features/products/domain/models/product_model.dart';

abstract class UserProfileRemoteDataSource {
  Future<List<Product>> getUserProducts(String userId);
}
