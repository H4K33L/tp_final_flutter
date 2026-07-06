import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tp_final_fluter/models/room/room.dart';
import 'package:tp_final_fluter/models/round/round.dart';
import 'package:tp_final_fluter/game_page_widget/finished_widget.dart';
import 'package:tp_final_fluter/game_page_widget/playing_widget.dart';
import 'package:tp_final_fluter/game_page_widget/result_widjet.dart';
import 'package:tp_final_fluter/game_page_widget/starting_widget.dart';
import 'package:tp_final_fluter/game_page_widget/voting_widjet.dart';
import 'package:tp_final_fluter/game_page_widget/waiting_widget.dart';
import 'package:tp_final_fluter/repositories/room_repository.dart';
import 'package:tp_final_fluter/repositories/round_repository.dart';

class GamePage extends ConsumerStatefulWidget {
  const GamePage({
    super.key,
    required this.title,
    required this.id,
    required this.userName,
    required this.camera,
  });

  final String title;
  final String id;
  final String userName;
  final CameraDescription camera;

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
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _error != null
              ? Center(child: Text('Erreur: $_error'))
              : roomId == null
                  ? const Center(child: CircularProgressIndicator())
                  : RoomRouter(roomId: roomId!, camera: widget.camera),
        ),
      ),
    );
  }
}

/// Niveau 1 : route sur RoomStatus (waiting, starting, playing, results, finished)
class RoomRouter extends ConsumerWidget {
  const RoomRouter({required this.roomId, required this.camera, super.key});
  final String roomId;
  final CameraDescription camera;

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
          RoomStatus.playing  => RoundRouter(roomId: roomId, camera: camera),
          RoomStatus.results  => ResultsWidget(roomId: roomId),
          RoomStatus.finished => FinishedWidget(roomId: roomId),
        };
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
    );
  }
}

/// Niveau 2 : route sur RoundStatus (capturing, voting, closed) — actif seulement
/// pendant RoomStatus.playing, puisque Room.status ne suit pas les sous-phases.
class RoundRouter extends ConsumerWidget {
  const RoundRouter({required this.roomId, required this.camera, super.key});
  final String roomId;
  final CameraDescription camera;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roundAsync = ref.watch(roundstreamProvider(roomId));

    return roundAsync.when(
      data: (round) {
        if (round == null) {
          return const Center(child: Text('Manche introuvable'));
        }
        return switch (round.status) {
          RoundStatus.capturing => PlayingWidget(id: roomId, camera: camera),
          RoundStatus.voting    => VotingWidget(roomId: roomId),
          RoundStatus.closed    => const Center(child: CircularProgressIndicator()),
        };
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
    );
  }
}