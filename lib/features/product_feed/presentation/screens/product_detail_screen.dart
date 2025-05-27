import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo/core/error/failures.dart';
import 'package:rivo/features/auth/presentation/providers/auth_provider.dart';
import 'package:rivo/features/product_feed/presentation/providers/product_detail_provider.dart';
import 'package:rivo/features/products/presentation/providers/delete_product_provider.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';
import 'package:rivo/features/products/domain/utils/product_utils.dart';

// Temporary implementation of formatRelativeTime
String formatRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);
  
  if (difference.inDays > 30) {
    return '${(difference.inDays / 30).floor()} months ago';
  } else if (difference.inDays > 0) {
    return '${difference.inDays} days ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} hours ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} minutes ago';
  } else {
    return 'Just now';
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

    // Handle case where product was deleted
    if (isDeleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This product is no longer available')),
          );
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // TODO: Share product
            },
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
                const SnackBar(content: Text('This product no longer exists')),
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
                  'Failed to load product',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  error is Failure ? error.message : 'An unexpected error occurred',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(productDetailProvider(productId)),
                  child: const Text('Retry'),
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
              content: Text(e is Failure ? e.message : 'Failed to like product'),
              backgroundColor: Colors.red,
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
              content: Text(e is Failure ? e.message : 'Failed to save product'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

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
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported, size: 48),
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
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Like and Save Buttons
                Row(
                  children: [
                    // Like Button
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : null,
                      ),
                      onPressed: currentUserId == null 
                          ? null 
                          : handleLike,
                    ),
                    Text(likeCount.toString()),
                    
                    const SizedBox(width: 16),
                    
                    // Save Button
                    IconButton(
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: isSaved ? Theme.of(context).colorScheme.primary : null,
                      ),
                      onPressed: currentUserId == null 
                          ? null 
                          : handleSave,
                    ),
                    Text(saveCount.toString()),
                  ],
                ),
                
                const Divider(height: 32),
                
                // Description
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                
                const SizedBox(height: 24),
                
                // Seller Info
                Text(
                  'Seller Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    child: Text(product.ownerId[0].toUpperCase()),
                  ),
                  title: Text('User ${product.ownerId.substring(0, 6)}'),
                  subtitle: Text('Posted ${formatRelativeTime(product.createdAt)}'),
                  trailing: currentUserId != null && currentUserId != product.ownerId
                      ? TextButton(
                          onPressed: () {
                            // TODO: Navigate to chat
                          },
                          child: const Text('Chat'),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
