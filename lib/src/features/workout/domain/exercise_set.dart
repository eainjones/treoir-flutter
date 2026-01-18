import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_set.freezed.dart';
part 'exercise_set.g.dart';

/// A single set within a workout exercise
@freezed
sealed class ExerciseSet with _$ExerciseSet {
  const ExerciseSet._();

  const factory ExerciseSet({
    required String id,
    required int orderIndex,
    int? reps,
    double? weightKg,
    int? rpe,
    @Default('working') String setType,
    @Default(false) bool isCompleted,
    DateTime? completedAt,
  }) = _ExerciseSet;

  factory ExerciseSet.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSetFromJson(json);

  /// Display weight in user's preferred unit
  String displayWeight({bool useImperial = false}) {
    if (weightKg == null) return '-';
    if (useImperial) {
      final lbs = weightKg! * 2.20462;
      return '${lbs.toStringAsFixed(1)} lbs';
    }
    return '${weightKg!.toStringAsFixed(1)} kg';
  }

  /// Get the set type display label
  String get setTypeLabel {
    switch (setType) {
      case 'warmup':
        return 'W';
      case 'drop':
        return 'D';
      case 'failure':
        return 'F';
      case 'amrap':
        return 'A';
      case 'working':
      default:
        return '';
    }
  }
}

/// Set type enum for type safety
enum SetType {
  working,
  warmup,
  drop,
  failure,
  amrap,
}

extension SetTypeExtension on SetType {
  String get value {
    switch (this) {
      case SetType.working:
        return 'working';
      case SetType.warmup:
        return 'warmup';
      case SetType.drop:
        return 'drop';
      case SetType.failure:
        return 'failure';
      case SetType.amrap:
        return 'amrap';
    }
  }

  String get label {
    switch (this) {
      case SetType.working:
        return 'Working';
      case SetType.warmup:
        return 'Warm-up';
      case SetType.drop:
        return 'Drop';
      case SetType.failure:
        return 'Failure';
      case SetType.amrap:
        return 'AMRAP';
    }
  }
}
