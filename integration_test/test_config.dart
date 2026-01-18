/// Test configuration for integration tests
///
/// Copy this file to test_config_local.dart and fill in your credentials.
/// The _local.dart file is gitignored and won't be committed.
///
/// Usage:
///   1. Copy: cp test_config.dart test_config_local.dart
///   2. Edit test_config_local.dart with your real credentials
///   3. Run: flutter test integration_test/

class TestConfig {
  /// Test user email - replace with a real test account
  static const String testEmail = 'your-test-email@example.com';

  /// Test user password - replace with a real password
  static const String testPassword = 'your-test-password';

  /// Whether to run tests that require authentication
  /// Set to true once you've configured real credentials
  static const bool authTestsEnabled = false;

  /// Timeout for waiting on async operations
  static const Duration defaultTimeout = Duration(seconds: 30);

  /// Shorter timeout for UI elements that should appear quickly
  static const Duration uiTimeout = Duration(seconds: 10);
}
