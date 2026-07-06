import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tp_final_fluter/models/submission/submission.dart';
import 'package:tp_final_fluter/services/auth_provider.dart';

final submissionsRepositoryProvider = Provider((ref) => SubmissionsRepository(ref.watch(firestoreProvider)));

final submissionStreamProvider = StreamProvider.family<Submission?, ({String idRoom, String idRound, String idPlayer})>((ref, params) {
  return ref.watch(submissionsRepositoryProvider).watchSubmission(idRoom: params.idRoom, idRound: params.idRound, idPlayer: params.idPlayer);
});

class SubmissionsRepository {
  final FirebaseFirestore _db;
  SubmissionsRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _rooms => _db.collection('rooms');

  Future<void> createSubmission({required String idRoom, required String idRound, required String idPlayer, required Submission sub}) async {
    await _rooms.doc(idRoom)
      .collection('rounds')
      .doc(idRound)
      .collection('submissions')
      .doc(idPlayer)
      .set(sub.toJson());
  }

  Future<List<Submission>> getSubmissionsByRound({required String idRoom, required String idRound}) async {
    var data = await _rooms.doc(idRoom)
      .collection('rounds')
      .doc(idRound)
      .collection('submissions')
      .get();

    final List<Submission> rounds = data.docs.map((doc) {
      final json = doc.data();
      return Submission.fromJson({'id': doc.id, ...json});
    }).toList();

    return rounds;
  }

  Stream<Submission?> watchSubmission({required String idRoom, required String idRound, required String idPlayer}) {
    return _rooms.doc(idRoom)
      .collection('rounds')
      .doc(idRound)
      .collection('submissions')
      .doc(idPlayer)
      .snapshots()
      .map((doc) {
        if (!doc.exists) return null;
        return Submission.fromJson(doc.data()!);
      });
  }
}
