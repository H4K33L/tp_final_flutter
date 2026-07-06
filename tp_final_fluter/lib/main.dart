import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tp_final_fluter/firebase_options.dart';
import 'package:tp_final_fluter/game_page.dart';
import 'package:tp_final_fluter/models/player/player.dart';
import 'package:tp_final_fluter/not_found_page.dart';
import 'package:tp_final_fluter/providers/storageRepository.dart';
import 'package:tp_final_fluter/services/player_service.dart';
import 'package:tp_final_fluter/services/room_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var cameras = await availableCameras();
  final firstCamera = cameras.first;
  await Firebase.initializeApp(
    options:DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ProviderScope(
    child: MaterialApp(
      title: "test",
      home: Scaffold(
        body: PlayerScreen(),
      )
    )));
}

class RoomScreen extends ConsumerWidget {
  //final String code;
  //const RoomScreen({required this.code, super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(storageRepositoryProvider);
    final provider = ref.watch(roomStreamProvider("ABC"));
    final url = storage.uploadImageFromUrl(
      imageUrl: 'https://preview.redd.it/just-a-random-picture-that-ive-taken-in-barcelona-v0-lvtkrfbkdwof1.jpeg?width=640&crop=smart&auto=webp&s=6e632273ff13db8fd640a5553f2d8cb9e8c5c496',
      path: 'images/ABC/cover.jpg',
    );

    return provider.when(
      data: (room) => room == null
          ? const Text('Room introuvable')
          : Text('Room ${room.code} - ${room.hostId}'),
      loading: () => const CircularProgressIndicator(),
      error: (e, st) => Text('Erreur: $e'),
    );
  }
}

class PlayerScreen extends ConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: implement build
    final provider = ref.watch(playerRepositoryProvider);
    provider.createPlayer(idRoom: "ABC", player: Player(
      id:"zer",
      displayName: "azerty",
      isHost:false,
      isReady : false,
      isSpectator: false,
    ));
    provider.getPlayersByRoom(idRoom: "ABC");
    return Text("hi");
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'snap_theme',
      routes: {
      '/': (context) => MyHomePage(title: 'snap_theme main page',),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/game') {
          final args = ModalRoute.of(context)!.settings.arguments as GameRouteArgumment;
          return MaterialPageRoute(
            builder: (context) => GamePage(id: args.id, title: 'snap_theme game page', userName: args.username,),
          );
        }
        return null;
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => NotFoundPage());
      },
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    final roomIdControler = TextEditingController();
    final userNameControler = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            TextField(controller: userNameControler),
            TextButton(
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/game',arguments:  GameRouteArgumment(id: '0',username: userNameControler.value.text));
              },
              child: Text('Create a room'),
            ),
            Text('Join room'),
            TextField(controller: roomIdControler),
            TextButton(
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/game',arguments: GameRouteArgumment(id: roomIdControler.value.text,username: userNameControler.value.text));
              },
              child: Text('Join'),
            ),
          ],
        ),
      ),
    );
  }
}

class GameRouteArgumment {
  GameRouteArgumment({required this.id, required this.username });
  final String id;
  final String username;
}
