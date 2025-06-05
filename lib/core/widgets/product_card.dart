import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../features/products/domain/entities/product.dart';
import '../animations/app_animations.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../presentation/widgets/app_button.dart' show AppButton, AppButtonVariant;

class ProductCard extends ConsumerWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onWishlistTap;
  final bool isInWishlist;
  final bool showWishlistButton;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onWishlistTap,
    this.isInWishlist = false,
    this.showWishlistButton = true,
    this.borderRadius,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final cardWidth = width ?? (size.width / 2) - 24;
    
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: cardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Wishlist Button
            Stack(
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.radiusL),
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: CachedNetworkImage(
                      imageUrl: product.images.isNotEmpty 
                          ? product.images.first 
                          : 'https://via.placeholder.com/300x400',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.error_outline, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                
                // Wishlist Button
                if (showWishlistButton)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: AppButton.icon(
                      icon: isInWishlist ? Icons.favorite : Icons.favorite_border,
                      onPressed: onWishlistTap,
                      tooltip: isInWishlist ? 'Remove from wishlist' : 'Add to wishlist',
                      variant: isInWishlist ? AppButtonVariant.danger : AppButtonVariant.text,
                      size: 36.0,
                      iconSize: 20.0,
                    ),
                  ),
                
                // Only One Tag with animation
                if (product.isOnlyOne)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: AppAnimations.scaleIn(
                      delay: 0.3,
                      beginScale: 0.8,
                      endScale: 1.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'רק אחד נשאר!',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 1),
                                blurRadius: 4,
                                // ignore: deprecated_member_use
                                color: Colors.black.withOpacity(0.2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Product Title
            Text(
              product.title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            // Product Price
            Text(
              '₪${product.price.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            
            // Seller Info
            if (product.sellerName != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    // Seller Avatar
                    if (product.sellerAvatar != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: CircleAvatar(
                          radius: 10,
                          backgroundImage: CachedNetworkImageProvider(
                            product.sellerAvatar!,
                          ),
                        ),
                      ),
                    
                    // Seller Name
                    Expanded(
                      child: Text(
                        product.sellerName!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
