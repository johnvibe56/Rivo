import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final String productId;
  final String productName;
  final String productImage;
  final double productPrice;
  final int quantity;

  const CartItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.productPrice,
    this.quantity = 1,
  });

  CartItem copyWith({
    String? productId,
    String? productName,
    String? productImage,
    double? productPrice,
    int? quantity,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      productPrice: productPrice ?? this.productPrice,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'productPrice': productPrice,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productImage: json['productImage'] as String,
      productPrice: (json['productPrice'] as num).toDouble(),
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  @override
  List<Object?> get props => [productId];

  @override
  bool get stringify => true;
}
