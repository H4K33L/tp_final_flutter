import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';
part 'result.g.dart';

@freezed
abstract class Result with _$Result {
  const factory Result({
    @JsonKey(includeToJson: false) required String id, // = Firestore doc.id = the playerId this result is about
    required int voteCount,
    required int pointsEarned,
  }) = _Result;

  factory Result.fromJson(Map<String, dynamic> json) => _$ResultFromJson(json);
}