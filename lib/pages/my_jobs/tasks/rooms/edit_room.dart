import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:k2e/autocomplete.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/pages/my_jobs/tasks/samples/edit_acm.dart';
import 'package:k2e/pages/my_jobs/tasks/samples/edit_sample_asbestos_air.dart';
import 'package:k2e/styles.dart';
import 'package:k2e/theme.dart';
import 'package:k2e/utils/camera.dart';
import 'package:k2e/widgets/acm_card.dart';
import 'package:k2e/widgets/custom_auto_complete.dart';
import 'package:k2e/widgets/dialogs.dart';
import 'package:k2e/widgets/loading.dart';

class EditRoom extends StatefulWidget {
  EditRoom({Key key, this.room}) : super(key: key);
  final String room;
  @override
  _EditRoomState createState() => new _EditRoomState();
}

class _EditRoomState extends State<EditRoom> {
  String _title = "Edit Room";
  bool isLoading = true;
  Map<String,dynamic> roomObj = new Map<String,dynamic>();

  // images
  String room;
  Map<String,String> _roomgroup;
  Map<String,String> _template;
  bool localPhoto = false;
  List<Map<String, String>> roomgrouplist = new List();

  List<String> rooms = AutoComplete.rooms.split(';');
  GlobalKey key = new GlobalKey<AutoCompleteTextFieldState<String>>();

  final controllerRoomCode = TextEditingController();
  
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
    super.initState();
  }

//  _updateName(name) {
//    this.setState(() {
//      roomObj["name"] = name.trim();
//    });
//  }
//
//  _updateRoomCode() {
//    this.setState(() {
//      roomObj["roomcode"] = controllerRoomCode.text.trim();
//    });
//  }

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
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  Firestore.instance.document(DataManager
                      .get()
                      .currentJobPath).collection('rooms')
                      .document(room)
                      .setData(
                      roomObj, merge: true);
                  Navigator.pop(context);
                }
              })
            ]
        ),
        body: isLoading ?
        loadingPage(loadingText: 'Loading room info...')
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
                        child: new TextFormField(
                          decoration: new InputDecoration(
                            labelText: "Room Name",
                          ),
                          onSaved: (String value) {
                            roomObj["name"] = value.trim();
                          },
                          validator: (String value) {
                            return value.isEmpty ? 'You must add a room name' : null;
                          },
                          focusNode: _focusNodes[0],
                          initialValue: roomObj["name"],
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          onFieldSubmitted: (v) {
                            FocusScope.of(context).requestFocus(_focusNodes[1]);
                          },
                        ),
//                        child: new AutoCompleteFormField(
//                          decoration: new InputDecoration(
//                              labelText: "Room Name"
//                          ),
//                          key: formFieldKey,
//                          scrollController: _scrollController,
//                          textInputAction: TextInputAction.next,
//                          initialValue: roomObj["name"] != null ? roomObj["name"] : "",
//                          suggestions: rooms,
//
//                          textChanged: (item) {
//                            _updateName(item);
//                          },
//                          itemSubmitted: (item) {
//                            _updateName(item.toString());
//                          },
//                          itemBuilder: (context, item) {
//                            return new Padding(
//                                padding: EdgeInsets.all(8.0), child: new Text(item));
//                          },
//                          itemSorter: (a, b) {
//                            return a.compareTo(b);
//                          },
//                          itemFilter: (item, query) {
//                            return item.toLowerCase().contains(query.toLowerCase());
//                          }),
                      ),
                      new Container(
                        child: TextFormField(
                            decoration: const InputDecoration(
                                labelText: "Room Code",
                                hintText: "e.g. B1 (use for large surveys with many similar rooms)",
                            ),
                            autocorrect: false,
                            onSaved: (String value) {
                              roomObj["roomObj"] = value.trim();
                            },
                            validator: (String value) {
//                              return value.length > 0 ? 'You must add a room name' : null;
                            },
                            initialValue: roomObj["roomcode"],
                            focusNode: _focusNodes[1],
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ),
                    new Container(
                      alignment: Alignment.topLeft,
                      padding: EdgeInsets.only(top: 14.0,),
                      child: new Text("Room Group/Building/Level", style: Styles.label,),
                    ),
                    new Container(
                      alignment: Alignment.topLeft,
                      child: DropdownButton<String>(
                        value: (_roomgroup == null) ? null : _roomgroup['path'],
                        iconSize: 24.0,
                        items: roomgrouplist.map((Map<String,String> roomgroup) {
                          print(roomgroup.toString());
                          String val = "Untitled";
                          if (roomgroup['name'] != null) val = roomgroup['name'];
                          return new DropdownMenuItem<String>(
                            value: roomgroup["path"],
                            child: new Text(val),
                          );
                        }).toList(),
                        hint: Text("-"),
                        onChanged: (value) {
                          setState(() {
                            _roomgroup = roomgrouplist.firstWhere((e) => e['path'] == value);
                            roomObj["roomgroup"] = _roomgroup;
//                              acm.setData({"room": _room}, merge: true);
                          });
                        },
                      ),
                    ),
                    new Divider(),
                    new Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(top: 14.0, bottom: 14.0,),
                      child: new Text("Presumed and Sampled Materials", style: Styles.h2,),
                    ),
                    new StreamBuilder(
                        stream: Firestore.instance.document(DataManager.get().currentJobPath).collection('acm').where("roompath", isEqualTo: widget.room).snapshots(),
                        builder: (context, snapshot) {
                          print("Room object : " + widget.room.toString());
                          if (!snapshot.hasData) return
                            Container(
                                padding: EdgeInsets.only(top: 16.0),
                                alignment: Alignment.center,
                                color: Colors.white,

                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment
                                        .center,
                                    children: <Widget>[
                                      new CircularProgressIndicator(),
                                      Container(
                                          alignment: Alignment.center,
                                          height: 64.0,
                                          child:
                                          Text("Loading samples...")
                                      )
                                    ]));
                          if (snapshot.data.documents.length == 0) return
                            Center(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.not_interested, size: 64.0),
                                      Container(
                                          alignment: Alignment.center,
                                          height: 64.0,
                                          child:
                                          Text('This job has no ACM items.')
                                      )
                                    ]
                                )
                            );
                          return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data.documents.length,
                              itemBuilder: (context, index) {
                                print(snapshot.data.documents[index]['jobnumber']);
                                return AcmCard(
                                  doc: snapshot.data.documents[index],
                                  onCardClick: () async {
                                    if (snapshot.data.documents[index]['sampletype'] == 'air'){
                                      Navigator.of(context).push(
                                        new MaterialPageRoute(builder: (context) =>
                                            EditSampleAsbestosAir(
                                                sample: snapshot.data.documents[index]
                                                    .documentID)),
                                      );
                                    } else {
                                      Navigator.of(context).push(
                                        new MaterialPageRoute(builder: (context) =>
                                            EditACM(
                                                acm: snapshot.data.documents[index]
                                                    .documentID)),
                                      );
                                    }
                                  },
                                  onCardLongPress: () {
                                    // Delete
                                    // Bulk add /clone etc.
                                  },
                                );
                              }
                          );
                        }
                    ),
                    new Container(padding: EdgeInsets.only(top: 14.0)),
                    new Divider(),
                    new Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(top: 14.0,),
                      child: new Text("Building Materials", style: Styles.h2,),
                    ),
                    new Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(top: 14.0,),
                      child: new FlatButton(
                          child: const Text("Load New Room Template"),
                          color: Colors.white,
                          onPressed: () {
                            showRoomTemplateDialog(context, roomObj, applyTemplate,);
                          }
                        ),
                    ),
                    (roomObj['buildingmaterials'] != null && roomObj['buildingmaterials'].length > 0) ?
//                    roomObj['buildingmaterials'].map((item) => buildBuildingMaterials(item))
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: roomObj['buildingmaterials'].length,
                        itemBuilder: (context, index) {
                        return buildBuildingMaterials(index);
                      })
                        :
                        new Container()
//                    buildBuildingMaterials(),
                    ],
                ),
              ),
        ),
    );
  }

  buildBuildingMaterials (index) {
//      print("Building item: " + item.toString());
    var item = roomObj['buildingmaterials'][index];
    Widget widget = new Row(
      children: <Widget>[
        new Container(
          width: 100.0,
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(right: 14.0,),
//          child: new Text(item["label"], style: Styles.label,),
          child: TextFormField(
            initialValue: item["label"],
            autocorrect: false,
            focusNode: _focusNodes[(index * 2) + 2],
            autovalidate: true,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (text) {
              roomObj['buildingmaterials'][index]["label"] = text;
              FocusScope.of(context).requestFocus(_focusNodes[(index * 2) + 3]);
            },
            validator: (String value) {
//              return value.contains('@') ? 'Do not use the @ character' : null;
            },
            onSaved: (text) {
              this.setState(() {
                roomObj['buildingmaterials'][index]["label"] = text;
              });
            },
            textCapitalization: TextCapitalization.sentences,
          )
        ),
        new Flexible(
          child: TextFormField(
            initialValue: item["material"],
            autocorrect: false,
            focusNode: _focusNodes[(index * 2) + 3],
            autovalidate: true,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (text) {
              roomObj['buildingmaterials'][index]["material"] = text;
              print (roomObj['buildingmaterials'][index+1].toString());
              print (roomObj['buildingmaterials'][index+1]["label"].toString());
              print (roomObj['buildingmaterials'][index+1]["label"].length.toString());
              if (roomObj['buildingmaterials'][index+1] != null && roomObj['buildingmaterials'][index+1]["label"] != null && roomObj['buildingmaterials'][index+1]["label"].length > 0) {
                // Label is filled in, just skip to the material field
                FocusScope.of(context).requestFocus(_focusNodes[((index + 1) * 2) + 3]);
              } else {
                FocusScope.of(context).requestFocus(_focusNodes[((index + 1) * 2) + 2]);
                if (index + 1 == roomObj['buildingmaterials'].length) {
                  roomObj['buildingmaterials'] =
                  new List<dynamic>.from(roomObj['buildingmaterials'])
                    ..addAll([{"label": "", "material": "",}]);
                }
              }
            },
            validator: (String value) {
//              return value.contains('@') ? 'Do not use the @ character' : null;
            },
            onSaved: (text) {
              this.setState(() {
                roomObj['buildingmaterials'][index]["material"] = text;
              });
            },
            textCapitalization: TextCapitalization.none,
          ),
        )
      ]
    );
    return widget;
  }

  void applyTemplate(roomObj) {
    this.setState(() {
      roomObj = roomObj;
    });
  }

  void _loadRoom() async {
    print('room is ' + room.toString());
    // Load roomgroups from job
    roomgrouplist = [{"name": '-', "path": 'UnGrouped',}];
    QuerySnapshot roomSnapshot = await Firestore.instance.document(DataManager.get().currentJobPath).collection('roomgroups').getDocuments();
    roomSnapshot.documents.forEach((doc) => roomgrouplist.add({"name": doc.data['name'],"path": doc.documentID}));
    print('ROOMGROUPLIST ' + roomgrouplist.toString());

//    print("Loading room");
    if (room == null) {
      _title = "Add New Room";
      roomObj['name'] = null;
      roomObj['path_local'] = null;
      roomObj['path_remote'] = null;
      roomObj['buildingmaterials'] = null;

      setState(() {
        isLoading = false;
      });

    } else {
      print('Edit room is ' + room.toString());
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
              if (roomObj['roomgroup'] != null) _roomgroup = new Map<String, String>.from(roomObj['roomgroup']);
              if (doc.data["roomcode"] != null) controllerRoomCode.text = doc.data["roomcode"];
              isLoading = false;
            });
      });
    }
    print(_title.toString());
  }

  void _handleImageUpload(File image) async {
    String path = widget.room;
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
    ).then((url) {
      if (this.mounted) {
        setState((){
          roomObj["path_remote"] = url;
          localPhoto = false;
        });
      } else {
        // User has left the page, upload url straight to firestore
        Firestore.instance.document(DataManager
            .get()
            .currentJobPath).collection('rooms')
            .document(path)
            .setData(
            {"path_remote": url }, merge: true);
      }
    });
  }
}
