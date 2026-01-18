// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_set.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExerciseSet {

 String get id; int get orderIndex; int? get reps; double? get weightKg; int? get rpe; String get setType; bool get isCompleted; DateTime? get completedAt;
/// Create a copy of ExerciseSet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseSetCopyWith<ExerciseSet> get copyWith => _$ExerciseSetCopyWithImpl<ExerciseSet>(this as ExerciseSet, _$identity);

  /// Serializes this ExerciseSet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseSet&&(identical(other.id, id) || other.id == id)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.rpe, rpe) || other.rpe == rpe)&&(identical(other.setType, setType) || other.setType == setType)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderIndex,reps,weightKg,rpe,setType,isCompleted,completedAt);

@override
String toString() {
  return 'ExerciseSet(id: $id, orderIndex: $orderIndex, reps: $reps, weightKg: $weightKg, rpe: $rpe, setType: $setType, isCompleted: $isCompleted, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class $ExerciseSetCopyWith<$Res>  {
  factory $ExerciseSetCopyWith(ExerciseSet value, $Res Function(ExerciseSet) _then) = _$ExerciseSetCopyWithImpl;
@useResult
$Res call({
 String id, int orderIndex, int? reps, double? weightKg, int? rpe, String setType, bool isCompleted, DateTime? completedAt
});




}
/// @nodoc
class _$ExerciseSetCopyWithImpl<$Res>
    implements $ExerciseSetCopyWith<$Res> {
  _$ExerciseSetCopyWithImpl(this._self, this._then);

  final ExerciseSet _self;
  final $Res Function(ExerciseSet) _then;

/// Create a copy of ExerciseSet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderIndex = null,Object? reps = freezed,Object? weightKg = freezed,Object? rpe = freezed,Object? setType = null,Object? isCompleted = null,Object? completedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,reps: freezed == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,rpe: freezed == rpe ? _self.rpe : rpe // ignore: cast_nullable_to_non_nullable
as int?,setType: null == setType ? _self.setType : setType // ignore: cast_nullable_to_non_nullable
as String,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExerciseSet].
extension ExerciseSetPatterns on ExerciseSet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseSet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseSet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseSet value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseSet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseSet value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseSet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int orderIndex,  int? reps,  double? weightKg,  int? rpe,  String setType,  bool isCompleted,  DateTime? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseSet() when $default != null:
return $default(_that.id,_that.orderIndex,_that.reps,_that.weightKg,_that.rpe,_that.setType,_that.isCompleted,_that.completedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int orderIndex,  int? reps,  double? weightKg,  int? rpe,  String setType,  bool isCompleted,  DateTime? completedAt)  $default,) {final _that = this;
switch (_that) {
case _ExerciseSet():
return $default(_that.id,_that.orderIndex,_that.reps,_that.weightKg,_that.rpe,_that.setType,_that.isCompleted,_that.completedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int orderIndex,  int? reps,  double? weightKg,  int? rpe,  String setType,  bool isCompleted,  DateTime? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseSet() when $default != null:
return $default(_that.id,_that.orderIndex,_that.reps,_that.weightKg,_that.rpe,_that.setType,_that.isCompleted,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExerciseSet extends ExerciseSet {
  const _ExerciseSet({required this.id, required this.orderIndex, this.reps, this.weightKg, this.rpe, this.setType = 'working', this.isCompleted = false, this.completedAt}): super._();
  factory _ExerciseSet.fromJson(Map<String, dynamic> json) => _$ExerciseSetFromJson(json);

@override final  String id;
@override final  int orderIndex;
@override final  int? reps;
@override final  double? weightKg;
@override final  int? rpe;
@override@JsonKey() final  String setType;
@override@JsonKey() final  bool isCompleted;
@override final  DateTime? completedAt;

/// Create a copy of ExerciseSet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseSetCopyWith<_ExerciseSet> get copyWith => __$ExerciseSetCopyWithImpl<_ExerciseSet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseSetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseSet&&(identical(other.id, id) || other.id == id)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.rpe, rpe) || other.rpe == rpe)&&(identical(other.setType, setType) || other.setType == setType)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderIndex,reps,weightKg,rpe,setType,isCompleted,completedAt);

@override
String toString() {
  return 'ExerciseSet(id: $id, orderIndex: $orderIndex, reps: $reps, weightKg: $weightKg, rpe: $rpe, setType: $setType, isCompleted: $isCompleted, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$ExerciseSetCopyWith<$Res> implements $ExerciseSetCopyWith<$Res> {
  factory _$ExerciseSetCopyWith(_ExerciseSet value, $Res Function(_ExerciseSet) _then) = __$ExerciseSetCopyWithImpl;
@override @useResult
$Res call({
 String id, int orderIndex, int? reps, double? weightKg, int? rpe, String setType, bool isCompleted, DateTime? completedAt
});




}
/// @nodoc
class __$ExerciseSetCopyWithImpl<$Res>
    implements _$ExerciseSetCopyWith<$Res> {
  __$ExerciseSetCopyWithImpl(this._self, this._then);

  final _ExerciseSet _self;
  final $Res Function(_ExerciseSet) _then;

/// Create a copy of ExerciseSet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderIndex = null,Object? reps = freezed,Object? weightKg = freezed,Object? rpe = freezed,Object? setType = null,Object? isCompleted = null,Object? completedAt = freezed,}) {
  return _then(_ExerciseSet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,reps: freezed == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,rpe: freezed == rpe ? _self.rpe : rpe // ignore: cast_nullable_to_non_nullable
as int?,setType: null == setType ? _self.setType : setType // ignore: cast_nullable_to_non_nullable
as String,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
