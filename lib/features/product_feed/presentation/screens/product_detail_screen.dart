import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo/core/error/failures.dart';
import 'package:rivo/features/auth/presentation/providers/auth_provider.dart';
import 'package:rivo/features/product_feed/presentation/providers/product_detail_provider.dart';
import 'package:rivo/features/products/presentation/providers/delete_product_provider.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';
import 'package:rivo/features/products/domain/utils/product_utils.dart';
import 'package:rivo/core/presentation/widgets/app_button.dart';
import 'package:rivo/l10n/app_localizations.dart';

  // Format relative time with localization
  String formatRelativeTime(DateTime dateTime, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    final l10n = AppLocalizations.of(context)!;
    
    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return l10n.monthsAgo(months);
    } else if (difference.inDays > 0) {
      return l10n.daysAgo(difference.inDays);
    } else if (difference.inHours > 0) {
      return l10n.hoursAgo(difference.inHours);
    } else if (difference.inMinutes > 0) {
      return l10n.minutesAgo(difference.inMinutes);
    } else {
      return l10n.justNow;
    }
  }

class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));
    final currentUser = ref.watch(authStateProvider).valueOrNull?.user;
    final isDeleted = ref.watch(deletedProductsProvider).contains(productId);
    final l10n = AppLocalizations.of(context)!;

    // Handle case where product was deleted
    if (isDeleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.productNoLongerAvailable),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.productDetails),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8.0),
            child: AppButton.secondary(
              onPressed: () {
                // TODO: Share product
              },
              label: l10n.share,
              height: 36,
            ),
          ),
        ],
      ),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) {
          // If product is not found, show a message and pop back
          if (error is Failure && error.message.contains('not found')) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.productNoLongerExists)),
              );
            });
            return const SizedBox.shrink();
          }
          
          // For other errors, show error UI with retry option
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  l10n.failedToLoadProduct,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  error is Failure ? error.message : l10n.unexpectedError,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                AppButton.primary(
                  onPressed: () => ref.refresh(productDetailProvider(productId)),
                  label: l10n.retry,
                ),
              ],
            ),
          );
        },
        data: (product) {
          return _buildProductDetails(context, ref, product, currentUser?.id);
        },
      ),
    );
  }

  Widget _buildProductDetails(
    BuildContext context,
    WidgetRef ref,
    Product product,
    String? currentUserId,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isLiked = ProductUtils.isLikedByUser(product, currentUserId);
    final isSaved = ProductUtils.isSavedByUser(product, currentUserId);
    final likeCount = ProductUtils.likeCount(product);
    final saveCount = ProductUtils.saveCount(product);
    
    Future<void> handleLike() async {
      try {
        await ref.read(likeProductProvider(product.id).future);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e is Failure ? e.message : l10n.failedToLikeProduct),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
    
    Future<void> handleSave() async {
      try {
        await ref.read(saveProductProvider(product.id).future);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e is Failure ? e.message : l10n.failedToSaveProduct),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product Image
          AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.image_not_supported,
                  size: 48,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          
          // Product Info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Price
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Action Buttons
                _buildActionButtons(
                  context: context,
                  onLike: handleLike,
                  onSave: handleSave,
                  isLiked: isLiked,
                  isSaved: isSaved,
                  likeCount: likeCount,
                  saveCount: saveCount,
                  isAuthenticated: currentUserId != null,
                ),
                
                const SizedBox(height: 16),
                
                // Buy Now and Add to Cart Buttons
                Row(
                  children: [
                    Expanded(
                      child: AppButton.secondary(
                        onPressed: () {
                          // TODO: Add to cart functionality
                        },
                        label: l10n.addToCart,
                        icon: Icons.add_shopping_cart,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppButton.primary(
                        onPressed: () {
                          // TODO: Buy now functionality
                        },
                        label: l10n.buyNow,
                      ),
                    ),
                  ],
                ),
                
                const Divider(height: 32),
                
                // Description
                _buildSectionTitle(context, l10n.description),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Seller Info
                _buildSectionTitle(context, l10n.sellerInformation),
                const SizedBox(height: 8),
                _buildSellerInfo(context, product, currentUserId),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  Widget _buildActionButtons({
    required BuildContext context,
    required VoidCallback onLike,
    required VoidCallback onSave,
    required bool isLiked,
    required bool isSaved,
    required int likeCount,
    required int saveCount,
    required bool isAuthenticated,
  }) {
    final l10n = AppLocalizations.of(context)!;
    
    return Row(
      children: [
        // Like Button
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton.icon(
              icon: isLiked ? Icons.favorite : Icons.favorite_border,
              tooltip: isLiked ? l10n.unlike : l10n.like,
              onPressed: isAuthenticated ? onLike : null,

            ),
            const SizedBox(width: 4),
            Text(
              likeCount.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        
        const SizedBox(width: 16),
        
        // Save Button
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton.icon(
              icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
              tooltip: isSaved ? l10n.unsave : l10n.save,
              onPressed: isAuthenticated ? onSave : null,
            ),
            const SizedBox(width: 4),
            Text(
              saveCount.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildSellerInfo(BuildContext context, Product product, String? currentUserId) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Text(
          product.ownerId[0].toUpperCase(),
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        '${l10n.user} ${product.ownerId.substring(0, 6)}',
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Text(
        '${l10n.posted} ${formatRelativeTime(product.createdAt, context)}',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: currentUserId != null && currentUserId != product.ownerId
          ? AppButton.secondary(
              onPressed: () {
                // TODO: Navigate to chat
              },
              label: l10n.chat,
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            )
          : null,
    );
  }
}
