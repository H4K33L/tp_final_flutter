// Unit tests for core game logic — no Firebase initialization required.
// Run with: flutter test

import 'package:flutter_test/flutter_test.dart';
import 'package:tp_final_fluter/models/vote/vote.dart';
import 'package:tp_final_fluter/models/player/player.dart';

// ── Pure helpers that mirror the logic in RoundsRepository ───────────────────

/// Counts votes per target player.
Map<String, int> countVotes(List<Vote> votes) {
  final counts = <String, int>{};
  for (final v in votes) {
    counts[v.votedForPlayerId] = (counts[v.votedForPlayerId] ?? 0) + 1;
  }
  return counts;
}

/// Returns the set of winning player IDs (all players tied at the maximum).
Set<String> computeWinners(Map<String, int> voteCounts) {
  if (voteCounts.isEmpty) return {};
  final max = voteCounts.values.reduce((a, b) => a > b ? a : b);
  return voteCounts.entries
      .where((e) => e.value == max)
      .map((e) => e.key)
      .toSet();
}

/// Returns false if a player tries to vote for themselves.
bool canVote({required String voterId, required String targetId}) {
  return voterId != targetId;
}

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ── Vote winner computation ─────────────────────────────────────────────────
  group('countVotes', () {
    test('accumulates votes correctly', () {
      final votes = [
        Vote(id: 'v1', votedForPlayerId: 'alice', votedAt: DateTime.now()),
        Vote(id: 'v2', votedForPlayerId: 'alice', votedAt: DateTime.now()),
        Vote(id: 'v3', votedForPlayerId: 'bob', votedAt: DateTime.now()),
      ];
      final counts = countVotes(votes);
      expect(counts['alice'], 2);
      expect(counts['bob'], 1);
    });

    test('returns empty map for no votes', () {
      expect(countVotes([]), isEmpty);
    });
  });

  group('computeWinners', () {
    test('single clear winner', () {
      final counts = {'alice': 3, 'bob': 1, 'carol': 1};
      expect(computeWinners(counts), equals({'alice'}));
    });

    test('tie — all tied players win', () {
      final counts = {'alice': 2, 'bob': 2, 'carol': 1};
      expect(computeWinners(counts), equals({'alice', 'bob'}));
    });

    test('three-way tie — all three win', () {
      final counts = {'a': 1, 'b': 1, 'c': 1};
      expect(computeWinners(counts), equals({'a', 'b', 'c'}));
    });

    test('empty vote counts yields no winners', () {
      expect(computeWinners({}), isEmpty);
    });
  });

  // ── Self-vote prevention ────────────────────────────────────────────────────
  group('canVote (self-vote prevention)', () {
    test('voting for yourself is forbidden', () {
      expect(canVote(voterId: 'uid1', targetId: 'uid1'), isFalse);
    });

    test('voting for another player is allowed', () {
      expect(canVote(voterId: 'uid1', targetId: 'uid2'), isTrue);
    });
  });

  // ── Player model (Freezed) ──────────────────────────────────────────────────
  group('Player Freezed model', () {
    test('constructs and reads fields correctly', () {
      const player = Player(
        id: 'abc',
        displayName: 'Jerem',
        isHost: true,
        isReady: false,
        isSpectator: false,
        totalScore: 3,
      );
      expect(player.id, 'abc');
      expect(player.displayName, 'Jerem');
      expect(player.isHost, isTrue);
      expect(player.totalScore, 3);
    });

    test('copyWith updates only the specified field', () {
      const player = Player(
        id: 'abc',
        displayName: 'Jerem',
        isHost: false,
        isReady: false,
        isSpectator: false,
      );
      final updated = player.copyWith(totalScore: 5);
      expect(updated.totalScore, 5);
      expect(updated.displayName, 'Jerem'); // unchanged
    });

    test('toJson excludes the id field', () {
      const player = Player(
        id: 'should-not-appear',
        displayName: 'Kiki',
        isHost: false,
        isReady: true,
        isSpectator: false,
      );
      final json = player.toJson();
      expect(json.containsKey('id'), isFalse);
      expect(json['displayName'], 'Kiki');
    });
  });

  // ── Leaderboard sort ─────────────────────────────────────────────────────────
  group('Leaderboard sort', () {
    test('players are sorted by totalScore descending', () {
      final players = [
        const Player(id: 'a', displayName: 'A', isHost: false, isReady: false, isSpectator: false, totalScore: 1),
        const Player(id: 'b', displayName: 'B', isHost: false, isReady: false, isSpectator: false, totalScore: 5),
        const Player(id: 'c', displayName: 'C', isHost: false, isReady: false, isSpectator: false, totalScore: 3),
      ];
      final sorted = [...players]..sort((a, b) => b.totalScore.compareTo(a.totalScore));
      expect(sorted.map((p) => p.id).toList(), ['b', 'c', 'a']);
    });
  });
}

