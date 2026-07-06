import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tp_final_fluter/models/testRoom.dart';
import 'package:tp_final_fluter/services/auth_provider.dart';

final roomRepositoryProvider = Provider((ref) => RoomRepository(ref.watch(firestoreProvider)));

final roomStreamProvider = StreamProvider.family<Room?, String>((ref, code) {
  return ref.watch(roomRepositoryProvider).watchRoom(code);
});

class RoomRepository {
  final FirebaseFirestore _db;
  RoomRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _rooms => _db.collection('rooms');

  // Créer
  Future<void> createRoom({required String hostId, required Room room}) async {
    await _rooms.doc(room.code).set(room.toJson());
  }

  Future<Room?> getRoom(String code) async {
    final doc = await _rooms.doc(code).get();
    if (!doc.exists) return null;

    return Room.fromJson(doc.data()!);
  }

  Stream<Room?> watchRoom(String code) {
    return _rooms.doc(code).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Room.fromJson(doc.data()!);
    });
  }

  String _generateRoomCode() {
    // ex: code court à 6 caractères pour que les joueurs rejoignent facilement
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = DateTime.now().millisecondsSinceEpoch;
    return List.generate(6, (i) => chars[(rnd + i * 7) % chars.length]).join();
  }
}