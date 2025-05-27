import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo/core/error/exceptions.dart';
import 'package:rivo/core/error/failures.dart';
import 'package:rivo/features/auth/presentation/providers/auth_provider.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';
import 'package:rivo/features/products/presentation/providers/delete_product_provider.dart';
import 'package:rivo/features/products/presentation/providers/product_repository_provider.dart';

final productDetailProvider = FutureProvider.autoDispose.family<Product, String>((ref, productId) async {
  // First check if the product was recently deleted
  final deleteNotifier = ref.read(deleteProductNotifierProvider.notifier);
  if (deleteNotifier.isProductDeleted(productId)) {
    debugPrint('ℹ️ [productDetailProvider] Product $productId was recently deleted');
    throw const NotFoundException('This product has been deleted');
  }
  
  final repository = ref.watch(productRepositoryRefProvider);
  final result = await repository.getProductById(productId);
  
  return result.fold(
    (failure) => throw failure,
    (product) => product ?? (throw const NotFoundException('Product not found')),
  );
});

final likeProductProvider = FutureProvider.family.autoDispose<void, String>((ref, productId) async {
  final repository = ref.read(productRepositoryRefProvider);
  final currentUser = ref.read(authStateProvider).valueOrNull?.user;
  if (currentUser == null) {
    throw const UnauthorizedFailure('Please sign in to like products');
  }
  await repository.toggleLike(productId, currentUser.id);
  ref.invalidate(productDetailProvider(productId));
});

final saveProductProvider = FutureProvider.family.autoDispose<void, String>((ref, productId) async {
  final repository = ref.read(productRepositoryRefProvider);
  final currentUser = ref.read(authStateProvider).valueOrNull?.user;
  if (currentUser == null) {
    throw const UnauthorizedFailure('Please sign in to save products');
  }
  await repository.toggleSave(productId, currentUser.id);
  ref.invalidate(productDetailProvider(productId));
});
