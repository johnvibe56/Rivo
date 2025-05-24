import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo/features/auth/presentation/providers/auth_provider.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';
import 'package:rivo/features/products/domain/utils/product_utils.dart';
import 'package:rivo/features/products/presentation/providers/product_providers.dart';

class ProductCard extends ConsumerWidget {
  final Product product;
  final VoidCallback? onTap;
  final bool showUserActions;

  const ProductCard({
    Key? key,
    required this.product,
    this.onTap,
    this.showUserActions = true,
  }) : super(key: key);

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
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 1,
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            
            // Product Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : null,
                          ),
                          onPressed: handleLike,
                        ),
                        Text(likeCount.toString()),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                          ),
                          onPressed: handleSave,
                        ),
                        Text(saveCount.toString()),
                      ],
                    ),
                  ],
                ],
              ),
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
      final result = await ref.read(productRepositoryProvider).toggleLike(product.id, userId);
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
      final result = await ref.read(productRepositoryProvider).toggleSave(product.id, userId);
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
