import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/workout_repository.dart';
import '../../domain/workout.dart';

part 'workout_providers.g.dart';

/// Provider for workout list with pagination
@riverpod
class WorkoutList extends _$WorkoutList {
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  Future<List<Workout>> build() async {
    _currentPage = 1;
    _hasMore = true;
    return _fetchWorkouts(1);
  }

  Future<List<Workout>> _fetchWorkouts(int page) async {
    final repo = ref.read(workoutRepositoryProvider);
    final response = await repo.listWorkouts(page: page);
    _hasMore = response.hasMore;
    _currentPage = response.page;
    return response.workouts;
  }

  /// Load more workouts (pagination)
  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    try {
      final currentWorkouts = state.valueOrNull ?? [];
      final moreWorkouts = await _fetchWorkouts(_currentPage + 1);
      state = AsyncData([...currentWorkouts, ...moreWorkouts]);
    } catch (e) {
      // Keep current state on error
    } finally {
      _isLoadingMore = false;
    }
  }

  /// Refresh workout list
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchWorkouts(1));
  }

  /// Add workout to list
  void addWorkout(Workout workout) {
    final current = state.valueOrNull ?? [];
    state = AsyncData([workout, ...current]);
  }

  /// Remove workout from list
  void removeWorkout(String workoutId) {
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((w) => w.id != workoutId).toList());
  }

  /// Update workout in list
  void updateWorkout(Workout workout) {
    final current = state.valueOrNull ?? [];
    state = AsyncData(
      current.map((w) => w.id == workout.id ? workout : w).toList(),
    );
  }

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
}

/// Provider for a single workout detail
@riverpod
Future<Workout> workoutDetail(Ref ref, String workoutId) async {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.getWorkout(workoutId);
}

/// Provider for recent workouts (home screen preview)
@riverpod
Future<List<Workout>> recentWorkouts(Ref ref) async {
  final repo = ref.watch(workoutRepositoryProvider);
  final response = await repo.listWorkouts(page: 1, pageSize: 5);
  return response.workouts;
}

/// Active workout state
class ActiveWorkoutState {
  final Workout? workout;
  final bool isLoading;
  final String? error;
  final Duration elapsed;

  const ActiveWorkoutState({
    this.workout,
    this.isLoading = false,
    this.error,
    this.elapsed = Duration.zero,
  });

  ActiveWorkoutState copyWith({
    Workout? workout,
    bool? isLoading,
    String? error,
    Duration? elapsed,
  }) {
    return ActiveWorkoutState(
      workout: workout ?? this.workout,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      elapsed: elapsed ?? this.elapsed,
    );
  }

  bool get hasActiveWorkout => workout != null && workout!.isActive;
}

/// Active workout notifier
@riverpod
class ActiveWorkout extends _$ActiveWorkout {
  @override
  ActiveWorkoutState build() {
    return const ActiveWorkoutState();
  }

  /// Start a new workout
  Future<bool> startWorkout({String? name, String? routineId}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repo = ref.read(workoutRepositoryProvider);
      final workout = await repo.createWorkout(
        name: name,
        routineId: routineId,
      );

      state = ActiveWorkoutState(workout: workout);

      // Add to workout list
      ref.read(workoutListProvider.notifier).addWorkout(workout);

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Load existing workout
  Future<bool> loadWorkout(String workoutId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repo = ref.read(workoutRepositoryProvider);
      final workout = await repo.getWorkout(workoutId);

      state = ActiveWorkoutState(workout: workout);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Complete the active workout
  Future<bool> completeWorkout({String? notes}) async {
    if (state.workout == null) return false;

    state = state.copyWith(isLoading: true);

    try {
      final repo = ref.read(workoutRepositoryProvider);
      final completed = await repo.completeWorkout(
        state.workout!.id,
        notes: notes,
      );

      // Update workout list
      ref.read(workoutListProvider.notifier).updateWorkout(completed);

      // Clear active workout
      state = const ActiveWorkoutState();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Discard workout
  Future<bool> discardWorkout() async {
    if (state.workout == null) return false;

    try {
      final repo = ref.read(workoutRepositoryProvider);
      await repo.deleteWorkout(state.workout!.id);

      // Remove from list
      ref.read(workoutListProvider.notifier).removeWorkout(state.workout!.id);

      state = const ActiveWorkoutState();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Add exercise to workout
  Future<bool> addExercise(String exerciseId, {String? notes}) async {
    if (state.workout == null) return false;

    try {
      final repo = ref.read(workoutRepositoryProvider);
      final workoutExercise = await repo.addExercise(
        workoutId: state.workout!.id,
        exerciseId: exerciseId,
        notes: notes,
      );

      final updatedExercises = [...state.workout!.exercises, workoutExercise];
      final updatedWorkout = state.workout!.copyWith(
        exercises: updatedExercises,
        exerciseCount: updatedExercises.length,
      );

      state = state.copyWith(workout: updatedWorkout);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Add set to exercise
  Future<bool> addSet({
    required String exerciseId,
    required int reps,
    required double weightKg,
    int? rpe,
    String setType = 'working',
  }) async {
    if (state.workout == null) return false;

    try {
      final repo = ref.read(workoutRepositoryProvider);
      final newSet = await repo.addSet(
        workoutId: state.workout!.id,
        exerciseId: exerciseId,
        reps: reps,
        weightKg: weightKg,
        rpe: rpe,
        setType: setType,
      );

      // Update local state
      final updatedExercises = state.workout!.exercises.map((ex) {
        if (ex.id == exerciseId) {
          return ex.copyWith(sets: [...ex.sets, newSet]);
        }
        return ex;
      }).toList();

      final updatedWorkout = state.workout!
          .copyWith(exercises: updatedExercises)
          .recalculateTotals();

      state = state.copyWith(workout: updatedWorkout);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Update a set
  Future<bool> updateSet({
    required String exerciseId,
    required String setId,
    int? reps,
    double? weightKg,
    int? rpe,
    String? setType,
    bool? isCompleted,
  }) async {
    if (state.workout == null) return false;

    try {
      final repo = ref.read(workoutRepositoryProvider);
      final updatedSet = await repo.updateSet(
        workoutId: state.workout!.id,
        exerciseId: exerciseId,
        setId: setId,
        reps: reps,
        weightKg: weightKg,
        rpe: rpe,
        setType: setType,
        isCompleted: isCompleted,
      );

      // Update local state
      final updatedExercises = state.workout!.exercises.map((ex) {
        if (ex.id == exerciseId) {
          final updatedSets = ex.sets.map((s) {
            if (s.id == setId) return updatedSet;
            return s;
          }).toList();
          return ex.copyWith(sets: updatedSets);
        }
        return ex;
      }).toList();

      final updatedWorkout = state.workout!
          .copyWith(exercises: updatedExercises)
          .recalculateTotals();

      state = state.copyWith(workout: updatedWorkout);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Remove exercise from workout
  Future<bool> removeExercise(String exerciseId) async {
    if (state.workout == null) return false;

    try {
      final repo = ref.read(workoutRepositoryProvider);
      await repo.removeExercise(
        workoutId: state.workout!.id,
        exerciseId: exerciseId,
      );

      // Update local state
      final updatedExercises = state.workout!.exercises
          .where((ex) => ex.id != exerciseId)
          .toList();

      final updatedWorkout = state.workout!
          .copyWith(
            exercises: updatedExercises,
            exerciseCount: updatedExercises.length,
          )
          .recalculateTotals();

      state = state.copyWith(workout: updatedWorkout);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Delete a set
  Future<bool> deleteSet({
    required String exerciseId,
    required String setId,
  }) async {
    if (state.workout == null) return false;

    try {
      final repo = ref.read(workoutRepositoryProvider);
      await repo.deleteSet(
        workoutId: state.workout!.id,
        exerciseId: exerciseId,
        setId: setId,
      );

      // Update local state
      final updatedExercises = state.workout!.exercises.map((ex) {
        if (ex.id == exerciseId) {
          final updatedSets = ex.sets.where((s) => s.id != setId).toList();
          return ex.copyWith(sets: updatedSets);
        }
        return ex;
      }).toList();

      final updatedWorkout = state.workout!
          .copyWith(exercises: updatedExercises)
          .recalculateTotals();

      state = state.copyWith(workout: updatedWorkout);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Update exercise note
  Future<bool> updateExerciseNote({
    required String exerciseId,
    required String notes,
  }) async {
    if (state.workout == null) return false;

    try {
      final repo = ref.read(workoutRepositoryProvider);
      final updatedExercise = await repo.updateExercise(
        workoutId: state.workout!.id,
        exerciseId: exerciseId,
        notes: notes,
      );

      // Update local state
      final updatedExercises = state.workout!.exercises.map((ex) {
        if (ex.id == exerciseId) return updatedExercise;
        return ex;
      }).toList();

      final updatedWorkout = state.workout!.copyWith(exercises: updatedExercises);
      state = state.copyWith(workout: updatedWorkout);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Reorder exercises
  Future<bool> reorderExercises(List<String> exerciseIds) async {
    if (state.workout == null) return false;

    // Optimistically reorder locally first
    final reorderedExercises = <dynamic>[];
    for (final id in exerciseIds) {
      final exercise = state.workout!.exercises.firstWhere((ex) => ex.id == id);
      reorderedExercises.add(exercise);
    }

    final updatedWorkout = state.workout!.copyWith(
      exercises: reorderedExercises.cast(),
    );
    state = state.copyWith(workout: updatedWorkout);

    try {
      final repo = ref.read(workoutRepositoryProvider);
      await repo.reorderExercises(
        workoutId: state.workout!.id,
        exerciseIds: exerciseIds,
      );
      return true;
    } catch (e) {
      // Revert on error - reload from server would be better
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Replace exercise with another
  Future<bool> replaceExercise({
    required String oldExerciseId,
    required String newExerciseId,
  }) async {
    if (state.workout == null) return false;

    try {
      final repo = ref.read(workoutRepositoryProvider);
      final newExercise = await repo.replaceExercise(
        workoutId: state.workout!.id,
        oldExerciseId: oldExerciseId,
        newExerciseId: newExerciseId,
      );

      // Update local state - replace the old exercise with the new one
      final updatedExercises = state.workout!.exercises.map((ex) {
        if (ex.id == oldExerciseId) return newExercise;
        return ex;
      }).toList();

      final updatedWorkout = state.workout!.copyWith(exercises: updatedExercises);
      state = state.copyWith(workout: updatedWorkout);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Update elapsed time
  void updateElapsed(Duration elapsed) {
    state = state.copyWith(elapsed: elapsed);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
