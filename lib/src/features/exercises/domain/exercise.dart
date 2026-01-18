import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise.freezed.dart';
part 'exercise.g.dart';

/// Exercise entity representing a workout exercise
@freezed
sealed class Exercise with _$Exercise {
  const factory Exercise({
    required String id,
    required String name,
    required String category,
    required String primaryMuscle,
    @Default([]) List<String> secondaryMuscles,
    required String equipment,
    @Default(false) bool isCustom,
  }) = _Exercise;

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);
}

/// Exercise category enum
enum ExerciseCategory {
  strength,
  cardio,
  flexibility,
  bodyweight,
}

/// Primary muscle groups
enum MuscleGroup {
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  forearms,
  core,
  quads,
  hamstrings,
  glutes,
  calves,
  fullBody,
}

/// Equipment types
enum Equipment {
  barbell,
  dumbbell,
  kettlebell,
  cable,
  machine,
  bodyweight,
  band,
  other,
}
