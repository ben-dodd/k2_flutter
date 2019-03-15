import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/pages/my_jobs/tasks/acm/acm_card.dart';
import 'package:k2e/pages/my_jobs/tasks/acm/edit_acm.dart';
import 'package:k2e/pages/my_jobs/tasks/acm/edit_sample_asbestos_air.dart';
import 'package:k2e/styles.dart';
import 'package:k2e/theme.dart';
import 'package:k2e/utils/camera.dart';
import 'package:k2e/widgets/custom_auto_complete.dart';
import 'package:k2e/widgets/custom_typeahead.dart';
import 'package:k2e/widgets/dialogs.dart';
import 'package:k2e/widgets/loading.dart';
import 'package:uuid/uuid.dart';

class EditRoom extends StatefulWidget {
  EditRoom({Key key, this.room}) : super(key: key);
  final String room;
  @override
  _EditRoomState createState() => new _EditRoomState();
}

class _EditRoomState extends State<EditRoom> {
  String _title = "Edit Room";
  bool isLoading = true;
  String initRoomGroup;
  Map<String, dynamic> roomObj = new Map<String, dynamic>();

  // images
  String room;
  bool localPhoto = false;
  List<Map<String, String>> roomgrouplist = new List();
  final Map constants = DataManager.get().constants;
  GlobalKey key = new GlobalKey<AutoCompleteTextFieldState<String>>();

//  final controllerRoomCode = TextEditingController();
  final _roomCodeController = TextEditingController();
  final _roomNameController = TextEditingController();

  List rooms;
  List items;
  List materials;

  var _formKey = GlobalKey<FormState>();
//  GlobalKey formFieldKey = new GlobalKey<AutoCompleteFormFieldState<String>>();

  ScrollController _scrollController;

  // Create list of focus nodes
  final _focusNodes = List<FocusNode>.generate(
    200,
    (i) => FocusNode(),
  );

  @override
  void initState() {
    room = widget.room;
//    controllerRoomCode.addListener(_updateRoomCode);
    _loadRoom();
    _scrollController = ScrollController();

    rooms = constants['roomsuggestions'];
    items = constants['buildingitems'];
    materials = constants['buildingmaterials'];
    super.initState();
  }

  Widget build(BuildContext context) {
    return new Scaffold(
//        resizeToAvoidBottomPadding: false,
      appBar: new AppBar(
          title: Text(_title),
          leading: new IconButton(
            icon: new Icon(Icons.clear),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: <Widget>[
            new IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    // Update room group map if new room has been added or if room's room group has changed
                    Firestore.instance
                        .document(DataManager.get().currentJobPath)
                        .collection('rooms')
                        .document(roomObj['path'])
                        .setData(roomObj);
                    if (roomObj['roomgrouppath'] == null ||
                        roomObj['roomgrouppath'] != initRoomGroup) {
                      updateRoomGroups(initRoomGroup, roomObj, widget.room);
                    } else {
                      updateRoomCard(roomObj['roomgrouppath'], roomObj);
                    }
                    Navigator.pop(context);
                  }
                })
          ]),
      body: isLoading
          ? loadingPage(loadingText: 'Loading room info...')
          : GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: Form(
                key: _formKey,
                child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: _scrollController,
                    padding: new EdgeInsets.all(8.0),
//                  padding: new EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 200.0),
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Container(
                            alignment: Alignment.center,
                            height: 312.0,
                            width: 240.0,
                            decoration: BoxDecoration(
                                border: new Border.all(color: Colors.black)),
                            child: GestureDetector(
                                onTap: () {
                                  ImagePicker.pickImage(
                                          source: ImageSource.camera)
                                      .then((image) {
//                                          _imageFile = image;
                                    if (image != null) {
                                      localPhoto = true;
                                      _handleImageUpload(image);
                                    }
                                  });
                                },
//                                    child: (_imageFile != null)
//                                        ? Image.file(_imageFile)
                                child: localPhoto
                                    ? new Image.file(
                                        new File(roomObj['path_local']))
                                    : (roomObj['path_remote'] != null)
                                        ? new CachedNetworkImage(
                                            imageUrl: roomObj['path_remote'],
                                            placeholder: (context, url) => new CircularProgressIndicator(),
                                            errorWidget:  (context, url, error) => new Icon(Icons.error),
                                            fadeInDuration:
                                                new Duration(seconds: 1),
                                          )
                                        : new Icon(
                                            Icons.camera,
                                            color: CompanyColors.accentRippled,
                                            size: 48.0,
                                          )),
                          )
                        ],
                      ),
                      CustomTypeAhead(
                        controller: _roomNameController,
                        //                            initialValue: acmObj['materialrisk_surfacedesc'],
                        capitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.done,
                        label: 'Room Name',
                        suggestions: rooms,
                        onSaved: (value) => roomObj['name'] = value.trim(),
                        validator: (value) {},
                        focusNode: _focusNodes[0],
                        nextFocus: _focusNodes[1],
                        onSuggestionSelected: (suggestion) {
                          _roomNameController.text = suggestion['label'];
                          if (_roomCodeController.text == '') {
                            _roomCodeController.text = suggestion['code'];
                          }
                        },
                        onSubmitted: (v) {},
                      ),
                      new Container(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Room Code",
                            hintText:
                                "e.g. B1 (use for large surveys with many similar rooms)",
                          ),
                          controller: _roomCodeController,
                          autocorrect: false,
                          onSaved: (String value) =>
                              roomObj["roomcode"] = value.trim(),
                          focusNode: _focusNodes[1],
                          textCapitalization: TextCapitalization.characters,
                        ),
                      ),
                      new Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.only(
                          top: 14.0,
                        ),
                        child: new Text(
                          "Room Group/Building/Level",
                          style: Styles.label,
                        ),
                      ),
                      new Container(
                        alignment: Alignment.topLeft,
                        child: DropdownButton<String>(
                          value: (roomObj['roomgrouppath'] == null)
                              ? null
                              : roomObj['roomgrouppath'],
                          iconSize: 24.0,
                          items: roomgrouplist
                              .map((Map<String, String> roomgroup) {
                            print(roomgroup.toString());
                            String val = "Untitled";
                            if (roomgroup['name'] != null)
                              val = roomgroup['name'];
                            return new DropdownMenuItem<String>(
                              value: roomgroup["path"],
                              child: new Text(val),
                            );
                          }).toList(),
                          hint: Text("-"),
                          onChanged: (value) {
                            setState(() {
//                            _roomgroup = roomgrouplist.firstWhere((e) => e['path'] == value);
                              if (value == '') {
                                roomObj['roomtype'] = 'orphan';
                              } else
                                roomObj['roomtype'] = null;
                              roomObj["roomgroupname"] =
                                  roomgrouplist.firstWhere(
                                      (e) => e['path'] == value)['name'];
                              ;
                              roomObj["roomgrouppath"] = value;
                              DataManager.get().currentRoomGroup = value;
//                              acm.setData({"room": _room}, merge: true);
                            });
                          },
                        ),
                      ),
                      ExpansionTile(
                          initiallyExpanded: true,
                          title: new Text(
                            "Presumed and Sampled Materials",
                            style: Styles.h2,
                          ),
                          children: <Widget>[
                            new Row(children: <Widget>[
                              new Container(
                                  alignment: Alignment.topLeft,
                                  child: Checkbox(
                                      value: roomObj['presume'] != null
                                          ? roomObj['presume']
                                          : false,
                                      onChanged: (value) => setState(() {
                                            roomObj['presume'] =
                                                roomObj['presume'] != null
                                                    ? !roomObj['presume']
                                                    : true;
                                          }))),
                              new Container(
                                alignment: Alignment.topLeft,
                                child: new Text(
                                  "Presume Entire Room (Inaccessible)",
                                  style: Styles.label,
                                ),
                              ),
                            ]),
                            widget.room != null
                                ? new StreamBuilder(
                                    stream: Firestore.instance
                                        .document(
                                            DataManager.get().currentJobPath)
                                        .collection('acm')
                                        .where("roompath",
                                            isEqualTo: widget.room)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      print("Room object : " +
                                          widget.room.toString());
                                      if (!snapshot.hasData)
                                        return Container(
                                            padding: EdgeInsets.only(top: 16.0),
                                            alignment: Alignment.center,
                                            color: Colors.white,
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  new CircularProgressIndicator(),
                                                  Container(
                                                      alignment:
                                                          Alignment.center,
                                                      height: 64.0,
                                                      child: Text(
                                                          "Loading ACM items..."))
                                                ]));
                                      if (snapshot.data.documents.length == 0)
                                        return Center(
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                              Icon(Icons.not_interested,
                                                  size: 64.0),
                                              Container(
                                                  alignment: Alignment.center,
                                                  height: 64.0,
                                                  child: Text(
                                                      'This job has no ACM items.'))
                                            ]));
                                      return ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount:
                                              snapshot.data.documents.length,
                                          itemBuilder: (context, index) {
                                            var doc = snapshot
                                                .data.documents[index].data;
                                            doc['path'] = snapshot.data
                                                .documents[index].documentID;
                                            return AcmCard(
                                              doc: snapshot
                                                  .data.documents[index],
                                              onCardClick: () async {
                                                if (snapshot.data
                                                            .documents[index]
                                                        ['sampletype'] ==
                                                    'air') {
                                                  Navigator.of(context).push(
                                                    new MaterialPageRoute(
                                                        builder: (context) =>
                                                            EditSampleAsbestosAir(
                                                                sample: snapshot
                                                                    .data
                                                                    .documents[
                                                                        index]
                                                                    .documentID)),
                                                  );
                                                } else {
                                                  Navigator.of(context).push(
                                                    new MaterialPageRoute(
                                                        builder: (context) =>
                                                            EditACM(
                                                                acm: snapshot
                                                                    .data
                                                                    .documents[
                                                                        index]
                                                                    .documentID)),
                                                  );
                                                }
                                              },
                                              onCardLongPress: () {
                                                // Delete
                                                // Bulk add /clone etc.
                                              },
                                            );
                                          });
                                    })
                                : new Center(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                        Icon(Icons.not_interested, size: 64.0),
                                        Container(
                                            alignment: Alignment.center,
                                            height: 64.0,
                                            child: Text(
                                                'This job has no ACM items.'))
                                      ])),
                          ]),
//                    new Container(padding: EdgeInsets.only(top: 14.0)),
//                    new Divider(),
                      ExpansionTile(
                        initiallyExpanded: true,
                        title: new Text(
                          "Building Materials",
                          style: Styles.h2,
                        ),
                        children: <Widget>[
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.fromLTRB(
                                  2.0,
                                  8.0,
                                  4.0,
                                  8.0,
                                ),
                                child: new OutlineButton(
                                  child: const Text("Load New Template"),
                                  color: Colors.white,
                                  onPressed: () {
                                    showRoomTemplateDialog(
                                      context,
                                      roomObj,
                                      applyTemplate,
                                    );
                                  },
                                  shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(30.0)),
                                ),
                              ),
                              new Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.fromLTRB(
                                  4.0,
                                  8.0,
                                  2.0,
                                  8.0,
                                ),
                                child: new OutlineButton(
                                  child: const Text("Clear Empty Rows"),
                                  color: Colors.white,
                                  onPressed: () {
                                    if (roomObj["buildingmaterials"] != null &&
                                        roomObj["buildingmaterials"].length >
                                            0) {
                                      this.setState(() {
                                        roomObj["buildingmaterials"] =
                                            roomObj["buildingmaterials"]
                                                .where((bm) =>
                                                    bm["material"] == null ||
                                                    bm["material"]
                                                            .trim()
                                                            .length >
                                                        0)
                                                .toList();
                                      });
                                    }
                                  },
                                  shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(30.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          (roomObj['buildingmaterials'] != null &&
                                  roomObj['buildingmaterials'].length > 0)
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount:
                                      roomObj['buildingmaterials'].length,
                                  itemBuilder: (context, index) {
                                    return buildBuildingMaterials(index);
                                  })
                              : new Container(),
//                    buildBuildingMaterials(),
                        ],
                      ),
                      widget.room != null
                          ? new Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(
                                top: 14.0,
                              ),
                              child: new OutlineButton(
                                  shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(30.0)),
                                  child: Text("Delete Room",
                                      style: new TextStyle(
                                          color: Theme.of(context).accentColor,
                                          fontWeight: FontWeight.bold)),
                                  //                          color: Colors.white,
                                  onPressed: () {
                                    _deleteDialog();
                                  }),
                            )
                          : new Container(),
                    ]),
              ),
            ),
    );
  }

  void _deleteDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text('Delete Room'),
            content: new Text('Are you sure you wish to delete this room (' +
                roomObj['name'] +
                ')?\nNote: This will not delete any ACM linked to this room.'),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Cancel',
                    style: new TextStyle(color: Colors.black)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                  child: new Text('Delete'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _deleteRoom();
                  }),
            ],
          );
        });
  }

  void _deleteRoom() {
    // Remove from room group
    var initRoomGroup = roomObj['roomgrouppath'];
    roomObj['roomgrouppath'] = null;
    updateRoomGroups(initRoomGroup, roomObj, room);

    // Remove ACM references
    Firestore.instance
        .document(DataManager.get().currentJobPath)
        .collection('acm')
        .where('roompath', isEqualTo: widget.room)
        .getDocuments()
        .then((doc) {
      doc.documents.forEach((doc) {
        Firestore.instance
            .document(DataManager.get().currentJobPath)
            .collection('acm')
            .document(doc.documentID)
            .setData({
          'roomname': null,
          'roompath': null,
        }, merge: true);
      });
    });

    // Remove images
    if (roomObj['storage_ref'] != null) {
      FirebaseStorage.instance.ref().child(roomObj['storage_ref']).delete();
    }

    // Remove room
    Firestore.instance
        .document(DataManager.get().currentJobPath)
        .collection('rooms')
        .document(widget.room)
        .delete();

    // Pop
    Navigator.pop(context);
  }

  buildBuildingMaterials(index) {
//      print("Building item: " + item.toString());
    var item = roomObj['buildingmaterials'][index];
    TextEditingController labelController =
        TextEditingController(text: item['label']);
    TextEditingController materialController =
        TextEditingController(text: item['material']);
    Widget widget = new Row(children: <Widget>[
      new Container(
        width: 150.0,
        alignment: Alignment.topLeft,
        padding: EdgeInsets.only(
          right: 14.0,
        ),
//          child: new Text(item["label"], style: Styles.label,),
        child: CustomTypeAhead(
          controller: labelController,
          capitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
//          label: 'Item',
          suggestions: items,
          onSaved: (value) =>
              roomObj['buildingmaterials'][index]["label"] = value.trim(),
          validator: (value) {},
          focusNode: _focusNodes[(index * 2) + 2],
          nextFocus: _focusNodes[(index * 2) + 3],
        ),
//          child: TextFormField(
//            style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
//            initialValue: item["label"],
//            autocorrect: false,
//            focusNode: _focusNodes[(index * 2) + 2],
//            autovalidate: true,
//            textInputAction: TextInputAction.next,
//            onFieldSubmitted: (text) {
//              print(text.toString());
//              setState(() {
//                roomObj['buildingmaterials'][index]["label"] = text.trim();
//              });
//              FocusScope.of(context).requestFocus(_focusNodes[(index * 2) + 3]);
//            },
//            validator: (String value) {
////              return value.contains('@') ? 'Do not use the @ character' : null;
//            },
//            onSaved: (text) {
//              setState(() {
//                roomObj['buildingmaterials'][index]["label"] = text.trim();
//              });
//            },
//            textCapitalization: TextCapitalization.sentences,
//          )
      ),
      new Flexible(
        child: CustomTypeAhead(
          controller: materialController,
          capitalization: TextCapitalization.none,
          textInputAction: TextInputAction.next,
//            label: 'Material',
          suggestions: materials,
          onSaved: (value) =>
              roomObj['buildingmaterials'][index]["material"] = value.trim(),
          validator: (value) {},
          focusNode: _focusNodes[(index * 2) + 3],
          nextFocus: (roomObj['buildingmaterials'].length - 1 != index &&
                  roomObj['buildingmaterials'][index + 1] != null &&
                  roomObj['buildingmaterials'][index + 1]["label"]
                          .trim()
                          .length >
                      0)
              ? _focusNodes[((index + 1) * 2) + 3]
              : _focusNodes[((index + 1) * 2) + 2],
        ),
//          child: TextFormField(
//            initialValue: item["material"],
//            autocorrect: false,
//            focusNode: _focusNodes[(index * 2) + 3],
//            autovalidate: true,
//            textInputAction: TextInputAction.next,
//            onFieldSubmitted: (text) {
//              setState(() {
//                roomObj['buildingmaterials'][index]["material"] = text.trim();
//              });
//              if (roomObj['buildingmaterials'][index+1] != null && roomObj['buildingmaterials'][index+1]["label"].trim().length > 0) {
//                FocusScope.of(context).requestFocus(_focusNodes[((index + 1) * 2) + 3]);
//              } else {
//                // If label field isn't filled in, go to it on Keyboard Next otherwise go to the next material
//                FocusScope.of(context).requestFocus(_focusNodes[((index + 1) * 2) + 2]);
//              }
//              if (roomObj['buildingmaterials'].length < index + 2) {
//                roomObj['buildingmaterials'] =
//                new List<dynamic>.from(roomObj['buildingmaterials'])
//                  ..addAll([{"label": "", "material": "",}]);
//              }
//            },
//            validator: (String value) {
////              return value.contains('@') ? 'Do not use the @ character' : null;
//            },
//            onSaved: (text) {
//              setState(() {
//                roomObj['buildingmaterials'][index]["material"] = text.trim();
//              });
//            },
//            textCapitalization: TextCapitalization.none,
//          ),
      )
    ]);
    return widget;
  }

  void applyTemplate(roomObj) {
    this.setState(() {
      roomObj = roomObj;
    });
  }

  void _loadRoom() async {
//    print('room is ' + room.toString());
    // Load roomgroups from job
    roomgrouplist = [
      {
        "name": '-',
        "path": '',
      }
    ];
    QuerySnapshot roomSnapshot = await Firestore.instance
        .document(DataManager.get().currentJobPath)
        .collection('rooms')
        .where('roomtype', isEqualTo: 'group')
        .getDocuments();
    roomSnapshot.documents.forEach((doc) =>
        roomgrouplist.add({"name": doc.data['name'], "path": doc.documentID}));
//    print('ROOMGROUPLIST ' + roomgrouplist.toString());

//    print("Loading room");
    if (room == null) {
      _title = "Add New Room";
      roomObj['name'] = null;
      roomObj['path_local'] = null;
      roomObj['path_remote'] = null;
      roomObj['buildingmaterials'] = null;
      roomObj['roomtype'] = 'orphan';
      roomObj['roomgrouppath'] = DataManager.get().currentRoomGroup;

      // New room requires us to create a path so it doesn't need internet to get one from Firestore
      roomObj['path'] = new Uuid().v1();

      setState(() {
        isLoading = false;
      });
    } else {
//      print('Edit room is ' + room.toString());
      _title = "Edit Room";
      Firestore.instance
          .document(DataManager.get().currentJobPath)
          .collection('rooms')
          .document(room)
          .get()
          .then((doc) {
        // image
        if (doc.data['path_remote'] == null && doc.data['path_local'] != null) {
          // only local image available (e.g. when taking photos with no internet)
          localPhoto = true;
          _handleImageUpload(File(doc.data['path_local']));
        } else if (doc.data['path_remote'] != null) {
          localPhoto = false;
        }
        setState(() {
          roomObj = doc.data;
          _roomNameController.text = roomObj['name'];
          _roomCodeController.text = roomObj['roomcode'];
          initRoomGroup = doc.data['roomgrouppath'];
          isLoading = false;
        });
      });
    }
//    print(_title.toString());
  }

  void _handleImageUpload(File image) async {
    String path = widget.room;
    String roomgrouppath = roomObj['roomgrouppath'];
    String storageRef = roomObj['storage_ref'];

    updateRoomCard(
        roomgrouppath, {'path_local': image.path, 'path': roomObj['path']});
    setState(() {
      roomObj["path_local"] = image.path;
    });
//    Firestore.instance.document(DataManager.get().currentJobPath)
//        .collection('rooms').document(room).setData({"path_local": image.path},merge: true).then((_) {
//      setState((){});
//    });
    String roomgroup = roomObj["roomgroupname"];
    String name = roomObj["name"];
    String roomcode = roomObj["roomcode"];
    if (roomgroup == null) roomgroup = 'RoomGroup';
    if (name == null) name = "Untitled";
    if (roomcode == null) roomcode = "RG-U";
    ImageSync(
            image,
            50,
            roomgroup + name + "(" + roomcode + ")-" + roomObj['path'],
            "jobs/" + DataManager.get().currentJobNumber,
            Firestore.instance
                .document(DataManager.get().currentJobPath)
                .collection('rooms')
                .document(room))
        .then((refs) {
      // Delete old photo
      if (storageRef != null)
        FirebaseStorage.instance.ref().child(storageRef).delete();

      updateRoomCard(roomgrouppath, {
        'path_remote': refs['downloadURL'],
        'storage_ref': refs['storageRef'],
        'path': roomObj['path']
      });
      if (this.mounted) {
        setState(() {
          roomObj["path_remote"] = refs['downloadURL'];
          roomObj['storage_ref'] = refs['storageRef'];
          localPhoto = false;
        });
      } else {
        // User has left the page, upload url straight to firestore
        Firestore.instance
            .document(DataManager.get().currentJobPath)
            .collection('rooms')
            .document(path)
            .setData({
          "path_remote": refs['downloadURL'],
          "storage_ref": refs['storageRef'],
        }, merge: true);
      }
    });
  }
}

void updateRoomGroups(
    String initRoomGroup, Map<String, dynamic> roomObj, String room) {
  print("Update room groups " + initRoomGroup.toString());
  if (roomObj['roomgrouppath'] != null)
    Firestore.instance
        .document(DataManager.get().currentJobPath)
        .collection('rooms')
        .document(roomObj['roomgrouppath'])
        .get()
        .then((doc) {
      var initChildren = new List.from(doc.data['children']);
      print("Adding to room group: " + initChildren.toString());
      initChildren
        ..addAll([
          {
            "name": roomObj['name'],
            "path": roomObj['path'],
            "path_local": roomObj['path_local'],
            "path_remote": roomObj['path_remote'],
          }
        ]);
      Firestore.instance
          .document(DataManager.get().currentJobPath)
          .collection('rooms')
          .document(roomObj['roomgrouppath'])
          .setData({"children": initChildren}, merge: true);
    });
  if (initRoomGroup != null) {
    // Remove from previous room group
    Firestore.instance
        .document(DataManager.get().currentJobPath)
        .collection('rooms')
        .document(initRoomGroup)
        .get()
        .then((doc) {
      var initChildren = doc.data['children']
          .where((child) => child['path'] != roomObj['path'])
          .toList();
      print("Removing from room group " + initChildren.toString());
      Firestore.instance
          .document(DataManager.get().currentJobPath)
          .collection('rooms')
          .document(initRoomGroup)
          .setData({"children": initChildren}, merge: true);
    });
  }
}

void updateRoomCard(String roomgrouppath, Map<String, dynamic> updateObj) {
  if (roomgrouppath != null)
    Firestore.instance
        .document(DataManager.get().currentJobPath)
        .collection('rooms')
        .document(roomgrouppath)
        .get()
        .then((doc) {
      var list = new List.from(doc.data['children']).map((doc) {
        if (doc['path'] == updateObj['path']) {
          return {
            "name": updateObj['name'] != null ? updateObj['name'] : doc['name'],
            "path": updateObj['path'] != null ? updateObj['path'] : doc['path'],
            "path_remote": updateObj['path_remote'] != null
                ? updateObj['path_remote']
                : doc['path_remote'],
            "path_local": updateObj['path_local'] != null
                ? updateObj['path_local']
                : doc['path_local'],
          };
        } else {
          return doc;
        }
      }).toList();
      Firestore.instance
          .document(DataManager.get().currentJobPath)
          .collection('rooms')
          .document(roomgrouppath)
          .setData({"children": list}, merge: true);
    });
}
