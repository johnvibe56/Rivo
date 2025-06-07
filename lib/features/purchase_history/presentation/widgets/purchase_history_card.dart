import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rivo/core/presentation/widgets/app_button.dart';
import 'package:rivo/core/utils/date_utils.dart' as date_utils;
import 'package:rivo/features/purchase_history/domain/models/purchase_with_product_model.dart';
import 'package:rivo/l10n/l10n.dart' show LocalizationExtension;

class PurchaseHistoryCard extends StatelessWidget {
  final PurchaseWithProduct purchase;
  final VoidCallback? onTap;

  const PurchaseHistoryCard({
    super.key,
    required this.purchase,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final formattedDate = date_utils.AppDateUtils.formatPurchaseDate(
      purchase.createdAt.toLocal(),
      context,
    );
    final purchaseDate = date_utils.AppDateUtils.getPurchasedOnText(
      formattedDate,
      context,
    );

    return Card(
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            textDirection: Directionality.of(context),
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildProductImage(theme),
              ),
              SizedBox(width: 16.w),
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (purchase.product == null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Product information is missing',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            purchase.product?.name ?? 'Unnamed Product',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            purchase.product?.price != null
                                ? '\$${purchase.product!.price!.toStringAsFixed(2)}'
                                : 'Price not available',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Purchased on: $purchaseDate',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(ThemeData theme) {
    // If product is null, show a placeholder
    if (purchase.product == null) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.shopping_bag_outlined, 
          size: 40,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    // Use a transparent placeholder while loading
    const placeholder = 'https://placehold.co/80x80/EFEFEF/AAAAAA?text=No+Image';
    final imageUrl = purchase.product?.imageUrl?.isNotEmpty == true
        ? purchase.product!.imageUrl!
        : placeholder;

    return Semantics(
      label: purchase.product?.name ?? 'Unnamed Product',
      child: Image.network(
        imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 80,
            height: 80,
            color: theme.colorScheme.surfaceContainerHighest,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image, 
                  size: 30,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 4),
                Text(
                  'No Image',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
