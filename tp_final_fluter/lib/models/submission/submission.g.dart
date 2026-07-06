// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Submission _$SubmissionFromJson(Map<String, dynamic> json) => _Submission(
  id: json['id'] as String,
  photoUrl: json['photoUrl'] as String,
  storagePath: json['storagePath'] as String,
  submittedAt: const TimestampConverter().fromJson(
    json['submittedAt'] as Timestamp,
  ),
);

Map<String, dynamic> _$SubmissionToJson(_Submission instance) =>
    <String, dynamic>{
      'photoUrl': instance.photoUrl,
      'storagePath': instance.storagePath,
      'submittedAt': const TimestampConverter().toJson(instance.submittedAt),
    };
