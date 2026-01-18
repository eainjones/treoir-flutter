import 'package:freezed_annotation/freezed_annotation.dart';

import '../../exercises/domain/exercise.dart';

part 'routine.freezed.dart';
part 'routine.g.dart';

/// Routine entity representing a workout template
@freezed
sealed class Routine with _$Routine {
  const factory Routine({
    required String id,
    required String name,
    @Default(0) int exerciseCount,
    int? estimatedDuration,
    @Default([]) List<RoutineExercise> exercises,
  }) = _Routine;

  factory Routine.fromJson(Map<String, dynamic> json) =>
      _$RoutineFromJson(json);
}

/// An exercise template within a routine
@freezed
sealed class RoutineExercise with _$RoutineExercise {
  const factory RoutineExercise({
    required String id,
    required int orderIndex,
    required Exercise exercise,
    @Default(3) int targetSets,
    String? targetRepsRange,
    String? notes,
  }) = _RoutineExercise;

  factory RoutineExercise.fromJson(Map<String, dynamic> json) =>
      _$RoutineExerciseFromJson(json);
}
