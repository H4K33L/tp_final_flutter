import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../timestamp_converter.dart';

part 'room.freezed.dart';
part 'room.g.dart';

enum RoomStatus { waiting, starting, playing, results, finished }

@freezed
abstract class Room with _$Room {
  const factory Room({
    @JsonKey(includeToJson: false) required String id, // = Firestore doc.id = the room's join code
    required String hostId,
    required RoomStatus status,
    required int maxPlayers,
    required int totalRounds,
    required int currentRound,
    @TimestampConverter() required DateTime createdAt,
  }) = _Room;

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
}