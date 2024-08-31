import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:interpret/main.dart';

class VideoScreen extends StatefulWidget {
  late List<CameraDescription> cameras;

  VideoScreen() {
    someFunction();
  }

  void someFunction() async {
    List<CameraDescription> cameras = await availableCameras();
    this.cameras = cameras;
  }

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late CameraController _controller;
  late Future<void> _controllerInitializer;
  late List<CameraDescription> cameras;

  @override
  void initState() {
    super.initState();
    initializeCameraController();
  }

  Future<void> initializeCameraController() async {
    List<CameraDescription> cameras = await availableCameras();
    this.cameras = cameras;
    if (cameras.isNotEmpty) {
      _controller = CameraController(
        cameras[1], // You can choose a camera (front/back) here
        ResolutionPreset.medium, // Choose a suitable resolution preset
      );

      _controllerInitializer = _controller.initialize();
    }
    setState(() {}); // Update the state to reflect the changes
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Translation'),
      ),
      body: cameras.isNotEmpty // Check if cameras list is not empty
          ? FutureBuilder<void>(
              future: _controllerInitializer,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            )
          : Center(
              child:
                  CircularProgressIndicator()), // Show spinner if cameras is empty
    );
  }
}
