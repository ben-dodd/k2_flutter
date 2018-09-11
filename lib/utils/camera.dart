import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:k2e/utils/helpers.dart';
import 'package:k2e/utils/logs.dart';


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

Future<File> ImageSync (File image, int compressionFactor, String fileName, String folder) async {
  print('compressing image');
  File compImage = await compressImage(
      image, compressionFactor);
  compImage.length().then((int) {
    print('Compressed size ' + int.toString());
  });
  print(fileName);
  StorageUploadTask putFile =
  FirebaseStorage.instance.ref().child(
      "$folder/$fileName").putFile(
      compImage);
//                          putFile.future.catchError(onError);

  UploadTaskSnapshot uploadSnapshot = await putFile
      .future;

  print("image uploaded");

  Map<String,
      dynamic> pictureData = new Map<
      String,
      dynamic>();
  pictureData["url"] =
      uploadSnapshot.downloadUrl.toString();


  DocumentReference collectionReference =
  Firestore.instance.collection(
      "collection")
      .document(fileName);

  await Firestore.instance.runTransaction((transaction) async {
    await transaction.set(
        collectionReference, pictureData);
    print("instance created");
  });
  return compImage;
}