// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vote.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Vote {

@JsonKey(includeToJson: false) String get id; String get votedForPlayerId;@TimestampConverter() DateTime get votedAt;
/// Create a copy of Vote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoteCopyWith<Vote> get copyWith => _$VoteCopyWithImpl<Vote>(this as Vote, _$identity);

  /// Serializes this Vote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Vote&&(identical(other.id, id) || other.id == id)&&(identical(other.votedForPlayerId, votedForPlayerId) || other.votedForPlayerId == votedForPlayerId)&&(identical(other.votedAt, votedAt) || other.votedAt == votedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,votedForPlayerId,votedAt);

@override
String toString() {
  return 'Vote(id: $id, votedForPlayerId: $votedForPlayerId, votedAt: $votedAt)';
}


}

/// @nodoc
abstract mixin class $VoteCopyWith<$Res>  {
  factory $VoteCopyWith(Vote value, $Res Function(Vote) _then) = _$VoteCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String id, String votedForPlayerId,@TimestampConverter() DateTime votedAt
});




}
/// @nodoc
class _$VoteCopyWithImpl<$Res>
    implements $VoteCopyWith<$Res> {
  _$VoteCopyWithImpl(this._self, this._then);

  final Vote _self;
  final $Res Function(Vote) _then;

/// Create a copy of Vote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? votedForPlayerId = null,Object? votedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,votedForPlayerId: null == votedForPlayerId ? _self.votedForPlayerId : votedForPlayerId // ignore: cast_nullable_to_non_nullable
as String,votedAt: null == votedAt ? _self.votedAt : votedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Vote].
extension VotePatterns on Vote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Vote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Vote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Vote value)  $default,){
final _that = this;
switch (_that) {
case _Vote():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Vote value)?  $default,){
final _that = this;
switch (_that) {
case _Vote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String votedForPlayerId, @TimestampConverter()  DateTime votedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Vote() when $default != null:
return $default(_that.id,_that.votedForPlayerId,_that.votedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String votedForPlayerId, @TimestampConverter()  DateTime votedAt)  $default,) {final _that = this;
switch (_that) {
case _Vote():
return $default(_that.id,_that.votedForPlayerId,_that.votedAt);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String id,  String votedForPlayerId, @TimestampConverter()  DateTime votedAt)?  $default,) {final _that = this;
switch (_that) {
case _Vote() when $default != null:
return $default(_that.id,_that.votedForPlayerId,_that.votedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Vote implements Vote {
  const _Vote({@JsonKey(includeToJson: false) required this.id, required this.votedForPlayerId, @TimestampConverter() required this.votedAt});
  factory _Vote.fromJson(Map<String, dynamic> json) => _$VoteFromJson(json);

@override@JsonKey(includeToJson: false) final  String id;
@override final  String votedForPlayerId;
@override@TimestampConverter() final  DateTime votedAt;

/// Create a copy of Vote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoteCopyWith<_Vote> get copyWith => __$VoteCopyWithImpl<_Vote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Vote&&(identical(other.id, id) || other.id == id)&&(identical(other.votedForPlayerId, votedForPlayerId) || other.votedForPlayerId == votedForPlayerId)&&(identical(other.votedAt, votedAt) || other.votedAt == votedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,votedForPlayerId,votedAt);

@override
String toString() {
  return 'Vote(id: $id, votedForPlayerId: $votedForPlayerId, votedAt: $votedAt)';
}


}

/// @nodoc
abstract mixin class _$VoteCopyWith<$Res> implements $VoteCopyWith<$Res> {
  factory _$VoteCopyWith(_Vote value, $Res Function(_Vote) _then) = __$VoteCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String id, String votedForPlayerId,@TimestampConverter() DateTime votedAt
});




}
/// @nodoc
class __$VoteCopyWithImpl<$Res>
    implements _$VoteCopyWith<$Res> {
  __$VoteCopyWithImpl(this._self, this._then);

  final _Vote _self;
  final $Res Function(_Vote) _then;

/// Create a copy of Vote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? votedForPlayerId = null,Object? votedAt = null,}) {
  return _then(_Vote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,votedForPlayerId: null == votedForPlayerId ? _self.votedForPlayerId : votedForPlayerId // ignore: cast_nullable_to_non_nullable
as String,votedAt: null == votedAt ? _self.votedAt : votedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
