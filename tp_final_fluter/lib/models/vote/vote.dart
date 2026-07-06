import 'package:freezed_annotation/freezed_annotation.dart';
import '../timestamp_converter.dart';

part 'vote.freezed.dart';
part 'vote.g.dart';

@freezed
abstract class Vote with _$Vote {
  const factory Vote({
    @JsonKey(includeToJson: false) required String id, // = Firestore doc.id = the voterId
    required String votedForPlayerId,
    @TimestampConverter() required DateTime votedAt,
  }) = _Vote;

  factory Vote.fromJson(Map<String, dynamic> json) => _$VoteFromJson(json);
}