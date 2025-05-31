// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_with_product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PurchaseWithProductImpl _$$PurchaseWithProductImplFromJson(
        Map<String, dynamic> json) =>
    _$PurchaseWithProductImpl(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      product: json['product'] == null
          ? null
          : ProductDetails.fromJson(json['product'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$PurchaseWithProductImplToJson(
        _$PurchaseWithProductImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'product': instance.product,
    };

_$ProductDetailsImpl _$$ProductDetailsImplFromJson(Map<String, dynamic> json) =>
    _$ProductDetailsImpl(
      id: json['id'] as String,
      name: json['name'] as String?,
      imageUrl: json['image_url'] as String?,
      price: (json['price'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$ProductDetailsImplToJson(
        _$ProductDetailsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image_url': instance.imageUrl,
      'price': instance.price,
    };
