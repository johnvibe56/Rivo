import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';

class MarketplacePostCard extends StatelessWidget {
  final Product product;
  final VoidCallback onFavorite;
  final VoidCallback onMessage;
  final VoidCallback onBuy;

  const MarketplacePostCard({
    super.key,
    required this.product,
    required this.onFavorite,
    required this.onMessage,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Stack(
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
                    // Favorite Button
                    _buildActionButton(
                      icon: Icons.favorite_border,
                      onPressed: onFavorite,
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Message Button
                    _buildActionButton(
                      icon: Icons.message,
                      onPressed: onMessage,
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
      ],
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
