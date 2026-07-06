import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResultsWidget extends ConsumerWidget{
  const ResultsWidget({super.key, required String roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final winner = "aurelien";
    
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Text("And the winner is .... $winner"),
          ],
        )
      )
    );
  }
}