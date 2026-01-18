import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/routine_repository.dart';
import '../../domain/routine.dart';

part 'routine_providers.g.dart';

/// Routine list provider with pagination
@riverpod
class RoutineList extends _$RoutineList {
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  Future<List<Routine>> build() async {
    _currentPage = 1;
    _hasMore = true;
    return _fetchRoutines(1);
  }

  Future<List<Routine>> _fetchRoutines(int page) async {
    final repo = ref.read(routineRepositoryProvider);
    final response = await repo.listRoutines(page: page);
    _hasMore = response.hasMore;
    _currentPage = response.page;
    return response.routines;
  }

  /// Load more routines (pagination)
  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    try {
      final currentRoutines = state.valueOrNull ?? [];
      final moreRoutines = await _fetchRoutines(_currentPage + 1);
      state = AsyncData([...currentRoutines, ...moreRoutines]);
    } catch (e) {
      // Keep current state on error
    } finally {
      _isLoadingMore = false;
    }
  }

  /// Refresh routine list
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchRoutines(1));
  }

  /// Add routine to list
  void addRoutine(Routine routine) {
    final current = state.valueOrNull ?? [];
    state = AsyncData([routine, ...current]);
  }

  /// Remove routine from list
  void removeRoutine(String routineId) {
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((r) => r.id != routineId).toList());
  }

  /// Update routine in list
  void updateRoutine(Routine routine) {
    final current = state.valueOrNull ?? [];
    state = AsyncData(
      current.map((r) => r.id == routine.id ? routine : r).toList(),
    );
  }

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
}

/// Provider for a single routine detail
@riverpod
Future<Routine> routineDetail(Ref ref, String routineId) async {
  final repo = ref.watch(routineRepositoryProvider);
  return repo.getRoutine(routineId);
}

/// State for creating/editing a routine
class RoutineEditorState {
  final String? id;
  final String name;
  final int? estimatedDuration;
  final List<RoutineExercise> exercises;
  final bool isLoading;
  final String? error;
  final bool isSaved;

  const RoutineEditorState({
    this.id,
    this.name = '',
    this.estimatedDuration,
    this.exercises = const [],
    this.isLoading = false,
    this.error,
    this.isSaved = false,
  });

  RoutineEditorState copyWith({
    String? id,
    String? name,
    int? estimatedDuration,
    List<RoutineExercise>? exercises,
    bool? isLoading,
    String? error,
    bool? isSaved,
  }) {
    return RoutineEditorState(
      id: id ?? this.id,
      name: name ?? this.name,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      exercises: exercises ?? this.exercises,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  bool get isValid => name.trim().isNotEmpty;
  bool get isEditing => id != null;
}

/// Routine editor notifier for create/edit flows
@riverpod
class RoutineEditor extends _$RoutineEditor {
  @override
  RoutineEditorState build() {
    return const RoutineEditorState();
  }

  /// Load existing routine for editing
  Future<void> loadRoutine(String routineId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repo = ref.read(routineRepositoryProvider);
      final routine = await repo.getRoutine(routineId);

      state = RoutineEditorState(
        id: routine.id,
        name: routine.name,
        estimatedDuration: routine.estimatedDuration,
        exercises: routine.exercises,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Update routine name
  void setName(String name) {
    state = state.copyWith(name: name);
  }

  /// Update estimated duration
  void setEstimatedDuration(int? duration) {
    state = state.copyWith(estimatedDuration: duration);
  }

  /// Add exercise to routine
  void addExercise(RoutineExercise exercise) {
    state = state.copyWith(
      exercises: [...state.exercises, exercise],
    );
  }

  /// Remove exercise from routine
  void removeExercise(String exerciseId) {
    state = state.copyWith(
      exercises: state.exercises.where((e) => e.id != exerciseId).toList(),
    );
  }

  /// Reorder exercises
  void reorderExercises(int oldIndex, int newIndex) {
    final exercises = List<RoutineExercise>.from(state.exercises);
    if (newIndex > oldIndex) newIndex--;
    final item = exercises.removeAt(oldIndex);
    exercises.insert(newIndex, item);
    state = state.copyWith(exercises: exercises);
  }

  /// Save routine (create or update)
  Future<bool> save() async {
    if (!state.isValid) {
      state = state.copyWith(error: 'Please enter a routine name');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final repo = ref.read(routineRepositoryProvider);
      Routine routine;

      if (state.isEditing) {
        routine = await repo.updateRoutine(
          id: state.id!,
          name: state.name,
          estimatedDuration: state.estimatedDuration,
        );
        ref.read(routineListProvider.notifier).updateRoutine(routine);
      } else {
        routine = await repo.createRoutine(
          name: state.name,
          estimatedDuration: state.estimatedDuration,
        );
        ref.read(routineListProvider.notifier).addRoutine(routine);
      }

      state = state.copyWith(
        id: routine.id,
        isLoading: false,
        isSaved: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Reset editor state
  void reset() {
    state = const RoutineEditorState();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
