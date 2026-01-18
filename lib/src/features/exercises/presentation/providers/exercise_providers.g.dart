// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$popularExercisesHash() => r'de40aed07586038630541ece58ec644fddcb8306';

/// Popular exercises provider
///
/// Copied from [popularExercises].
@ProviderFor(popularExercises)
final popularExercisesProvider =
    AutoDisposeFutureProvider<List<Exercise>>.internal(
      popularExercises,
      name: r'popularExercisesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$popularExercisesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PopularExercisesRef = AutoDisposeFutureProviderRef<List<Exercise>>;
String _$recentExercisesHash() => r'f1846eca1a1f86d09c26ee19e5e5fc07dc8b9f95';

/// Recent exercises provider
///
/// Copied from [recentExercises].
@ProviderFor(recentExercises)
final recentExercisesProvider =
    AutoDisposeFutureProvider<List<Exercise>>.internal(
      recentExercises,
      name: r'recentExercisesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recentExercisesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentExercisesRef = AutoDisposeFutureProviderRef<List<Exercise>>;
String _$exerciseListHash() => r'16014337c1d9c7051f15f0fb83d6f3f7d91d443a';

/// Exercise list provider with search and filters
///
/// Copied from [ExerciseList].
@ProviderFor(ExerciseList)
final exerciseListProvider =
    AutoDisposeAsyncNotifierProvider<ExerciseList, List<Exercise>>.internal(
      ExerciseList.new,
      name: r'exerciseListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$exerciseListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ExerciseList = AutoDisposeAsyncNotifier<List<Exercise>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
