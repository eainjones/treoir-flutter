// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Workout {

 String get id; String? get name; String? get notes; DateTime get startedAt; DateTime? get completedAt; int? get durationSeconds; int get totalSets; int get totalReps; double get totalVolumeKg; int get exerciseCount; List<WorkoutExercise> get exercises; String? get routineId; String get syncStatus; String get status;
/// Create a copy of Workout
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutCopyWith<Workout> get copyWith => _$WorkoutCopyWithImpl<Workout>(this as Workout, _$identity);

  /// Serializes this Workout to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Workout&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.totalSets, totalSets) || other.totalSets == totalSets)&&(identical(other.totalReps, totalReps) || other.totalReps == totalReps)&&(identical(other.totalVolumeKg, totalVolumeKg) || other.totalVolumeKg == totalVolumeKg)&&(identical(other.exerciseCount, exerciseCount) || other.exerciseCount == exerciseCount)&&const DeepCollectionEquality().equals(other.exercises, exercises)&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,notes,startedAt,completedAt,durationSeconds,totalSets,totalReps,totalVolumeKg,exerciseCount,const DeepCollectionEquality().hash(exercises),routineId,syncStatus,status);

@override
String toString() {
  return 'Workout(id: $id, name: $name, notes: $notes, startedAt: $startedAt, completedAt: $completedAt, durationSeconds: $durationSeconds, totalSets: $totalSets, totalReps: $totalReps, totalVolumeKg: $totalVolumeKg, exerciseCount: $exerciseCount, exercises: $exercises, routineId: $routineId, syncStatus: $syncStatus, status: $status)';
}


}

/// @nodoc
abstract mixin class $WorkoutCopyWith<$Res>  {
  factory $WorkoutCopyWith(Workout value, $Res Function(Workout) _then) = _$WorkoutCopyWithImpl;
@useResult
$Res call({
 String id, String? name, String? notes, DateTime startedAt, DateTime? completedAt, int? durationSeconds, int totalSets, int totalReps, double totalVolumeKg, int exerciseCount, List<WorkoutExercise> exercises, String? routineId, String syncStatus, String status
});




}
/// @nodoc
class _$WorkoutCopyWithImpl<$Res>
    implements $WorkoutCopyWith<$Res> {
  _$WorkoutCopyWithImpl(this._self, this._then);

  final Workout _self;
  final $Res Function(Workout) _then;

/// Create a copy of Workout
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? notes = freezed,Object? startedAt = null,Object? completedAt = freezed,Object? durationSeconds = freezed,Object? totalSets = null,Object? totalReps = null,Object? totalVolumeKg = null,Object? exerciseCount = null,Object? exercises = null,Object? routineId = freezed,Object? syncStatus = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,totalSets: null == totalSets ? _self.totalSets : totalSets // ignore: cast_nullable_to_non_nullable
as int,totalReps: null == totalReps ? _self.totalReps : totalReps // ignore: cast_nullable_to_non_nullable
as int,totalVolumeKg: null == totalVolumeKg ? _self.totalVolumeKg : totalVolumeKg // ignore: cast_nullable_to_non_nullable
as double,exerciseCount: null == exerciseCount ? _self.exerciseCount : exerciseCount // ignore: cast_nullable_to_non_nullable
as int,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<WorkoutExercise>,routineId: freezed == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String?,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Workout].
extension WorkoutPatterns on Workout {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Workout value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Workout() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Workout value)  $default,){
final _that = this;
switch (_that) {
case _Workout():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Workout value)?  $default,){
final _that = this;
switch (_that) {
case _Workout() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? name,  String? notes,  DateTime startedAt,  DateTime? completedAt,  int? durationSeconds,  int totalSets,  int totalReps,  double totalVolumeKg,  int exerciseCount,  List<WorkoutExercise> exercises,  String? routineId,  String syncStatus,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Workout() when $default != null:
return $default(_that.id,_that.name,_that.notes,_that.startedAt,_that.completedAt,_that.durationSeconds,_that.totalSets,_that.totalReps,_that.totalVolumeKg,_that.exerciseCount,_that.exercises,_that.routineId,_that.syncStatus,_that.status);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? name,  String? notes,  DateTime startedAt,  DateTime? completedAt,  int? durationSeconds,  int totalSets,  int totalReps,  double totalVolumeKg,  int exerciseCount,  List<WorkoutExercise> exercises,  String? routineId,  String syncStatus,  String status)  $default,) {final _that = this;
switch (_that) {
case _Workout():
return $default(_that.id,_that.name,_that.notes,_that.startedAt,_that.completedAt,_that.durationSeconds,_that.totalSets,_that.totalReps,_that.totalVolumeKg,_that.exerciseCount,_that.exercises,_that.routineId,_that.syncStatus,_that.status);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? name,  String? notes,  DateTime startedAt,  DateTime? completedAt,  int? durationSeconds,  int totalSets,  int totalReps,  double totalVolumeKg,  int exerciseCount,  List<WorkoutExercise> exercises,  String? routineId,  String syncStatus,  String status)?  $default,) {final _that = this;
switch (_that) {
case _Workout() when $default != null:
return $default(_that.id,_that.name,_that.notes,_that.startedAt,_that.completedAt,_that.durationSeconds,_that.totalSets,_that.totalReps,_that.totalVolumeKg,_that.exerciseCount,_that.exercises,_that.routineId,_that.syncStatus,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Workout extends Workout {
  const _Workout({required this.id, this.name, this.notes, required this.startedAt, this.completedAt, this.durationSeconds, this.totalSets = 0, this.totalReps = 0, this.totalVolumeKg = 0.0, this.exerciseCount = 0, final  List<WorkoutExercise> exercises = const [], this.routineId, this.syncStatus = 'pending', this.status = 'active'}): _exercises = exercises,super._();
  factory _Workout.fromJson(Map<String, dynamic> json) => _$WorkoutFromJson(json);

@override final  String id;
@override final  String? name;
@override final  String? notes;
@override final  DateTime startedAt;
@override final  DateTime? completedAt;
@override final  int? durationSeconds;
@override@JsonKey() final  int totalSets;
@override@JsonKey() final  int totalReps;
@override@JsonKey() final  double totalVolumeKg;
@override@JsonKey() final  int exerciseCount;
 final  List<WorkoutExercise> _exercises;
@override@JsonKey() List<WorkoutExercise> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}

@override final  String? routineId;
@override@JsonKey() final  String syncStatus;
@override@JsonKey() final  String status;

/// Create a copy of Workout
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutCopyWith<_Workout> get copyWith => __$WorkoutCopyWithImpl<_Workout>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Workout&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.totalSets, totalSets) || other.totalSets == totalSets)&&(identical(other.totalReps, totalReps) || other.totalReps == totalReps)&&(identical(other.totalVolumeKg, totalVolumeKg) || other.totalVolumeKg == totalVolumeKg)&&(identical(other.exerciseCount, exerciseCount) || other.exerciseCount == exerciseCount)&&const DeepCollectionEquality().equals(other._exercises, _exercises)&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,notes,startedAt,completedAt,durationSeconds,totalSets,totalReps,totalVolumeKg,exerciseCount,const DeepCollectionEquality().hash(_exercises),routineId,syncStatus,status);

@override
String toString() {
  return 'Workout(id: $id, name: $name, notes: $notes, startedAt: $startedAt, completedAt: $completedAt, durationSeconds: $durationSeconds, totalSets: $totalSets, totalReps: $totalReps, totalVolumeKg: $totalVolumeKg, exerciseCount: $exerciseCount, exercises: $exercises, routineId: $routineId, syncStatus: $syncStatus, status: $status)';
}


}

/// @nodoc
abstract mixin class _$WorkoutCopyWith<$Res> implements $WorkoutCopyWith<$Res> {
  factory _$WorkoutCopyWith(_Workout value, $Res Function(_Workout) _then) = __$WorkoutCopyWithImpl;
@override @useResult
$Res call({
 String id, String? name, String? notes, DateTime startedAt, DateTime? completedAt, int? durationSeconds, int totalSets, int totalReps, double totalVolumeKg, int exerciseCount, List<WorkoutExercise> exercises, String? routineId, String syncStatus, String status
});




}
/// @nodoc
class __$WorkoutCopyWithImpl<$Res>
    implements _$WorkoutCopyWith<$Res> {
  __$WorkoutCopyWithImpl(this._self, this._then);

  final _Workout _self;
  final $Res Function(_Workout) _then;

/// Create a copy of Workout
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? notes = freezed,Object? startedAt = null,Object? completedAt = freezed,Object? durationSeconds = freezed,Object? totalSets = null,Object? totalReps = null,Object? totalVolumeKg = null,Object? exerciseCount = null,Object? exercises = null,Object? routineId = freezed,Object? syncStatus = null,Object? status = null,}) {
  return _then(_Workout(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,totalSets: null == totalSets ? _self.totalSets : totalSets // ignore: cast_nullable_to_non_nullable
as int,totalReps: null == totalReps ? _self.totalReps : totalReps // ignore: cast_nullable_to_non_nullable
as int,totalVolumeKg: null == totalVolumeKg ? _self.totalVolumeKg : totalVolumeKg // ignore: cast_nullable_to_non_nullable
as double,exerciseCount: null == exerciseCount ? _self.exerciseCount : exerciseCount // ignore: cast_nullable_to_non_nullable
as int,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<WorkoutExercise>,routineId: freezed == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String?,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
