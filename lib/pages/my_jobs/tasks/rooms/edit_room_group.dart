//
//import 'dart:async';
//import 'dart:io';
//
//import 'package:cached_network_image/cached_network_image.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter/material.dart';
//import 'package:image_picker/image_picker.dart';
//import 'package:k2e/autocomplete.dart';
//import 'package:k2e/data/datamanager.dart';
//import 'package:k2e/styles.dart';
//import 'package:k2e/theme.dart';
//import 'package:k2e/utils/camera.dart';
//import 'package:k2e/widgets/custom_auto_complete.dart';
//import 'package:k2e/widgets/loading.dart';
//
//class EditRoomGroup extends StatefulWidget {
//  EditRoomGroup({Key key, this.roomgroup}) : super(key: key);
//  final String roomgroup;
//  @override
//  _EditRoomGroupState createState() => new _EditRoomGroupState();
//}
//
//class _EditRoomGroupState extends State<EditRoomGroup> {
//  String _title = "Edit Room Group";
//  bool isLoading = true;
//  String roomgroupText;
//
//  // images
//  String roomgroup;
//
////  List<Map<String, String>> roomGroupTemplates = AutoComplete.roomgrouptemplates.split(";").map( => );
//
//  final controllerName = TextEditingController();
//  final controllerPrefix = TextEditingController();
//
//  @override
//  void initState() {
//    controllerName.addListener(_updateName);
//
//    roomgroup = widget.roomgroup;
//    Map<String, String> _template;
//    _loadRoom();
//
//    super.initState();
//  }
//
//  _updateName() {
//    Firestore.instance.document(DataManager.get().currentJobPath).collection('roomgroups').document(roomgroup).setData(
//        {"name": controllerName.text}, merge: true);
//  }
//
//  Widget build(BuildContext context) {
//    return new Scaffold(
////        resizeToAvoidBottomPadding: false,
//        appBar:
//        new AppBar(title: Text(_title),
//            actions: <Widget>[
//              new IconButton(icon: const Icon(Icons.check), onPressed: () {
//                Navigator.pop(context);
//              })
//            ]),
//        body: isLoading ?
//        loadingPage(loadingText: 'Loading room info...')
//        : new StreamBuilder(stream: Firestore.instance.document(DataManager.get().currentJobPath).collection('rooms').document(room).snapshots(),
//            builder: (context, snapshot) {
//              if (!snapshot.hasData) return
//                loadingPage(loadingText: 'Loading room info...');
//              if (snapshot.hasData) {
//                return GestureDetector(
//                    onTap: () {
//                      FocusScope.of(context).requestFocus(new FocusNode());
//                    },
//                    child: Container(
//                        padding: new EdgeInsets.all(8.0),
//                        child: ListView(
//                          children: <Widget>[
//                            new Text("Room Name", style: Styles.label,),
//                            new Container(
//                              child: DropdownButton<String>(
//                                value: (_template == null) ? null : _template['name'],
//                                iconSize: 24.0,
//                                items: roomGroupTemplates.map((Map<String,String> template) {
//                                  return new DropdownMenuItem<String>(
//                                    value: template["name"],
//                                    child: new Text(template["name"]),
//                                  );
//                                }).toList(),
//                                hint: Text("Select a template to autopopulate rooms"),
//                                onChanged: (value) {
//                                  setState(() {
//                                    _template = roomGroupTemplates.firstWhere((e) => e['name'] == value);
////                                    acm.setData({"room": _room}, merge: true);
//                                  });
//                                },
//                              ),
//                            ),
//                            ],
//                        ),
//                    )
//                );
//              }
//            }
//        )
//    );
//  }
//
//  void _loadRoom() async {
//    if (room == null) {
//      _title = "Add New Room";
//      Map<String, dynamic> dataMap = new Map();
//
//      dataMap['name'] = null;
//
//      dataMap['path_local'] = null;
//      dataMap['path_remote'] = null;
//
//      Firestore.instance.document(DataManager.get().currentJobPath)
//          .collection('rooms').add(dataMap).then((ref) {
//        room = ref.documentID;
//        setState(() {
//          isLoading = false;
//        });
//      });
//    } else {
//      _title = "Edit Room";
//      Firestore.instance.document(DataManager.get().currentJobPath)
//          .collection('rooms').document(room).get().then((doc) {
//            controllerName.text = doc.data['name'];
//            roomText = doc.data['name'];
//            // image
//            if (doc.data['path_remote'] == null && doc.data['path_local'] != null){
//              // only local image available (e.g. when taking photos with no internet)
//              localPhoto = true;
//              _handleImageUpload(File(doc.data['path_local']));
//            } else if (doc.data['path_remote'] != null) {
//              localPhoto = false;
//            }
//            setState(() {
//              print(controllerName.text);
//              isLoading = false;
//            });
//      });
//    }
//  }
//
//  void _handleImageUpload(File image) async {
//    Firestore.instance.document(DataManager.get().currentJobPath)
//        .collection('rooms').document(room).setData({"path_local": image.path},merge: true).then((_) {
//      setState((){});
//    });
//    ImageSync(
//        image,
//        50,
//        "sitephoto.jpg",
//        DataManager.get().currentJobNumber,
//        Firestore.instance.document(DataManager.get().currentJobPath)
//            .collection('rooms').document(room)
//    ).then((_) {
//      setState((){
//        localPhoto = false;
//      });
//    });
//  }
//
//}