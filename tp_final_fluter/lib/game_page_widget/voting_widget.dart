import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tp_final_fluter/repositories/player_repository.dart';
import 'package:tp_final_fluter/repositories/vote_repository.dart';
import 'package:tp_final_fluter/repositories/round_repository.dart';
import 'package:tp_final_fluter/repositories/room_repository.dart';
import 'package:tp_final_fluter/providers/storageRepository.dart';
import 'package:tp_final_fluter/providers/auth_provider.dart';

/// Extracts the player ID from the Storage image name (e.g. "uid123.jpeg" → "uid123").
String _playerIdFromStorageImage(StorageImage image) {
  final name = image.name;
  final dot = name.lastIndexOf('.');
  return dot != -1 ? name.substring(0, dot) : name;
}

class VotingGallery extends ConsumerStatefulWidget {
  final String roomId;
  final int roundNumber;

  const VotingGallery({
    super.key,
    required this.roomId,
    required this.roundNumber,
  });

  @override
  ConsumerState<VotingGallery> createState() => _VotingGalleryState();
}

class _VotingGalleryState extends ConsumerState<VotingGallery> {
  bool _isSubmitting = false;
  bool _closingVote = false;
  Timer? _autoCloseTimer;

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  void _scheduleTimer(DateTime votingEndsAt) {
    if (_autoCloseTimer != null) return; // already scheduled
    final remaining = votingEndsAt.difference(DateTime.now());
    if (remaining.isNegative) {
      _triggerCloseVoting();
      return;
    }
    _autoCloseTimer = Timer(remaining, _triggerCloseVoting);
  }

  void _triggerCloseVoting() {
    if (_closingVote) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final room = ref.read(roomStreamProvider(widget.roomId)).value;
    if (room?.hostId != uid) return;
    _closingVote = true;
    ref.read(roundsRepositoryProvider).closeVotingAndComputeResults(
      roomId: widget.roomId,
      roundNumber: widget.roundNumber,
    ).catchError((e) {
      _closingVote = false;
      debugPrint('closeVoting error: $e');
    });
  }

  Future<void> _vote(String votedForPlayerId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(votesRepositoryProvider).submitVote(
        roomId: widget.roomId,
        roundNumber: widget.roundNumber,
        voterId: currentUserId,
        votedForPlayerId: votedForPlayerId,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoArgs = (roomId: widget.roomId, roundNumber: widget.roundNumber);
    final voteArgs = (roomId: widget.roomId, roundNumber: widget.roundNumber);

    final currentUserId = ref.watch(currentUserIdProvider);
    final photosAsync = ref.watch(photosStreamProvider(photoArgs));
    final votesAsync = ref.watch(allVotesForRoundStreamProvider(voteArgs));
    final hasVoted = ref.watch(hasVotedProvider(voteArgs));

    final roomAsync = ref.watch(roomStreamProvider(widget.roomId));
    final isHost = roomAsync.value?.hostId == currentUserId;

    // Schedule voting timer from the round's votingEndsAt
    final roundAsync = ref.watch(roundstreamProvider((idRoom: widget.roomId, idRound: widget.roundNumber.toString())));
    final votingEndsAt = roundAsync.value?.votingEndsAt;
    if (votingEndsAt != null) _scheduleTimer(votingEndsAt);

    // Auto-close when all non-spectator players have voted
    if (isHost) {
      ref.listen(allVotesForRoundStreamProvider(voteArgs), (_, votesNext) {
        final vs = votesNext.value ?? [];
        final players = ref.read(playersStreamProvider(widget.roomId)).value ?? [];
        final activeCount = players.where((p) => !p.isSpectator).length;
        if (activeCount > 0 && vs.length >= activeCount) _triggerCloseVoting();
      });
    }

    final votes = votesAsync.value ?? [];
    final myVote = votes.where((v) => v.id == currentUserId).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text('Vote - Manche ${widget.roundNumber}'),
        elevation: 0,
      ),
      body: photosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (photos) {
          if (photos.isEmpty) {
            return const Center(child: Text('Aucune photo soumise pour cette manche.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(photosStreamProvider(photoArgs).future),
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: photos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final photo = photos[index];
                final playerId = _playerIdFromStorageImage(photo);
                final isOwnPhoto = playerId == currentUserId;
                final isSelected = myVote?.votedForPlayerId == playerId;
                final voteCount = votes.where((v) => v.votedForPlayerId == playerId).length;
                final canTap = !isOwnPhoto && !hasVoted && !_isSubmitting && currentUserId != null;

                return GestureDetector(
                  onTap: canTap ? () => _vote(playerId) : null,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.greenAccent : Colors.grey[400]!,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Opacity(
                          opacity: isOwnPhoto ? 0.5 : 1.0,
                          child: Image.network(
                            photo.downloadUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, _) =>
                                const Center(child: Icon(Icons.broken_image)),
                          ),
                        ),
                      ),
                      if (isOwnPhoto)
                        const Positioned.fill(
                          child: Center(
                            child: Text(
                              'Ta photo',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      if (isSelected)
                        const Positioned(
                          top: 6,
                          right: 6,
                          child: Icon(Icons.check_circle, color: Colors.greenAccent, size: 28),
                        ),
                      if (voteCount > 0)
                        Positioned(
                          bottom: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$voteCount vote${voteCount > 1 ? 's' : ''}',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
