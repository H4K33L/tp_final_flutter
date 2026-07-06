import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../timestamp_converter.dart';

part 'round.freezed.dart';
part 'round.g.dart';

enum RoundStatus { capturing, voting, closed }

@freezed
abstract class Round with _$Round {
  const factory Round({
    @JsonKey(includeToJson: false) required String id, // = Firestore doc.id (the round number in string format)
    required String theme,
    required String themeMasterId,
    required RoundStatus status,
    @TimestampConverter() required DateTime startedAt,
    @TimestampConverter() required DateTime endsAt,
    @NullableTimestampConverter() DateTime? votingEndsAt, // nullable
  }) = _Round;

  factory Round.fromJson(Map<String, dynamic> json) => _$RoundFromJson(json);
}