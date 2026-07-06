import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StartingWidget extends ConsumerWidget{
  const StartingWidget({super.key, required String roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roundThemeControler = TextEditingController();

    List list = ['jerem','kiki'];
    bool isAdmin = true;

    // ajouter condition pour admin room
    if (isAdmin) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            TextField(controller: roundThemeControler),
            TextButton(
              onPressed: () => {},
              child: Text('start'),
            ),
          ],
        )
      )
    );
    } else {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
         for(String item in list) Text(item);
         Text: 'Waiting the admin chose the subject',
          ],
        )
      )
    );
    }
  }
}