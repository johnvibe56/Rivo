import 'package:rivo/core/error/failures.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';
import 'package:rivo/features/products/domain/repositories/product_repository.dart';
import 'package:dartz/dartz.dart';

class ToggleLikeUseCase {
  final ProductRepository repository;

  ToggleLikeUseCase(this.repository);

  Future<Either<Failure, void>> call(String productId, String userId) async {
    try {
      return await repository.toggleLike(productId, userId);
    } catch (e) {
      return Left(ServerFailure('Failed to toggle like'));
    }
  }
}

class ToggleSaveUseCase {
  final ProductRepository repository;

  ToggleSaveUseCase(this.repository);

  Future<Either<Failure, void>> call(String productId, String userId) async {
    try {
      return await repository.toggleSave(productId, userId);
    } catch (e) {
      return Left(ServerFailure('Failed to toggle save'));
    }
  }
}

class CreateProductUseCase {
  final ProductRepository repository;

  CreateProductUseCase(this.repository);

  Future<Either<Failure, Product>> call(Product product) async {
    try {
      return await repository.createProduct(product);
    } catch (e) {
      return Left(ServerFailure('Failed to create product'));
    }
  }
}

class UpdateProductUseCase {
  final ProductRepository repository;

  UpdateProductUseCase(this.repository);

  Future<Either<Failure, Product>> call(Product product) async {
    try {
      return await repository.updateProduct(product);
    } catch (e) {
      return Left(ServerFailure('Failed to update product'));
    }
  }
}

class DeleteProductUseCase {
  final ProductRepository repository;

  DeleteProductUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    try {
      return await repository.deleteProduct(id);
    } catch (e) {
      return Left(ServerFailure('Failed to delete product'));
    }
  }
}
