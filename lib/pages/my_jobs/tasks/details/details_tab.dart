import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/styles.dart';

import 'package:image_picker/image_picker.dart';
import 'package:k2e/theme.dart';
import 'package:k2e/utils/helpers.dart';
import 'package:k2e/widgets/loading.dart';

// The base page for any type of job. Shows address, has cover photo,

class DetailsTab extends StatefulWidget {
  DetailsTab() : super();

  @override
  _DetailsTabState createState() => new _DetailsTabState();
}

class _DetailsTabState extends State<DetailsTab> {
  Stream fireStream;
  final controllerAddress = TextEditingController();
  final controllerDescription = TextEditingController();
  DocumentSnapshot jobDoc;
  String imageUrl;
  File _imageFile;

  @override
  Future initState() {
    print("data manager " + DataManager.get().currentJobPath);
    fireStream = Firestore.instance.document(DataManager
        .get()
        .currentJobPath).snapshots();
    controllerAddress.addListener(_updateAddress);
    controllerDescription.addListener(_updateDescription);
//    try {
//      _imageFile = new File(jobHeader.imagePath);
//    } catch (e) {
//      print(e.toString());
//    }

    super.initState();
  }

  _updateAddress() {
    Firestore.instance.document(DataManager
        .get()
        .currentJobPath).setData(
        {"address": controllerAddress.text}, merge: true);
  }

  _updateDescription() {
    Firestore.instance.document(DataManager
        .get()
        .currentJobPath).setData(
        {"description": controllerDescription.text}, merge: true);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        // this field stops the keyboard hiding the view when inputs are selected
        body:
        new StreamBuilder(
            stream: fireStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                print(snapshot.data.toString());
                if (!snapshot.hasData) return
                  loadingPage(loadingText: 'Loading job info...');
                if (snapshot.hasData) {
                  print (snapshot.data['address']);
                  if (controllerAddress.text == '') {
                    controllerAddress.text = snapshot.data['address'];
                    controllerDescription.text = snapshot.data['description'];
//                    imageUrl = snapshot.data['imagePath'];
//                    if (imageUrl != '') {
//                      print(imageUrl);
////                      _imageFile =
////                      FirebaseStorage.instance.ref().child(imageUrl).getData(
////                          null) as File;
//                    }
                  }
                  return GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                      },
                      child: Container(
                        padding: new EdgeInsets.all(8.0),
                        child: ListView(
                            children: <Widget>[
                              Container(
                                  alignment: Alignment.topLeft,
                                  child: Text(snapshot.data['clientName']
                                      , style: Styles.h1)
                              ),
                              Container(
                                alignment: Alignment.topLeft,
                                child: TextField(
                                    decoration: const InputDecoration(
                                        labelText: "Address"),
                                    autocorrect: false,
                                    controller: controllerAddress,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null
                                ),
                              ),
                              Container(
                                alignment: Alignment.topLeft,
                                child: TextField(
                                    decoration: const InputDecoration(
                                        labelText: "Description"),
                                    autocorrect: false,
                                    controller: controllerDescription,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                height: 156.0,
                                child: GestureDetector(
                                    onTap: () async {
                                      File image = await ImagePicker.pickImage(
                                          source: ImageSource.camera);
                                      image.length().then((int) {
                                        print('Original size ' + int.toString());
                                      });
//                          setState(() {
//                            _imageFile = image;
//                          });
                                      File compImage = await compressImage(
                                          image, 50);
                                      compImage.length().then((int) {
                                        print('Compressed size ' + int.toString());
                                      });
                                      setState(() {
                                        _imageFile = compImage;
                                      });
                                      var fileName = "site_photo.jpeg";
                                      var folder = snapshot.data['jobNumber'];
                                      print(fileName);
                                      StorageUploadTask putFile =
                                      FirebaseStorage.instance.ref().child(
                                          "$folder/$fileName").putFile(
                                          _imageFile);
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

                                      await Firestore.instance.runTransaction((
                                          transaction) async {
                                        await transaction.set(
                                            collectionReference, pictureData);
                                        print("instance created");
                                      });
//                          }).catchError(onError);

//                          String fileName = basename(_imageFile.path);
//
//                          // Upload image
//                          final uploadTask = FirebaseStorage.instance.ref().putFile(_imageFile);
//                          imageUrl = (await uploadTask.future).downloadUrl.toString();
//                          Firestore.instance.document(DataManager.get().currentJobPath).setData({"imagePath": imageUrl.toString()}, merge: true);
////                          File newImage = await _imageFile.copy('${docPath.path}/$fileName');
////                          setState(() async {
////                            Firestore.instance.document(DataManager.get().currentJobPath).setData({"imagePath": fileName}, merge: true);
////                            print(_imageFile.path);
////                            print(fileName);
////                          });
                                    },
                                    child: (_imageFile != null)
//                        ? new Image.file(new File(DataManager.get().currentJob.jobHeader.imagePath))
                                        ? Image.file(_imageFile)
                                        : new Icon(
                                      Icons.camera, color: CompanyColors.accent,
                                      size: 48.0,)
                                ),
                              )
                            ]
                        ),
                      )
                  );
                }
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else {
                return errorPage();
              }
            }

        )
    );
  }
}
//https://stackoverflow.com/questions/46515679/flutter-firebase-compression-before-upload-image
