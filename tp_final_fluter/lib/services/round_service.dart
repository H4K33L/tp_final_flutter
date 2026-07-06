import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tp_final_fluter/models/round/round.dart';
import 'package:tp_final_fluter/services/auth_provider.dart';

final roundRepositoryProvider = Provider((ref) => RoundRepository(ref.watch(firestoreProvider)));

final roundStreamProvider = StreamProvider.family<Round?, ({String idRoom, String idRound})>((ref, params) {
  return ref.watch(roundRepositoryProvider).watchRound(idRoom: params.idRoom,idRound: params.idRound);
});

class RoundRepository {
  final FirebaseFirestore _db;
  RoundRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _rooms => _db.collection('rooms');

  Future<void> createRound({required String idRoom, required Round round}) async
  {
    await _rooms.doc(idRoom)
      .collection('rounds')
      .doc(round.id)
      .set(round.toJson());
  }

  Future<List<Round>> getRoundByRoom({required String idRoom}) async
  {
    var data = await _rooms.doc(idRoom)
      .collection('rounds')
      .get();
    final List<Round> rounds = data.docs.map((doc) {
      final json = doc.data();
      return Round.fromJson({'id': doc.id, ...json});
    }).toList();

    return rounds;
  }

  Stream<Round?> watchRound({required String idRoom, required String idRound})
  {
    return _rooms.doc(idRoom)
    .collection('rounds')
    .doc(idRound)
    .snapshots()
    .map((doc) {
      if (!doc.exists) return null;
      return Round.fromJson(doc.data()!);
    });
  }
}