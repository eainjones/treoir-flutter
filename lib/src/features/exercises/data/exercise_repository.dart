import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../shared/providers/dio_provider.dart';
import '../domain/exercise.dart';

/// Exercise repository provider
final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepository(ref.watch(dioProvider));
});

/// Response for paginated exercises
class ExerciseListResponse {
  final List<Exercise> exercises;
  final int page;
  final int pageSize;
  final int total;
  final bool hasMore;

  ExerciseListResponse({
    required this.exercises,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.hasMore,
  });
}

/// Repository for exercise operations
class ExerciseRepository {
  final Dio _dio;

  ExerciseRepository(this._dio);

  /// List exercises with optional filtering
  Future<ExerciseListResponse> listExercises({
    int page = 1,
    int? pageSize,
    String? search,
    String? category,
    String? muscleGroup,
    String? equipment,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.exercises,
        queryParameters: {
          'page': page,
          'page_size': pageSize ?? ApiConstants.exercisePageSize,
          if (search != null && search.isNotEmpty) 'search': search,
          if (category != null) 'category': category,
          if (muscleGroup != null) 'muscle_group': muscleGroup,
          if (equipment != null) 'equipment': equipment,
        },
      );

      final data = response.data;
      final items = (data['items'] as List?)
              ?.map((e) => Exercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      return ExerciseListResponse(
        exercises: items,
        page: data['page'] ?? page,
        pageSize: data['page_size'] ?? pageSize ?? ApiConstants.exercisePageSize,
        total: data['total'] ?? items.length,
        hasMore: data['has_more'] ?? false,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get exercise by ID
  Future<Exercise> getExercise(String exerciseId) async {
    try {
      final response = await _dio.get('${ApiConstants.exercises}/$exerciseId');
      return Exercise.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create custom exercise
  Future<Exercise> createCustomExercise({
    required String name,
    required String category,
    required String primaryMuscle,
    List<String>? secondaryMuscles,
    required String equipment,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.exercises,
        data: {
          'name': name,
          'category': category,
          'primary_muscle': primaryMuscle,
          'secondary_muscles': secondaryMuscles ?? [],
          'equipment': equipment,
        },
      );
      return Exercise.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get popular exercises (frequently used)
  Future<List<Exercise>> getPopularExercises() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.exercises}/popular',
        queryParameters: {'limit': 10},
      );

      return (response.data as List?)
              ?.map((e) => Exercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
    } on DioException catch (e) {
      // If endpoint not available, return empty list
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw _handleError(e);
    }
  }

  /// Get recently used exercises
  Future<List<Exercise>> getRecentExercises() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.exercises}/recent',
        queryParameters: {'limit': 10},
      );

      return (response.data as List?)
              ?.map((e) => Exercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
    } on DioException catch (e) {
      // If endpoint not available, return empty list
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final message = e.response?.data?['message'] ?? e.message;
      return Exception(message);
    }
    return Exception(e.message ?? 'Network error');
  }
}
