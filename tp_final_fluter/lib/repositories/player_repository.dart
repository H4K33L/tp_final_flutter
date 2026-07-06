import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tp_final_fluter/models/player/player.dart';
import 'package:tp_final_fluter/providers/auth_provider.dart';

final playerRepositoryProvider = Provider((ref) => PlayerRepository(ref.watch(firestoreProvider)));

final playerStreamProvider = StreamProvider.family<Player?, ({String idRoom, String idPlayer})>((ref, params) {
  return ref.watch(playerRepositoryProvider).watchPlayer(idRoom: params.idRoom, idPlayer: params.idPlayer);
});

final playersStreamProvider = StreamProvider.family<List<Player>, String>((ref, idRoom) {
  return ref.watch(playerRepositoryProvider).watchPlayers(idRoom: idRoom);
});

class PlayerRepository {
  final FirebaseFirestore _db;
  PlayerRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _rooms => _db.collection('rooms');

  Future<void> createPlayer({required String idRoom, required Player player}) async {
    await _rooms
        .doc(idRoom)
        .collection('players')
        .doc(player.id)
        .set(player.toJson());
  }

  Future<List<Player>> getPlayersByRoom({required String idRoom}) async {
    final data = await _rooms.doc(idRoom).collection('players').get();
    final List<Player> players = data.docs.map((doc) {
      return Player.fromJson({'id': doc.id, ...doc.data()});
    }).toList();
    return players;
  }

  Stream<Player?> watchPlayer({required String idRoom, required String idPlayer}) {
    return _rooms
        .doc(idRoom)
        .collection('players')
        .doc(idPlayer)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return Player.fromJson({'id': doc.id, ...doc.data()!}); // fix: id injecté
    });
  }

  Stream<List<Player>> watchPlayers({required String idRoom}) {
    return _rooms.doc(idRoom).collection('players').snapshots().map((snap) {
      return snap.docs.map((doc) {
        return Player.fromJson({'id': doc.id, ...doc.data()});
      }).toList();
    });
  }
}