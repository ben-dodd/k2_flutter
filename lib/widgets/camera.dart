import 'package:flutter/material.dart';
/// Display the control bar with buttons to take pictures and record videos.
//Widget _captureControlRowWidget() {
//  return new Row(
//    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//    mainAxisSize: MainAxisSize.max,
//    children: <Widget>[
//      new IconButton(
//        icon: const Icon(Icons.camera_alt),
//        color: Colors.blue,
//        onPressed: controller != null &&
//            controller.value.isInitialized &&
//            !controller.value.isRecordingVideo
//            ? onTakePictureButtonPressed
//            : null,
//      ),
//      new IconButton(
//        icon: const Icon(Icons.videocam),
//        color: Colors.blue,
//        onPressed: controller != null &&
//            controller.value.isInitialized &&
//            !controller.value.isRecordingVideo
//            ? onVideoRecordButtonPressed
//            : null,
//      ),
//      new IconButton(
//        icon: const Icon(Icons.stop),
//        color: Colors.red,
//        onPressed: controller != null &&
//            controller.value.isInitialized &&
//            controller.value.isRecordingVideo
//            ? onStopButtonPressed
//            : null,
//      )
//    ],
//  );
//}

///// Display a row of toggle to select the camera (or a message if no camera is available).
//Widget _cameraTogglesRowWidget() {
//  final List<Widget> toggles = <Widget>[];
//
//  if (DataManager.get().cameras.isEmpty) {
//    return const Text('No camera found');
//  } else {
//    for (CameraDescription cameraDescription in DataManager.get().cameras) {
//      toggles.add(
//        new SizedBox(
//          width: 90.0,
//          child: new RadioListTile<CameraDescription>(
//            title:
//            new Icon(getCameraLensIcon(cameraDescription.lensDirection)),
//            groupValue: controller?.description,
//            value: cameraDescription,
//            onChanged: controller != null && controller.value.isRecordingVideo
//                ? null
//                : onNewCameraSelected,
//          ),
//        ),
//      );
//    }
//  }
//
//  return new Row(children: toggles);
//}