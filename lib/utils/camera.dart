import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:k2e/utils/logs.dart';
import 'package:uuid/uuid.dart';

Future<List<CameraDescription>> getCameras() async {
  // Fetch the available cameras before initializing the app.
  try {
    return await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  return null;
}

Future<File> getPicture() async {
  return await ImagePicker.pickImage(source: ImageSource.camera);
//  image.length().then((int) {
//    print('Original size ' + int.toString());
//  });
//  return image;
}

Future<Map<String, String>> ImageSync(File image, int compressionFactor,
    String fileName, String folder, DocumentReference ref) async {
  print('compressing image');
  File compImage;

  compImage = await FlutterNativeImage.compressImage(
    image.path,
    quality: compressionFactor,
    // todo: set to target widths etc.
    percentage: 60,
  );

//    var uid = Random.secure().nextInt(999999);
  print(fileName.toString());
  var uid = new Uuid().v1().toString();
  var ref = "$folder/$fileName-$uid.jpg";

  StorageUploadTask uploadTask =
      FirebaseStorage.instance.ref().child(ref).putFile(compImage);
  //                          putFile.future.catchError(onError);

  StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
  String downloadURL = await storageTaskSnapshot.ref.getDownloadURL();
//      ref.setData({"path_remote": uploadSnapshot.downloadUrl.toString()}, merge: true);
  print(downloadURL);
  print("image uploaded");

  return {
    'downloadURL': downloadURL,
    'storageRef': ref.toString(),
  };
}
