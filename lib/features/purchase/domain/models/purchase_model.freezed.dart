// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'purchase_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Purchase _$PurchaseFromJson(Map<String, dynamic> json) {
  return _Purchase.fromJson(json);
}

/// @nodoc
mixin _$Purchase {
  String get id => throw _privateConstructorUsedError;
  String get buyerId => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  PurchaseStatus get status => throw _privateConstructorUsedError;
  String? get transactionId => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  String? get productStatus => throw _privateConstructorUsedError;

  /// Serializes this Purchase to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Purchase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PurchaseCopyWith<Purchase> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PurchaseCopyWith<$Res> {
  factory $PurchaseCopyWith(Purchase value, $Res Function(Purchase) then) =
      _$PurchaseCopyWithImpl<$Res, Purchase>;
  @useResult
  $Res call(
      {String id,
      String buyerId,
      String productId,
      DateTime createdAt,
      PurchaseStatus status,
      String? transactionId,
      String? errorMessage,
      String? productStatus});
}

/// @nodoc
class _$PurchaseCopyWithImpl<$Res, $Val extends Purchase>
    implements $PurchaseCopyWith<$Res> {
  _$PurchaseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Purchase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? buyerId = null,
    Object? productId = null,
    Object? createdAt = null,
    Object? status = null,
    Object? transactionId = freezed,
    Object? errorMessage = freezed,
    Object? productStatus = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      buyerId: null == buyerId
          ? _value.buyerId
          : buyerId // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PurchaseStatus,
      transactionId: freezed == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      productStatus: freezed == productStatus
          ? _value.productStatus
          : productStatus // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PurchaseImplCopyWith<$Res>
    implements $PurchaseCopyWith<$Res> {
  factory _$$PurchaseImplCopyWith(
          _$PurchaseImpl value, $Res Function(_$PurchaseImpl) then) =
      __$$PurchaseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String buyerId,
      String productId,
      DateTime createdAt,
      PurchaseStatus status,
      String? transactionId,
      String? errorMessage,
      String? productStatus});
}

/// @nodoc
class __$$PurchaseImplCopyWithImpl<$Res>
    extends _$PurchaseCopyWithImpl<$Res, _$PurchaseImpl>
    implements _$$PurchaseImplCopyWith<$Res> {
  __$$PurchaseImplCopyWithImpl(
      _$PurchaseImpl _value, $Res Function(_$PurchaseImpl) _then)
      : super(_value, _then);

  /// Create a copy of Purchase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? buyerId = null,
    Object? productId = null,
    Object? createdAt = null,
    Object? status = null,
    Object? transactionId = freezed,
    Object? errorMessage = freezed,
    Object? productStatus = freezed,
  }) {
    return _then(_$PurchaseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      buyerId: null == buyerId
          ? _value.buyerId
          : buyerId // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PurchaseStatus,
      transactionId: freezed == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      productStatus: freezed == productStatus
          ? _value.productStatus
          : productStatus // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PurchaseImpl implements _Purchase {
  const _$PurchaseImpl(
      {required this.id,
      required this.buyerId,
      required this.productId,
      required this.createdAt,
      required this.status,
      this.transactionId,
      this.errorMessage,
      this.productStatus});

  factory _$PurchaseImpl.fromJson(Map<String, dynamic> json) =>
      _$$PurchaseImplFromJson(json);

  @override
  final String id;
  @override
  final String buyerId;
  @override
  final String productId;
  @override
  final DateTime createdAt;
  @override
  final PurchaseStatus status;
  @override
  final String? transactionId;
  @override
  final String? errorMessage;
  @override
  final String? productStatus;

  @override
  String toString() {
    return 'Purchase(id: $id, buyerId: $buyerId, productId: $productId, createdAt: $createdAt, status: $status, transactionId: $transactionId, errorMessage: $errorMessage, productStatus: $productStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PurchaseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.buyerId, buyerId) || other.buyerId == buyerId) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.productStatus, productStatus) ||
                other.productStatus == productStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, buyerId, productId,
      createdAt, status, transactionId, errorMessage, productStatus);

  /// Create a copy of Purchase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PurchaseImplCopyWith<_$PurchaseImpl> get copyWith =>
      __$$PurchaseImplCopyWithImpl<_$PurchaseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PurchaseImplToJson(
      this,
    );
  }
}

abstract class _Purchase implements Purchase {
  const factory _Purchase(
      {required final String id,
      required final String buyerId,
      required final String productId,
      required final DateTime createdAt,
      required final PurchaseStatus status,
      final String? transactionId,
      final String? errorMessage,
      final String? productStatus}) = _$PurchaseImpl;

  factory _Purchase.fromJson(Map<String, dynamic> json) =
      _$PurchaseImpl.fromJson;

  @override
  String get id;
  @override
  String get buyerId;
  @override
  String get productId;
  @override
  DateTime get createdAt;
  @override
  PurchaseStatus get status;
  @override
  String? get transactionId;
  @override
  String? get errorMessage;
  @override
  String? get productStatus;

  /// Create a copy of Purchase
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PurchaseImplCopyWith<_$PurchaseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PurchaseResult _$PurchaseResultFromJson(Map<String, dynamic> json) {
  return _PurchaseResult.fromJson(json);
}

/// @nodoc
mixin _$PurchaseResult {
  bool get alreadyPurchased => throw _privateConstructorUsedError;
  Purchase? get purchase => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Serializes this PurchaseResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PurchaseResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PurchaseResultCopyWith<PurchaseResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PurchaseResultCopyWith<$Res> {
  factory $PurchaseResultCopyWith(
          PurchaseResult value, $Res Function(PurchaseResult) then) =
      _$PurchaseResultCopyWithImpl<$Res, PurchaseResult>;
  @useResult
  $Res call({bool alreadyPurchased, Purchase? purchase, String? errorMessage});

  $PurchaseCopyWith<$Res>? get purchase;
}

/// @nodoc
class _$PurchaseResultCopyWithImpl<$Res, $Val extends PurchaseResult>
    implements $PurchaseResultCopyWith<$Res> {
  _$PurchaseResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PurchaseResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? alreadyPurchased = null,
    Object? purchase = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      alreadyPurchased: null == alreadyPurchased
          ? _value.alreadyPurchased
          : alreadyPurchased // ignore: cast_nullable_to_non_nullable
              as bool,
      purchase: freezed == purchase
          ? _value.purchase
          : purchase // ignore: cast_nullable_to_non_nullable
              as Purchase?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of PurchaseResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PurchaseCopyWith<$Res>? get purchase {
    if (_value.purchase == null) {
      return null;
    }

    return $PurchaseCopyWith<$Res>(_value.purchase!, (value) {
      return _then(_value.copyWith(purchase: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PurchaseResultImplCopyWith<$Res>
    implements $PurchaseResultCopyWith<$Res> {
  factory _$$PurchaseResultImplCopyWith(_$PurchaseResultImpl value,
          $Res Function(_$PurchaseResultImpl) then) =
      __$$PurchaseResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool alreadyPurchased, Purchase? purchase, String? errorMessage});

  @override
  $PurchaseCopyWith<$Res>? get purchase;
}

/// @nodoc
class __$$PurchaseResultImplCopyWithImpl<$Res>
    extends _$PurchaseResultCopyWithImpl<$Res, _$PurchaseResultImpl>
    implements _$$PurchaseResultImplCopyWith<$Res> {
  __$$PurchaseResultImplCopyWithImpl(
      _$PurchaseResultImpl _value, $Res Function(_$PurchaseResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of PurchaseResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? alreadyPurchased = null,
    Object? purchase = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_$PurchaseResultImpl(
      alreadyPurchased: null == alreadyPurchased
          ? _value.alreadyPurchased
          : alreadyPurchased // ignore: cast_nullable_to_non_nullable
              as bool,
      purchase: freezed == purchase
          ? _value.purchase
          : purchase // ignore: cast_nullable_to_non_nullable
              as Purchase?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PurchaseResultImpl extends _PurchaseResult {
  const _$PurchaseResultImpl(
      {this.alreadyPurchased = false, this.purchase, this.errorMessage})
      : super._();

  factory _$PurchaseResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$PurchaseResultImplFromJson(json);

  @override
  @JsonKey()
  final bool alreadyPurchased;
  @override
  final Purchase? purchase;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'PurchaseResult(alreadyPurchased: $alreadyPurchased, purchase: $purchase, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PurchaseResultImpl &&
            (identical(other.alreadyPurchased, alreadyPurchased) ||
                other.alreadyPurchased == alreadyPurchased) &&
            (identical(other.purchase, purchase) ||
                other.purchase == purchase) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, alreadyPurchased, purchase, errorMessage);

  /// Create a copy of PurchaseResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PurchaseResultImplCopyWith<_$PurchaseResultImpl> get copyWith =>
      __$$PurchaseResultImplCopyWithImpl<_$PurchaseResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PurchaseResultImplToJson(
      this,
    );
  }
}

abstract class _PurchaseResult extends PurchaseResult {
  const factory _PurchaseResult(
      {final bool alreadyPurchased,
      final Purchase? purchase,
      final String? errorMessage}) = _$PurchaseResultImpl;
  const _PurchaseResult._() : super._();

  factory _PurchaseResult.fromJson(Map<String, dynamic> json) =
      _$PurchaseResultImpl.fromJson;

  @override
  bool get alreadyPurchased;
  @override
  Purchase? get purchase;
  @override
  String? get errorMessage;

  /// Create a copy of PurchaseResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PurchaseResultImplCopyWith<_$PurchaseResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
