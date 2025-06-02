import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo/features/product_feed/domain/models/product_model.dart';

// State class for product list
class ProductState {
  final List<Product> products;
  final bool isLoading;
  final bool hasError;
  final bool hasReachedMax;
  final int page;
  final String? errorMessage;

  const ProductState({
    this.products = const [],
    this.isLoading = false,
    this.hasError = false,
    this.hasReachedMax = false,
    this.page = 1,
    this.errorMessage,
  });

  ProductState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? hasError,
    bool? hasReachedMax,
    int? page,
    String? errorMessage,
  }) {
    return ProductState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Provider for product state
class ProductNotifier extends StateNotifier<ProductState> {
  ProductNotifier() : super(const ProductState());

  // Mock data generator
  List<Product> _generateMockProducts({int count = 10}) {
    return List.generate(count, (index) {
      final id = '${DateTime.now().millisecondsSinceEpoch}-$index';
      final price = (20 + (index * 5)).toDouble();
      final discount = index % 3 == 0 ? 10.0 : 0.0;
      
      return Product(
        id: id,
        name: 'מוצר ${index + 1}',
        description: 'תיאור מוצר ${index + 1}',
        price: price,
        imageUrl: 'https://picsum.photos/300/300?random=$index',
        category: 'קטגוריה ${index % 3 + 1}',
        discountPercentage: discount,
        quantity: index % 5,
      );
    });
  }

  // Fetch initial products
  Future<void> fetchProducts({bool refresh = false}) async {
    if (state.isLoading) return;

    try {
      state = state.copyWith(
        isLoading: true,
        hasError: false,
        errorMessage: null,
      );

      // Simulate network delay
      await Future<void>.delayed(const Duration(seconds: 1));

      final products = _generateMockProducts(count: 10);
      
      state = state.copyWith(
        products: products,
        isLoading: false,
        page: 1,
        hasReachedMax: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  // Load more products
  Future<void> loadMoreProducts() async {
    if (state.isLoading || state.hasReachedMax) return;

    try {
      state = state.copyWith(isLoading: true);

      // Simulate network delay
      await Future<void>.delayed(const Duration(seconds: 1));

      final newProducts = _generateMockProducts(count: 5);
      
      state = state.copyWith(
        products: [...state.products, ...newProducts],
        isLoading: false,
        page: state.page + 1,
        hasReachedMax: newProducts.isEmpty,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  // Toggle favorite status
  void toggleFavorite(String productId) {
    final products = List<Product>.from(state.products);
    final index = products.indexWhere((p) => p.id == productId);
    
    if (index != -1) {
      // In a real app, you would update this in your backend
      // This is just for demonstration
      state = state.copyWith(products: products);
    }
  }
}

// Provider for product state
final productProvider = StateNotifierProvider<ProductNotifier, ProductState>(
  (ref) => ProductNotifier(),
);
