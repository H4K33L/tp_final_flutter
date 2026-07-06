import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tp_final_fluter/core/timeStampConverter.dart';

part 'testRoom.freezed.dart';
part 'testRoom.g.dart';

@freezed
abstract class Room with _$Room {  
  const factory Room({
    required String code,
    required String hostId, // <-- convention lowerCamelCase, voir remarque plus bas
    required int totalRound,
    @TimestampConverter() required DateTime createdAt,
    @Default("Waiting") String status,
    @Default(6) int maxPlayers,
    @Default(0) int currentRound,
  }) = _Room;

  factory Room.fromJson(Map<String, dynamic> json)
    => _$RoomFromJson(json);
}