import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/pages/my_jobs/tasks/map/map_painter.dart';
import 'package:k2e/utils/camera.dart';
import 'package:k2e/widgets/common_widgets.dart';
import 'package:location/location.dart';
import 'package:k2e/utils/firebase_conversion_functions.dart';
import 'package:uuid/uuid.dart';

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
  Map<String, dynamic> mapObj = new Map<String, dynamic>();

  // images
  String map;
  bool localPhoto = false;
  List<Map<String, String>> mapgrouplist = new List();

  List<List<Offset>> paths = new List<List<Offset>>();
  List<Offset> offsetPoints; //List of points in one Tap or ery point o

  // Location
  var location = new Location();
  double latitude;
  double longitude;
  double initLatitude;
  double initLongitude;

  final controllerMapCode = TextEditingController();

  var _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    map = widget.map;
//    controllerMapCode.addListener(_updateMapCode);
    _loadMap();
    location.getLocation().then((location) {
      setState(() {
        initLatitude = location.latitude;
        initLongitude = location.longitude;
      });
    });
    location.onLocationChanged().listen((LocationData currentLocation) {
      setState(() {
        latitude = currentLocation.latitude;
        longitude = currentLocation.longitude;
      });
    });
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
//                if (_formKey.currentState.validate()){
//                  _formKey.currentState.save();
                  if (paths.length > 0) {
                    // Convert List of Lists of Offsets into a format Firebase can store
                    // Firebase can't do Lists of Lists
                    mapObj['paths'] = convertListListOffsetToFirestore(paths);
                  }

                  Firestore.instance
                      .document(DataManager.get().currentJobPath)
                      .collection('maps')
                      .document(mapObj['path'])
                      .setData(mapObj, merge: true);
                  Navigator.pop(context);
//                }
                })
          ]),
      body: isLoading
          ? LoadingPage(loadingText: 'Loading map info...')
          : Container(
              child: MapPainter(
              pathColour: Colors.black,
              paths: paths,
              photo: null,
              surveyorPos: {
                'latitude': latitude,
                'longitude': longitude,
                'initLatitude': initLatitude,
                'initLongitude': initLongitude,
              },
              updatePaths: (List<Offset> points) {
                setState(() {
                  offsetPoints = points;
                  paths.add(offsetPoints);
                });
              },
              updatePoints: (List<Offset> points) {
                setState(() {
                  offsetPoints = points;
                });
              },
            )),
    );
  }

  void _loadMap() async {
    print('map is ' + map.toString());
    // Load mapgroups from job
    mapgrouplist = [
      {
        "name": '-',
        "path": '',
      }
    ];
    QuerySnapshot mapSnapshot = await Firestore.instance
        .document(DataManager.get().currentJobPath)
        .collection('maps')
        .where('maptype', isEqualTo: 'group')
        .getDocuments();
    mapSnapshot.documents.forEach((doc) =>
        mapgrouplist.add({"name": doc.data['name'], "path": doc.documentID}));
    print('ROOMGROUPLIST ' + mapgrouplist.toString());

//    print("Loading map");
    if (map == null) {
      _title = "Add New Map";
      mapObj['name'] = null;
      mapObj['path_local'] = null;
      mapObj['path_remote'] = null;
      mapObj['maptype'] = 'orphan';
      mapObj['path'] = new Uuid().v1();
      mapObj['paths'] = new List<List<Offset>>();

      setState(() {
        isLoading = false;
      });
    } else {
      print('Edit map is ' + map.toString());
      _title = "Edit Map";
      Firestore.instance
          .document(DataManager.get().currentJobPath)
          .collection('maps')
          .document(map)
          .get()
          .then((doc) {
        // image
        mapObj = doc.data;
        if (mapObj['paths'] != null)
          paths = convertFirestoreToListListOffset(mapObj['paths']);
        else
          paths = new List<List<Offset>>();

        if (mapObj['path_remote'] == null && mapObj['path_local'] != null) {
          // only local image available (e.g. when taking photos with no internet)
          localPhoto = true;
          _handleImageUpload(File(mapObj['path_local']));
        } else if (mapObj['path_remote'] != null) {
          localPhoto = false;
        }
        setState(() {
          mapObj = mapObj;
          initMapGroup = mapObj['mapgrouppath'];
//              if (mapObj['mapgrouppath'] != null) _mapgroup = { "path": mapObj['mapgrouppath'], "name": mapObj['mapgroupname'] };
          if (mapObj["mapcode"] != null)
            controllerMapCode.text = mapObj["mapcode"];
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

    updateMapCard(
        mapgrouppath, {'path_local': image.path, 'path': mapObj['path']});
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
            "map_" + mapObj['path'],
            "jobs/" + DataManager.get().currentJobNumber,
            Firestore.instance
                .document(DataManager.get().currentJobPath)
                .collection('maps')
                .document(map))
        .then((refs) {
      // Delete old photo
      if (storageRef != null)
        FirebaseStorage.instance.ref().child(storageRef).delete();

      updateMapCard(mapgrouppath, {
        'path_remote': refs['downloadURL'],
        'storage_ref': refs['storageRef'],
        'path': mapObj['path']
      });
      if (this.mounted) {
        setState(() {
          mapObj["path_remote"] = refs['downloadURL'];
          mapObj['storage_ref'] = refs['storageRef'];
          localPhoto = false;
        });
      } else {
        // User has left the page, upload url straight to firestore
        Firestore.instance
            .document(DataManager.get().currentJobPath)
            .collection('maps')
            .document(path)
            .setData({
          "path_remote": refs['downloadURL'],
          "storage_ref": refs['storageRef'],
        }, merge: true);
      }
    });
  }
}

void updateMapGroups(
    String initMapGroup, Map<String, dynamic> mapObj, String map) {
  print("Update map groups " + initMapGroup.toString());
  if (mapObj['mapgrouppath'] != null)
    Firestore.instance
        .document(DataManager.get().currentJobPath)
        .collection('maps')
        .document(mapObj['mapgrouppath'])
        .get()
        .then((doc) {
      var initChildren = new List.from(doc.data['children']);
      print("Adding to map group: " + initChildren.toString());
      initChildren
        ..addAll([
          {
            "name": mapObj['name'],
            "path": mapObj['path'],
            "path_local": mapObj['path_local'],
            "path_remote": mapObj['path_remote'],
          }
        ]);
      Firestore.instance
          .document(DataManager.get().currentJobPath)
          .collection('maps')
          .document(mapObj['mapgrouppath'])
          .setData({"children": initChildren}, merge: true);
    });
  if (initMapGroup != null) {
    // Remove from previous map group
    Firestore.instance
        .document(DataManager.get().currentJobPath)
        .collection('maps')
        .document(initMapGroup)
        .get()
        .then((doc) {
      var initChildren = doc.data['children']
          .where((child) => child['path'] != mapObj['path'])
          .toList();
      print("Removing from map group " + initChildren.toString());
      Firestore.instance
          .document(DataManager.get().currentJobPath)
          .collection('maps')
          .document(initMapGroup)
          .setData({"children": initChildren}, merge: true);
    });
  }
}

void updateMapCard(String mapgrouppath, Map<String, dynamic> updateObj) {
  if (mapgrouppath != null)
    Firestore.instance
        .document(DataManager.get().currentJobPath)
        .collection('maps')
        .document(mapgrouppath)
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
          .collection('maps')
          .document(mapgrouppath)
          .setData({"children": list}, merge: true);
    });
}
