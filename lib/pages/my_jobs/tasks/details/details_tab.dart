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
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
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

  // IMAGES
  String path_local;
  String path_remote;

  bool localPhoto = false;

  @override
  void initState() {
    fireStream = Firestore.instance.document(DataManager
        .get()
        .currentJobPath).snapshots();
    controllerAddress.addListener(_updateAddress);
    controllerDescription.addListener(_updateDescription);

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
                  if (snapshot.data['path_image'] != null) print ('image path: ' + snapshot.data['path_image']);
                  print (snapshot.data['address']);
                  if (controllerAddress.text == '') {
                    controllerAddress.text = snapshot.data['address'];
                    controllerDescription.text = snapshot.data['description'];
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
                                  child: Text(snapshot.data['clientname']
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
                        Row(
                              children: <Widget>[Container(
                                alignment: Alignment.center,
                                height: 156.0,
                                width: 206.0,
                                margin: EdgeInsets.symmetric(vertical: 4.0),
                                padding: EdgeInsets.fromLTRB(8.0,0.0,4.0,0.0),
                                decoration: new BoxDecoration(
                                  color: Colors.white,
                                  border: new Border.all(color: Colors.black38, width: 2.0),
                                  borderRadius: new BorderRadius.circular(16.0),
                                ), child: GestureDetector(
                                    onTap: () {
                                        ImagePicker.pickImage(source: ImageSource.camera).then((image) {
//                                          _imageFile = image;
                                          setState(() {
                                            path_local = image.path;
                                            localPhoto = true;
                                          });
                                          _handleImageUpload(image);
                                        });
                                    },
//                                    child: (_imageFile != null)
//                                        ? Image.file(_imageFile)
                                  child: (localPhoto) ?
                                  (path_local != null) ?
                                  new Image.file(new File(path_local))
                                      : new Container()
                                      : (path_remote != null) ?
                                  new CachedNetworkImage(
                                    imageUrl: path_remote,
                                    placeholder: new CircularProgressIndicator(),
                                    errorWidget: new Icon(Icons.error),
                                    fadeInDuration: new Duration(seconds: 1),
                                  )
                                      : new Icon(
                                    Icons.camera, color: CompanyColors.accent,
                                    size: 48.0,)
                                ),
                              )]),
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

  void _handleImageUpload(File image) async {
    ImageSync(
        image,
        50,
        "sitephoto.jpg",
        DataManager.get().currentJobNumber,
        Firestore.instance.document(DataManager
            .get()
            .currentJobPath)
    ).then((path) {
      setState(() {
        path_remote = path;
        localPhoto = false;
      });
    });
  }
}