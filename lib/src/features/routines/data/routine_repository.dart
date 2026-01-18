import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../shared/providers/dio_provider.dart';
import '../domain/routine.dart';

/// Routine repository provider
final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  return RoutineRepository(ref.watch(dioProvider));
});

/// Response wrapper for paginated routine list
class RoutineListResponse {
  final List<Routine> routines;
  final int page;
  final int pageSize;
  final int total;
  final bool hasMore;

  RoutineListResponse({
    required this.routines,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.hasMore,
  });
}

/// Repository handling routine operations
class RoutineRepository {
  final Dio _dio;

  RoutineRepository(this._dio);

  /// List user's routines
  Future<RoutineListResponse> listRoutines({
    int page = 1,
    int pageSize = ApiConstants.defaultPageSize,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.routines,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      final data = response.data;
      final routines = (data['data'] as List?)
              ?.map((json) => Routine.fromJson(json as Map<String, dynamic>))
              .toList() ??
          [];

      final meta = data['meta'] ?? {};
      return RoutineListResponse(
        routines: routines,
        page: meta['page'] ?? page,
        pageSize: meta['pageSize'] ?? pageSize,
        total: meta['total'] ?? routines.length,
        hasMore: meta['hasMore'] ?? false,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get routine by ID with full details
  Future<Routine> getRoutine(String id) async {
    try {
      final response = await _dio.get('${ApiConstants.routines}/$id');
      return Routine.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create new routine
  Future<Routine> createRoutine({
    required String name,
    int? estimatedDuration,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.routines,
        data: {
          'name': name,
          if (estimatedDuration != null) 'estimatedDuration': estimatedDuration,
        },
      );
      return Routine.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update routine
  Future<Routine> updateRoutine({
    required String id,
    String? name,
    int? estimatedDuration,
  }) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.routines}/$id',
        data: {
          if (name != null) 'name': name,
          if (estimatedDuration != null) 'estimatedDuration': estimatedDuration,
        },
      );
      return Routine.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete routine
  Future<void> deleteRoutine(String id) async {
    try {
      await _dio.delete('${ApiConstants.routines}/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Add exercise to routine
  Future<RoutineExercise> addExercise({
    required String routineId,
    required String exerciseId,
    int targetSets = 3,
    String? targetRepsRange,
    String? notes,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.routines}/$routineId/exercises',
        data: {
          'exerciseId': exerciseId,
          'targetSets': targetSets,
          if (targetRepsRange != null) 'targetRepsRange': targetRepsRange,
          if (notes != null) 'notes': notes,
        },
      );
      return RoutineExercise.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Remove exercise from routine
  Future<void> removeExercise({
    required String routineId,
    required String exerciseId,
  }) async {
    try {
      await _dio.delete(
        '${ApiConstants.routines}/$routineId/exercises/$exerciseId',
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Reorder exercises in routine
  Future<void> reorderExercises({
    required String routineId,
    required List<String> exerciseIds,
  }) async {
    try {
      await _dio.patch(
        '${ApiConstants.routines}/$routineId/exercises/reorder',
        data: {
          'exerciseIds': exerciseIds,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Duplicate a routine
  Future<Routine> duplicateRoutine(String id) async {
    try {
      final response = await _dio.post('${ApiConstants.routines}/$id/duplicate');
      return Routine.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response?.statusCode == 401) {
      return Exception('Unauthorized - please sign in again');
    }
    if (e.response?.statusCode == 404) {
      return Exception('Routine not found');
    }
    final message = e.response?.data?['error']?['message'] ?? e.message;
    return Exception(message ?? 'An error occurred');
  }
}
