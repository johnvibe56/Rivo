import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';
import 'package:rivo/features/wishlist/presentation/widgets/wishlist_button.dart';

class MarketplacePostCard extends ConsumerWidget {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 500, // Fixed height for the card
        child: Stack(
          children: [
        // Product Image
        Positioned.fill(
          child: CachedNetworkImage(
            imageUrl: product.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
        
        // Gradient overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  const Color.fromRGBO(0, 0, 0, 0.8),
                  Colors.transparent,
                  Colors.transparent,
                  const Color.fromRGBO(0, 0, 0, 0.4),
                ],
              ),
            ),
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
                    
                    // Buy Button
                    ElevatedButton.icon(
                      onPressed: onBuy,
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: const Text('Buy Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Owner Info
        Positioned(
          top: 16,
          left: 16,
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: CachedNetworkImageProvider(
                  'https://i.pravatar.cc/150?u=${product.ownerId}',
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Seller ${product.ownerId.split('_').last}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        // Message and Buy buttons
        if (onMessage != null || onBuy != null)
          Positioned(
            bottom: 16,
            right: 16,
            child: Row(
              children: [
                // Message button
                if (onMessage != null)
                  FloatingActionButton.small(
                    heroTag: 'message_${product.id}',
                    onPressed: onMessage != null ? () => onMessage!() : null,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.message, color: Colors.black),
                  ),
                if (onMessage != null && onBuy != null) 
                  const SizedBox(width: 12),
                // Buy button
                if (onBuy != null)
                  FloatingActionButton(
                    heroTag: 'buy_${product.id}',
                    onPressed: onBuy != null ? () => onBuy!() : null,
                    backgroundColor: theme.colorScheme.primary,
                    child: const Icon(Icons.shopping_bag, color: Colors.white),
                  ),
              ],
            ),
          ),
        ],
      ),
    ));
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
