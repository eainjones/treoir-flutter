import 'package:freezed_annotation/freezed_annotation.dart';

import 'workout_exercise.dart';

part 'workout.freezed.dart';
part 'workout.g.dart';

/// Workout entity representing a training session
@freezed
sealed class Workout with _$Workout {
  const Workout._();

  const factory Workout({
    required String id,
    String? name,
    String? notes,
    required DateTime startedAt,
    DateTime? completedAt,
    int? durationSeconds,
    @Default(0) int totalSets,
    @Default(0) int totalReps,
    @Default(0.0) double totalVolumeKg,
    @Default(0) int exerciseCount,
    @Default([]) List<WorkoutExercise> exercises,
    String? routineId,
    @Default('pending') String syncStatus,
    @Default('active') String status,
  }) = _Workout;

  factory Workout.fromJson(Map<String, dynamic> json) =>
      _$WorkoutFromJson(json);

  /// Check if workout is currently active
  bool get isActive => completedAt == null && status == 'active';

  /// Check if workout is completed
  bool get isCompleted => completedAt != null || status == 'completed';

  /// Get elapsed duration
  Duration get elapsedDuration {
    if (durationSeconds != null) {
      return Duration(seconds: durationSeconds!);
    }
    final endTime = completedAt ?? DateTime.now();
    return endTime.difference(startedAt);
  }

  /// Format duration as HH:MM:SS
  String get formattedDuration {
    final duration = elapsedDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m ${seconds}s';
  }

  /// Calculate totals from exercises
  Workout recalculateTotals() {
    int sets = 0;
    int reps = 0;
    double volume = 0.0;

    for (final exercise in exercises) {
      for (final set in exercise.sets) {
        if (set.isCompleted) {
          sets++;
          reps += set.reps ?? 0;
          volume += (set.weightKg ?? 0) * (set.reps ?? 0);
        }
      }
    }

    return copyWith(
      totalSets: sets,
      totalReps: reps,
      totalVolumeKg: volume,
      exerciseCount: exercises.length,
    );
  }
}

/// Workout status enum
enum WorkoutStatus {
  active,
  completed,
  discarded,
}

/// Sync status enum
enum SyncStatus {
  pending,
  synced,
}
