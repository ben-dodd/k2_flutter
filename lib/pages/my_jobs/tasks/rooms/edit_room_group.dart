import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:k2e/autocomplete.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/theme.dart';
import 'package:k2e/utils/camera.dart';
import 'package:k2e/widgets/custom_auto_complete.dart';
import 'package:k2e/widgets/dialogs.dart';
import 'package:k2e/widgets/loading.dart';

class EditRoomGroup extends StatefulWidget {
  EditRoomGroup({Key key, this.room}) : super(key: key);
  final String room;
  @override
  _EditRoomGroupState createState() => new _EditRoomGroupState();
}

class _EditRoomGroupState extends State<EditRoomGroup> {
  String _title = "Edit Room";
  bool isLoading = true;
  Map<String,dynamic> roomObj = new Map<String,dynamic>();

  // images
  String room;
  bool localPhoto = false;

  List<String> rooms = AutoComplete.rooms.split(';');
  GlobalKey key = new GlobalKey<AutoCompleteTextFieldState<String>>();

  ScrollController _scrollController;

  @override
  void initState() {
    room = widget.room;
    _loadRoom();
    _scrollController = ScrollController();
    super.initState();
  }

  _updateName(name) {
    this.setState(() {
      roomObj["name"] = name.trim();
    });
  }

  Widget build(BuildContext context) {
    return new Scaffold(
//        resizeToAvoidBottomPadding: false,
      appBar:
      new AppBar(title: Text(_title),
          leading: new IconButton(
            icon: new Icon(Icons.clear),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: <Widget>[
            new IconButton(icon: const Icon(Icons.check), onPressed: () {
              if (roomObj["name"] == null || roomObj["name"] == "") {
                showValidationAlertDialog(context, "Fields Incomplete", "You must give the room a name.");
                return;
              }
              Firestore.instance.document(DataManager.get().currentJobPath).collection('rooms').document(room).setData(
                  roomObj, merge: true);
              Navigator.pop(context);
            })
          ]
      ),
      body: isLoading ?
      loadingPage(loadingText: 'Loading room info...')
          : GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
          child: ListView(
            controller: _scrollController,
            padding: new EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 200.0),
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Container(
                    alignment: Alignment.center,
                    height: 312.0,
                    width: 240.0,
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
                        new Image.file(new File(roomObj['path_local']))
                            : (roomObj['path_remote'] != null) ?
                        new CachedNetworkImage(
                          imageUrl: roomObj['path_remote'],
                          placeholder: new CircularProgressIndicator(),
                          errorWidget: new Icon(Icons.error),
                          fadeInDuration: new Duration(seconds: 1),
                        )
                            :  new Icon(
                          Icons.camera, color: CompanyColors.accent,
                          size: 48.0,)
                    ),
                  )],
              ),
              new Container(
                child: new AutoCompleteTextField<String>(
                    decoration: new InputDecoration(
                        labelText: "Room Name"
                    ),
                    key: key,
                    scrollController: _scrollController,
                    initialValue: roomObj["name"] != null ? roomObj["name"] : "",
                    suggestions: rooms,

                    textChanged: (item) {
                      _updateName(item);
                    },
                    itemSubmitted: (item) {
                      _updateName(item.toString());
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
          ),
        ),
      ),
    );
  }

  void _loadRoom() async {
//    print("Loading room");
    if (room == null) {
      _title = "Add New Room";
      roomObj['name'] = null;
      roomObj['path_local'] = null;
      roomObj['path_remote'] = null;

      isLoading = false;
    } else {
      _title = "Edit Room";
      Firestore.instance.document(DataManager.get().currentJobPath)
          .collection('rooms').document(room).get().then((doc) {
        // image
        if (doc.data['path_remote'] == null && doc.data['path_local'] != null){
          // only local image available (e.g. when taking photos with no internet)
          localPhoto = true;
          _handleImageUpload(File(doc.data['path_local']));
        } else if (doc.data['path_remote'] != null) {
          localPhoto = false;
        }
        setState(() {
          roomObj = doc.data;
          isLoading = false;
        });
      });
    }
  }

  void _handleImageUpload(File image) async {
    setState(() {
      roomObj["path_local"] = image.path;
    });
//    Firestore.instance.document(DataManager.get().currentJobPath)
//        .collection('rooms').document(room).setData({"path_local": image.path},merge: true).then((_) {
//      setState((){});
//    });
    String roomgroup = roomObj["roomgroup"];
    String name = roomObj["name"];
    String roomcode = roomObj["roomcode"];
    if (roomgroup == null) roomgroup = 'RoomGroup';
    if (name == null) name = "Untitled";
    if (roomcode == null) roomcode = "RG-U";
    ImageSync(
        image,
        50,
        roomgroup + name + "(" + roomcode + ")",
        "jobs/" + DataManager.get().currentJobNumber,
        Firestore.instance.document(DataManager.get().currentJobPath)
            .collection('rooms').document(room)
    ).then((_) {
      setState((){
        localPhoto = false;
      });
    });
  }
}
