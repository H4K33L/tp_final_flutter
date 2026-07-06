import 'firestore.dart';
import '../models/vote/vote.dart';

class VoteService {
  /// Enregistre le vote d'un joueur. L'ID du document = voterId,
  /// ce qui empêche matériellement le double-vote.
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