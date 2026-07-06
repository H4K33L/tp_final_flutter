import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore.dart';
import '../services/vote_service.dart';
import '../models/vote/vote.dart';
import 'auth_providers.dart';

// --- Actions ---
final voteServiceProvider = Provider<VoteService>((ref) => VoteService());

// --- Votes de la manche courante ---
final votesStreamProvider = StreamProvider.family<List<Vote>, ({String roomId, int roundNumber})>((ref, args) {
  return votesRef(args.roomId, args.roundNumber).snapshots().map(
    (snap) => snap.docs.map((d) => d.data()).toList(),
  );
});

// Est-ce que LE joueur courant a déjà voté pour cette manche ?
final hasVotedProvider = Provider.family<bool, ({String roomId, int roundNumber})>((ref, args) {
  final uid = ref.watch(currentUserIdProvider);
  final votes = ref.watch(votesStreamProvider(args)).value ?? [];
  if (uid == null) return false;
  return votes.any((v) => v.id == uid);
});