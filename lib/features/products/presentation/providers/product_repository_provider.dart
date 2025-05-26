import 'package:rivo/features/products/data/repositories/product_repository_impl.dart';
import 'package:rivo/features/products/domain/repositories/product_repository.dart';
import 'package:rivo/features/products/data/datasources/product_remote_data_source.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_repository_provider.g.dart';

@riverpod
ProductRepository productRepository(ProductRepositoryRef ref) {
  final remoteDataSource = ProductRemoteDataSource();
  return ProductRepositoryImpl(remoteDataSource: remoteDataSource);
}
