import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/utils/helpers.dart';
import 'package:k2e/utils/logs.dart';
import 'package:flutter_native_image/flutter_native_image.dart';


Future<List<CameraDescription>> getCameras() async {
  // Fetch the available cameras before initializing the app.
  try {
    return await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  return null;
}

Future <File> getPicture() async {
  return await ImagePicker.pickImage(source: ImageSource.camera);
//  image.length().then((int) {
//    print('Original size ' + int.toString());
//  });
//  return image;
}

  Future<void> ImageSync (File image, int compressionFactor, String fileName, String folder, DocumentReference ref) async {
    print('compressing image');
    File compImage;
    UploadTaskSnapshot uploadSnapshot;

    compImage = await FlutterNativeImage.compressImage(
      image.path,
      quality: compressionFactor,
      // todo: set to target widths etc.
      percentage: 60,
    );

    StorageUploadTask putFile =
      FirebaseStorage.instance.ref().child(
          "$folder/$fileName").putFile(
          compImage);
      //                          putFile.future.catchError(onError);

      uploadSnapshot = await putFile.future;
      print('Image path: ' + uploadSnapshot.downloadUrl.toString());
      ref.setData({"path_remote": uploadSnapshot.downloadUrl.toString()}, merge: true);
      print("image uploaded");
}