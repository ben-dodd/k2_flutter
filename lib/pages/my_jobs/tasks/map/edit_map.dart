import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:k2e/autocomplete.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/pages/my_jobs/tasks/acm/edit_acm.dart';
import 'package:k2e/pages/my_jobs/tasks/acm/edit_sample_asbestos_air.dart';
import 'package:k2e/styles.dart';
import 'package:k2e/theme.dart';
import 'package:k2e/utils/camera.dart';
import 'package:k2e/widgets/acm_card.dart';
import 'package:k2e/widgets/custom_auto_complete.dart';
import 'package:k2e/widgets/dialogs.dart';
import 'package:k2e/widgets/loading.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditMap extends StatefulWidget {
  EditMap({Key key, this.map}) : super(key: key);
  final String map;
  @override
  _EditMapState createState() => new _EditMapState();
}

class _EditMapState extends State<EditMap> {
  String _title = "Edit Map";
  bool isLoading = true;
  String initMapGroup;
  Map<String,dynamic> mapObj = new Map<String,dynamic>();

  // images
  String map;
  bool localPhoto = false;
  List<Map<String, String>> mapgrouplist = new List();

  final controllerMapCode = TextEditingController();
  
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
    map = widget.map;
//    controllerMapCode.addListener(_updateMapCode);
    _loadMap();
    _scrollController = ScrollController();
    super.initState();
  }

//  _updateName(name) {
//    this.setState(() {
//      mapObj["name"] = name.trim();
//    });
//  }
//
//  _updateMapCode() {
//    this.setState(() {
//      mapObj["mapcode"] = controllerMapCode.text.trim();
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
                if (_formKey.currentState.validate()){
                  _formKey.currentState.save();
                  // Update map group map if new map has been added or if map's map group has changed
//                  print("Widget Map" + widget.map.toString());
//                  print(mapObj['mapgroup'].toString());
//                  print(initMapGroup.toString());
                  if (mapObj['path'] == null) {
                    Firestore.instance.document(DataManager.get().currentJobPath).collection('maps').add(mapObj).then((doc) {
                      mapObj['path'] = doc.documentID;
                      if (mapObj['mapgrouppath'] == null || mapObj['mapgrouppath'] != initMapGroup) {
                        updateMapGroups(initMapGroup, mapObj, widget.map);
                      } else {
                        updateMapCard(mapObj['mapgrouppath'], mapObj);
                      }
                      Firestore.instance.document(DataManager.get().currentJobPath).collection('maps').document(doc.documentID).setData({"path": doc.documentID}, merge: true);
                      });
                  } else {
                    if (mapObj['mapgrouppath'] == null || mapObj['mapgrouppath'] != initMapGroup) {
                      updateMapGroups(initMapGroup, mapObj, widget.map);
                    } else {
                      updateMapCard(mapObj['mapgrouppath'], mapObj);
                    }
                    Firestore.instance.document(DataManager.get().currentJobPath).collection('maps').document(map).setData(
                        mapObj, merge: true);
                  }
                  Navigator.pop(context);
                }
              })
            ]
        ),
        body: isLoading ?
        loadingPage(loadingText: 'Loading map info...')
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
                            new Image.file(new File(mapObj['path_local']))
                                : (mapObj['path_remote'] != null) ?
                            new CachedNetworkImage(
                              imageUrl: mapObj['path_remote'],
                              placeholder: new CircularProgressIndicator(),
                              errorWidget: new Icon(Icons.error),
                              fadeInDuration: new Duration(seconds: 1),
                            )
                                :  new Icon(
                              Icons.camera, color: CompanyColors.accentRippled,
                              size: 48.0,)
                          ),
                        )],
                      ),
                      new Container(
                        child: new TextFormField(
                          decoration: new InputDecoration(
                            labelText: "Map Name",
                          ),
                          onSaved: (String value) {
                            mapObj["name"] = value.trim();
                          },
                          validator: (String value) {
                            return value.isEmpty ? 'You must add a map name' : null;
                          },
                          focusNode: _focusNodes[0],
                          initialValue: mapObj["name"],
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          onFieldSubmitted: (v) {
                            FocusScope.of(context).requestFocus(_focusNodes[1]);
                          },
                        ),
//                        child: new AutoCompleteFormField(
//                          decoration: new InputDecoration(
//                              labelText: "Map Name"
//                          ),
//                          key: formFieldKey,
//                          scrollController: _scrollController,
//                          textInputAction: TextInputAction.next,
//                          initialValue: mapObj["name"] != null ? mapObj["name"] : "",
//                          suggestions: maps,
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
                                labelText: "Map Code",
                                hintText: "e.g. B1 (use for large surveys with many similar maps)",
                            ),
                            autocorrect: false,
                            onSaved: (String value) {
                              mapObj["mapcode"] = value.trim();
                            },
                            validator: (String value) {
//                              return value.length > 0 ? 'You must add a map name' : null;
                            },
                            initialValue: mapObj["mapcode"],
                            focusNode: _focusNodes[1],
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ),
                    new Container(
                      alignment: Alignment.topLeft,
                      padding: EdgeInsets.only(top: 14.0,),
                      child: new Text("Map Group/Building/Level", style: Styles.label,),
                    ),
                    new Container(
                      alignment: Alignment.topLeft,
                      child: DropdownButton<String>(
                        value: (mapObj['mapgrouppath'] == null) ? null : mapObj['mapgrouppath'],
                        iconSize: 24.0,
                        items: mapgrouplist.map((Map<String,String> mapgroup) {
                          print(mapgroup.toString());
                          String val = "Untitled";
                          if (mapgroup['name'] != null) val = mapgroup['name'];
                          return new DropdownMenuItem<String>(
                            value: mapgroup["path"],
                            child: new Text(val),
                          );
                        }).toList(),
                        hint: Text("-"),
                        onChanged: (value) {
                          setState(() {
//                            _mapgroup = mapgrouplist.firstWhere((e) => e['path'] == value);
                            if (value == '') {
                              mapObj['maptype'] = 'orphan';
                            } else mapObj['maptype'] = null;
                            mapObj["mapgroupname"] = mapgrouplist.firstWhere((e) => e['path'] == value)['name'];;
                            mapObj["mapgrouppath"] = value;
//                              acm.setData({"map": _map}, merge: true);
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
                    widget.map != null ? new StreamBuilder(
                        stream: Firestore.instance.document(DataManager.get().currentJobPath).collection('acm').where("mappath", isEqualTo: widget.map).snapshots(),
                        builder: (context, snapshot) {
                          print("Map object : " + widget.map.toString());
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
                                          Text("Loading ACM items...")
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
                                var doc = snapshot.data.documents[index].data;
                                doc['path'] = snapshot.data.documents[index].documentID;
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
                    )
                    :

                    new Center(
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
                    ),
                    new Container(padding: EdgeInsets.only(top: 14.0)),
                    new Divider(),
                    new Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(top: 14.0,),
                      child: new Text("Building Materials", style: Styles.h2,),
                    ),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.fromLTRB(2.0,8.0,4.0, 8.0,),
                          child: new OutlineButton(
                              child: const Text("Load New Template"),
                              color: Colors.white,
                              onPressed: () {
//                                showMapTemplateDialog(context, mapObj, applyTemplate,);
                              },
                              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                          ),
                        ),
                        new Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.fromLTRB(4.0,8.0,2.0, 8.0,),
                          child: new OutlineButton(
                              child: const Text("Clear Empty Rows"),
                              color: Colors.white,
                              onPressed: () {
                                if (mapObj["buildingmaterials"] != null && mapObj["buildingmaterials"].length > 0) {
                                  this.setState(() {
                                    mapObj["buildingmaterials"] = mapObj["buildingmaterials"].where((bm) => bm["material"] == null || bm["material"].trim().length > 0).toList();
                                  });
                                }
                              },
                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0),),
                          ),
                        ),],
                    ),
                    (mapObj['buildingmaterials'] != null && mapObj['buildingmaterials'].length > 0) ?
//                    mapObj['buildingmaterials'].map((item) => buildBuildingMaterials(item))
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: mapObj['buildingmaterials'].length,
                        itemBuilder: (context, index) {
                        return buildBuildingMaterials(index);
                      })
                        :
                        new Container(),
                    new Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(top: 14.0,),
                      child: new OutlineButton(
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                          child: Text("Delete Map",
                              style: new TextStyle(color: Theme.of(context).accentColor, fontWeight: FontWeight.bold
                              )
                          ),
//                          color: Colors.white,
                          onPressed: () {
                            _deleteDialog();
                          }
                      ),
                    ),
//                    buildBuildingMaterials(),
                    ],
                ),
              ),
        ),
    );
  }

  void _deleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text('Delete Map'),
          content: new Text('Are you sure you wish to delete this map (' + mapObj['name'] + ')?\nNote: This will not delete any ACM linked to this map.'),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Cancel', style: new TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMap();
              }
            ),
          ],
        );
      }
    );
  }

  void _deleteMap() {
    // Remove from map group
    var initMapGroup = mapObj['mapgrouppath'];
    mapObj['mapgrouppath'] = null;
    updateMapGroups(initMapGroup, mapObj, map);

    // Remove ACM references
    Firestore.instance.document(DataManager.get().currentJobPath).collection('acm').where('mappath', isEqualTo: mapObj['path']).getDocuments().then((doc) {
      doc.documents.forEach((doc) {
        Firestore.instance.document(DataManager.get().currentJobPath).collection('acm').document(doc.documentID).setData({'mapname': null, 'mappath': null,}, merge: true);
      });
    });

    // Remove images
    if (mapObj['storage_ref'] != null) {
      FirebaseStorage.instance.ref().child(mapObj['storage_ref']).delete();
    }

    // Remove map
    Firestore.instance.document(DataManager.get().currentJobPath).collection('maps').document(mapObj['path']).delete();

    // Pop
    Navigator.pop(context);
  }

  buildBuildingMaterials (index) {
//      print("Building item: " + item.toString());
    var item = mapObj['buildingmaterials'][index];
    Widget widget = new Row(
      children: <Widget>[
        new Container(
          width: 100.0,
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(right: 14.0,),
//          child: new Text(item["label"], style: Styles.label,),
          child: TextFormField(
            style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            initialValue: item["label"],
            autocorrect: false,
            focusNode: _focusNodes[(index * 2) + 2],
            autovalidate: true,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (text) {
              print(text.toString());
              setState(() {
                mapObj['buildingmaterials'][index]["label"] = text.trim();
              });
              FocusScope.of(context).requestFocus(_focusNodes[(index * 2) + 3]);
            },
            validator: (String value) {
//              return value.contains('@') ? 'Do not use the @ character' : null;
            },
            onSaved: (text) {
              setState(() {
                mapObj['buildingmaterials'][index]["label"] = text.trim();
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
              setState(() {
                mapObj['buildingmaterials'][index]["material"] = text.trim();
              });
              if (mapObj['buildingmaterials'][index+1] != null && mapObj['buildingmaterials'][index+1]["label"].trim().length > 0) {
                FocusScope.of(context).requestFocus(_focusNodes[((index + 1) * 2) + 3]);
              } else {
                // If label field isn't filled in, go to it on Keyboard Next otherwise go to the next material
                FocusScope.of(context).requestFocus(_focusNodes[((index + 1) * 2) + 2]);
              }
              if (mapObj['buildingmaterials'].length < index + 2) {
                mapObj['buildingmaterials'] =
                new List<dynamic>.from(mapObj['buildingmaterials'])
                  ..addAll([{"label": "", "material": "",}]);
              }
            },
            validator: (String value) {
//              return value.contains('@') ? 'Do not use the @ character' : null;
            },
            onSaved: (text) {
              setState(() {
                mapObj['buildingmaterials'][index]["material"] = text.trim();
              });
            },
            textCapitalization: TextCapitalization.none,
          ),
        )
      ]
    );
    return widget;
  }

  void applyTemplate(mapObj) {
    this.setState(() {
      mapObj = mapObj;
    });
  }

  void _loadMap() async {
    print('map is ' + map.toString());
    // Load mapgroups from job
    mapgrouplist = [{"name": '-', "path": '',}];
    QuerySnapshot mapSnapshot = await Firestore.instance.document(DataManager.get().currentJobPath).collection('maps').where('maptype', isEqualTo: 'group').getDocuments();
    mapSnapshot.documents.forEach((doc) => mapgrouplist.add({"name": doc.data['name'],"path": doc.documentID}));
    print('ROOMGROUPLIST ' + mapgrouplist.toString());

//    print("Loading map");
    if (map == null) {
      _title = "Add New Map";
      mapObj['name'] = null;
      mapObj['path_local'] = null;
      mapObj['path_remote'] = null;
      mapObj['buildingmaterials'] = null;
      mapObj['maptype'] = 'orphan';

      setState(() {
        isLoading = false;
      });

    } else {
      print('Edit map is ' + map.toString());
      _title = "Edit Map";
      Firestore.instance.document(DataManager.get().currentJobPath)
          .collection('maps').document(map).get().then((doc) {
            // image
            if (doc.data['path_remote'] == null && doc.data['path_local'] != null){
              // only local image available (e.g. when taking photos with no internet)
              localPhoto = true;
              _handleImageUpload(File(doc.data['path_local']));
            } else if (doc.data['path_remote'] != null) {
              localPhoto = false;
            }
            setState(() {
              mapObj = doc.data;
              initMapGroup = doc.data['mapgrouppath'];
//              if (mapObj['mapgrouppath'] != null) _mapgroup = { "path": mapObj['mapgrouppath'], "name": mapObj['mapgroupname'] };
              if (doc.data["mapcode"] != null) controllerMapCode.text = doc.data["mapcode"];
              isLoading = false;
            });
      });
    }
    print(_title.toString());
  }

  void _handleImageUpload(File image) async {
    String path = widget.map;
    String mapgrouppath = mapObj['mapgrouppath'];
    String storageRef = mapObj['storage_ref'];

    updateMapCard(mapgrouppath, {'path_local': image.path, 'path': mapObj['path']});
    setState(() {
      mapObj["path_local"] = image.path;
    });
//    Firestore.instance.document(DataManager.get().currentJobPath)
//        .collection('maps').document(map).setData({"path_local": image.path},merge: true).then((_) {
//      setState((){});
//    });
    String mapgroup = mapObj["mapgroupname"];
    String name = mapObj["name"];
    String mapcode = mapObj["mapcode"];
    if (mapgroup == null) mapgroup = 'MapGroup';
    if (name == null) name = "Untitled";
    if (mapcode == null) mapcode = "RG-U";
    ImageSync(
        image,
        50,
        mapgroup + name + "(" + mapcode + ")",
        "jobs/" + DataManager.get().currentJobNumber,
        Firestore.instance.document(DataManager.get().currentJobPath)
            .collection('maps').document(map)
    ).then((refs) {
      // Delete old photo
      if (storageRef != null) FirebaseStorage.instance.ref().child(storageRef).delete();

      updateMapCard(mapgrouppath, {'path_remote': refs['downloadURL'], 'storage_ref': refs['storageRef'], 'path': mapObj['path']});
      if (this.mounted) {
        setState((){
          mapObj["path_remote"] = refs['downloadURL'];
          mapObj['storage_ref'] = refs['storageRef'];
          localPhoto = false;
        });
      } else {
        // User has left the page, upload url straight to firestore
        Firestore.instance.document(DataManager
            .get()
            .currentJobPath).collection('maps')
            .document(path)
            .setData(
            {"path_remote": refs['downloadURL'], "storage_ref": refs['storageRef'], }, merge: true);
      }
    });
  }
}

void updateMapGroups(String initMapGroup, Map<String, dynamic> mapObj, String map) {
  print("Update map groups " + initMapGroup.toString());
  if (mapObj['mapgrouppath'] != null) Firestore.instance.document(DataManager.get().currentJobPath).collection('maps').document(mapObj['mapgrouppath']).get().then((doc) {
    var initChildren = new List.from(doc.data['children']);
    print("Adding to map group: " + initChildren.toString());
    initChildren..addAll([{
      "name": mapObj['name'],
      "path": mapObj['path'],
      "path_local": mapObj['path_local'],
      "path_remote": mapObj['path_remote'],
    }]);
    Firestore.instance.document(DataManager.get().currentJobPath).collection('maps').document(mapObj['mapgrouppath']).setData({"children": initChildren}, merge: true);
  });
  if (initMapGroup != null) {
    // Remove from previous map group
    Firestore.instance.document(DataManager.get().currentJobPath).collection('maps').document(initMapGroup).get().then((doc) {
      var initChildren = doc.data['children'].where((child) => child['path'] != mapObj['path']).toList();
      print("Removing from map group " + initChildren.toString());
      Firestore.instance.document(DataManager.get().currentJobPath).collection('maps').document(initMapGroup).setData({"children": initChildren}, merge: true);
    });
  }
}

void updateMapCard(String mapgrouppath, Map<String, dynamic> updateObj) {
  if (mapgrouppath != null) Firestore.instance.document(DataManager.get().currentJobPath)
      .collection('maps').document(mapgrouppath).get().then((doc) {
    var list = new List.from(doc.data['children']).map((doc) {
      if (doc['path'] == updateObj['path']) {
        return {
          "name": updateObj['name'] != null ? updateObj['name'] : doc['name'],
          "path": updateObj['path'] != null ? updateObj['path'] : doc['path'],
          "path_remote": updateObj['path_remote'] != null ? updateObj['path_remote'] : doc['path_remote'],
          "path_local": updateObj['path_local'] != null ? updateObj['path_local'] : doc['path_local'],
        };
      } else {
        return doc;
      }
    }).toList();
    Firestore.instance.document(DataManager.get().currentJobPath)
        .collection('maps').document(mapgrouppath).setData({"children": list}, merge: true);
  });
}