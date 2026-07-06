// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'round.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Round _$RoundFromJson(Map<String, dynamic> json) => _Round(
  id: json['id'] as String,
  theme: json['theme'] as String,
  themeMasterId: json['themeMasterId'] as String,
  status: $enumDecode(_$RoundStatusEnumMap, json['status']),
  startedAt: const TimestampConverter().fromJson(
    json['startedAt'] as Timestamp,
  ),
  endsAt: const TimestampConverter().fromJson(json['endsAt'] as Timestamp),
  votingEndsAt: const NullableTimestampConverter().fromJson(
    json['votingEndsAt'] as Timestamp?,
  ),
);

Map<String, dynamic> _$RoundToJson(_Round instance) => <String, dynamic>{
  'theme': instance.theme,
  'themeMasterId': instance.themeMasterId,
  'status': _$RoundStatusEnumMap[instance.status]!,
  'startedAt': const TimestampConverter().toJson(instance.startedAt),
  'endsAt': const TimestampConverter().toJson(instance.endsAt),
  'votingEndsAt': const NullableTimestampConverter().toJson(
    instance.votingEndsAt,
  ),
};

const _$RoundStatusEnumMap = {
  RoundStatus.capturing: 'capturing',
  RoundStatus.voting: 'voting',
  RoundStatus.closed: 'closed',
};
