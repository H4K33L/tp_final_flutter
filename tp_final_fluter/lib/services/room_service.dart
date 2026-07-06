import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore.dart';
import '../models/room/room.dart';
import '../models/player/player.dart';

final roomRepositoryProvider = Provider((ref) => RoomService());

class RoomService {
  final _auth = FirebaseAuth.instance;

  /// Crée une nouvelle room, l'utilisateur courant devient host.
  /// Retourne le code de la room créée.
  Future<String> createRoom({required String displayName}) async {
    final uid = _auth.currentUser!.uid;

    String code;
    DocumentSnapshot existing;
    do {
      code = _generateCode();
      existing = await roomsRef().doc(code).get();
    } while (existing.exists);

    final room = Room(
      id: code,
      hostId: uid,
      status: RoomStatus.waiting,
      maxPlayers: 6,
      totalRounds: 5,
      currentRound: 0,
      createdAt: DateTime.now(),
    );
    await roomsRef().doc(code).set(room);

    final player = Player(
      id: uid,
      displayName: displayName,
      isHost: true,
      isReady: false,
      isSpectator: false,
    );
    await playersRef(code).doc(uid).set(player);

    return code;
  }

  /// Rejoint une room existante. Lève une exception si la room
  /// n'existe pas, est pleine, ou n'est plus en attente.
  Future<void> joinRoom({required String code, required String displayName}) async {
    final uid = _auth.currentUser!.uid;

    final roomSnap = await roomsRef().doc(code).get();
    if (!roomSnap.exists) {
      throw Exception('Room introuvable');
    }
    final room = roomSnap.data()!;
    if (room.status != RoomStatus.waiting) {
      throw Exception('La partie a déjà commencé');
    }

    final playersSnap = await playersRef(code).get();
    if (playersSnap.docs.length >= room.maxPlayers) {
      throw Exception('Room complète');
    }

    // Si le joueur est déjà dedans (ex: reconnexion), on ne le recrée pas
    final alreadyIn = playersSnap.docs.any((d) => d.id == uid);
    if (alreadyIn) return;

    final player = Player(
      id: uid,
      displayName: displayName,
      isHost: false,
      isReady: false,
      isSpectator: false,
    );
    await playersRef(code).doc(uid).set(player);
  }

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = DateTime.now().microsecondsSinceEpoch;
    return List.generate(6, (i) => chars[(rand + i * 37) % chars.length]).join();
  }
}
