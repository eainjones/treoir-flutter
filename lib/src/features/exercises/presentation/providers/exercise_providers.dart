import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/exercise_repository.dart';
import '../../domain/exercise.dart';

part 'exercise_providers.g.dart';

/// Current search query for exercises
final exerciseSearchQueryProvider = StateProvider<String>((ref) => '');

/// Current category filter
final exerciseCategoryFilterProvider = StateProvider<String?>((ref) => null);

/// Current muscle group filter
final exerciseMuscleFilterProvider = StateProvider<String?>((ref) => null);

/// Current equipment filter
final exerciseEquipmentFilterProvider = StateProvider<String?>((ref) => null);

/// Exercise list provider with search and filters
@riverpod
class ExerciseList extends _$ExerciseList {
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  Future<List<Exercise>> build() async {
    final search = ref.watch(exerciseSearchQueryProvider);
    final category = ref.watch(exerciseCategoryFilterProvider);
    final muscle = ref.watch(exerciseMuscleFilterProvider);
    final equipment = ref.watch(exerciseEquipmentFilterProvider);

    _currentPage = 1;
    _hasMore = true;

    return _fetchExercises(
      page: 1,
      search: search,
      category: category,
      muscle: muscle,
      equipment: equipment,
    );
  }

  Future<List<Exercise>> _fetchExercises({
    required int page,
    String? search,
    String? category,
    String? muscle,
    String? equipment,
  }) async {
    final repo = ref.read(exerciseRepositoryProvider);
    final response = await repo.listExercises(
      page: page,
      search: search,
      category: category,
      muscleGroup: muscle,
      equipment: equipment,
    );
    _hasMore = response.hasMore;
    _currentPage = response.page;
    return response.exercises;
  }

  /// Load more exercises (pagination)
  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    try {
      final search = ref.read(exerciseSearchQueryProvider);
      final category = ref.read(exerciseCategoryFilterProvider);
      final muscle = ref.read(exerciseMuscleFilterProvider);
      final equipment = ref.read(exerciseEquipmentFilterProvider);

      final currentExercises = state.valueOrNull ?? [];
      final moreExercises = await _fetchExercises(
        page: _currentPage + 1,
        search: search,
        category: category,
        muscle: muscle,
        equipment: equipment,
      );
      state = AsyncData([...currentExercises, ...moreExercises]);
    } catch (e) {
      // Keep current state on error
    } finally {
      _isLoadingMore = false;
    }
  }

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
}

/// Popular exercises provider
@riverpod
Future<List<Exercise>> popularExercises(Ref ref) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  return repo.getPopularExercises();
}

/// Recent exercises provider
@riverpod
Future<List<Exercise>> recentExercises(Ref ref) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  return repo.getRecentExercises();
}

/// Available muscle groups for filtering
const muscleGroups = [
  'Chest',
  'Back',
  'Shoulders',
  'Biceps',
  'Triceps',
  'Forearms',
  'Core',
  'Quads',
  'Hamstrings',
  'Glutes',
  'Calves',
];

/// Available equipment for filtering
const equipmentTypes = [
  'Barbell',
  'Dumbbell',
  'Kettlebell',
  'Cable',
  'Machine',
  'Bodyweight',
  'Band',
];

/// Available categories for filtering
const exerciseCategories = [
  'Strength',
  'Cardio',
  'Flexibility',
  'Bodyweight',
];
