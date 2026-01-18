// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$routineDetailHash() => r'd8013994a68cebc91e3f135d2c6a263f43a6caf2';

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

/// Provider for a single routine detail
///
/// Copied from [routineDetail].
@ProviderFor(routineDetail)
const routineDetailProvider = RoutineDetailFamily();

/// Provider for a single routine detail
///
/// Copied from [routineDetail].
class RoutineDetailFamily extends Family<AsyncValue<Routine>> {
  /// Provider for a single routine detail
  ///
  /// Copied from [routineDetail].
  const RoutineDetailFamily();

  /// Provider for a single routine detail
  ///
  /// Copied from [routineDetail].
  RoutineDetailProvider call(String routineId) {
    return RoutineDetailProvider(routineId);
  }

  @override
  RoutineDetailProvider getProviderOverride(
    covariant RoutineDetailProvider provider,
  ) {
    return call(provider.routineId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'routineDetailProvider';
}

/// Provider for a single routine detail
///
/// Copied from [routineDetail].
class RoutineDetailProvider extends AutoDisposeFutureProvider<Routine> {
  /// Provider for a single routine detail
  ///
  /// Copied from [routineDetail].
  RoutineDetailProvider(String routineId)
    : this._internal(
        (ref) => routineDetail(ref as RoutineDetailRef, routineId),
        from: routineDetailProvider,
        name: r'routineDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$routineDetailHash,
        dependencies: RoutineDetailFamily._dependencies,
        allTransitiveDependencies:
            RoutineDetailFamily._allTransitiveDependencies,
        routineId: routineId,
      );

  RoutineDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.routineId,
  }) : super.internal();

  final String routineId;

  @override
  Override overrideWith(
    FutureOr<Routine> Function(RoutineDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RoutineDetailProvider._internal(
        (ref) => create(ref as RoutineDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        routineId: routineId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Routine> createElement() {
    return _RoutineDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RoutineDetailProvider && other.routineId == routineId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, routineId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RoutineDetailRef on AutoDisposeFutureProviderRef<Routine> {
  /// The parameter `routineId` of this provider.
  String get routineId;
}

class _RoutineDetailProviderElement
    extends AutoDisposeFutureProviderElement<Routine>
    with RoutineDetailRef {
  _RoutineDetailProviderElement(super.provider);

  @override
  String get routineId => (origin as RoutineDetailProvider).routineId;
}

String _$routineListHash() => r'e734533b7927d3c8886be01d50fba205aacbc6a2';

/// Routine list provider with pagination
///
/// Copied from [RoutineList].
@ProviderFor(RoutineList)
final routineListProvider =
    AutoDisposeAsyncNotifierProvider<RoutineList, List<Routine>>.internal(
      RoutineList.new,
      name: r'routineListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$routineListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RoutineList = AutoDisposeAsyncNotifier<List<Routine>>;
String _$routineEditorHash() => r'03e7e1292707554ad0e9892d5c239bbf492c6c2f';

/// Routine editor notifier for create/edit flows
///
/// Copied from [RoutineEditor].
@ProviderFor(RoutineEditor)
final routineEditorProvider =
    AutoDisposeNotifierProvider<RoutineEditor, RoutineEditorState>.internal(
      RoutineEditor.new,
      name: r'routineEditorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$routineEditorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RoutineEditor = AutoDisposeNotifier<RoutineEditorState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
