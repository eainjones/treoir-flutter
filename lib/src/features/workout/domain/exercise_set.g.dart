// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExerciseSet _$ExerciseSetFromJson(Map<String, dynamic> json) => _ExerciseSet(
  id: json['id'] as String,
  orderIndex: (json['orderIndex'] as num).toInt(),
  reps: (json['reps'] as num?)?.toInt(),
  weightKg: (json['weightKg'] as num?)?.toDouble(),
  rpe: (json['rpe'] as num?)?.toInt(),
  setType: json['setType'] as String? ?? 'working',
  isCompleted: json['isCompleted'] as bool? ?? false,
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
);

Map<String, dynamic> _$ExerciseSetToJson(_ExerciseSet instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderIndex': instance.orderIndex,
      'reps': instance.reps,
      'weightKg': instance.weightKg,
      'rpe': instance.rpe,
      'setType': instance.setType,
      'isCompleted': instance.isCompleted,
      'completedAt': instance.completedAt?.toIso8601String(),
    };
