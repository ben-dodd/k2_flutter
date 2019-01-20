import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/styles.dart';

import 'package:image_picker/image_picker.dart';
import 'package:k2e/theme.dart';
import 'package:k2e/utils/camera.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:k2e/widgets/loading.dart';

// The base page for any type of job. Shows address, has cover photo,

class DetailsTab extends StatefulWidget {
  DetailsTab() : super();

  @override
  _DetailsTabState createState() => new _DetailsTabState();
}

//todo: https://stackoverflow.com/questions/37699688/cache-images-local-from-google-firebase-storage

class _DetailsTabState extends State<DetailsTab> {
  DocumentReference details;
  Stream detailsStream;
  final controllerAddress = TextEditingController();
  final controllerDescription = TextEditingController();

  // IMAGES
  String path_local;
  String path_remote;

  bool localPhoto = false;

  @override
  void initState() {
    controllerAddress.addListener(_updateAddress);
    controllerDescription.addListener(_updateDescription);
    _loadDetails();

    super.initState();
  }

  _updateAddress() {
    details.setData(
        {"address": controllerAddress.text}, merge: true);
  }

  _updateDescription() {
    details.setData(
        {"description": controllerDescription.text}, merge: true);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        // this field stops the keyboard hiding the view when inputs are selected
        body: new StreamBuilder(
            stream: detailsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (!snapshot.hasData) return
                  loadingPage(loadingText: 'Loading job info...');
                if (snapshot.hasData) {
                  print (snapshot.data['address']);
                  if (controllerAddress.text == '') {
                    controllerAddress.text = snapshot.data['address'];
                    controllerDescription.text = snapshot.data['description'];
                  }
                  if (snapshot.data['path_local'] != null) print ('local path: ' + snapshot.data['path_local']);
                  if (snapshot.data['path_remote'] != null) print ('remote path: ' + snapshot.data['path_remote']);
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
                                alignment: Alignment.bottomCenter,
                                child: Text("Main Site Photo", style: Styles.h2,)
                              ),
                        Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[Container(
                                alignment: Alignment.center,
                                height: 156.0,
                                width: 206.0,
                                margin: EdgeInsets.symmetric(vertical: 4.0),
                                padding: EdgeInsets.fromLTRB(4.0,0.0,4.0,0.0),
                                decoration: new BoxDecoration(
                                  color: Colors.white,
                                  border: new Border.all(color: Colors.black38, width: 2.0),
//                                  borderRadius: new BorderRadius.circular(16.0),
                                ), child: GestureDetector(
                                    onTap: () {
                                        ImagePicker.pickImage(source: ImageSource.camera).then((image) {
//                                          _imageFile = image;
                                          localPhoto = true;
                                          _handleImageUpload(image);
                                        });
                                    },
//                                    child: (_imageFile != null)
//                                        ? Image.file(_imageFile)
                                  child: localPhoto ?
                                  new Image.file(new File(snapshot.data['path_local']))
                                  : (snapshot.data['path_remote'] != null) ?
                                  new CachedNetworkImage(
                                    imageUrl: snapshot.data['path_remote'],
                                    placeholder: new CircularProgressIndicator(),
                                    errorWidget: new Icon(Icons.error),
                                    fadeInDuration: new Duration(seconds: 1),
                                  )
                                  :  new Icon(
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

  void _loadDetails() async {
    details = Firestore.instance.document(DataManager.get().currentJobPath);
    detailsStream = details.snapshots();
    DocumentSnapshot doc = await details.get();
    if (doc.data['path_local'] != null && doc.data['path_remote'] == null){
      // only local image available (e.g. when taking photos with no internet)
      localPhoto = true;
      // try to upload
      _handleImageUpload(File(doc.data['path_local']));
    } else if (doc.data['path_remote'] != null) {
      localPhoto = false;
    }
    setState(() {
      print('is loading set to false');
    });
  }

  void _handleImageUpload(File image) async {
    details.setData({"path_local": image.path},merge: true).then((_) {
      setState((){});
    });
    ImageSync(
        image,
        50,
        "sitephoto.jpg",
        DataManager.get().currentJobNumber,
        details
    ).then((_) {
      setState((){
        localPhoto = false;
      });
    });
  }
}