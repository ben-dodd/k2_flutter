import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/utils/logs.dart';
import 'package:path_provider/path_provider.dart';
//
///// Returns a suitable camera icon for [direction].
//IconData getCameraLensIcon(CameraLensDirection direction) {
//  switch (direction) {
//    case CameraLensDirection.back:
//      return Icons.camera_rear;
//    case CameraLensDirection.front:
//      return Icons.camera_front;
//    case CameraLensDirection.external:
//      return Icons.camera;
//  }
//  throw new ArgumentError('Unknown lens direction');
//}
//
//  /// Display the preview from the camera (or a message if the preview is not available).
//  Widget _cameraPreviewWidget() {
//    if (controller == null || !controller.value.isInitialized) {
//      return const Text(
//        'Tap a camera',
//        style: TextStyle(
//          color: Colors.white,
//          fontSize: 24.0,
//          fontWeight: FontWeight.w900,
//        ),
//      );
//    } else {
//      return new AspectRatio(
//        aspectRatio: controller.value.aspectRatio,
//        child: new CameraPreview(controller),
//      );
//    }
//  }
//
//  /// Display the thumbnail of the captured image or video.
//  Widget _thumbnailWidget() {
//    return new Expanded(
//      child: new Align(
//        alignment: Alignment.centerRight,
//        child: videoController == null && imagePath == null
//            ? null
//            : new SizedBox(
//          child: (videoController == null)
//              ? new Image.file(new File(imagePath))
//              : new Container(
//            child: new Center(
//              child: new AspectRatio(
//                  aspectRatio: videoController.value.size != null
//                      ? videoController.value.aspectRatio
//                      : 1.0,
//                  child: new VideoPlayer(videoController)),
//            ),
//            decoration: new BoxDecoration(
//                border: new Border.all(color: Colors.pink)),
//          ),
//          width: 64.0,
//          height: 64.0,
//        ),
//      ),
//    );
//  }



  String timestamp() => new DateTime.now().millisecondsSinceEpoch.toString();


//
//  void onNewCameraSelected(CameraDescription cameraDescription) async {
//    if (controller != null) {
//      await controller.dispose();
//    }
//    controller = new CameraController(cameraDescription, ResolutionPreset.high);
//
//    // If the controller is updated then update the UI.
//    controller.addListener(() {
//      if (mounted) setState(() {});
//      if (controller.value.hasError) {
//        showInSnackBar('Camera error ${controller.value.errorDescription}');
//      }
//    });
//
//    try {
//      await controller.initialize();
//    } on CameraException catch (e) {
//      _showCameraException(e);
//    }
//
//    if (mounted) {
//      setState(() {});
//    }
//  }


//  void onVideoRecordButtonPressed() {
//    startVideoRecording().then((String filePath) {
//      if (mounted) setState(() {});
//      if (filePath != null) showInSnackBar('Saving video to $filePath');
//    });
//  }
//
//  void onStopButtonPressed() {
//    stopVideoRecording().then((_) {
//      if (mounted) setState(() {});
//      showInSnackBar('Video recorded to: $videoPath');
//    });
//  }

//  Future<String> startVideoRecording() async {
//    if (!controller.value.isInitialized) {
//      showInSnackBar('Error: select a camera first.');
//      return null;
//    }
//
//    final Directory extDir = await getApplicationDocumentsDirectory();
//    final String dirPath = '${extDir.path}/Movies/flutter_test';
//    await new Directory(dirPath).create(recursive: true);
//    final String filePath = '$dirPath/${timestamp()}.mp4';
//
//    if (controller.value.isRecordingVideo) {
//      // A recording is already started, do nothing.
//      return null;
//    }
//
//    try {
//      videoPath = filePath;
//      await controller.startVideoRecording(filePath);
//    } on CameraException catch (e) {
//      _showCameraException(e);
//      return null;
//    }
//    return filePath;
//  }
//
//  Future<void> stopVideoRecording() async {
//    if (!controller.value.isRecordingVideo) {
//      return null;
//    }
//
//    try {
//      await controller.stopVideoRecording();
//    } on CameraException catch (e) {
//      _showCameraException(e);
//      return null;
//    }
//
//    await _startVideoPlayer();
//  }
//
//  Future<void> _startVideoPlayer() async {
//    final VideoPlayerController vcontroller =
//    new VideoPlayerController.file(new File(videoPath));
//    videoPlayerListener = () {
//      if (videoController != null && videoController.value.size != null) {
//        // Refreshing the state to update video player with the correct ratio.
//        if (mounted) setState(() {});
//        videoController.removeListener(videoPlayerListener);
//      }
//    };
//    vcontroller.addListener(videoPlayerListener);
//    await vcontroller.setLooping(true);
//    await vcontroller.initialize();
//    await videoController?.dispose();
//    if (mounted) {
//      setState(() {
//        imagePath = null;
//        videoController = vcontroller;
//      });
//    }
//    await vcontroller.play();
//  }

Future<String> takePicture(CameraController controller) async {
  if (!controller.value.isInitialized) {
    print('Error: select a camera first.');
    return null;
  }
  final Directory extDir = await getApplicationDocumentsDirectory();
  final String dirPath = '${extDir.path}/Pictures/k2_e';
  await new Directory(dirPath).create(recursive: true);
  final String filePath = '$dirPath/${DataManager.get().currentJob.jobHeader.jobNumber}_${timestamp()}.jpg';

  if (controller.value.isTakingPicture) {
    // A capture is already pending, do nothing.
    return null;
  }

  try {
    await controller.takePicture(filePath);
  } on CameraException catch (e) {
    _showCameraException(e);
    return null;
  }
  return filePath;
}

void _showCameraException(CameraException e) {
  logError(e.code, e.description);
  print('Error: ${e.code}\n${e.description}');
}

Future<List<CameraDescription>> getCameras() async {
  // Fetch the available cameras before initializing the app.
  try {
    return await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  return null;
}