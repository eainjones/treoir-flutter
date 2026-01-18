import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API configuration constants
class ApiConstants {
  ApiConstants._();

  /// Base URL for the Treoir API
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://treoir.xyz/api/v1';

  /// Supabase project URL
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? '';

  /// Supabase anonymous key
  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// API endpoints
  static const String workouts = '/workouts';
  static const String exercises = '/exercises';
  static const String routines = '/routines';
  static const String sets = '/sets';

  /// Pagination defaults
  static const int defaultPageSize = 20;
  static const int exercisePageSize = 50;

  /// Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
