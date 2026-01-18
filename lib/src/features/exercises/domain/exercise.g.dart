// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Exercise _$ExerciseFromJson(Map<String, dynamic> json) => _Exercise(
  id: json['id'] as String,
  name: json['name'] as String,
  category: json['category'] as String,
  primaryMuscle: json['primaryMuscle'] as String,
  secondaryMuscles:
      (json['secondaryMuscles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  equipment: json['equipment'] as String,
  isCustom: json['isCustom'] as bool? ?? false,
);

Map<String, dynamic> _$ExerciseToJson(_Exercise instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'category': instance.category,
  'primaryMuscle': instance.primaryMuscle,
  'secondaryMuscles': instance.secondaryMuscles,
  'equipment': instance.equipment,
  'isCustom': instance.isCustom,
};
