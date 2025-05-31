import 'package:freezed_annotation/freezed_annotation.dart';

part 'purchase_model.freezed.dart';
part 'purchase_model.g.dart';

// Purchase status enum
enum PurchaseStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
}

/// Represents a purchase transaction
@freezed
class Purchase with _$Purchase {
  const factory Purchase({
    required String id,
    required String buyerId,
    required String productId,
    required DateTime createdAt,
    required PurchaseStatus status,
    String? transactionId,
    String? errorMessage,
    String? productStatus,
  }) = _Purchase;

  factory Purchase.fromJson(Map<String, dynamic> json) =>
      _$PurchaseFromJson(json);
}

/// Represents the result of a purchase operation
@freezed
class PurchaseResult with _$PurchaseResult {
  const PurchaseResult._();
  
  const factory PurchaseResult({
    @Default(false) bool alreadyPurchased,
    Purchase? purchase,
    String? errorMessage,
  }) = _PurchaseResult;
  
  factory PurchaseResult.fromJson(Map<String, dynamic> json) => 
      _$PurchaseResultFromJson(json);
      
  /// Returns true if the operation was successful
  bool get isSuccess => errorMessage == null;
  
  /// Returns true if the product was already purchased
  bool get isAlreadyPurchased => alreadyPurchased;
  
  /// Returns the error message if the operation failed
  String? get error => errorMessage;
  
  /// Creates a failure result with the given error message
  factory PurchaseResult.failure(String message) {
    return PurchaseResult(
      alreadyPurchased: false,
      errorMessage: message,
    );
  }
  
  /// Creates a success result with the given purchase
  factory PurchaseResult.success({required Purchase purchase}) {
    return PurchaseResult(
      alreadyPurchased: false,
      purchase: purchase,
    );
  }
}