import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo/features/wishlist/presentation/providers/wishlist_providers.dart';

class WishlistButton extends ConsumerStatefulWidget {
  final String productId;
  final String userId;
  final double size;
  final Color? color;
  final Color? selectedColor;

  const WishlistButton({
    super.key,
    required this.productId,
    required this.userId,
    this.size = 24.0,
    this.color,
    this.selectedColor,
  });

  @override
  ConsumerState<WishlistButton> createState() => _WishlistButtonState();
}

class _WishlistButtonState extends ConsumerState<WishlistButton> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final wishlistAsync = ref.watch(wishlistNotifierProvider(widget.userId));
    
    return wishlistAsync.when(
      loading: () => _buildButton(isInWishlist: false, isLoading: true),
      error: (error, _) => _buildButton(
        isInWishlist: false,
        showError: true,
      ),
      data: (wishlist) {
        final isInWishlist = wishlist.contains(widget.productId);
        return _buildButton(
          isInWishlist: isInWishlist,
          isLoading: _isProcessing,
        );
      },
    );
  }

  Widget _buildButton({
    required bool isInWishlist,
    bool isLoading = false,
    bool showError = false,
  }) {
    final theme = Theme.of(context);
    final defaultColor = theme.colorScheme.onSurface;
    final color = widget.color ?? Color.lerp(
      defaultColor,
      Colors.transparent,
      0.3,
    )!;
    final selectedColor = widget.selectedColor ?? theme.colorScheme.error;

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(
            isInWishlist ? Icons.favorite : Icons.favorite_border,
            color: isInWishlist ? selectedColor : color,
            size: widget.size,
          ),
          onPressed: isLoading || _isProcessing
              ? null
              : () => _toggleWishlist(!isInWishlist),
        ),
        if (isLoading || _isProcessing)
          Positioned.fill(
            child: Center(
              child: SizedBox(
                width: widget.size * 0.6,
                height: widget.size * 0.6,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isInWishlist ? selectedColor : color,
                  ),
                ),
              ),
            ),
          ),
        if (showError)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _toggleWishlist(bool isAdding) async {
    if (_isProcessing || !mounted) return;
    
    debugPrint('[WishlistButton] Toggling wishlist for product ${widget.productId}');
    debugPrint('[WishlistButton] Current user ID: ${widget.userId}');
    debugPrint('[WishlistButton] Action: ${isAdding ? 'Add to' : 'Remove from'} wishlist');

    // Immediately update the UI for better responsiveness
    setState(() => _isProcessing = true);

    try {
      // Get the notifier and ensure it's ready
      final notifier = ref.read(wishlistNotifierProvider(widget.userId).notifier);
      debugPrint('[WishlistButton] Calling toggleWishlist on notifier');
      
      // Schedule the toggle to run after the current build phase
      await Future.delayed(Duration.zero, () {
        if (!mounted) return;
        notifier.toggleWishlist(widget.productId, widget.userId);
      });
      
      debugPrint('[WishlistButton] toggleWishlist completed successfully');
      
      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAdding ? 'Added to wishlist' : 'Removed from wishlist',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('[WishlistButton] Error in _toggleWishlist: $e');
      debugPrint(stackTrace.toString());
      
      // Show error feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to ${isAdding ? 'add to' : 'remove from'} wishlist',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
