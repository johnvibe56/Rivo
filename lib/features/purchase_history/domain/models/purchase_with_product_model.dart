import 'package:freezed_annotation/freezed_annotation.dart';

part 'purchase_with_product_model.freezed.dart';
part 'purchase_with_product_model.g.dart';

@freezed
class PurchaseWithProduct with _$PurchaseWithProduct {
  const factory PurchaseWithProduct({
    required String id,
    required DateTime createdAt,
    required ProductDetails? product,
  }) = _PurchaseWithProduct;

  factory PurchaseWithProduct.fromJson(Map<String, dynamic> json) => 
      _$PurchaseWithProductFromJson(json);
}

@freezed
class ProductDetails with _$ProductDetails {
  const factory ProductDetails({
    required String id,
    String? name,
    String? imageUrl,
    double? price,
  }) = _ProductDetails;

  factory ProductDetails.fromJson(Map<String, dynamic> json) => 
      _$ProductDetailsFromJson(json);
}
