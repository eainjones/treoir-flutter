import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/api_constants.dart';

/// Dio instance provider
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add interceptors
  dio.interceptors.addAll([
    AuthInterceptor(),
    LoggingInterceptor(),
    ErrorInterceptor(),
  ]);

  return dio;
});

/// Auth interceptor to add Bearer token to requests
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      try {
        final response = await Supabase.instance.client.auth.refreshSession();
        if (response.session != null) {
          // Retry the request with new token
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer ${response.session!.accessToken}';

          final dio = Dio();
          final retryResponse = await dio.fetch(opts);
          return handler.resolve(retryResponse);
        }
      } catch (e) {
        // Refresh failed, sign out user
        await Supabase.instance.client.auth.signOut();
      }
    }
    handler.next(err);
  }
}

/// Logging interceptor for debugging
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🌐 REQUEST[${options.method}] => ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ ERROR[${err.response?.statusCode}] => ${err.requestOptions.uri}');
    print('   Message: ${err.message}');
    handler.next(err);
  }
}

/// Error interceptor for consistent error handling
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Transform DioException into more specific errors if needed
    final response = err.response;

    if (response != null) {
      final data = response.data;
      if (data is Map<String, dynamic> && data['error'] != null) {
        // API returned structured error
        final apiError = data['error'] as Map<String, dynamic>;
        err = DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: err.type,
          error: ApiException(
            code: apiError['code'] as String? ?? 'UNKNOWN',
            message: apiError['message'] as String? ?? 'An error occurred',
          ),
        );
      }
    }

    handler.next(err);
  }
}

/// Custom API exception
class ApiException implements Exception {
  final String code;
  final String message;

  ApiException({required this.code, required this.message});

  @override
  String toString() => 'ApiException: [$code] $message';
}
