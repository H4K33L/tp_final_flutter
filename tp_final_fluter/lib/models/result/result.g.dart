// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Result _$ResultFromJson(Map<String, dynamic> json) => _Result(
  id: json['id'] as String,
  voteCount: (json['voteCount'] as num).toInt(),
  pointsEarned: (json['pointsEarned'] as num).toInt(),
);

Map<String, dynamic> _$ResultToJson(_Result instance) => <String, dynamic>{
  'voteCount': instance.voteCount,
  'pointsEarned': instance.pointsEarned,
};
