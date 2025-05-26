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
  static const String _tag = 'FeedScreen';
  final Set<String> _favoriteProductIds = {};
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Logger.d('Initializing...', tag: _tag);
    
    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
    
    // Log the current route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentRoute = ModalRoute.of(context)?.settings.name;
      Logger.d('Current route: $currentRoute', tag: _tag);
      
      // Trigger initial load
      _loadInitialProducts();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialProducts() async {
    Logger.d('Triggering initial product load...', tag: _tag);
    try {
      await ref.read(productListNotifierProvider.notifier).refresh();
      Logger.d('Initial product load completed', tag: _tag);
    } catch (error, stackTrace) {
      Logger.e('Failed to load products: $error', stackTrace, tag: _tag);
    }
  }

  void _onScroll() {
    if (_isLoading) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final delta = MediaQuery.of(context).size.height * 0.2; // Load more when 20% from bottom
    
    if (currentScroll >= (maxScroll - delta)) {
      _loadMoreProducts();
    }
  }
  
  Future<void> _loadMoreProducts() async {
    if (_isLoading) return;
    
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Load the next page of products
      await ref.read(productListNotifierProvider.notifier).loadMore();
    } catch (e, stackTrace) {
      Logger.e('Error loading more products: $e', stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load more products'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListNotifierProvider);
    final hasMore = ref.watch(
      productListNotifierProvider.select((value) {
        return value.maybeWhen(
          data: (products) => products.isNotEmpty && products.length % 10 == 0,
          orElse: () => false,
        );
      }),
    );

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
                onPressed: _loadInitialProducts,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (products) {
          Logger.d('Rendering ${products.length} products', tag: _tag);
          
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
                    onPressed: _loadInitialProducts,
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
              // Product list with pull-to-refresh
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadInitialProducts,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: products.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Show loading indicator at the bottom when there are more items to load
                      if (hasMore && index == products.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      
                      final product = products[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: MarketplacePostCard(
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
                        ),
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
  }
}
