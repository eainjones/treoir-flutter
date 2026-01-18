// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Routine _$RoutineFromJson(Map<String, dynamic> json) => _Routine(
  id: json['id'] as String,
  name: json['name'] as String,
  exerciseCount: (json['exerciseCount'] as num?)?.toInt() ?? 0,
  estimatedDuration: (json['estimatedDuration'] as num?)?.toInt(),
  exercises:
      (json['exercises'] as List<dynamic>?)
          ?.map((e) => RoutineExercise.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$RoutineToJson(_Routine instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'exerciseCount': instance.exerciseCount,
  'estimatedDuration': instance.estimatedDuration,
  'exercises': instance.exercises,
};

_RoutineExercise _$RoutineExerciseFromJson(Map<String, dynamic> json) =>
    _RoutineExercise(
      id: json['id'] as String,
      orderIndex: (json['orderIndex'] as num).toInt(),
      exercise: Exercise.fromJson(json['exercise'] as Map<String, dynamic>),
      targetSets: (json['targetSets'] as num?)?.toInt() ?? 3,
      targetRepsRange: json['targetRepsRange'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$RoutineExerciseToJson(_RoutineExercise instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderIndex': instance.orderIndex,
      'exercise': instance.exercise,
      'targetSets': instance.targetSets,
      'targetRepsRange': instance.targetRepsRange,
      'notes': instance.notes,
    };
