// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Workout _$WorkoutFromJson(Map<String, dynamic> json) => _Workout(
  id: json['id'] as String,
  name: json['name'] as String?,
  notes: json['notes'] as String?,
  startedAt: DateTime.parse(json['startedAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
  totalSets: (json['totalSets'] as num?)?.toInt() ?? 0,
  totalReps: (json['totalReps'] as num?)?.toInt() ?? 0,
  totalVolumeKg: (json['totalVolumeKg'] as num?)?.toDouble() ?? 0.0,
  exerciseCount: (json['exerciseCount'] as num?)?.toInt() ?? 0,
  exercises:
      (json['exercises'] as List<dynamic>?)
          ?.map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  routineId: json['routineId'] as String?,
  syncStatus: json['syncStatus'] as String? ?? 'pending',
  status: json['status'] as String? ?? 'active',
);

Map<String, dynamic> _$WorkoutToJson(_Workout instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'notes': instance.notes,
  'startedAt': instance.startedAt.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'durationSeconds': instance.durationSeconds,
  'totalSets': instance.totalSets,
  'totalReps': instance.totalReps,
  'totalVolumeKg': instance.totalVolumeKg,
  'exerciseCount': instance.exerciseCount,
  'exercises': instance.exercises,
  'routineId': instance.routineId,
  'syncStatus': instance.syncStatus,
  'status': instance.status,
};
