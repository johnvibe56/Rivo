import 'package:dartz/dartz.dart';
import 'package:rivo/core/error/exceptions.dart';
import 'package:rivo/core/error/failures.dart';
import 'package:rivo/core/utils/logger.dart';
import 'package:rivo/features/wishlist/data/datasources/wishlist_remote_data_source.dart';
import 'package:rivo/features/wishlist/domain/repositories/wishlist_repository.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  static const String _tag = 'WishlistRepository';
  final WishlistRemoteDataSource _remoteDataSource;

  WishlistRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, void>> toggleWishlistItem(String productId, String userId) async {
    try {
      await _remoteDataSource.toggleWishlistItem(productId, userId);
      return const Right(null);
    } on ServerException catch (e, stackTrace) {
      Logger.e('Failed to toggle wishlist item: ${e.message}', stackTrace, tag: _tag);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      Logger.e('Unexpected error in toggleWishlistItem', stackTrace, tag: _tag);
      return Left(ServerFailure('Failed to update wishlist'));
    }
  }

  @override
  Future<Either<Failure, bool>> isProductInWishlist(String productId, String userId) async {
    try {
      final isInWishlist = await _remoteDataSource.isProductInWishlist(productId, userId);
      return Right(isInWishlist);
    } on ServerException catch (e, stackTrace) {
      Logger.e('Failed to check wishlist status: ${e.message}', stackTrace, tag: _tag);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      Logger.e('Unexpected error in isProductInWishlist', stackTrace, tag: _tag);
      return Left(ServerFailure('Failed to check wishlist status'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getWishlistedProductIds(String userId) async {
    try {
      final productIds = await _remoteDataSource.getWishlistedProductIds(userId);
      return Right(productIds);
    } on ServerException catch (e, stackTrace) {
      Logger.e('Failed to get wishlisted products: ${e.message}', stackTrace, tag: _tag);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      Logger.e('Unexpected error in getWishlistedProductIds', stackTrace, tag: _tag);
      return Left(ServerFailure('Failed to load wishlist'));
    }
  }
}
