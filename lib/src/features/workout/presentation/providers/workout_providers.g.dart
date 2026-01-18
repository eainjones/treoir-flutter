// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$workoutDetailHash() => r'1d90059cd853eeefe50900a2777c8554e0fe1d0c';

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

/// Provider for a single workout detail
///
/// Copied from [workoutDetail].
@ProviderFor(workoutDetail)
const workoutDetailProvider = WorkoutDetailFamily();

/// Provider for a single workout detail
///
/// Copied from [workoutDetail].
class WorkoutDetailFamily extends Family<AsyncValue<Workout>> {
  /// Provider for a single workout detail
  ///
  /// Copied from [workoutDetail].
  const WorkoutDetailFamily();

  /// Provider for a single workout detail
  ///
  /// Copied from [workoutDetail].
  WorkoutDetailProvider call(String workoutId) {
    return WorkoutDetailProvider(workoutId);
  }

  @override
  WorkoutDetailProvider getProviderOverride(
    covariant WorkoutDetailProvider provider,
  ) {
    return call(provider.workoutId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'workoutDetailProvider';
}

/// Provider for a single workout detail
///
/// Copied from [workoutDetail].
class WorkoutDetailProvider extends AutoDisposeFutureProvider<Workout> {
  /// Provider for a single workout detail
  ///
  /// Copied from [workoutDetail].
  WorkoutDetailProvider(String workoutId)
    : this._internal(
        (ref) => workoutDetail(ref as WorkoutDetailRef, workoutId),
        from: workoutDetailProvider,
        name: r'workoutDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$workoutDetailHash,
        dependencies: WorkoutDetailFamily._dependencies,
        allTransitiveDependencies:
            WorkoutDetailFamily._allTransitiveDependencies,
        workoutId: workoutId,
      );

  WorkoutDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.workoutId,
  }) : super.internal();

  final String workoutId;

  @override
  Override overrideWith(
    FutureOr<Workout> Function(WorkoutDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WorkoutDetailProvider._internal(
        (ref) => create(ref as WorkoutDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        workoutId: workoutId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Workout> createElement() {
    return _WorkoutDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkoutDetailProvider && other.workoutId == workoutId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, workoutId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WorkoutDetailRef on AutoDisposeFutureProviderRef<Workout> {
  /// The parameter `workoutId` of this provider.
  String get workoutId;
}

class _WorkoutDetailProviderElement
    extends AutoDisposeFutureProviderElement<Workout>
    with WorkoutDetailRef {
  _WorkoutDetailProviderElement(super.provider);

  @override
  String get workoutId => (origin as WorkoutDetailProvider).workoutId;
}

String _$recentWorkoutsHash() => r'aec126d428dfd2abe57666b6d6b167cf196af84b';

/// Provider for recent workouts (home screen preview)
///
/// Copied from [recentWorkouts].
@ProviderFor(recentWorkouts)
final recentWorkoutsProvider =
    AutoDisposeFutureProvider<List<Workout>>.internal(
      recentWorkouts,
      name: r'recentWorkoutsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recentWorkoutsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentWorkoutsRef = AutoDisposeFutureProviderRef<List<Workout>>;
String _$workoutListHash() => r'24b42976e2e8b06292728ff8ad7e942975e4da56';

/// Provider for workout list with pagination
///
/// Copied from [WorkoutList].
@ProviderFor(WorkoutList)
final workoutListProvider =
    AutoDisposeAsyncNotifierProvider<WorkoutList, List<Workout>>.internal(
      WorkoutList.new,
      name: r'workoutListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$workoutListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WorkoutList = AutoDisposeAsyncNotifier<List<Workout>>;
String _$activeWorkoutHash() => r'a50c45c3717b90bf6bced19bf8b1d2374c80bac1';

/// Active workout notifier
///
/// Copied from [ActiveWorkout].
@ProviderFor(ActiveWorkout)
final activeWorkoutProvider =
    AutoDisposeNotifierProvider<ActiveWorkout, ActiveWorkoutState>.internal(
      ActiveWorkout.new,
      name: r'activeWorkoutProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeWorkoutHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ActiveWorkout = AutoDisposeNotifier<ActiveWorkoutState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
