import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore.dart';
import '../services/room_service.dart';
import '../models/room/room.dart';
import '../models/player/player.dart';
import 'auth_providers.dart';

// --- Actions ---
final roomServiceProvider = Provider<RoomService>((ref) => RoomService());

// --- Lecture temps réel ---
final roomStreamProvider = StreamProvider.family<Room?, String>((ref, roomId) {
  return roomsRef().doc(roomId).snapshots().map((snap) => snap.data());
});

final playersStreamProvider = StreamProvider.family<List<Player>, String>((ref, roomId) {
  return playersRef(roomId).snapshots().map(
    (snap) => snap.docs.map((d) => d.data()).toList(),
  );
});

// Le joueur courant, dérivé de playersStreamProvider + currentUserIdProvider
final currentPlayerProvider = Provider.family<Player?, String>((ref, roomId) {
  final uid = ref.watch(currentUserIdProvider);
  final players = ref.watch(playersStreamProvider(roomId)).value ?? [];
  if (uid == null) return null;
  try {
    return players.firstWhere((p) => p.id == uid);
  } catch (_) {
    return null;
  }
});

final isHostProvider = Provider.family<bool, String>((ref, roomId) {
  return ref.watch(currentPlayerProvider(roomId))?.isHost ?? false;
});