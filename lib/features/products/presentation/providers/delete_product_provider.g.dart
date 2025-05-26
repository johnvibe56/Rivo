// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_product_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deleteProductFunctionHash() =>
    r'33026ba3d43837878b606fcc90454b1fff779b46';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [deleteProductFunction].
@ProviderFor(deleteProductFunction)
const deleteProductFunctionProvider = DeleteProductFunctionFamily();

/// See also [deleteProductFunction].
class DeleteProductFunctionFamily extends Family<AsyncValue<bool>> {
  /// See also [deleteProductFunction].
  const DeleteProductFunctionFamily();

  /// See also [deleteProductFunction].
  DeleteProductFunctionProvider call(
    String productId,
  ) {
    return DeleteProductFunctionProvider(
      productId,
    );
  }

  @override
  DeleteProductFunctionProvider getProviderOverride(
    covariant DeleteProductFunctionProvider provider,
  ) {
    return call(
      provider.productId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'deleteProductFunctionProvider';
}

/// See also [deleteProductFunction].
class DeleteProductFunctionProvider extends AutoDisposeFutureProvider<bool> {
  /// See also [deleteProductFunction].
  DeleteProductFunctionProvider(
    String productId,
  ) : this._internal(
          (ref) => deleteProductFunction(
            ref as DeleteProductFunctionRef,
            productId,
          ),
          from: deleteProductFunctionProvider,
          name: r'deleteProductFunctionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$deleteProductFunctionHash,
          dependencies: DeleteProductFunctionFamily._dependencies,
          allTransitiveDependencies:
              DeleteProductFunctionFamily._allTransitiveDependencies,
          productId: productId,
        );

  DeleteProductFunctionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.productId,
  }) : super.internal();

  final String productId;

  @override
  Override overrideWith(
    FutureOr<bool> Function(DeleteProductFunctionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DeleteProductFunctionProvider._internal(
        (ref) => create(ref as DeleteProductFunctionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        productId: productId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _DeleteProductFunctionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteProductFunctionProvider &&
        other.productId == productId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, productId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DeleteProductFunctionRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `productId` of this provider.
  String get productId;
}

class _DeleteProductFunctionProviderElement
    extends AutoDisposeFutureProviderElement<bool>
    with DeleteProductFunctionRef {
  _DeleteProductFunctionProviderElement(super.provider);

  @override
  String get productId => (origin as DeleteProductFunctionProvider).productId;
}

String _$deleteProductNotifierHash() =>
    r'98147448b01e909e2a2ebf08032a04250748bd5b';

/// See also [DeleteProductNotifier].
@ProviderFor(DeleteProductNotifier)
final deleteProductNotifierProvider = AutoDisposeNotifierProvider<
    DeleteProductNotifier, DeleteProductState>.internal(
  DeleteProductNotifier.new,
  name: r'deleteProductNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deleteProductNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DeleteProductNotifier = AutoDisposeNotifier<DeleteProductState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
