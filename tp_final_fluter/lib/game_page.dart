import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tp_final_fluter/models/room/room.dart';
import 'package:tp_final_fluter/models/round/round.dart';
import 'package:tp_final_fluter/game_page_widget/finished_widget.dart';
import 'package:tp_final_fluter/game_page_widget/playing_widget.dart';
import 'package:tp_final_fluter/game_page_widget/voting_widget.dart';
import 'package:tp_final_fluter/game_page_widget/starting_widget.dart';
import 'package:tp_final_fluter/game_page_widget/waiting_widget.dart';
import 'package:tp_final_fluter/repositories/room_repository.dart';
import 'package:tp_final_fluter/repositories/round_repository.dart';
import 'package:tp_final_fluter/game_page_widget/result_widget.dart';

class GamePage extends ConsumerStatefulWidget {
  const GamePage({
    super.key,
    required this.id,
    required this.userName,
    required this.camera,
  });

  final String id;
  final String userName;
  final CameraDescription? camera;

  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage> {
  String? roomId;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_setupRoom);
  }

  Future<void> _setupRoom() async {
    final service = ref.read(roomRepositoryProvider);
    try {
      final String finalRoomId;
      if (widget.id == '0') {
        finalRoomId = await service.createRoom(displayName: widget.userName);
      } else {
        await service.joinRoom(code: widget.id, displayName: widget.userName);
        finalRoomId = widget.id;
      }
      if (mounted) setState(() => roomId = finalRoomId);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(elevation: 0),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Retour'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (roomId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return RoomRouter(roomId: roomId!, camera: widget.camera);
  }
}

class RoomRouter extends ConsumerWidget {
  const RoomRouter({required this.roomId, required this.camera, super.key});
  final String roomId;
  final CameraDescription? camera;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomAsync = ref.watch(roomStreamProvider(roomId));

    return roomAsync.when(
      data: (room) {
        if (room == null) {
          return const Center(child: Text('Room introuvable'));
        }
        return switch (room.status) {
          RoomStatus.waiting  => WaitingWidget(roomId: roomId),
          RoomStatus.starting => StartingWidget(roomId: roomId),
          RoomStatus.playing  => RoundRouter(
              roomId: roomId,
              roundNumber: room.currentRound,
              camera: camera,
            ),
          RoomStatus.results  => ResultsWidget(roomId: roomId),
          RoomStatus.finished => FinishedWidget(roomId: roomId),
        };
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
    );
  }
}

class RoundRouter extends ConsumerWidget {
  const RoundRouter({
    required this.roomId,
    required this.roundNumber,
    required this.camera,
    super.key,
  });
  final String roomId;
  final int roundNumber;
  final CameraDescription? camera;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roundAsync = ref.watch(
      roundstreamProvider((idRoom: roomId, idRound: roundNumber.toString())),
    );

    return roundAsync.when(
      data: (round) {
        if (round == null) {
          return const Center(child: Text('Manche introuvable'));
        }
        return switch (round.status) {
          RoundStatus.capturing => PlayingWidget(
              roomId: roomId,
              camera: camera,
              roundNumber: roundNumber,
              endsAt: round.endsAt,
            ),
          RoundStatus.voting    => VotingGallery(roomId: roomId, roundNumber: roundNumber),
          RoundStatus.closed    => const Center(child: CircularProgressIndicator()),
        };
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
    );
  }
}