import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tp_final_fluter/models/result/result.dart';
import 'package:tp_final_fluter/models/room/room.dart';
import 'package:tp_final_fluter/models/round/round.dart';
import 'package:tp_final_fluter/models/submission/submission.dart';
import 'package:tp_final_fluter/providers/auth_provider.dart';
import 'package:tp_final_fluter/services/firestore.dart';

final roundsRepositoryProvider = Provider((ref) => RoundsRepository(ref.watch(firestoreProvider)));

final roundstreamProvider = StreamProvider.family<Round?, ({String idRoom, String idRound})>((ref, params) {
  return ref.watch(roundsRepositoryProvider).watchRound(idRoom: params.idRoom, idRound: params.idRound);
});

class RoundsRepository {
  final FirebaseFirestore _db;
  RoundsRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _rooms => _db.collection('rooms');
  
  /// Le host lance une nouvelle manche : choisit le thème, démarre le timer de 60s,
  /// et fait passer la room en "playing".
  Future<void> startRound({
    required String roomId,
    required String theme,
    required int roundNumber,
    required String themeMasterId,
  }) async {
    final now = DateTime.now();
    final round = Round(
      id: roundNumber.toString(),
      theme: theme,
      themeMasterId: themeMasterId,
      status: RoundStatus.capturing,
      startedAt: now,
      endsAt: now.add(const Duration(seconds: 60)),
      votingEndsAt: null,
    );

    await roundsRef(roomId).doc(roundNumber.toString()).set(round);

    await roomsRef().doc(roomId).update({
      'status': RoomStatus.playing.name,
      'currentRound': roundNumber,
    });
  }

  /// Un joueur soumet sa photo pour la manche en cours.
  /// Refuse si le timer de capture est déjà écoulé.
  Future<void> submitPhoto({
    required String roomId,
    required int roundNumber,
    required String playerId,
    required String photoUrl,
    required String storagePath,
  }) async {
    final roundSnap = await roundsRef(roomId).doc(roundNumber.toString()).get();
    final round = roundSnap.data();
    if (round == null) throw Exception('Manche introuvable');
    if (DateTime.now().isAfter(round.endsAt)) {
      throw Exception('Le temps est écoulé, impossible de soumettre');
    }

    final submission = Submission(
      id: playerId,
      photoUrl: photoUrl,
      storagePath: storagePath,
      submittedAt: DateTime.now(),
    );

    await submissionsRef(roomId, roundNumber).doc(playerId).set(submission);
  }

  /// Fait passer la manche de "capturing" à "voting" (timer écoulé ou host force).
  Future<void> closeCapture({required String roomId, required int roundNumber}) async {
    await roundsRef(roomId).doc(roundNumber.toString()).update({
      'status': RoundStatus.voting.name,
      'votingEndsAt': Timestamp.fromDate(DateTime.now().add(const Duration(seconds: 30))),
    });
  }

  /// Clôture le vote : compte les votes, écrit les résultats, incrémente les scores.
  Future<void> closeVotingAndComputeResults({
    required String roomId,
    required int roundNumber,
  }) async {
    final votesSnap = await votesRef(roomId, roundNumber).get();
    final votes = votesSnap.docs.map((d) => d.data()).toList();

    // Compte les votes par joueur voté
    final voteCounts = <String, int>{};
    for (final vote in votes) {
      voteCounts[vote.votedForPlayerId] = (voteCounts[vote.votedForPlayerId] ?? 0) + 1;
    }

    if (voteCounts.isEmpty) {
      await _closeRound(roomId, roundNumber);
      return;
    }

    final maxVotes = voteCounts.values.reduce((a, b) => a > b ? a : b);
    // Gère l'égalité : tous les joueurs avec le max de votes gagnent des points
    final winners = voteCounts.entries.where((e) => e.value == maxVotes).map((e) => e.key).toSet();

    final batch = FirebaseFirestore.instance.batch();

    for (final entry in voteCounts.entries) {
      final playerId = entry.key;
      final voteCount = entry.value;
      final pointsEarned = winners.contains(playerId) ? 1 : 0;

      final result = Result(id: playerId, voteCount: voteCount, pointsEarned: pointsEarned);
      batch.set(resultsRef(roomId, roundNumber).doc(playerId), result);

      if (pointsEarned > 0) {
        final playerRef = playersRef(roomId).doc(playerId);
        batch.update(playerRef, {'totalScore': FieldValue.increment(pointsEarned)});
      }
    }

    await batch.commit();
    await _closeRound(roomId, roundNumber);
  }

  Future<void> _closeRound(String roomId, int roundNumber) async {
    await roundsRef(roomId).doc(roundNumber.toString()).update({'status': RoundStatus.closed.name});
    await roomsRef().doc(roomId).update({'status': RoomStatus.results.name});
  }

  /// Calcule l'index du prochain maître du thème (rotation équitable).
  int computeThemeMasterIndex({required int roundNumber, required int playerCount}) {
    return roundNumber % playerCount;
  }

  Stream<Round?> watchRound({required String idRoom, required String idRound}) {
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