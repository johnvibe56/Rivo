import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo/features/auth/presentation/providers/auth_provider.dart';
import 'package:rivo/features/follow/presentation/widgets/follow_button.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';
import 'package:rivo/features/purchase/purchase.dart';

class ProductUtils {
  static bool isLikedByUser(Product product, String? userId) {
    if (userId == null) return false;
    return product.likedBy.contains(userId);
  }

  static int likeCount(Product product) {
    return product.likedBy.length;
  }

  static int saveCount(Product product) {
    return product.savedBy.length;
  }

  static bool isSavedByUser(Product product, String? userId) {
    if (userId == null) return false;
    return product.savedBy.contains(userId);
  }

  static String formatPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }

  static String getShortDescription(String description) {
    return description.length > 100
        ? '${description.substring(0, 100)}...'
        : description;
  }
}

class ProductCard extends ConsumerStatefulWidget {
  final Product product;
  final bool showUserActions;
  final bool showPurchaseButton;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.showUserActions = true,
    this.showPurchaseButton = true,
    this.onTap,
  });

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  late final Product product;
  late final bool showUserActions;
  late final bool showPurchaseButton;
  late final VoidCallback? onTap;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    product = widget.product;
    showUserActions = widget.showUserActions;
    showPurchaseButton = widget.showPurchaseButton;
    onTap = widget.onTap;
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onPressed,
    int count = 0,
    Color? color,
    bool isLoading = false,
    bool isPrimary = false,
    String? label,
  }) {
    // Create a wrapper that prevents event propagation
    void handleTap() {
      onPressed();
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: TextButton(
        onPressed: isLoading ? null : handleTap,
        style: TextButton.styleFrom(
          foregroundColor: isPrimary 
              ? Colors.white 
              : color ?? Theme.of(context).textTheme.bodyLarge?.color,
          backgroundColor: isPrimary 
              ? Colors.transparent 
              : null,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: const Size(40, 40),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isPrimary ? Colors.white : (color ?? Theme.of(context).colorScheme.primary),
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isPrimary ? Colors.white : null,
                  ),
                  if (label != null) ...[
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        color: isPrimary ? Colors.white : null,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ] else if (count > 0) ...[
                    const SizedBox(width: 4),
                    Text(
                      count.toString(),
                      style: TextStyle(
                        color: isPrimary ? Colors.white : null,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  void handleLike() {
    if (_currentUser == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleLike(ref, _currentUser!.id);
    });
  }

  void handleSave() {
    if (_currentUser == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleSave(ref, _currentUser!.id);
    });
  }

  void handlePurchase() {
    if (_currentUser == null) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in to make a purchase')),
          );
        });
      }
      return;
    }

    if (_currentUser!.id == product.ownerId) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You cannot purchase your own product')),
          );
        });
      }
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPurchase();
    });
  }

  Future<void> _startPurchase() async {
    try {
      await ref.read(purchaseProductProvider(product.id).notifier).purchaseProduct();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase successful!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    _currentUser = authState.valueOrNull?.user;

    final isLiked = ProductUtils.isLikedByUser(product, _currentUser?.id);
    final likeCount = ProductUtils.likeCount(product);
    final saveCount = ProductUtils.saveCount(product);
    final isSaved = ProductUtils.isSavedByUser(product, _currentUser?.id);

    // Debug prints
    debugPrint('showPurchaseButton: $showPurchaseButton');
    debugPrint('Current user ID: ${_currentUser?.id}');
    debugPrint('Product owner ID: ${product.ownerId}');
    debugPrint('Show purchase button: ${showPurchaseButton && _currentUser?.id != product.ownerId}');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 400,
            minHeight: 320, // Increased minimum height to ensure space for buttons
          ),
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
                          const SizedBox(height: 8),
                          Text(
                            ProductUtils.getShortDescription(product.description),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                        
                        // Seller and Follow Button
                        if (showUserActions) ...[
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const CircleAvatar(
                                radius: 12,
                                backgroundImage: NetworkImage(
                                  'https://via.placeholder.com/48',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  product.ownerName.isNotEmpty
                                      ? product.ownerName
                                      : 'User ${product.ownerId.substring(0, 8)}',
                                  style: const TextStyle(fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_currentUser?.id != product.ownerId) ...[
                                FollowButton(
                                  sellerId: product.ownerId,
                                  size: 24,
                                  iconSize: 14,
                                  showText: false,
                                ),
                              ] else ...[
                                Text(
                                  ' (You)',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                        
                        // Action Buttons
                        if (showUserActions) ...[
                          const Divider(height: 12, thickness: 1),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTapDown: (_) => handleLike(),
                                  behavior: HitTestBehavior.opaque,
                                  child: _buildActionButton(
                                    context: context,
                                    icon: isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isLiked ? Colors.red : null,
                                    count: likeCount,
                                    onPressed: handleLike,
                                  ),
                                ),
                                GestureDetector(
                                  onTapDown: (_) => handleSave(),
                                  behavior: HitTestBehavior.opaque,
                                  child: _buildActionButton(
                                    context: context,
                                    icon: isSaved
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    count: saveCount,
                                    onPressed: handleSave,
                                  ),
                                ),
                                // Show purchase button only for products the user doesn't own
                                if (_currentUser?.id != product.ownerId)
                                  Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Theme.of(context).colorScheme.primary,
                                          Theme.of(context).colorScheme.primary.withAlpha((0.8 * 255).round()),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context).colorScheme.primary.withAlpha((0.3 * 255).round()),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: GestureDetector(
                                      onTapDown: (_) => handlePurchase(),
                                      behavior: HitTestBehavior.opaque,
                                      child: _buildActionButton(
                                        context: context,
                                        icon: Icons.shopping_cart,
                                        onPressed: handlePurchase,
                                        color: Colors.white,
                                        isPrimary: true,
                                        label: 'Buy',
                                      ),
                                    ),
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

  Future<void> _handleLike(WidgetRef ref, String userId) async {
    try {
      // TODO: Implement like functionality
      debugPrint('Liked product: ${product.id}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to like: $e')),
        );
      }
    }
  }

  Future<void> _handleSave(WidgetRef ref, String userId) async {
    try {
      // TODO: Implement save functionality
      debugPrint('Saved product: ${product.id}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }
  
  // Keeping this for future implementation
  // void _navigateToSellerProfile(BuildContext context, Product product) {
  //   // TODO: Implement navigation to seller profile
  //   debugPrint('Navigate to seller profile: ${product.ownerId}');
  // }
}
