import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore.dart';
import '../models/result/result.dart';

final roundResultsStreamProvider = StreamProvider.family<List<Result>, ({String roomId, int roundNumber})>((ref, args) {
  return resultsRef(args.roomId, args.roundNumber).snapshots().map(
    (snap) => snap.docs.map((d) => d.data()).toList(),
  );
});

// Classement général = players triés par totalScore (réutilise playersStreamProvider)