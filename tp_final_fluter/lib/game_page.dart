import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key, required this.title, required this.id, required this.userName});

  final String title;
  final String id;
  final String userName;
@override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.deepPurple);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title:  title,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          centerTitle: true,
        ),
      ),
      home: _GamePage(title: title, id: id, userName: userName,),
    );
  }
}

class _GamePage extends ConsumerWidget  {
  const _GamePage({required this.title, required this.id, required this.userName});
  final String title;
  final String userName;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final state = ref.watch(gameControlerProvider);
    // final notifier = ref.read(gameControlerProvider.notifier);

    // notifier.joinOrCreateRoom(id, userName);

    // waiting   → lobby, joueurs rejoignent, host attend que tout le monde soit "ready"
    // starting  → host a lancé, thème de la manche 1 en cours de sélection
    // playing   → manche en cours, joueurs prennent/uploadent leur photo (endsAt actif)
    // voting    → uploads clos (ou timer écoulé), joueurs votent
    // results   → scores de la manche affichés, brève pause avant la manche suivante
    // finished  → nombre de manches atteint, classement final affiché
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          // child: state.when(
          //   // status: (params) => methode
          //   waiting: () =>  WaitingWidget(),
          //   starting: () => StartingWidget(),
          //   playing: () => PlayingWidget(),
          //   voting: () => VotingWidget(),
          //   results: () => ResultsWidget(),
          //   finished: () => FinishedWidget(),
          // )
        )
      )
    );
  }
  
}