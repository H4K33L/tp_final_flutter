import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tp_final_fluter/providers/vote_providers.dart';
import 'package:tp_final_fluter/providers/storageRepository.dart';
import 'package:tp_final_fluter/providers/auth_providers.dart';

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

  Future<void> _vote(String votedForPlayerId, String currentUserId) async {
    setState(() => _isSubmitting = true);
    try {
      final voteService = ref.read(voteServiceProvider);
      await voteService.submitVote(
        roomId: widget.roomId,
        roundNumber: widget.roundNumber,
        voterId: currentUserId,
        votedForPlayerId: votedForPlayerId,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = (roomId: widget.roomId, roundNumber: widget.roundNumber);

    final currentUserId = ref.watch(currentUserIdProvider);
    final photosAsync = ref.watch(photosStreamProvider(args));
    final votes = ref.watch(votesStreamProvider(args)).value ?? [];
    final hasVoted = ref.watch(hasVotedProvider(args));

    final myVote = votes.where((v) => v.id == currentUserId).firstOrNull;

    return photosAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
      error: (e, _) => Center(child: Text('Erreur: $e', style: const TextStyle(color: Colors.white))),
      data: (photos) {
        return RefreshIndicator(
          onRefresh: () async => ref.refresh(photosStreamProvider(args).future),
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: photos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final photo = photos[index];
              final playerId = playerIdFromStorageImage(photo);
              final isOwnPhoto = playerId == currentUserId;
              final isSelected = myVote?.votedForPlayerId == playerId;
              final voteCount = votes.where((v) => v.votedForPlayerId == playerId).length;

              final canTap = !isOwnPhoto && !hasVoted && !_isSubmitting && currentUserId != null;

              return GestureDetector(
                onTap: canTap ? () => _vote(playerId, currentUserId) : null,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.greenAccent : Colors.grey[800]!,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Opacity(
                        opacity: isOwnPhoto ? 0.4 : 1.0,
                        child: Image.network(
                          photo.downloadUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.broken_image, color: Colors.white54),
                          ),
                        ),
                      ),
                    ),
                    if (isOwnPhoto)
                      const Positioned.fill(
                        child: Center(
                          child: Text(
                            'Ta photo',
                            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    if (isSelected)
                      const Positioned(
                        top: 4,
                        right: 4,
                        child: Icon(Icons.check_circle, color: Colors.greenAccent),
                      ),
                    if (voteCount > 0)
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$voteCount',
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
    );
  }
}