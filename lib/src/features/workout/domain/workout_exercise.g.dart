// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkoutExercise _$WorkoutExerciseFromJson(Map<String, dynamic> json) =>
    _WorkoutExercise(
      id: json['id'] as String,
      orderIndex: (json['orderIndex'] as num).toInt(),
      notes: json['notes'] as String?,
      exercise: Exercise.fromJson(json['exercise'] as Map<String, dynamic>),
      sets:
          (json['sets'] as List<dynamic>?)
              ?.map((e) => ExerciseSet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$WorkoutExerciseToJson(_WorkoutExercise instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderIndex': instance.orderIndex,
      'notes': instance.notes,
      'exercise': instance.exercise,
      'sets': instance.sets,
    };
