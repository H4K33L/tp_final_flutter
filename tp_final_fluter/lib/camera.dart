import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';


// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key, required this.id, required this.camera});

  final String id;
  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // Camera controller to display output
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Column(
                children: [
                    CountdownTimerScreen(time: 30),
                    CameraPreview(_controller),
                ]
            );
            
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();

            if (!context.mounted) return;

            // Display image
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => DisplayPictureScreen(
                  id: widget.id,
                  imagePath: image.path,
                ),
              ),
            );
          } catch (e) {
            // TODO : handle error
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String id;
  final String imagePath;
  const DisplayPictureScreen({super.key, required this.id, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Taken Picture')),
      body: Column(children: [
        Image.file(File(imagePath)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            ElevatedButton(onPressed: () {Navigator.pop(context);}, child: Text("Take a better picture")),
            ElevatedButton(onPressed: () {Navigator.pushNamed(context, "/submissions/$id");}, child: Text("Validate")),
          ],
        ),
      ],
      )
    );
  }
}

class CountdownTimerScreen extends ConsumerWidget {
  const CountdownTimerScreen({super.key, required this.time});

  final int time;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
        child: TimerCountdown(
            format: CountDownTimerFormat.secondsOnly,
          endTime: DateTime.now().add(
            Duration(
              seconds: time,
            ),
          ),
          onEnd: () {
            print("Timer finished");
            // TODO : handle end of round
          },
        ),
      );
  }
}