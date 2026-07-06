import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WaitingWidget extends ConsumerWidget{
  const WaitingWidget({super.key, required String roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

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
              for(String item in list) Text(item),
              Text('Launch party'),
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
            for(String item in list) Text(item),
            Text('Waiting the host to start'),
          ],
        )
      )
    );
    }
  }
  
}