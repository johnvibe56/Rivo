import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo/features/product_feed/domain/models/product_feed_state.dart';
import 'package:rivo/features/product_feed/presentation/providers/product_feed_provider.dart';
import 'package:rivo/features/products/presentation/widgets/product_card.dart';

class ProductFeedScreen extends ConsumerStatefulWidget {
  const ProductFeedScreen({super.key});

  @override
  ConsumerState<ProductFeedScreen> createState() => _ProductFeedScreenState();
}

class _ProductFeedScreenState extends ConsumerState<ProductFeedScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load initial products if not already loaded
    Future.microtask(() => ref.read(productFeedNotifierProvider.notifier).loadInitialProducts());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final threshold = 0.9 * maxScroll;

    if (currentScroll >= threshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });

    await ref.read(productFeedNotifierProvider.notifier).loadMoreProducts();
    
    if (mounted) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(productFeedNotifierProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productFeedNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
          ),
        ],
      ),
      body: _buildBody(AsyncValue.data(state)),
    );
  }

  Widget _buildBody(AsyncValue<ProductFeedState> state) {
    return state.when(
      data: (feedState) => _buildProductGrid(feedState),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error loading products',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref
                  .read(productFeedNotifierProvider.notifier)
                  .loadInitialProducts(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid(ProductFeedState state) {
    if (state.products.isEmpty && state.status == ProductFeedStatus.success) {
      return const Center(child: Text('No products found'));
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: state.products.length + (state.hasReachedEnd ? 0 : 1),
        itemBuilder: (context, index) {
          if (index >= state.products.length) {
            return _buildLoadingIndicator();
          }
          return ProductCard(product: state.products[index]);
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
