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
  bool isLoading = true;
  String roomText;

  // images
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
        body: isLoading ?
        loadingPage(loadingText: 'Loading room info...')
        : new StreamBuilder(stream: Firestore.instance.document(DataManager.get().currentJobPath).collection('rooms').document(room).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return
                loadingPage(loadingText: 'Loading room info...');
              if (snapshot.hasData) {
                return GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                    child: Container(
                        padding: new EdgeInsets.all(8.0),
                        child: ListView(
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                              new Container(width: 150.0,
                                child: new Column(children: <Widget>[
                                  Container(
                                    alignment: Alignment.center,
                                    height: 156.0,
                                    width: 120.0,
                                    decoration: BoxDecoration(border: new Border.all(color: Colors.black)),
                                    child: GestureDetector(
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
                                  )],
                                ),),
                              new Expanded(
                              child: new Container(
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

      dataMap['path_local'] = null;
      dataMap['path_remote'] = null;

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
            if (doc.data['path_remote'] == null && doc.data['path_local'] != null){
              // only local image available (e.g. when taking photos with no internet)
              localPhoto = true;
              _handleImageUpload(File(doc.data['path_local']));
            } else if (doc.data['path_remote'] != null) {
              localPhoto = false;
            }
            setState(() {
              isLoading = false;
            });
      });
    }
  }

  void _handleImageUpload(File image) async {
    Firestore.instance.document(DataManager.get().currentJobPath)
        .collection('rooms').document(room).setData({"path_local": image.path},merge: true).then((_) {
      setState((){});
    });
    ImageSync(
        image,
        50,
        "sitephoto.jpg",
        DataManager.get().currentJobNumber,
        Firestore.instance.document(DataManager.get().currentJobPath)
            .collection('rooms').document(room)
    ).then((_) {
      setState((){
        localPhoto = false;
      });
    });
  }

}