import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/styles.dart';

import 'package:image_picker/image_picker.dart';
import 'package:k2e/theme.dart';
import 'package:k2e/utils/camera.dart';
import 'package:k2e/utils/helpers.dart';
import 'package:k2e/utils/sync.dart';
import 'package:k2e/widgets/loading.dart';

// The base page for any type of job. Shows address, has cover photo,

class DetailsTab extends StatefulWidget {
  DetailsTab() : super();

  @override
  _DetailsTabState createState() => new _DetailsTabState();
}

//todo: https://stackoverflow.com/questions/37699688/cache-images-local-from-google-firebase-storage

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
                                height: 40.0,
                                alignment: Alignment.bottomLeft,
                                child: Text("Main Site Photo", style: Styles.h2,)
                              ),
                              Container(
                                alignment: Alignment.center,
                                height: 156.0,
                                decoration: BoxDecoration(border: new Border.all(color: Colors.black)),
                                child: GestureDetector(
                                    onTap: () {
                                      handleImage();
                                    },
                                    child: (_imageFile != null)
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

  void handleImage() async {
    ImagePicker.pickImage(source: ImageSource.camera).then((image) {
      setState(() {
        _imageFile = image;
        print (image.path + " added!");
      });
      ImageSync(
          image,
          50,
          "site_photo.jpg",
          DataManager.get().currentJobNumber
      ).then((image) {
        setState(() {
          print ("uploaded yay!");
          _imageFile = image;
        });
      });
    });
  }
}
//https://stackoverflow.com/questions/46515679/flutter-firebase-compression-before-upload-image
