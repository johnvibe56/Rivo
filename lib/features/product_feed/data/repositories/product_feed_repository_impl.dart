import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:rivo/core/error/exceptions.dart';
import 'package:rivo/core/error/failures.dart';
import 'package:rivo/features/product_feed/domain/repositories/product_feed_repository.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';
import 'package:uuid/uuid.dart';

class ProductFeedRepositoryImpl implements ProductFeedRepository {
  // Simulate network delay
  final Duration _delay = const Duration(milliseconds: 500);
  final int _totalMockProducts = 50;

  // Generate mock products
  List<Product> _generateMockProducts({required int start, required int limit}) {
    final end = (start + limit) > _totalMockProducts ? _totalMockProducts : start + limit;
    return List.generate(
      end - start,
      (index) => Product(
        id: const Uuid().v4(),
        title: 'Product ${start + index + 1}',
        description: 'This is a mock product description for product ${start + index + 1}.',
        price: 9.99 * (index % 5 + 1),
        imageUrl: 'https://picsum.photos/200/300?random=${start + index}',
        ownerId: 'mock_owner_id',
        likedBy: List.generate(3, (_) => 'user_${DateTime.now().millisecondsSinceEpoch}'),
        savedBy: List.generate(2, (_) => 'user_${DateTime.now().millisecondsSinceEpoch + 1}'),
        createdAt: DateTime.now(),
      ),
    );
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
        throw ServerException('Failed to load products');
      }

      // Generate mock products
      final start = (page - 1) * limit;
      final products = _generateMockProducts(start: start, limit: limit);

      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }
}
