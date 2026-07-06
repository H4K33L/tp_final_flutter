import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tp_final_fluter/models/vote/vote.dart';
import 'package:tp_final_fluter/providers/auth_provider.dart';
import 'package:tp_final_fluter/services/firestore.dart';

final votesRepositoryProvider = Provider((ref) => VotesRepository(ref.watch(firestoreProvider)));

final votestreamProvider = StreamProvider.family<Vote?, ({String idRoom, String idRound, String idPlayer})>((ref, params) {
  return ref.watch(votesRepositoryProvider).watchVote(idRoom: params.idRoom, idRound: params.idRound, idPlayer: params.idPlayer);
});

class VotesRepository {
  final FirebaseFirestore _db;
  VotesRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _rooms => _db.collection('rooms');

  Future<void> createVote({required String idRoom, required String idRound, required String idPlayer, required Vote sub}) async {
    await _rooms.doc(idRoom)
      .collection('rounds')
      .doc(idRound)
      .collection('votes')
      .doc(idPlayer)
      .set(sub.toJson());
  }

  Future<List<Vote>> getVotesByRound({required String idRoom, required String idRound}) async {
    var data = await _rooms.doc(idRoom)
      .collection('rounds')
      .doc(idRound)
      .collection('votes')
      .get();

    final List<Vote> rounds = data.docs.map((doc) {
      final json = doc.data();
      return Vote.fromJson({'id': doc.id, ...json});
    }).toList();

    return rounds;
  }

  Stream<Vote?> watchVote({required String idRoom, required String idRound, required String idPlayer}) {
    return _rooms.doc(idRoom)
      .collection('rounds')
      .doc(idRound)
      .collection('votes')
      .doc(idPlayer)
      .snapshots()
      .map((doc) {
        if (!doc.exists) return null;
        return Vote.fromJson(doc.data()!);
      });
  }

  Future<void> submitVote({
    required String roomId,
    required int roundNumber,
    required String voterId,
    required String votedForPlayerId,
  }) async {
    if (voterId == votedForPlayerId) {
      throw Exception('Impossible de voter pour soi-même');
    }

    final existing = await votesRef(roomId, roundNumber).doc(voterId).get();
    if (existing.exists) {
      throw Exception('Vous avez déjà voté pour cette manche');
    }

    final vote = Vote(
      id: voterId,
      votedForPlayerId: votedForPlayerId,
      votedAt: DateTime.now(),
    );

    await votesRef(roomId, roundNumber).doc(voterId).set(vote);
  }
}