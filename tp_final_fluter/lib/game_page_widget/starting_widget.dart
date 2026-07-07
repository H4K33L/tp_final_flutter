import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tp_final_fluter/repositories/player_repository.dart';
import 'package:tp_final_fluter/repositories/room_repository.dart';
import 'package:tp_final_fluter/repositories/round_repository.dart';

class StartingWidget extends ConsumerStatefulWidget {
  const StartingWidget({super.key, required this.roomId});
  final String roomId;

  @override
  ConsumerState<StartingWidget> createState() => _StartingWidgetState();
}

class _StartingWidgetState extends ConsumerState<StartingWidget> {
  final _themeController = TextEditingController();
  bool _isStarting = false;

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  Future<void> _startRound() async {
    final theme = _themeController.text.trim();
    if (theme.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrez un thème avant de lancer')),
      );
      return;
    }
    setState(() => _isStarting = true);
    try {
      final room = ref.read(roomStreamProvider(widget.roomId)).value;
      final nextRound = (room?.currentRound ?? 0) + 1;
      final players = await ref.read(playerRepositoryProvider).getPlayersByRoom(idRoom: widget.roomId);
      final masterIndex = ref.read(roundsRepositoryProvider).computeThemeMasterIndex(
        roundNumber: nextRound,
        playerCount: players.length,
      );
      await ref.read(roundsRepositoryProvider).startRound(
        roomId: widget.roomId,
        theme: theme,
        roundNumber: nextRound,
        themeMasterId: players[masterIndex].id,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final room = ref.watch(roomStreamProvider(widget.roomId)).value;
    final isHost = room?.hostId == uid;

    if (!isHost) {
      return const Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Le host choisit le thème de la prochaine manche...'),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Choisir le thème'), elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _themeController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Thème de la manche',
                  hintText: 'Ex : quelque chose de rouge…',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: _isStarting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_circle_outline),
                label: const Text('Lancer la manche (60s)'),
                onPressed: _isStarting ? null : _startRound,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
