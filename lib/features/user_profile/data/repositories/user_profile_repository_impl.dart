import 'package:rivo/core/error/failures.dart';
import 'package:rivo/core/utils/logger.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';
import 'package:rivo/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:rivo/features/user_profile/data/datasources/user_profile_remote_data_source.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource remoteDataSource;

  UserProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Product>> getUserProducts(String userId) async {
    try {
      Logger.d('Getting products for user: $userId');
      final products = await remoteDataSource.getUserProducts(userId);
      Logger.d('Successfully retrieved ${products.length} products');
      return products;
    } catch (e, stackTrace) {
      Logger.e('Error getting user products: $e', stackTrace);
      throw ServerFailure(e.toString());
    }
  }
}
