import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tp_final_fluter/models/player/player.dart';
import 'package:tp_final_fluter/services/auth_provider.dart';
import 'package:tp_final_fluter/services/firestore.dart';

final playerRepositoryProvider = Provider((ref) => PlayerRepository(ref.watch(firestoreProvider)));

final playerStreamProvider = StreamProvider.family<Player?, ({String idRoom, String idPlayer})>((ref, params) {
  return ref.watch(playerRepositoryProvider).watchPlayer(idRoom: params.idRoom, idPlayer: params.idPlayer);
});

class PlayerRepository {
  final FirebaseFirestore _db;
  PlayerRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _rooms => _db.collection('rooms');

  Future<void> createPlayer({required String idRoom,required Player player }) async
  {
    await _rooms.doc(idRoom)
      .collection('players')
      .doc(player.id)
      .set(player.toJson());
  }

  Future<List<Player>> getPlayersByRoom({required String idRoom}) async
  {
    var data = await _rooms.doc(idRoom)
      .collection('players')
      .get();
    final List<Player> players = data.docs.map((doc) {
      final data = doc.data();
      return Player.fromJson({'id': doc.id, ...data});
    }).toList();
    return players;
  }

  Stream<Player?> watchPlayer({required String idRoom, required String idPlayer}) {
    return _rooms.doc(idRoom)
    .collection('players')
    .doc(idPlayer)
    .snapshots()
    .map((doc) {
      if (!doc.exists) return null;
      return Player.fromJson(doc.data()!);
    });
  }
}