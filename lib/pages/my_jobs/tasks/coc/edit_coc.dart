import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/pages/my_jobs/tasks/acm/edit_acm.dart';
import 'package:k2e/pages/my_jobs/tasks/acm/edit_sample_asbestos_air.dart';
import 'package:k2e/styles.dart';
import 'package:k2e/theme.dart';
import 'package:k2e/utils/camera.dart';
import 'package:k2e/pages/my_jobs/tasks/acm/acm_card.dart';
import 'package:k2e/widgets/custom_auto_complete.dart';
import 'package:k2e/widgets/custom_typeahead.dart';
import 'package:k2e/widgets/dialogs.dart';
import 'package:k2e/widgets/loading.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class EditCoc extends StatefulWidget {
  EditCoc({Key key, this.coc}) : super(key: key);
  final String coc;
  @override
  _EditCocState createState() => new _EditCocState();
}

class _EditCocState extends State<EditCoc> {
  String _title = "Edit Chain of Custody";
  bool isLoading = true;
  Map<String, dynamic> cocObj = new Map<String, dynamic>();

  // images
  String coc;
  bool localPhoto = false;
  List<Map<String, String>> roomgrouplist = new List();
  final Map constants = DataManager
      .get()
      .constants;
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
    coc = widget.coc;
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
                // Update room group map if new room has been added or if room's room group has changed
                Firestore.instance.document(DataManager
                    .get()
                    .currentJobPath).collection('rooms').document(
                    cocObj['path']).setData(cocObj);
                Navigator.pop(context);
              }
            })
          ]
      ),
      body: isLoading ?
      loadingPage(loadingText: 'Loading Chain of Custody...')
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
                Text(cocObj['jobNumber']),
                Text(cocObj['client']),
                Text(cocObj['address']),
                Text(cocObj['currentVersion'] == null
                    ? 'Not issued'
                    : 'Latest version: ' + cocObj['currentVersion']),
                CustomTypeAhead(
                  controller: _roomNameController,
//                            initialValue: acmObj['materialrisk_surfacedesc'],
                  capitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  label: 'Room Name',
                  suggestions: rooms,
                  onSaved: (value) => cocObj['name'] = value.trim(),
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
                      hintText: "e.g. B1 (use for large surveys with many similar rooms)",
                    ),
                    controller: _roomCodeController,
                    autocorrect: false,
                    onSaved: (String value) =>
                    cocObj["roomcode"] = value.trim(),
                    focusNode: _focusNodes[1],
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
                new Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(top: 14.0,),
                  child: new Text(
                    "Room Group/Building/Level", style: Styles.label,),
                ),
                new Container(
                  alignment: Alignment.topLeft,
                  child: DropdownButton<String>(
                    value: (cocObj['roomgrouppath'] == null)
                        ? null
                        : cocObj['roomgrouppath'],
                    iconSize: 24.0,
                    items: roomgrouplist.map((Map<String, String> roomgroup) {
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
//                            _roomgroup = roomgrouplist.firstWhere((e) => e['path'] == value);
                        if (value == '') {
                          cocObj['roomtype'] = 'orphan';
                        } else
                          cocObj['roomtype'] = null;
                        cocObj["roomgroupname"] =
                        roomgrouplist.firstWhere((e) => e['path'] ==
                            value)['name'];
                        ;
                        cocObj["roomgrouppath"] = value;
                        DataManager
                            .get()
                            .currentRoomGroup = value;
//                              acm.setData({"room": _room}, merge: true);
                      });
                    },
                  ),
                ),
                ExpansionTile(
                  title: new Text("Samples", style: Styles.h2,),
                  children: <Widget>[
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.fromLTRB(2.0, 8.0, 4.0, 8.0,),
                          child: new OutlineButton(
                            child: const Text("Load New Template"),
                            color: Colors.white,
                            onPressed: () {
                              showRoomTemplateDialog(
                                context, cocObj, applyTemplate,);
                            },
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0)),
                          ),
                        ),
                        new Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.fromLTRB(4.0, 8.0, 2.0, 8.0,),
                          child: new OutlineButton(
                            child: const Text("Clear Empty Rows"),
                            color: Colors.white,
                            onPressed: () {
                              if (cocObj["buildingmaterials"] != null &&
                                  cocObj["buildingmaterials"].length > 0) {
                                this.setState(() {
                                  cocObj["buildingmaterials"] =
                                      cocObj["buildingmaterials"].where((bm) =>
                                      bm["material"] == null || bm["material"]
                                          .trim()
                                          .length > 0).toList();
                                });
                              }
                            },
                            shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0),),
                          ),
                        ),
                      ],
                    ),
                    (cocObj['buildingmaterials'] != null &&
                        cocObj['buildingmaterials'].length > 0) ?
                    ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: cocObj['buildingmaterials'].length,
                        itemBuilder: (context, index) {
                          return buildBuildingMaterials(index);
                        })
                        :
                    new Container(),
//                    buildBuildingMaterials(),
                  ],
                ),
              ]
          ),
        ),
      ),
    );
  }

  buildBuildingMaterials(index) {
//      print("Building item: " + item.toString());
    var item = cocObj['buildingmaterials'][index];
    TextEditingController labelController = TextEditingController(
        text: item['label']);
    TextEditingController materialController = TextEditingController(
        text: item['material']);
    Widget widget = new Row(
        children: <Widget>[
          new Container(
            width: 150.0,
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(right: 14.0,),
//          child: new Text(item["label"], style: Styles.label,),
            child: CustomTypeAhead(
              controller: labelController,
              capitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
//          label: 'Item',
              suggestions: items,
              onSaved: (value) =>
              cocObj['buildingmaterials'][index]["label"] = value.trim(),
              validator: (value) {},
              focusNode: _focusNodes[(index * 2) + 2],
              nextFocus: _focusNodes[(index * 2) + 3],
            ),
          ),
          new Flexible(
            child: CustomTypeAhead(
              controller: materialController,
              capitalization: TextCapitalization.none,
              textInputAction: TextInputAction.next,
//            label: 'Material',
              suggestions: materials,
              onSaved: (value) =>
              cocObj['buildingmaterials'][index]["material"] = value.trim(),
              validator: (value) {},
              focusNode: _focusNodes[(index * 2) + 3],
              nextFocus: (cocObj['buildingmaterials'].length - 1 != index &&
                  cocObj['buildingmaterials'][index + 1] != null &&
                  cocObj['buildingmaterials'][index + 1]["label"]
                      .trim()
                      .length > 0)
                  ? _focusNodes[((index + 1) * 2) + 3] : _focusNodes[((index +
                  1) * 2) + 2],
            ),
          )
        ]
    );
    return widget;
  }

  void applyTemplate(cocObj) {
    this.setState(() {
      cocObj = cocObj;
    });
  }

  void _loadRoom() async {
//    print("Loading room");
    if (coc == null) {
      _title = "Add New Chain of Custody";
      cocObj['deleted'] = false;

      // New room requires us to create a path so it doesn't need internet to get one from Firestore
      cocObj['path'] = new Uuid().v1();

      setState(() {
        isLoading = false;
      });
    } else {
//      print('Edit room is ' + room.toString());
      _title = "Edit Chain of Custody";
      Firestore.instance.collection('cocs').document(coc).get().then((doc) {
        // image
        setState(() {
          cocObj = doc.data;
          _roomNameController.text = cocObj['name'];
          _roomCodeController.text = cocObj['roomcode'];
          isLoading = false;
        });
      });
    }
//    print(_title.toString());
  }
}