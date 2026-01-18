import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../shared/providers/dio_provider.dart';
import '../domain/workout.dart';
import '../domain/workout_exercise.dart';
import '../domain/exercise_set.dart';

/// Workout repository provider
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepository(ref.watch(dioProvider));
});

/// Repository handling workout operations
class WorkoutRepository {
  final Dio _dio;

  WorkoutRepository(this._dio);

  /// List workouts with pagination
  Future<WorkoutListResponse> listWorkouts({
    int page = 1,
    int pageSize = ApiConstants.defaultPageSize,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.workouts,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      final data = response.data;
      final workouts = (data['data'] as List)
          .map((json) => Workout.fromJson(json))
          .toList();

      final meta = data['meta'];
      return WorkoutListResponse(
        workouts: workouts,
        page: meta['page'],
        pageSize: meta['pageSize'],
        total: meta['total'],
        hasMore: meta['hasMore'],
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get workout by ID with full details
  Future<Workout> getWorkout(String id) async {
    try {
      final response = await _dio.get('${ApiConstants.workouts}/$id');
      return Workout.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create new workout
  Future<Workout> createWorkout({
    String? name,
    String? routineId,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.workouts,
        data: {
          if (name != null) 'name': name,
          if (routineId != null) 'routineId': routineId,
        },
      );
      return Workout.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Complete workout
  Future<Workout> completeWorkout(String id, {String? notes}) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.workouts}/$id',
        data: {
          'completedAt': DateTime.now().toIso8601String(),
          if (notes != null) 'notes': notes,
        },
      );
      return Workout.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete workout
  Future<void> deleteWorkout(String id) async {
    try {
      await _dio.delete('${ApiConstants.workouts}/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Add exercise to workout
  Future<WorkoutExercise> addExercise({
    required String workoutId,
    required String exerciseId,
    String? notes,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.workouts}/$workoutId/exercises',
        data: {
          'exerciseId': exerciseId,
          if (notes != null) 'notes': notes,
        },
      );
      return WorkoutExercise.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Remove exercise from workout
  Future<void> removeExercise({
    required String workoutId,
    required String exerciseId,
  }) async {
    try {
      await _dio.delete(
        '${ApiConstants.workouts}/$workoutId/exercises/$exerciseId',
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update exercise (notes, order)
  Future<WorkoutExercise> updateExercise({
    required String workoutId,
    required String exerciseId,
    String? notes,
    int? orderIndex,
  }) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.workouts}/$workoutId/exercises/$exerciseId',
        data: {
          if (notes != null) 'notes': notes,
          if (orderIndex != null) 'orderIndex': orderIndex,
        },
      );
      return WorkoutExercise.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Reorder exercises in workout
  Future<void> reorderExercises({
    required String workoutId,
    required List<String> exerciseIds,
  }) async {
    try {
      await _dio.patch(
        '${ApiConstants.workouts}/$workoutId/exercises/reorder',
        data: {
          'exerciseIds': exerciseIds,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Replace exercise in workout
  Future<WorkoutExercise> replaceExercise({
    required String workoutId,
    required String oldExerciseId,
    required String newExerciseId,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.workouts}/$workoutId/exercises/$oldExerciseId/replace',
        data: {
          'newExerciseId': newExerciseId,
        },
      );
      return WorkoutExercise.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Add set to exercise
  Future<ExerciseSet> addSet({
    required String workoutId,
    required String exerciseId,
    required int reps,
    required double weightKg,
    int? rpe,
    String setType = 'working',
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.workouts}/$workoutId/exercises/$exerciseId/sets',
        data: {
          'reps': reps,
          'weightKg': weightKg,
          if (rpe != null) 'rpe': rpe,
          'setType': setType,
          'isCompleted': true,
        },
      );
      return ExerciseSet.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update set
  Future<ExerciseSet> updateSet({
    required String workoutId,
    required String exerciseId,
    required String setId,
    int? reps,
    double? weightKg,
    int? rpe,
    String? setType,
    bool? isCompleted,
  }) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.workouts}/$workoutId/exercises/$exerciseId/sets/$setId',
        data: {
          if (reps != null) 'reps': reps,
          if (weightKg != null) 'weightKg': weightKg,
          if (rpe != null) 'rpe': rpe,
          if (setType != null) 'setType': setType,
          if (isCompleted != null) 'isCompleted': isCompleted,
        },
      );
      return ExerciseSet.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete set
  Future<void> deleteSet({
    required String workoutId,
    required String exerciseId,
    required String setId,
  }) async {
    try {
      await _dio.delete(
        '${ApiConstants.workouts}/$workoutId/exercises/$exerciseId/sets/$setId',
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response?.statusCode == 401) {
      return Exception('Unauthorized - please sign in again');
    }
    if (e.response?.statusCode == 404) {
      return Exception('Workout not found');
    }
    final message = e.response?.data?['error']?['message'] ?? e.message;
    return Exception(message ?? 'An error occurred');
  }
}

/// Response wrapper for paginated workout list
class WorkoutListResponse {
  final List<Workout> workouts;
  final int page;
  final int pageSize;
  final int total;
  final bool hasMore;

  WorkoutListResponse({
    required this.workouts,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.hasMore,
  });
}
