import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response.freezed.dart';
part 'api_response.g.dart';

/// Generic API response wrapper
@Freezed(genericArgumentFactories: true)
sealed class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({
    required bool success,
    T? data,
    ApiError? error,
    PaginationMeta? meta,
  }) = _ApiResponse<T>;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);
}

/// API error details
@freezed
sealed class ApiError with _$ApiError {
  const factory ApiError({
    required String code,
    required String message,
    @Default([]) List<FieldError> details,
  }) = _ApiError;

  factory ApiError.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorFromJson(json);
}

/// Field-level validation error
@freezed
sealed class FieldError with _$FieldError {
  const factory FieldError({
    required String field,
    required String message,
  }) = _FieldError;

  factory FieldError.fromJson(Map<String, dynamic> json) =>
      _$FieldErrorFromJson(json);
}

/// Pagination metadata
@freezed
sealed class PaginationMeta with _$PaginationMeta {
  const factory PaginationMeta({
    required int page,
    required int pageSize,
    required int total,
    required bool hasMore,
  }) = _PaginationMeta;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaFromJson(json);
}
