import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tp_final_fluter/repositories/player_repository.dart';
import 'package:tp_final_fluter/repositories/room_repository.dart';

class ResultsWidget extends ConsumerWidget {
  const ResultsWidget({super.key, required this.roomId});
  final String roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final roomAsync = ref.watch(roomStreamProvider(roomId));
    final room = roomAsync.value;
    final isHost = room?.hostId == uid;
    final currentRound = room?.currentRound ?? 0;
    final totalRounds = room?.totalRounds ?? 5;

    final playersAsync = ref.watch(playersStreamProvider(roomId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Résultats - Manche $currentRound / $totalRounds'),
        elevation: 0,
      ),
      body: SafeArea(
        child: playersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur: $e')),
          data: (players) {
            final sorted = [...players]..sort((a, b) => b.totalScore.compareTo(a.totalScore));
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Classement',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: sorted.length,
                    itemBuilder: (context, index) {
                      final p = sorted[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          title: Text(p.displayName),
                          trailing: Text(
                            '${p.totalScore} pt${p.totalScore != 1 ? 's' : ''}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: isHost
                      ? Row(
                          children: [
                            if (currentRound < totalRounds) ...[
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.skip_next),
                                  label: const Text('Manche suivante'),
                                  onPressed: () async {
                                    try {
                                      await ref.read(roomRepositoryProvider).startNextRound(roomId);
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Erreur: $e')),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.flag),
                                label: const Text('Terminer le jeu'),
                                onPressed: () async {
                                  try {
                                    await ref.read(roomRepositoryProvider).endGame(roomId);
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Erreur: $e')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'En attente que le host lance la manche suivante...',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
