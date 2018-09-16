import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:k2e/autocomplete.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/theme.dart';
import 'package:k2e/utils/camera.dart';
import 'package:k2e/widgets/loading.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

class EditRoom extends StatefulWidget {
  EditRoom({Key key, this.room}) : super(key: key);
  final String room;
  @override
  _EditRoomState createState() => new _EditRoomState();
}

class _EditRoomState extends State<EditRoom> {
  String _title = "Edit Room";
  Stream roomDoc;
  bool isLoading = true;
  String roomText;

  // images
  String localPath;
  String remotePath;

  String room;

  bool localPhoto = false;

  List<String> rooms = AutoComplete.rooms.split(';');

  final controllerName = TextEditingController();
//  final controllerSuperRoom = TextEditingController();
//  final controllerNotes = TextEditingController();


  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();

  @override
  void initState() {
    controllerName.addListener(_updateName);
//    controllerSuperRoom.addListener(_updateSuperRoom);
//    controllerNotes.addListener(_updateNotes);
    room = widget.room;
    _loadRoom();
    super.initState();
  }

  _updateName() {
    Firestore.instance.document(DataManager.get().currentJobPath).collection('rooms').document(room).setData(
        {"name": controllerName.text}, merge: true);
  }



  Widget build(BuildContext context) {
//    final DateTime today = new DateTime.now();

    rooms.sort();

    return new Scaffold(
//        resizeToAvoidBottomPadding: false,
        appBar:
        new AppBar(title: Text(_title),
            actions: <Widget>[
              new IconButton(icon: const Icon(Icons.check), onPressed: () {
                Navigator.pop(context);
              })
            ]),
        body: new StreamBuilder(stream: Firestore.instance.document(DataManager.get().currentJobPath).collection('rooms').document(room).snapshots(),
            builder: (context, snapshot) {
              if (isLoading || !snapshot.hasData) return
                loadingPage(loadingText: 'Loading room info...');
              if (!isLoading && snapshot.hasData) {
                return GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                    child: Container(
                        padding: new EdgeInsets.all(8.0),
                        child: ListView(
                          children: <Widget>[
                            Row(children: <Widget>[
                              new Container(width: 150.0,
                                child: new Column(children: <Widget>[
//                            new Container(
//                                height: 40.0,
//                                alignment: Alignment.center,
//                                child: Text("Sample Photo", style: Styles.h2,)
//                            ),
                                  Container(
                                    alignment: Alignment.center,
                                    height: 156.0,
                                    width: 120.0,
                                    decoration: BoxDecoration(border: new Border.all(color: Colors.black)),
                                    child: GestureDetector(
                                        onTap: () {
                                          ImagePicker.pickImage(source: ImageSource.camera).then((image) {
                                            setState(() {
                                              localPath = image.path;
                                              localPhoto = true;
                                            });
                                            _handleImageUpload(image);
                                            print (image.path + " added!");
                                          });
                                        },
//                                    child: (_imageFile != null)
//                                        ? Image.file(_imageFile)
                                        child: (localPhoto) ?
                                        (localPath != null) ?
                                        new Image.file(new File(localPath))
                                            : new Container()
                                            : (remotePath != null) ?
                                        new CachedNetworkImage(
                                          imageUrl: remotePath,
//                                            imageUrl: 'https://www.whaleoil.co.nz/wp-content/uploads/2018/08/Dog.jpg',
                                          placeholder: new CircularProgressIndicator(),
                                          errorWidget: new Icon(Icons.error),
                                          fadeInDuration: new Duration(seconds: 1),
                                        )
                                            : new Icon(
                                          Icons.camera, color: CompanyColors.accent,
                                          size: 48.0,)
                                    ),
                                  )],
                                ),),
                              new Expanded(child: new Container(
                              child: new Column(
                                children: <Widget>[
                                Container(
                                  child: AutoCompleteTextField<String>(
                                      decoration: new InputDecoration(
                                          hintText: roomText,
                                          labelText: "Room Name"

//                                        border: new OutlineInputBorder(
//                                            gapPadding: 0.0, borderRadius: new BorderRadius.circular(16.0)),
//                                        suffixIcon: new Icon(Icons.search)
                                      ),
                                      key: key,
                                      suggestions: rooms,
                                      textChanged: (item) {
                                        controllerName.text = item;
                                      },
                                      itemBuilder: (context, item) {
                                        return new Padding(
                                            padding: EdgeInsets.all(8.0), child: new Text(item));
                                      },
                                      itemSorter: (a, b) {
                                        return a.compareTo(b);
                                      },
                                      itemFilter: (item, query) {
                                        return item.toLowerCase().contains(query.toLowerCase());
                                      }),
                                ),
                              ],
                              )
                              ),)
                            ],
                            ),
                          ],
                        )
                    )
                );
              }
            }
        )
    );
  }

  void _loadRoom() async {
    if (room == null) {
      _title = "Add New Room";
      Map<String, dynamic> dataMap = new Map();

      dataMap['name'] = null;

      dataMap['localPath'] = null;
      dataMap['remotePath'] = null;

      localPath = null;
      Firestore.instance.document(DataManager.get().currentJobPath)
          .collection('rooms').add(dataMap).then((ref) {
        room = ref.documentID;
        setState(() {
          isLoading = false;
        });
      });
    } else {
      _title = "Edit Room";
      Firestore.instance.document(DataManager.get().currentJobPath)
          .collection('rooms').document(room).get().then((doc) {
            controllerName.text = doc.data['name'];
            roomText = doc.data['name'];
            // image
            remotePath = doc.data['remotePath'];
            localPath = doc.data['localPath'];
            if (remotePath == null && localPath != null){
              // only local image available (e.g. when taking photos with no internet)
              localPhoto = true;
            } else if (remotePath != null) {
              localPhoto = false;
            }
            setState(() {
              isLoading = false;
            });
      });
    }
  }

  void _handleImageUpload(File image) async {
    ImageSync(
        image,
        50,
        "room" + controllerName.text + "_" + room + ".jpg",
        DataManager.get().currentJobNumber,
        Firestore.instance.document(DataManager.get().currentJobPath)
            .collection('rooms').document(room)
    ).then((path) {
      setState(() {
        remotePath = path;
        localPhoto = false;
      });
    });
  }
}