import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';
import 'package:rivo/core/error/failures.dart';
import 'package:rivo/features/auth/presentation/providers/auth_provider.dart';
import 'package:rivo/features/products/presentation/providers/product_providers.dart';

final productDetailProvider = FutureProvider.autoDispose.family<Product, String>((ref, productId) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getProductById(productId);
  return result.fold(
    (failure) => throw failure,
    (product) => product,
  );
});

final likeProductProvider = FutureProvider.family.autoDispose<void, String>((ref, productId) async {
  final repository = ref.read(productRepositoryProvider);
  final currentUser = ref.read(authStateProvider).valueOrNull?.user;
  if (currentUser == null) {
    throw const UnauthorizedFailure('Please sign in to like products');
  }
  await repository.toggleLike(productId, currentUser.id);
  ref.invalidate(productDetailProvider(productId));
});

final saveProductProvider = FutureProvider.family.autoDispose<void, String>((ref, productId) async {
  final repository = ref.read(productRepositoryProvider);
  final currentUser = ref.read(authStateProvider).valueOrNull?.user;
  if (currentUser == null) {
    throw const UnauthorizedFailure('Please sign in to save products');
  }
  await repository.toggleSave(productId, currentUser.id);
  ref.invalidate(productDetailProvider(productId));
});
