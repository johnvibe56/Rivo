import 'package:equatable/equatable.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';

enum ProductFeedStatus { initial, loading, success, failure, loadingMore }

class ProductFeedState extends Equatable {
  final List<Product> products;
  final ProductFeedStatus status;
  final bool hasReachedEnd;
  final String? errorMessage;
  final int currentPage;
  final int itemsPerPage;

  const ProductFeedState({
    this.products = const [],
    this.status = ProductFeedStatus.initial,
    this.hasReachedEnd = false,
    this.errorMessage,
    this.currentPage = 1,
    this.itemsPerPage = 10,
  });

  bool get isInitial => status == ProductFeedStatus.initial;
  bool get isLoading => status == ProductFeedStatus.loading;
  bool get isLoadingMore => status == ProductFeedStatus.loadingMore;
  bool get isSuccess => status == ProductFeedStatus.success;
  bool get isFailure => status == ProductFeedStatus.failure;

  ProductFeedState copyWith({
    List<Product>? products,
    ProductFeedStatus? status,
    bool? hasReachedEnd,
    String? errorMessage,
    int? currentPage,
    int? itemsPerPage,
  }) {
    return ProductFeedState(
      products: products ?? this.products,
      status: status ?? this.status,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
    );
  }

  @override
  List<Object?> get props => [
        products,
        status,
        hasReachedEnd,
        errorMessage,
        currentPage,
        itemsPerPage,
      ];
}
