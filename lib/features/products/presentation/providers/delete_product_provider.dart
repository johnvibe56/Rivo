import 'package:flutter/material.dart';
import 'package:rivo/core/utils/logger.dart';
import 'package:rivo/features/products/presentation/providers/product_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delete_product_provider.g.dart';

// State for delete product operation
@immutable
class DeleteProductState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final String? productId;

  const DeleteProductState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.productId,
  });

  DeleteProductState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    String? productId,
  }) {
    return DeleteProductState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      productId: productId ?? this.productId,
    );
  }
}

@riverpod
class DeleteProductNotifier extends _$DeleteProductNotifier {
  @override
  DeleteProductState build() {
    return const DeleteProductState();
  }

  /// Starts the deletion process for a product
  void startDeleting(String productId) {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
      productId: productId,
    );
  }

  /// Deletes a product
  Future<bool> deleteProduct(String productId) async {
    if (state.isLoading && state.productId == productId) return false;
    
    // Set initial loading state if not already set
    if (!state.isLoading) {
      startDeleting(productId);
    }

    // State is now managed by startDeleting method

    try {
      final productRepository = ref.read(productRepositoryProvider);
      final result = await productRepository.deleteProduct(productId);
      
      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
            productId: null,
          );
          return false;
        },
        (_) {
          state = state.copyWith(
            isLoading: false,
            successMessage: 'Product deleted successfully',
            productId: null,
          );
          return true;
        },
      );
    } catch (e, stackTrace) {
      Logger.e('Error deleting product: $e', stackTrace);
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to delete product. Please try again.',
        productId: null,
      );
      return false;
    }
  }

  void reset() {
    state = const DeleteProductState();
  }
}

// Provider for the delete product function
@riverpod
Future<bool> deleteProductFunction(DeleteProductFunctionRef ref, String productId) async {
  try {
    final notifier = ref.read(deleteProductNotifierProvider.notifier);
    await notifier.deleteProduct(productId);
    return true;
  } catch (e) {
    return false;
  }
}

/// Provider to check if a product is being deleted
final isDeletingProductProvider = Provider.family<bool, String>(
  (ref, productId) {
    final state = ref.watch(deleteProductNotifierProvider);
    return state.isLoading;
  },
);
