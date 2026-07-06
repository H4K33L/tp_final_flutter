import 'package:freezed_annotation/freezed_annotation.dart';

part 'player.freezed.dart';
part 'player.g.dart';

@freezed
abstract class Player with _$Player {
  const factory Player({
    @JsonKey(includeToJson: false) required String id, // = Firestore doc.id (the uid), never written back into the document body
    required String displayName,
    required bool isHost,
    required bool isReady,
    required bool isSpectator,
    @Default(0) int totalScore,
  }) = _Player;

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
}