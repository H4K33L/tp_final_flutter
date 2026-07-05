import 'package:flutter/material.dart';
import 'package:tp_final_fluter/game_page.dart';
import 'package:tp_final_fluter/not_found_page.dart';

void main() {
  runApp(const MyApp());
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
