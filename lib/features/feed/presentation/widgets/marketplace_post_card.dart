import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo/features/follow/presentation/widgets/follow_button.dart';
import 'package:rivo/features/purchase/presentation/providers/purchase_provider.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';
// Removed unused import
import 'package:rivo/features/products/presentation/providers/delete_product_provider.dart';
import 'package:rivo/features/products/presentation/providers/product_providers.dart';
import 'package:rivo/features/wishlist/presentation/widgets/wishlist_button.dart';

/// Provider for checking if a product is being deleted
final isDeletingProductProvider = Provider.family<bool, String>((ref, productId) {
  final state = ref.watch(deleteProductNotifierProvider);
  return state.isLoading && state.productId == productId;
});

class MarketplacePostCard extends ConsumerWidget {
  // Helper method to check if product is sold (case-insensitive)
  bool _isProductSold(Product product) {
    final status = product.status?.toLowerCase().trim() ?? '';
    final isSold = status == 'sold' || status == 'purchased' || status == 'sold out';
    
    if (kDebugMode) {
      debugPrint('\n=== Product Status Check ===');
      debugPrint('Product ID: ${product.id}');
      debugPrint('Title: ${product.title}');
      debugPrint('Raw status: ${product.status}');
      debugPrint('Normalized status: $status');
      debugPrint('Is sold: $isSold');
      debugPrint('==========================\n');
    }
    
    return isSold;
  }

  final Product product;
  final String userId;
  final bool showWishlistButton;
  final VoidCallback? onMessage;
  final VoidCallback? onBuy;
  final VoidCallback? onTap;

  const MarketplacePostCard({
    super.key,
    required this.product,
    required this.userId,
    this.showWishlistButton = false,
    this.onMessage,
    this.onBuy,
    this.onTap,
  });

  void _navigateToSellerProfile(BuildContext context) {
    if (product.ownerId.isNotEmpty) {
      // Navigate to the seller profile using the correct route
      context.go(
        '/user/${product.ownerId}',
      );
    }
  }

  // Build delete button
  Widget _buildDeleteButton(BuildContext context, WidgetRef ref) {
    final isDeleting = ref.watch(isDeletingProductProvider(product.id));

    debugPrint('Rendering delete button for product: ${product.id}');
    debugPrint('Is current user owner: ${product.ownerId == userId}');
    debugPrint('Is deleting: $isDeleting');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDeleting ? null : () {
          debugPrint('Delete button tapped for product: ${product.id}');
          _confirmDelete(context, ref);
        },
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          child: isDeleting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.delete, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  // Show confirmation dialog before deleting
  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    // Check if already deleting
    final notifier = ref.read(deleteProductNotifierProvider.notifier);
    if (notifier.isDeleting(product.id)) {
      debugPrint('⚠️ [MarketplacePostCard] Product ${product.id} is already being deleted');
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    
    try {
      // Call the delete product function
      final success = await notifier.deleteProduct(product.id);
      
      if (!context.mounted) return;
      
      if (success) {
        // Only show success message if the widget is still in the tree
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product deleted successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );

          // Notify parent widget about the deletion
          if (onTap != null) {
            onTap!();
          }
        }
      } else {
        // Show error message from state if available
        final errorMessage = ref.read(deleteProductNotifierProvider).errorMessage;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage ?? 'An unexpected error occurred while deleting the product'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [MarketplacePostCard] Error in _confirmDelete: $e');
      debugPrint('Stack trace: $stackTrace');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (context.mounted) {
        // Reset the delete state
        ref.read(deleteProductNotifierProvider.notifier).reset();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Calculate button visibility
    final bool isOwner = userId == product.ownerId;
    final bool isSold = _isProductSold(product);
    final bool showButton = !isOwner && !isSold;
    
    // Debug log the product status
    if (kDebugMode) {
      debugPrint('\n=== MarketplacePostCard Debug Info ===');
      debugPrint('Product ID: ${product.id}');
      debugPrint('Title: ${product.title}');
      debugPrint('Status: ${product.status}');
      debugPrint('Is sold: $isSold');
      debugPrint('User ID: $userId');
      debugPrint('Owner ID: ${product.ownerId}');
      debugPrint('Is owner: $isOwner');
      debugPrint('Show button: $showButton');
      debugPrint('======================================\n');
    }

    return SizedBox(
      height: 500, // Fixed height for the card
      child: Stack(
        children: [
          // Main content with GestureDetector for the card tap
          Positioned.fill(
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Stack(
                children: [
                  // Product Image
                  Positioned.fill(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: product.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                        // SOLD overlay
                        if (_isProductSold(product))
                          Container(
                            color: Colors.black54,
                            child: Center(
                              child: Transform.rotate(
                                angle: -0.1, // Slight angle for visual appeal
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white, width: 3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'SOLD',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Gradient overlay
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Color.fromRGBO(0, 0, 0, 0.8),
                            Colors.transparent,
                            Colors.transparent,
                            Color.fromRGBO(0, 0, 0, 0.4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Delete button (only shown to owner)
          if (product.ownerId == userId && userId.isNotEmpty)
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.transparent,
                child: _buildDeleteButton(context, ref),
              ),
            ),

          // Product Info
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Title
                  Text(
                    product.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Description
                  Text(
                    product.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color.fromRGBO(255, 255, 255, 0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      // Wishlist button (only show if enabled and user is logged in)
                      if (showWishlistButton && userId.isNotEmpty)
                        WishlistButton(
                          productId: product.id,
                          userId: userId,
                          size: 32,
                          selectedColor: Colors.red,
                          color: Colors.white,
                        ),

                      const SizedBox(width: 12),

                      // Message Button
                      if (onMessage != null)
                        _buildActionButton(
                          icon: Icons.message,
                          onPressed: onMessage!,
                        ),

                      const Spacer(),

                      // Show Buy Button if user doesn't own the product and it's not sold
                      if (showButton)
                        Consumer(
                          builder: (context, ref, _) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                bool isLoading = false;

                                Future<void> handlePurchase() async {
                                  if (isLoading) return;
                                  
                                  if (userId.isEmpty) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Please log in to make a purchase')),
                                      );
                                    }
                                    return;
                                  }

                                  setState(() => isLoading = true);

                                  try {
                                    final provider = ref.read(purchaseProductProvider(product.id).notifier);
                                    final result = await provider.purchaseProduct();
                                    
                                    if (context.mounted) {
                                      result.when(
                                        data: (purchaseResult) async {
                                          if (purchaseResult.isSuccess) {
                                            // Show appropriate message based on whether this is a new purchase or existing one
                                            if (context.mounted) {
                                              final message = purchaseResult.isAlreadyPurchased
                                                  ? 'You have already purchased this item!'
                                                  : 'Purchase successful!';
                                              
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(message),
                                                  backgroundColor: purchaseResult.isAlreadyPurchased 
                                                      ? Colors.orange[800] 
                                                      : Colors.green,
                                                ),
                                              );
                                            }
                                            
                                            // Force a rebuild of this widget
                                            if (context.mounted) {
                                              setState(() {});
                                            }
                                            
                                            // Refresh the product list and product data in the background
                                            try {
                                              // Invalidate the product list provider to force a refresh
                                              ref.invalidate(productListNotifierProvider);
                                              
                                              // Refresh the current product
                                              final notifier = ref.read(productNotifierProvider(product.id).notifier);
                                              await notifier.getProduct(product.id);
                                              
                                              if (kDebugMode) {
                                                debugPrint('Product data refreshed after purchase');
                                              }
                                            } catch (e) {
                                              if (kDebugMode) {
                                                debugPrint('Error refreshing product data: $e');
                                              }
                                            }
                                          } else {
                                            // Handle failure case
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Purchase failed: ${purchaseResult.error ?? 'Unknown error'}'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                        loading: () {
                                          // This shouldn't happen here as we're after the operation
                                        },
                                        error: (error, stack) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Error: ${error.toString()}'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  } catch (e, stackTrace) {
                                    debugPrint('Purchase error: $e');
                                    debugPrint('Stack trace: $stackTrace');
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('An unexpected error occurred: ${e.toString()}'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (context.mounted) {
                                      setState(() => isLoading = false);
                                    }
                                  }
                                }

                                return ElevatedButton.icon(
                                  onPressed: handlePurchase,
                                  icon: isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Icon(Icons.shopping_bag_outlined),
                                  label: isLoading 
                                      ? const Text('Processing...') 
                                      : const Text('Buy Now'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Owner Info with Follow Button
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: CachedNetworkImageProvider(
                      'https://i.pravatar.cc/150?u=${product.ownerId}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _navigateToSellerProfile(context),
                    child: Text(
                      product.ownerName.isNotEmpty 
                          ? product.ownerName 
                          : 'User ${product.ownerId.substring(0, 8)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (product.ownerId != userId) 
                    FollowButton(
                      sellerId: product.ownerId,
                      size: 24,
                      iconSize: 12,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      showText: false,
                    ),
                ],
              ),
            ),
          ),

          // Removed duplicate buy button - using the one in the action buttons row instead
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}
