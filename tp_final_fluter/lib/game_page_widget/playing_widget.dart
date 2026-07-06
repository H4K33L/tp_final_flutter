import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:tp_final_fluter/providers/storageRepository.dart';
import 'package:tp_final_fluter/providers/auth_providers.dart';
import 'package:tp_final_fluter/providers/auth_providers.dart';
import 'package:tp_final_fluter/providers/round_providers.dart';
import 'package:tp_final_fluter/providers/room_providers.dart';

class PlayingWidget extends ConsumerWidget{
  const PlayingWidget({super.key, required this.id, required this.camera, required this.themeName});

  final String id;
  final CameraDescription camera;
  final String themeName;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TakePictureScreen(id: id, camera: camera, themeName: themeName,);
  }
}

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key, required this.id, required this.camera, required this.themeName});

  final String id;
  final CameraDescription camera;
  final String themeName;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<PlayingWidget> {
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Take a picture',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Stack(
              fit: StackFit.expand,
              children: [
                Text(widget.themeName),
                CameraPreview(_controller),
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: CountdownTimerScreen(time: 30),
                  ),
                ),
              ],
            );

          } else {
            // Otherwise, display a loading indicator.
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: FloatingActionButton(
          backgroundColor: colorScheme.primary,
          elevation: 0,
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
          child: const Icon(Icons.camera_alt, size: 30),
        ),
      ),
    );
  }
}

class DisplayPictureScreen extends ConsumerWidget {
  final String id;
  final String imagePath;
  const DisplayPictureScreen({super.key, required this.id, required this.imagePath});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final storage = ref.read(storageRepositoryProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    final round = ref.watch(roundServiceProvider);
    final room = ref.watch(roomServiceProvider);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: colorScheme.inversePrimary,
        title: const Text(
          'Taken Picture',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Image.file(File(imagePath), fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text("Take a better picture"),
                    onPressed: () {Navigator.pop(context);},
                  ),
                ),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text("Validate"),
                    onPressed: () {
                      storage.uploadFile(file: File(imagePath), path: "image/$round.id/$round.id/$currentUserId.jpeg");
                      Navigator.pushNamed(context, "/submissions/$id");
                    },
                  ),
                ),
              ],
            ),
          ],
          )
        ),
      ),
    );
  }
}

class CountdownTimerScreen extends ConsumerWidget {
  const CountdownTimerScreen({super.key, required this.time});

  final int time;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(30),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
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
      ),
    );
  }
}