import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore.dart';
import '../services/round_service.dart';
import '../models/round/round.dart';
import '../models/submission/submission.dart';
import 'room_providers.dart';
import 'auth_providers.dart';

// --- Actions ---
final roundServiceProvider = Provider<RoundService>((ref) => RoundService());

// --- Round courant, dépend de room.currentRound ---
final currentRoundStreamProvider = StreamProvider.family<Round?, String>((ref, roomId) {
  final roomAsync = ref.watch(roomStreamProvider(roomId));

  return roomAsync.when(
    data: (room) {
      if (room == null) return const Stream.empty();
      return roundsRef(roomId)
          .doc(room.currentRound.toString())
          .snapshots()
          .map((snap) => snap.data());
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

// --- Soumissions de la manche courante ---
final submissionsStreamProvider = StreamProvider.family<List<Submission>, ({String roomId, int roundNumber})>((ref, args) {
  return submissionsRef(args.roomId, args.roundNumber).snapshots().map(
    (snap) => snap.docs.map((d) => d.data()).toList(),
  );
});

// Est-ce que LE joueur courant a déjà soumis sa photo pour cette manche ?
final hasSubmittedProvider = Provider.family<bool, ({String roomId, int roundNumber})>((ref, args) {
  final uid = ref.watch(currentUserIdProvider);
  final submissions = ref.watch(submissionsStreamProvider(args)).value ?? [];
  if (uid == null) return false;
  return submissions.any((s) => s.id == uid);
});