// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Vote _$VoteFromJson(Map<String, dynamic> json) => _Vote(
  id: json['id'] as String,
  votedForPlayerId: json['votedForPlayerId'] as String,
  votedAt: const TimestampConverter().fromJson(json['votedAt'] as Timestamp),
);

Map<String, dynamic> _$VoteToJson(_Vote instance) => <String, dynamic>{
  'votedForPlayerId': instance.votedForPlayerId,
  'votedAt': const TimestampConverter().toJson(instance.votedAt),
};
