// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PurchaseImpl _$$PurchaseImplFromJson(Map<String, dynamic> json) =>
    _$PurchaseImpl(
      id: json['id'] as String,
      buyerId: json['buyerId'] as String,
      productId: json['productId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: $enumDecode(_$PurchaseStatusEnumMap, json['status']),
      transactionId: json['transactionId'] as String?,
      errorMessage: json['errorMessage'] as String?,
      productStatus: json['productStatus'] as String?,
    );

Map<String, dynamic> _$$PurchaseImplToJson(_$PurchaseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'buyerId': instance.buyerId,
      'productId': instance.productId,
      'createdAt': instance.createdAt.toIso8601String(),
      'status': _$PurchaseStatusEnumMap[instance.status]!,
      'transactionId': instance.transactionId,
      'errorMessage': instance.errorMessage,
      'productStatus': instance.productStatus,
    };

const _$PurchaseStatusEnumMap = {
  PurchaseStatus.pending: 'pending',
  PurchaseStatus.completed: 'completed',
  PurchaseStatus.failed: 'failed',
};

_$PurchaseResultImpl _$$PurchaseResultImplFromJson(Map<String, dynamic> json) =>
    _$PurchaseResultImpl(
      alreadyPurchased: json['alreadyPurchased'] as bool? ?? false,
      purchase: json['purchase'] == null
          ? null
          : Purchase.fromJson(json['purchase'] as Map<String, dynamic>),
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$$PurchaseResultImplToJson(
        _$PurchaseResultImpl instance) =>
    <String, dynamic>{
      'alreadyPurchased': instance.alreadyPurchased,
      'purchase': instance.purchase,
      'errorMessage': instance.errorMessage,
    };
