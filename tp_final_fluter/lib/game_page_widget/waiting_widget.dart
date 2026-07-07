import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tp_final_fluter/repositories/player_repository.dart';
import 'package:tp_final_fluter/repositories/room_repository.dart';

class WaitingWidget extends ConsumerWidget {
  const WaitingWidget({super.key, required this.roomId});
  final String roomId;

  Future<void> _leaveRoom(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomId)
          .collection('players')
          .doc(uid)
          .delete();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final roomAsync = ref.watch(roomStreamProvider(roomId));
    final playersAsync = ref.watch(playersStreamProvider(roomId));

    final isHost = roomAsync.value?.hostId == uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lobby'),
        elevation: 0,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.exit_to_app),
            label: const Text('Quitter'),
            onPressed: () => _leaveRoom(context),
          ),
        ],
      ),
      body: SafeArea(
        child: playersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur: $e')),
          data: (players) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  children: [
                    const Text('Code de la room', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      roomId,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final p = players[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text(p.displayName[0].toUpperCase())),
                      title: Text(p.displayName),
                      trailing: p.isHost ? const Chip(label: Text('Host')) : null,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: isHost
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '${players.length} joueur(s) connecté(s) (min. 2)',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Démarrer la partie'),
                            onPressed: players.length >= 2
                                ? () async {
                                    try {
                                      await ref.read(roomRepositoryProvider).setStatusStarting(roomId);
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Erreur: $e')),
                                        );
                                      }
                                    }
                                  }
                                : null,
                          ),
                        ],
                      )
                    : const Text(
                        'En attente que le host démarre la partie...',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
