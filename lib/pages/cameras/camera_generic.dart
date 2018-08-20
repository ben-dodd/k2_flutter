import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/utils/camera.dart';
import 'package:video_player/video_player.dart';

class CameraGeneric extends StatefulWidget {
  @override
  _CameraGenericState createState() => new _CameraGenericState();
}

class _CameraGenericState extends State<CameraGeneric> {
  CameraController controller;
  String imagePath;
  String videoPath;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;
  CameraDescription cameraDescription;

  @override
  void initState() {
    super.initState();
    onNewCameraSelected();
//    cameraDescription = DataManager.get().cameras[0];
    controller = new CameraController(cameraDescription, ResolutionPreset.high);
  }



  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      // no app bar
      body: new Column(
        children: <Widget>[
          new Expanded(
            child: new Container(
              child: new Padding(
                padding: const EdgeInsets.all(1.0),
                child: new Center(
                  child: _cameraPreviewWidget(controller),
                ),
              ),
              decoration: new BoxDecoration(
                color: Colors.black,
                border: new Border.all(
                  color: controller != null && controller.value.isRecordingVideo
                      ? Colors.redAccent
                      : Colors.grey,
                  width: 3.0,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onTakePictureButtonPressed,
            child: new Icon(Icons.camera, size: 40.0),)
          ]
        )
    );

  }

  void onTakePictureButtonPressed() {
    takePicture(controller).then((String filePath) {
//    if (mounted) {
      if (filePath != null) print('Picture saved to $filePath');
      print("filePath is null");
//      imagePath = filePath;
      controller.dispose();
      Navigator.of(context).pop(filePath);
      }
    );
  }

  void onNewCameraSelected() async {
    CameraDescription cameraDescription = DataManager.get().cameras[0];
    print('Camera Description: ' + cameraDescription.toString());
    if (controller != null) {
      await controller.dispose();
    }
    controller = new CameraController(cameraDescription, ResolutionPreset.high);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        print('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      print(e);
    }

    if (mounted) {
      setState(() {});
    }
  }
}

/// Display the preview from the camera (or a message if the preview is not available).
Widget _cameraPreviewWidget(CameraController controller) {
  if (controller == null || !controller.value.isInitialized) {
    return const Text(
      'Tap a camera',
      style: TextStyle(
        color: Colors.white,
        fontSize: 24.0,
        fontWeight: FontWeight.w900,
      ),
    );
  } else {
    return new AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: new CameraPreview(controller),
    );
  }
}
