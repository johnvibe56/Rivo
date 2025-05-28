import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo/features/auth/presentation/providers/auth_provider.dart';
import 'package:rivo/features/follow/presentation/widgets/follow_button.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';
import 'package:rivo/features/products/domain/utils/product_utils.dart';
import 'package:rivo/features/products/presentation/providers/product_repository_provider.dart';
import 'package:rivo/features/products/presentation/providers/product_providers.dart';
import 'package:rivo/core/router/app_router.dart';

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
    
    // Check if current user is the product owner
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
                        
                        // Seller and Follow Button
                        if (showUserActions) ...[
                          const SizedBox(height: 4),
                          SizedBox(
                            height: 24, // Fixed height for consistent row height
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _navigateToSellerProfile(context, product),
                                    child: Text(
                                      'Seller: ${product.ownerName.isNotEmpty ? product.ownerName : product.ownerId.substring(0, 8)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                if (currentUser?.id != product.ownerId) ...[
                                  const SizedBox(width: 8),
                                  Container(
color: Colors.red.withAlpha(76), // 0.3 opacity
                                    child: FollowButton(
                                      sellerId: product.ownerId,
                                      size: 24,
                                      iconSize: 14,
                                      showText: true, // Show text for debugging
                                      padding: const EdgeInsets.all(4),
                                    ),
                                  ),
                                ] else ...[
                                  // Debug info
                                  Text(
                                    ' (You)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                        
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

  void _navigateToSellerProfile(BuildContext context, Product product) {
    if (product.ownerId.isNotEmpty) {
      AppRouter.goToSellerProfile(
        context,
        sellerId: product.ownerId,
        displayName: product.ownerName.isNotEmpty ? product.ownerName : null,
      );
    }
  }

  Future<void> _handleSave(
    BuildContext context, 
    WidgetRef ref, 
    String userId,
  ) async {
    // Add a small delay to allow the UI to update
    await Future<void>.delayed(const Duration(milliseconds: 100));
    try {
      final repository = ref.read(productRepositoryRefProvider);
      final result = await repository.toggleSave(product.id, userId);

      if (!context.mounted) return;

      result.fold(
        (failure) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        (_) {
          // Invalidate relevant providers to refresh the UI
          ref.invalidate(productListNotifierProvider);
          ref.invalidate(productNotifierProvider(product.id));
          ref.invalidate(userProductsNotifierProvider(product.ownerId));
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while saving the product'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
