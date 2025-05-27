import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo/features/auth/presentation/providers/auth_provider.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';
import 'package:rivo/features/products/domain/utils/product_utils.dart';
import 'package:rivo/features/products/presentation/providers/product_providers.dart';
import 'package:rivo/features/products/presentation/providers/product_repository_provider.dart';

class ProductCard extends ConsumerWidget {
  final Product product;
  final VoidCallback? onTap;
  final bool showUserActions;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.showUserActions = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final currentUser = authState.valueOrNull?.user;
    final isLiked = ProductUtils.isLikedByUser(product, currentUser?.id);
    final likeCount = ProductUtils.likeCount(product);
    final saveCount = ProductUtils.saveCount(product);
    final isSaved = ProductUtils.isSavedByUser(product, currentUser?.id);

    Future<void> handleLike() async {
      final userId = currentUser?.id;
      if (userId != null) {
        await _handleLike(context, ref, userId);
      }
    }

    Future<void> handleSave() async {
      final userId = currentUser?.id;
      if (userId != null) {
        await _handleSave(context, ref, userId);
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap ?? () {
          // Use context.go for better navigation handling with GoRouter
          context.go('/product/${product.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12)),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              ),
              
              // Product Details
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title and Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                product.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              ProductUtils.formatPrice(product.price),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        
                        // Description
                        if (product.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            ProductUtils.getShortDescription(product.description),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        
                        // Like and Save Actions
                        if (showUserActions) ...[
                          const Divider(height: 16, thickness: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildActionButton(
                                  icon: isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isLiked ? Colors.red : null,
                                  count: likeCount,
                                  onPressed: handleLike,
                                ),
                                _buildActionButton(
                                  icon: isSaved
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  count: saveCount,
                                  onPressed: handleSave,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildActionButton({
    required IconData icon,
    required int count,
    Color? color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLike(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) async {
    try {
      final result = await ref.read(productRepositoryRefProvider).toggleLike(product.id, userId);
      if (!context.mounted) return;
      
      result.fold(
        (failure) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to toggle like: ${failure.message}')),
        ),
        (_) {
          ref.invalidate(productListNotifierProvider);
          ref.invalidate(productNotifierProvider(product.id));
          ref.invalidate(userProductsNotifierProvider(product.ownerId));
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred')),
        );
      }
    }
  }

  Future<void> _handleSave(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) async {
    try {
      final result = await ref.read(productRepositoryRefProvider).toggleSave(product.id, userId);
      if (!context.mounted) return;
      
      result.fold(
        (failure) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to toggle save: ${failure.message}')),
        ),
        (_) {
          ref.invalidate(productListNotifierProvider);
          ref.invalidate(productNotifierProvider(product.id));
          ref.invalidate(userProductsNotifierProvider(product.ownerId));
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred')),
        );
      }
    }
  }
}
