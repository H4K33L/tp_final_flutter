// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Room {

@JsonKey(includeToJson: false) String get id; String get hostId; RoomStatus get status; int get maxPlayers; int get totalRounds; int get currentRound;@TimestampConverter() DateTime get createdAt;
/// Create a copy of Room
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoomCopyWith<Room> get copyWith => _$RoomCopyWithImpl<Room>(this as Room, _$identity);

  /// Serializes this Room to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Room&&(identical(other.id, id) || other.id == id)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.status, status) || other.status == status)&&(identical(other.maxPlayers, maxPlayers) || other.maxPlayers == maxPlayers)&&(identical(other.totalRounds, totalRounds) || other.totalRounds == totalRounds)&&(identical(other.currentRound, currentRound) || other.currentRound == currentRound)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hostId,status,maxPlayers,totalRounds,currentRound,createdAt);

@override
String toString() {
  return 'Room(id: $id, hostId: $hostId, status: $status, maxPlayers: $maxPlayers, totalRounds: $totalRounds, currentRound: $currentRound, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $RoomCopyWith<$Res>  {
  factory $RoomCopyWith(Room value, $Res Function(Room) _then) = _$RoomCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String id, String hostId, RoomStatus status, int maxPlayers, int totalRounds, int currentRound,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class _$RoomCopyWithImpl<$Res>
    implements $RoomCopyWith<$Res> {
  _$RoomCopyWithImpl(this._self, this._then);

  final Room _self;
  final $Res Function(Room) _then;

/// Create a copy of Room
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? hostId = null,Object? status = null,Object? maxPlayers = null,Object? totalRounds = null,Object? currentRound = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,hostId: null == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RoomStatus,maxPlayers: null == maxPlayers ? _self.maxPlayers : maxPlayers // ignore: cast_nullable_to_non_nullable
as int,totalRounds: null == totalRounds ? _self.totalRounds : totalRounds // ignore: cast_nullable_to_non_nullable
as int,currentRound: null == currentRound ? _self.currentRound : currentRound // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Room].
extension RoomPatterns on Room {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Room value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Room() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Room value)  $default,){
final _that = this;
switch (_that) {
case _Room():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Room value)?  $default,){
final _that = this;
switch (_that) {
case _Room() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String hostId,  RoomStatus status,  int maxPlayers,  int totalRounds,  int currentRound, @TimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Room() when $default != null:
return $default(_that.id,_that.hostId,_that.status,_that.maxPlayers,_that.totalRounds,_that.currentRound,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String hostId,  RoomStatus status,  int maxPlayers,  int totalRounds,  int currentRound, @TimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Room():
return $default(_that.id,_that.hostId,_that.status,_that.maxPlayers,_that.totalRounds,_that.currentRound,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String id,  String hostId,  RoomStatus status,  int maxPlayers,  int totalRounds,  int currentRound, @TimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Room() when $default != null:
return $default(_that.id,_that.hostId,_that.status,_that.maxPlayers,_that.totalRounds,_that.currentRound,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Room implements Room {
  const _Room({@JsonKey(includeToJson: false) required this.id, required this.hostId, required this.status, required this.maxPlayers, required this.totalRounds, required this.currentRound, @TimestampConverter() required this.createdAt});
  factory _Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

@override@JsonKey(includeToJson: false) final  String id;
@override final  String hostId;
@override final  RoomStatus status;
@override final  int maxPlayers;
@override final  int totalRounds;
@override final  int currentRound;
@override@TimestampConverter() final  DateTime createdAt;

/// Create a copy of Room
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoomCopyWith<_Room> get copyWith => __$RoomCopyWithImpl<_Room>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoomToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Room&&(identical(other.id, id) || other.id == id)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.status, status) || other.status == status)&&(identical(other.maxPlayers, maxPlayers) || other.maxPlayers == maxPlayers)&&(identical(other.totalRounds, totalRounds) || other.totalRounds == totalRounds)&&(identical(other.currentRound, currentRound) || other.currentRound == currentRound)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hostId,status,maxPlayers,totalRounds,currentRound,createdAt);

@override
String toString() {
  return 'Room(id: $id, hostId: $hostId, status: $status, maxPlayers: $maxPlayers, totalRounds: $totalRounds, currentRound: $currentRound, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$RoomCopyWith<$Res> implements $RoomCopyWith<$Res> {
  factory _$RoomCopyWith(_Room value, $Res Function(_Room) _then) = __$RoomCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String id, String hostId, RoomStatus status, int maxPlayers, int totalRounds, int currentRound,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class __$RoomCopyWithImpl<$Res>
    implements _$RoomCopyWith<$Res> {
  __$RoomCopyWithImpl(this._self, this._then);

  final _Room _self;
  final $Res Function(_Room) _then;

/// Create a copy of Room
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? hostId = null,Object? status = null,Object? maxPlayers = null,Object? totalRounds = null,Object? currentRound = null,Object? createdAt = null,}) {
  return _then(_Room(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,hostId: null == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RoomStatus,maxPlayers: null == maxPlayers ? _self.maxPlayers : maxPlayers // ignore: cast_nullable_to_non_nullable
as int,totalRounds: null == totalRounds ? _self.totalRounds : totalRounds // ignore: cast_nullable_to_non_nullable
as int,currentRound: null == currentRound ? _self.currentRound : currentRound // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
