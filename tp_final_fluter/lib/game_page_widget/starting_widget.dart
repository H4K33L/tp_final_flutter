import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StartingWidget extends ConsumerWidget{
  const StartingWidget({super.key, required String roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roundThemeControler = TextEditingController();

    // ajouter condition pour admin room
    // if () {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            for(String item in list) Text(item);
            TextField(controller: roundThemeControler),
            FlatButton(
              onPressed: () { },
              child: Text('Launch round'),
            );
          ],
        )
      )
    );
    // } else {
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text(''),
    //     elevation: 0,
    //   ),
    //   body: SafeArea(
    //     child: Column(
    //       children: [
    //      for(String item in list) Text(item);
    //      Text: 'Waiting the 
    //       ],
    //     )
    //   )
    // );
    // }
  }
}