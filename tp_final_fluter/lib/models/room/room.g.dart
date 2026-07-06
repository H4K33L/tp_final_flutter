// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Room _$RoomFromJson(Map<String, dynamic> json) => _Room(
  id: json['id'] as String,
  hostId: json['hostId'] as String,
  status: $enumDecode(_$RoomStatusEnumMap, json['status']),
  maxPlayers: (json['maxPlayers'] as num).toInt(),
  totalRounds: (json['totalRounds'] as num).toInt(),
  currentRound: (json['currentRound'] as num).toInt(),
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
);

Map<String, dynamic> _$RoomToJson(_Room instance) => <String, dynamic>{
  'hostId': instance.hostId,
  'status': _$RoomStatusEnumMap[instance.status]!,
  'maxPlayers': instance.maxPlayers,
  'totalRounds': instance.totalRounds,
  'currentRound': instance.currentRound,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
};

const _$RoomStatusEnumMap = {
  RoomStatus.waiting: 'waiting',
  RoomStatus.starting: 'starting',
  RoomStatus.playing: 'playing',
  RoomStatus.results: 'results',
  RoomStatus.finished: 'finished',
};
