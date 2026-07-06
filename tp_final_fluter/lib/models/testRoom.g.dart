// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'testRoom.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Room _$RoomFromJson(Map<String, dynamic> json) => _Room(
  code: json['code'] as String,
  hostId: json['hostId'] as String,
  totalRound: (json['totalRound'] as num).toInt(),
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  status: json['status'] as String? ?? "Waiting",
  maxPlayers: (json['maxPlayers'] as num?)?.toInt() ?? 6,
  currentRound: (json['currentRound'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$RoomToJson(_Room instance) => <String, dynamic>{
  'code': instance.code,
  'hostId': instance.hostId,
  'totalRound': instance.totalRound,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'status': instance.status,
  'maxPlayers': instance.maxPlayers,
  'currentRound': instance.currentRound,
};
