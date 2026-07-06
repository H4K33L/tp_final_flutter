import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tp_final_fluter/models/result/result.dart';
import 'package:tp_final_fluter/services/auth_provider.dart';

final resultsRepositoryProvider = Provider((ref) => ResultsRepository(ref.watch(firestoreProvider)));

final resultStreamProvider = StreamProvider.family<Result?, ({String idRoom, String idRound, String idPlayer})>((ref, params) {
  return ref.watch(resultsRepositoryProvider).watchResult(idRoom: params.idRoom, idRound: params.idRound, idPlayer: params.idPlayer);
});

class ResultsRepository {
  final FirebaseFirestore _db;
  ResultsRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _rooms => _db.collection('rooms');

  Future<void> createResult({required String idRoom, required String idRound, required String idPlayer, required Result sub}) async {
    await _rooms.doc(idRoom)
      .collection('rounds')
      .doc(idRound)
      .collection('results')
      .doc(idPlayer)
      .set(sub.toJson());
  }

  Future<List<Result>> getResultsByRound({required String idRoom, required String idRound}) async {
    var data = await _rooms.doc(idRoom)
      .collection('rounds')
      .doc(idRound)
      .collection('results')
      .get();

    final List<Result> rounds = data.docs.map((doc) {
      final json = doc.data();
      return Result.fromJson({'id': doc.id, ...json});
    }).toList();

    return rounds;
  }

  Stream<Result?> watchResult({required String idRoom, required String idRound, required String idPlayer}) {
    return _rooms.doc(idRoom)
      .collection('rounds')
      .doc(idRound)
      .collection('results')
      .doc(idPlayer)
      .snapshots()
      .map((doc) {
        if (!doc.exists) return null;
        return Result.fromJson(doc.data()!);
      });
  }
}
