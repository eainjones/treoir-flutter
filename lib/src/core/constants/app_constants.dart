/// Application-wide constants
class AppConstants {
  AppConstants._();

  /// App name
  static const String appName = 'Treoir';

  /// Default rest timer durations (in seconds)
  static const List<int> restTimerOptions = [60, 90, 120, 180];
  static const int defaultRestTimerSeconds = 90;

  /// RPE scale range
  static const int minRpe = 1;
  static const int maxRpe = 10;

  /// Weight increments
  static const double weightIncrementKg = 2.5;
  static const double weightIncrementLbs = 5.0;

  /// Conversion factor
  static const double kgToLbs = 2.20462;

  /// Set types
  static const String setTypeWorking = 'working';
  static const String setTypeWarmup = 'warmup';
  static const String setTypeDrop = 'drop';
  static const String setTypeFailure = 'failure';
  static const String setTypeAmrap = 'amrap';

  /// Sync status
  static const String syncStatusPending = 'pending';
  static const String syncStatusSynced = 'synced';

  /// Workout status
  static const String workoutStatusActive = 'active';
  static const String workoutStatusCompleted = 'completed';
  static const String workoutStatusDiscarded = 'discarded';

  /// Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  /// Debounce durations
  static const Duration searchDebounce = Duration(milliseconds: 300);
  static const Duration syncDebounce = Duration(milliseconds: 300);
}
