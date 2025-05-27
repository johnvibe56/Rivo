import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:rivo/core/error/exceptions.dart';
import 'package:rivo/core/error/failures.dart';
import 'package:rivo/features/product_feed/domain/repositories/product_feed_repository.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';
import 'package:uuid/uuid.dart';

class ProductFeedRepositoryImpl implements ProductFeedRepository {
  // Simulate network delay
  static const Duration _delay = Duration(milliseconds: 500);
  final int _totalMockProducts = 50;

  // Generate mock products
  List<Product> _generateMockProducts({required int start, required int limit}) {
    final end = (start + limit) > _totalMockProducts ? _totalMockProducts : start + limit;
    final now = DateTime.now();
    const mockOwnerId = 'mock_owner_id';
    
    final int itemCount = end - start;
    final List<Product> products = <Product>[]..length = itemCount;
    for (int index = 0; index < itemCount; index++) {
      final int productIndex = start + index;
      // Create a non-const Product since we have runtime values
      // ignore: prefer_const_constructors
      products[index] = Product(
        id: Uuid().v4(),
        title: 'Product ${productIndex + 1}',
        description: 'This is a mock product description for product ${productIndex + 1}.',
        price: 9.99 * (index % 5 + 1),
        imageUrl: 'https://picsum.photos/200/300?random=$productIndex',
        ownerId: mockOwnerId,
        likedBy: const <String>[],
        savedBy: const <String>[],
        createdAt: now.add(Duration(seconds: index)),
      );
    }
    return products;
  }

  @override
  Future<Either<Failure, List<Product>>> getProducts({
    required int page,
    required int limit,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(_delay);

      // Simulate error for testing (every 3rd page fails)
      if (page % 3 == 0) {
        throw const ServerException('Failed to load products');
      }

      // Generate mock products
      final start = (page - 1) * limit;
      final products = _generateMockProducts(start: start, limit: limit);

      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }
}
