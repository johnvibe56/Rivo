import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rivo/core/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo/core/router/app_router.dart';
import 'package:rivo/features/feed/presentation/widgets/marketplace_post_card.dart';
import 'package:rivo/features/products/presentation/providers/product_providers.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final PageController _pageController = PageController();
  final Set<String> _favoriteProductIds = {};
  Timer? _autoPlayTimer;
  int _currentPage = 0;
  final bool _isUserScrolling = false;
  
  @override
  void initState() {
    super.initState();
    print('🚀 [DEBUG] FeedScreen: Initializing...');
    _startAutoPlay();
    
    // Print the current route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentRoute = ModalRoute.of(context)?.settings.name;
      print('📍 [DEBUG] Current route: $currentRoute');
      
      // Trigger initial load
      print('🔄 [DEBUG] FeedScreen: Triggering initial product load...');
      ref.read(productListNotifierProvider.notifier).refresh().then((_) {
        print('✅ [DEBUG] FeedScreen: Initial product load completed');
      }).catchError((error, stackTrace) {
        print('❌ [ERROR] FeedScreen: Failed to load products');
        print(error);
        print(stackTrace);
      });
    });
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
      if (!_isUserScrolling && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final products = ProviderScope.containerOf(context, listen: false)
              .read(productListNotifierProvider)
              .valueOrNull ?? [];
          if (products.isNotEmpty) {
            if (_currentPage < products.length - 1) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              _pageController.animateToPage(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          }
        });
      }
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final productsAsync = ref.watch(productListNotifierProvider);
        
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              context.go(AppRouter.getFullPath(AppRoutes.productUpload));
            },
            child: const Icon(Icons.add),
          ),
          body: productsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: $error', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      try {
                        // Show loading indicator
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('Refreshing products...'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        
                        // Trigger refresh and wait for it to complete
                        await ref.read(productListNotifierProvider.notifier).refresh();
                        
                        // Show success message
                        if (mounted) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('Products refreshed successfully!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      } catch (e) {
                        // Show error message if refresh fails
                        if (mounted) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text('Failed to refresh: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (products) {
              print('📊 [DEBUG] FeedScreen: Rendering ${products.length} products');
              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No products found', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => context.go(AppRouter.getFullPath(AppRoutes.productUpload)),
                        icon: const Icon(Icons.add),
                        label: const Text('Add your first product'),
                      ),
                    ],
                  ),
                );
              }
              // Update current page if needed
              if (_currentPage >= products.length && products.isNotEmpty) {
                _currentPage = 0;
              }
              
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
                        icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
                        onPressed: () async {
                          final scaffoldMessenger = ScaffoldMessenger.of(context);
                          try {
                            // Show loading indicator
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('Refreshing products...'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                            
                            // Trigger refresh using the notifier directly
                            await ref.read(productListNotifierProvider.notifier).refresh();
                            
                            // Show success message
                            if (mounted) {
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Products refreshed successfully!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          } catch (e) {
                            // Show error message if refresh fails
                            if (mounted) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text('Failed to refresh: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.white, size: 28),
                        onPressed: () {
                          // TODO: Implement search
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Search functionality coming soon!')),
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
                  // Add your feed content here
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(productListNotifierProvider.notifier).refresh();
                      },
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: _onPageChanged,
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return MarketplacePostCard(
                            product: product,
                            isFavorite: _favoriteProductIds.contains(product.id),
                            onFavoritePressed: () {
                              setState(() {
                                if (_favoriteProductIds.contains(product.id)) {
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
                              // TODO: Implement buy functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Buy functionality coming soon!')),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
