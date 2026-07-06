import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../timestamp_converter.dart';

part 'submission.freezed.dart';
part 'submission.g.dart';

@freezed
abstract class Submission with _$Submission {
  const factory Submission({
    @JsonKey(includeToJson: false) required String id, // = Firestore doc.id = the playerId who submitted
    required String photoUrl,
    required String storagePath,
    @TimestampConverter() required DateTime submittedAt,
  }) = _Submission;

  factory Submission.fromJson(Map<String, dynamic> json) => _$SubmissionFromJson(json);
}