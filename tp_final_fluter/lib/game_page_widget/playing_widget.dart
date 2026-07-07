import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tp_final_fluter/providers/storageRepository.dart';
import 'package:tp_final_fluter/repositories/player_repository.dart';
import 'package:tp_final_fluter/repositories/round_repository.dart';
import 'package:tp_final_fluter/repositories/room_repository.dart';
import 'package:tp_final_fluter/repositories/submission_repository.dart';

// ─── PlayingWidget ────────────────────────────────────────────────────────────
// Handles camera permission gate → spectator fallback → capture screen.

class PlayingWidget extends ConsumerStatefulWidget {
  const PlayingWidget({
    super.key,
    required this.roomId,
    required this.camera,
    required this.roundNumber,
    required this.endsAt,
  });

  final String roomId;
  final CameraDescription? camera;
  final int roundNumber;
  final DateTime endsAt;

  @override
  ConsumerState<PlayingWidget> createState() => _PlayingWidgetState();
}

class _PlayingWidgetState extends ConsumerState<PlayingWidget> {
  PermissionStatus? _cameraStatus;
  Timer? _autoCloseTimer;
  bool _closingCapture = false;

  @override
  void initState() {
    super.initState();
    _requestPermission();
    final remaining = widget.endsAt.difference(DateTime.now());
    if (!remaining.isNegative) {
      _autoCloseTimer = Timer(remaining, _onTimerExpired);
    }
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  void _onTimerExpired() => _triggerCloseCapture();

  Future<void> _triggerCloseCapture() async {
    if (_closingCapture) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final room = ref.read(roomStreamProvider(widget.roomId)).value;
    if (room?.hostId != uid) return;
    _closingCapture = true;
    try {
      await ref.read(roundsRepositoryProvider).closeCapture(
        roomId: widget.roomId,
        roundNumber: widget.roundNumber,
      );
    } catch (e) {
      _closingCapture = false;
      debugPrint('closeCapture error: $e');
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    if (mounted) setState(() => _cameraStatus = status);
  }

  Future<void> _becomeSpectator() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomId)
          .collection('players')
          .doc(uid)
          .update({'isSpectator': true});
    } catch (e) {
      debugPrint('becomeSpectator error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final room = ref.watch(roomStreamProvider(widget.roomId)).value;
    final isHost = room?.hostId == uid;

    // ── Auto-close when all non-spectator players have submitted ─────────────
    if (isHost) {
      ref.listen(
        allSubmissionsForRoundStreamProvider((roomId: widget.roomId, roundNumber: widget.roundNumber)),
        (_, subsAsync) {
          final subs = subsAsync.value ?? [];
          final players = ref.read(playersStreamProvider(widget.roomId)).value ?? [];
          final activeCount = players.where((p) => !p.isSpectator).length;
          if (activeCount > 0 && subs.length >= activeCount) {
            _triggerCloseCapture();
          }
        },
      );
    }

    final playerAsync = ref.watch(playerStreamProvider((idRoom: widget.roomId, idPlayer: uid)));
    final isSpectator = playerAsync.value?.isSpectator ?? false;

    final submissionAsync = ref.watch(
      submissionStreamProvider((idRoom: widget.roomId, idRound: widget.roundNumber.toString(), idPlayer: uid)),
    );

    // ── Spectator mode ──────────────────────────────────────────────────────
    if (isSpectator) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.visibility_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Mode spectateur',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vous pourrez voter une fois la phase de capture terminée.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // ── No camera hardware (emulator fallback) ──────────────────────────────
    if (widget.camera == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.no_photography_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune caméra détectée',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vous pouvez rejoindre en mode spectateur.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('Mode spectateur'),
                    onPressed: _becomeSpectator,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // ── Permission loading ───────────────────────────────────────────────────
    if (_cameraStatus == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // ── Permission denied (can retry) ────────────────────────────────────────
    if (_cameraStatus!.isDenied) {
      return _PermissionScreen(
        permanent: false,
        onRetry: _requestPermission,
        onSpectator: _becomeSpectator,
      );
    }

    // ── Permission permanently denied ────────────────────────────────────────
    if (_cameraStatus!.isPermanentlyDenied) {
      return _PermissionScreen(
        permanent: true,
        onRetry: () => openAppSettings(),
        onSpectator: _becomeSpectator,
      );
    }

    // ── Photo already submitted ──────────────────────────────────────────────
    if (submissionAsync.value != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline, size: 72, color: Colors.greenAccent),
                const SizedBox(height: 16),
                const Text(
                  'Photo soumise !',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'En attente des autres joueurs...',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── Camera screen ────────────────────────────────────────────────────────
    return TakePictureScreen(
      roomId: widget.roomId,
      camera: widget.camera!,
      roundNumber: widget.roundNumber,
      endsAt: widget.endsAt,
    );
  }
}

// ─── Permission denied screen ─────────────────────────────────────────────────
class _PermissionScreen extends StatelessWidget {
  const _PermissionScreen({
    required this.permanent,
    required this.onRetry,
    required this.onSpectator,
  });

  final bool permanent;
  final VoidCallback onRetry;
  final VoidCallback onSpectator;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.no_photography_outlined, size: 72, color: Colors.grey),
                const SizedBox(height: 24),
                Text(
                  permanent
                      ? 'Permission caméra refusée définitivement.'
                      : 'Permission caméra requise pour jouer.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  permanent
                      ? 'Activez-la dans les paramètres de l\'application ou continuez en tant que spectateur.'
                      : 'Accordez l\'accès à la caméra ou continuez en tant que spectateur (vote uniquement).',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  icon: Icon(permanent ? Icons.settings : Icons.refresh),
                  label: Text(permanent ? 'Ouvrir les paramètres' : 'Réessayer'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  onPressed: onRetry,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Continuer en mode spectateur'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  onPressed: onSpectator,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── TakePictureScreen ────────────────────────────────────────────────────────
class TakePictureScreen extends ConsumerStatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.roomId,
    required this.camera,
    required this.roundNumber,
    required this.endsAt,
  });

  final String roomId;
  final CameraDescription camera;
  final int roundNumber;
  final DateTime endsAt;

  @override
  ConsumerState<TakePictureScreen> createState() => TakePictureScreenState();
}

class TakePictureScreenState extends ConsumerState<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium, enableAudio: false);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final roundAsync = ref.watch(
      roundstreamProvider((idRoom: widget.roomId, idRound: widget.roundNumber.toString())),
    );
    final theme = roundAsync.value?.theme ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Prenez une photo', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          return Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(_controller),
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    CountdownTimerWidget(endsAt: widget.endsAt),
                    const SizedBox(height: 8),
                    if (theme.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          theme,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: FloatingActionButton(
          backgroundColor: colorScheme.primary,
          elevation: 0,
          onPressed: () async {
            try {
              await _initializeControllerFuture;
              final image = await _controller.takePicture();
              if (!context.mounted) return;
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DisplayPictureScreen(
                    roomId: widget.roomId,
                    roundNumber: widget.roundNumber,
                    imagePath: image.path,
                  ),
                ),
              );
            } catch (e) {
              debugPrint('Camera error: $e');
            }
          },
          child: const Icon(Icons.camera_alt, size: 30),
        ),
      ),
    );
  }
}

// ─── DisplayPictureScreen ─────────────────────────────────────────────────────
class DisplayPictureScreen extends ConsumerStatefulWidget {
  const DisplayPictureScreen({
    super.key,
    required this.roomId,
    required this.roundNumber,
    required this.imagePath,
  });

  final String roomId;
  final int roundNumber;
  final String imagePath;

  @override
  ConsumerState<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends ConsumerState<DisplayPictureScreen> {
  bool _isUploading = false;

  Future<void> _submit() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isUploading = true);
    try {
      final storage = ref.read(storageRepositoryProvider);
      final path = 'rooms/${widget.roomId}/rounds/${widget.roundNumber}/$uid.jpeg';
      final photoUrl = await storage.uploadFile(
        file: File(widget.imagePath),
        path: path,
      );

      await ref.read(roundsRepositoryProvider).submitPhoto(
        roomId: widget.roomId,
        roundNumber: widget.roundNumber,
        playerId: uid,
        photoUrl: photoUrl,
        storagePath: path,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur upload: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: colorScheme.inversePrimary,
        title: const Text('Valider la photo', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reprendre'),
                      onPressed: _isUploading ? null : () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: _isUploading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: const Text('Valider'),
                      onPressed: _isUploading ? null : _submit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── CountdownTimerWidget ─────────────────────────────────────────────────────
class CountdownTimerWidget extends StatelessWidget {
  const CountdownTimerWidget({super.key, required this.endsAt, this.onEnd});

  final DateTime endsAt;
  final VoidCallback? onEnd;

  @override
  Widget build(BuildContext context) {
    if (endsAt.difference(DateTime.now()).isNegative) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(30),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        child: TimerCountdown(
          format: CountDownTimerFormat.secondsOnly,
          endTime: endsAt,
          onEnd: onEnd ?? () {},
        ),
      ),
    );
  }
}
