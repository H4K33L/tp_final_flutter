import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room/room.dart';
import '../models/player/player.dart';
import '../models/round/round.dart';
import '../models/submission/submission.dart';
import '../models/vote/vote.dart';
import '../models/result/result.dart';

final _db = FirebaseFirestore.instance;

CollectionReference<Room> roomsRef() {
  return _db.collection('rooms').withConverter<Room>(
    fromFirestore: (snap, _) => Room.fromJson({...snap.data()!, 'id': snap.id}),
    toFirestore: (room, _) => room.toJson(),
  );
}

CollectionReference<Player> playersRef(String roomId) {
  return _db
      .collection('rooms').doc(roomId)
      .collection('players')
      .withConverter<Player>(
        fromFirestore: (snap, _) => Player.fromJson({...snap.data()!, 'id': snap.id}),
        toFirestore: (player, _) => player.toJson(),
      );
}

CollectionReference<Round> roundsRef(String roomId) {
  return _db
      .collection('rooms').doc(roomId)
      .collection('rounds')
      .withConverter<Round>(
        fromFirestore: (snap, _) => Round.fromJson({...snap.data()!, 'id': snap.id}),
        toFirestore: (round, _) => round.toJson(),
      );
}

CollectionReference<Submission> submissionsRef(String roomId, int roundNumber) {
  return _db
      .collection('rooms').doc(roomId)
      .collection('rounds').doc(roundNumber.toString())
      .collection('submissions')
      .withConverter<Submission>(
        fromFirestore: (snap, _) => Submission.fromJson({...snap.data()!, 'id': snap.id}),
        toFirestore: (sub, _) => sub.toJson(),
      );
}

CollectionReference<Vote> votesRef(String roomId, int roundNumber) {
  return _db
      .collection('rooms').doc(roomId)
      .collection('rounds').doc(roundNumber.toString())
      .collection('votes')
      .withConverter<Vote>(
        fromFirestore: (snap, _) => Vote.fromJson({...snap.data()!, 'id': snap.id}),
        toFirestore: (vote, _) => vote.toJson(),
      );
}

CollectionReference<Result> resultsRef(String roomId, int roundNumber) {
  return _db
      .collection('rooms').doc(roomId)
      .collection('rounds').doc(roundNumber.toString())
      .collection('results')
      .withConverter<Result>(
        fromFirestore: (snap, _) => Result.fromJson({...snap.data()!, 'id': snap.id}),
        toFirestore: (result, _) => result.toJson(),
      );
}