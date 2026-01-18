import 'package:freezed_annotation/freezed_annotation.dart';

import '../../exercises/domain/exercise.dart';
import 'exercise_set.dart';

part 'workout_exercise.freezed.dart';
part 'workout_exercise.g.dart';

/// An exercise within a workout, containing sets
@freezed
sealed class WorkoutExercise with _$WorkoutExercise {
  const WorkoutExercise._();

  const factory WorkoutExercise({
    required String id,
    required int orderIndex,
    String? notes,
    required Exercise exercise,
    @Default([]) List<ExerciseSet> sets,
  }) = _WorkoutExercise;

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) =>
      _$WorkoutExerciseFromJson(json);

  /// Get completed sets count
  int get completedSetsCount => sets.where((s) => s.isCompleted).length;

  /// Get total volume for this exercise (weight * reps)
  double get totalVolume {
    return sets.fold(0.0, (sum, set) {
      if (set.isCompleted && set.weightKg != null && set.reps != null) {
        return sum + (set.weightKg! * set.reps!);
      }
      return sum;
    });
  }

  /// Get the best set (highest weight with successful reps)
  ExerciseSet? get bestSet {
    final completedSets = sets.where((s) => s.isCompleted && s.weightKg != null);
    if (completedSets.isEmpty) return null;
    return completedSets.reduce((a, b) =>
      (a.weightKg ?? 0) >= (b.weightKg ?? 0) ? a : b
    );
  }
}
