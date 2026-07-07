import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tp_final_fluter/repositories/player_repository.dart';

class FinishedWidget extends ConsumerWidget {
  const FinishedWidget({super.key, required this.roomId});
  final String roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.watch(playersStreamProvider(roomId));

    return Scaffold(
      appBar: AppBar(title: const Text('Partie terminée !'), elevation: 0),
      body: SafeArea(
        child: playersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur: $e')),
          data: (players) {
            final sorted = [...players]..sort((a, b) => b.totalScore.compareTo(a.totalScore));
            const medals = ['🥇', '🥈', '🥉'];

            return Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Podium Final',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: sorted.length,
                    itemBuilder: (context, index) {
                      final p = sorted[index];
                      final medal = index < 3 ? medals[index] : '${index + 1}.';
                      return Card(
                        elevation: index == 0 ? 4 : 1,
                        child: ListTile(
                          leading: Text(medal, style: const TextStyle(fontSize: 28)),
                          title: Text(
                            p.displayName,
                            style: TextStyle(
                              fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal,
                              fontSize: index == 0 ? 18 : 16,
                            ),
                          ),
                          trailing: Text(
                            '${p.totalScore} pt${p.totalScore != 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: index == 0 ? 18 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.home),
                    label: const Text("Retour à l'accueil"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () =>
                        Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false),
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
