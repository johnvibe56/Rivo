import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rivo/features/feed/presentation/widgets/marketplace_post_card.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final PageController _pageController = PageController();
  List<Product> _products = [];
  final Set<String> _favoriteProductIds = {};
  Timer? _autoPlayTimer;
  int _currentPage = 0;
  bool _isUserScrolling = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _startAutoPlay();
  }
  
  Future<void> _loadProducts() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _products = List.generate(10, (index) => Product.mock());
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoPlayTimer?.cancel();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!_isUserScrolling && _currentPage < _products.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else if (!_isUserScrolling && _currentPage == _products.length - 1) {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _onScrollStart() {
    setState(() {
      _isUserScrolling = true;
    });
    _autoPlayTimer?.cancel();
  }

  void _onScrollEnd() {
    setState(() {
      _isUserScrolling = false;
    });
    _startAutoPlay();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Marketplace',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white, size: 28),
              onPressed: () {
                // TODO: Implement search
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Search coming soon!')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 28),
              onPressed: () {
                // TODO: Navigate to cart
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cart is empty')),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                if (notification.metrics.pixels < -100) {
                  // User pulled down far enough to trigger refresh
                  _loadProducts();
                  return true;
                }
              }
              return false;
            },
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: _products.length,
                  onPageChanged: _onPageChanged,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                final product = _products[index];
                final isFavorite = _favoriteProductIds.contains(product.id);
                
                return MarketplacePostCard(
                  product: product,
                  onFavorite: () {
                    setState(() {
                      if (isFavorite) {
                        _favoriteProductIds.remove(product.id);
                      } else {
                        _favoriteProductIds.add(product.id);
                      }
                    });
                  },
                  onMessage: () {
                    // TODO: Navigate to chat with seller
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening chat with seller...')),
                    );
                  },
                  onBuy: () {
                    // TODO: Handle purchase flow
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Adding ${product.title} to cart...'),
                        action: SnackBarAction(
                          label: 'Checkout',
                          onPressed: () {
                            // TODO: Navigate to checkout
                          },
                        ),
                      ),
                    );
                      },
                    );
                  },
                ),
                if (_products.isEmpty)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
