import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/styles.dart';
import 'package:k2e/widgets/loading.dart';

class EditRoomGroup extends StatefulWidget {
  EditRoomGroup({Key key, this.roomgroup}) : super(key: key);
  final String roomgroup;
  @override
  _EditRoomGroupState createState() => new _EditRoomGroupState();
}

class _EditRoomGroupState extends State<EditRoomGroup> {
  String _title = "Edit Room Group";
  bool isLoading = true;
  bool addAllOrphans = false;
  String templateName = '-';

  List templates = [
    {'name': '-'},
    {
      'name': 'Management: 3 Bedroom House',
      'rooms': [
        { 'name': 'Kitchen', 'template': 'Kitchen', },
        { 'name': 'Lounge', 'template': 'Lounge', },
        { 'name': 'Dining Room', 'template': 'Basic', },
        { 'name': 'Hallway', 'template': 'Hallway', },
        { 'name': 'Bathroom', 'template': 'Bathroom/Toilet', },
        { 'name': 'Toilet', 'template': 'Bathroom/Toilet', },
        { 'name': 'Laundry', 'template': 'Bathroom/Toilet', },
        { 'name': 'Bedroom 1', 'template': 'Basic', },
        { 'name': 'Bedroom 2', 'template': 'Basic', },
        { 'name': 'Bedroom 3', 'template': 'Basic', },
        { 'name': 'Ceiling Space', 'template': 'Basic', 'acm': [
          {'description': 'Surfaces', 'material': 'dust', }
        ]},
        { 'name': 'Exterior', 'template': 'Basic', },
        { 'name': 'Garage', 'template': 'Basic', },
        { 'name': 'Shed', 'template': 'Basic', },
      ],
    },
    {
      'name': 'Demolition: 3 Bedroom House',
      'rooms': [
        { 'name': 'Kitchen', 'template': 'Kitchen', },
        { 'name': 'HWC', 'template': 'Basic', },
        { 'name': 'Lounge', 'template': 'Lounge', },
        { 'name': 'Fireplace', 'template': 'Basic', },
        { 'name': 'Dining Room', 'template': 'Basic', },
        { 'name': 'Hallway', 'template': 'Hallway', },
        { 'name': 'Fuse Board', 'template': 'Basic', },
        { 'name': 'Bathroom', 'template': 'Bathroom/Toilet', },
        { 'name': 'Toilet', 'template': 'Bathroom/Toilet', },
        { 'name': 'Laundry', 'template': 'Bathroom/Toilet', },
        { 'name': 'Bedroom 1', 'template': 'Basic', },
        { 'name': 'Bedroom 2', 'template': 'Basic', },
        { 'name': 'Bedroom 3', 'template': 'Basic', },
        { 'name': 'Ceiling Space', 'template': 'Basic', 'acm': [
          {'description': 'Surfaces', 'material': 'dust', }
        ]},
        { 'name': 'Exterior', 'template': 'Basic', 'acm': [
          { 'description': 'Soil', 'material': 'soil', }
        ]},
        { 'name': 'Garage', 'template': 'Basic', },
        { 'name': 'Shed', 'template': 'Basic', },
      ],
    },
    {'name': 'Locomotive Type DC'},
    {'name': 'Locomotive Type DCP'},
    {'name': 'Locomotive Type DFM'},
    {'name': 'Locomotive Type DFT'},
    {'name': 'Locomotive Type DH'},
    {'name': 'Locomotive Type DSC'},
    {'name': 'Locomotive Type DXB'},
    {'name': 'Locomotive Type EF'},
    {'name': 'Electrical Substation'},
  ];

  List roomTemplates = [
    {
      "name": "Basic",
      "buildingmaterials": [
        {
          "label": "Ceiling",
          "material": "",
        },
        {
          "label": "Walls",
          "material": "",
        },
        {
          "label": "Floor",
          "material": "",
        },
      ],
    },
    {
      "name": "Hallway",
      "buildingmaterials": [
        {
          "label": "Ceiling",
          "material": "",
        },
        {
          "label": "Walls",
          "material": "",
        },
        {
          "label": "Fuse board",
          "material": "",
        },
        {
          "label": "Hot water cylinder",
          "material": "",
        },
        {
          "label": "Entry floor",
          "material": "",
        },
        {
          "label": "Floor",
          "material": "",
        },
      ],
    },
    {
      "name": "Kitchen",
      "buildingmaterials": [
        {
          "label": "Ceiling",
          "material": "",
        },
        {
          "label": "Walls",
          "material": "",
        },
        {
          "label": "Rangehood",
          "material": "",
        },
        {
          "label": "Hot Water Cylinder",
          "material": "",
        },
        {
          "label": "Bench",
          "material": "",
        },
        {
          "label": "Splashback",
          "material": "",
        },
        {
          "label": "Sink",
          "material": "",
        },
        {
          "label": "Pipework",
          "material": "",
        },
        {
          "label": "Sink",
          "material": "",
        },
        {
          "label": "Floor",
          "material": "",
        },
      ],
    },
    {
      "name": "Lounge",
      "buildingmaterials": [
        {
          "label": "Ceiling",
          "material": "",
        },
        {
          "label": "Walls",
          "material": "",
        },
        {
          "label": "Fireplace",
          "material": "",
        },
        {
          "label": "Heat pump",
          "material": "",
        },
        {
          "label": "Floor",
          "material": "",
        },
      ],
    },
    {
      "name": "Bathroom/Toilet",
      "buildingmaterials": [
        {
          "label": "Ceiling",
          "material": "",
        },
        {
          "label": "Walls",
          "material": "",
        },
        {
          "label": "Bath surround",
          "material": "",
        },
        {
          "label": "Bath",
          "material": "",
        },
        {
          "label": "Toilet",
          "material": "",
        },
        {
          "label": "Pipework",
          "material": "",
        },
        {
          "label": "Floor",
          "material": "",
        },
      ],
    },
  ];

  Map<String, dynamic> roomObj = new Map<String, dynamic>();

  // images
  String roomgroup;
  bool localPhoto = false;

  var _formKey = GlobalKey<FormState>();
  final _focusNodes = List<FocusNode>.generate(
    5,
        (i) => FocusNode(),
  );

  @override
  void initState() {
    roomgroup = widget.roomgroup;
    _loadRoom();
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
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                if (roomObj['path'] == null) {
                  Firestore.instance.document(DataManager.get().currentJobPath).collection('rooms').add(roomObj).then((doc) {
                    roomObj['path'] = doc.documentID;
                    Firestore.instance.document(DataManager.get().currentJobPath).collection('rooms').document(doc.documentID).setData({ 'path': doc.documentID }, merge: true);
                    if (addAllOrphans) addAllOrphansToGroup();
                    if (templateName != '-' && templates.firstWhere((template) => template['name'] == templateName)['rooms'] != null) createRoomsFromTemplate();
                  });
                } else {
                  Firestore.instance.document(DataManager.get().currentJobPath).collection('rooms').document(roomgroup).setData(
                      roomObj, merge: true);
                  if (addAllOrphans) addAllOrphansToGroup();
                }
                Navigator.pop(context);
              }
            })
          ]
      ),
      body: isLoading ?
      loadingPage(loadingText: 'Loading room group info...')
          : GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Form(
          key: _formKey,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: new EdgeInsets.all(8.0),
//                  padding: new EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 200.0),
            children: <Widget>[
              new Container(
                child: new TextFormField(
                  decoration: new InputDecoration(
                    labelText: "Room Group Name",
                  ),
                  onSaved: (String value) {
                    roomObj["name"] = value.trim();
                  },
                  validator: (String value) {
                    return value.isEmpty ? 'You must add a name' : null;
                  },
                  focusNode: _focusNodes[0],
                  initialValue: roomObj["name"],
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  onFieldSubmitted: (v) {
                    FocusScope.of(context).requestFocus(_focusNodes[1]);
                  },
                ),
              ),
              new Container(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Room Group Prefix",
                    hintText: "e.g. 1 for Level 1, B for Basement",
                  ),
                  autocorrect: false,
                  onSaved: (String value) {
                    roomObj["roomcode"] = value.trim();
                  },
                  initialValue: roomObj["roomcode"],
                  focusNode: _focusNodes[1],
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
              // TODO Add in templates
              // Add in type of survey etc.
              new Container(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Notes",
                  ),
                  autocorrect: false,
                  onSaved: (String value) {
                    roomObj["notes"] = value.trim();
                  },
                  initialValue: roomObj["notes"],
                  focusNode: _focusNodes[2],
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              new Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(top: 14.0,),
                child: new Text("Add All Ungrouped Rooms", style: Styles.label,),
              ),
              new Container(
                alignment: Alignment.topLeft,
                child: Checkbox(value: addAllOrphans, onChanged: (value) => setState(() {
                  addAllOrphans = value;
                }))
              ),
              new Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(top: 14.0,),
                child: new Text("Create Rooms from Template", style: Styles.label,),
              ),
              new DropdownButton<String>(
                value: templateName,
                iconSize: 24.0,
                items: templates.map((item) {
                  return new DropdownMenuItem<String>(
                    value: item["name"],
                    child: new Text(item["name"]),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    print(value);
                    templateName = value;
                  });
                }
            ),
            widget.roomgroup != null ?
              new Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 14.0,),
                child: new OutlineButton(
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                    child: Text("Delete Room Group",
                        style: new TextStyle(color: Theme.of(context).accentColor, fontWeight: FontWeight.bold
                        )
                    ),
//                          color: Colors.white,
                    onPressed: () {
                      _deleteDialog();
                    }
                ),
              )
              :
              new Container(),
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
            title: new Text('Delete Room'),
            content: new Text('Are you sure you wish to delete this room group (' + roomObj['name'] + ')?\nNote: All rooms linked to this room will be orphaned.'),
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
                    _deleteRoomGroup();
                  }
              ),
            ],
          );
        }
    );
  }

  void _deleteRoomGroup() {
    // Remove room references
    Firestore.instance.document(DataManager.get().currentJobPath).collection('rooms').where('roomgrouppath', isEqualTo: widget.roomgroup).getDocuments().then((doc) {
      doc.documents.forEach((doc) {
        Firestore.instance.document(DataManager.get().currentJobPath).collection('rooms').document(doc.documentID).setData({'roomgroupname': null, 'roomgrouppath': null, 'roomtype': 'orphan'}, merge: true);
      });
    });

    // Remove room
    Firestore.instance.document(DataManager.get().currentJobPath).collection('rooms').document(widget.roomgroup).delete();

    // Pop
    Navigator.pop(context);
  }

  void _loadRoom() async {
    if (roomgroup == null) {
      _title = "Add New Group";
      roomObj['name'] = null;
      roomObj['children'] = new List();
      roomObj['roomtype'] = 'group';
      isLoading = false;
    } else {
      _title = "Edit Room Group";
      Firestore.instance.document(DataManager
          .get()
          .currentJobPath)
          .collection('rooms').document(roomgroup).get().then((doc) {
        setState(() {
          roomObj = doc.data;
          isLoading = false;
        });
      });
    }
  }

  void createRoomsFromTemplate() {
    print ('Creating rooms from template ' + templateName);
    var template = templates.firstWhere((template) => template['name'] == templateName);
    print(template.toString());
    if (template == null || template['rooms'] == null) return;
    print(template['rooms'].length.toString());
    var childList = new List(template['rooms'].length);
    var index = 0;
    template['rooms'].forEach((room) {
      var newRoom = {
        'name': room['name'],
        'path_local': null,
        'path_remote': null,
        'buildingmaterials': roomTemplates.firstWhere((template) => template['name'] == room['template'])['buildingmaterials'],
        'roomtype': null,
        'roomgroupname': roomObj['name'],
        'roomgrouppath': roomObj['path'],
      };
      Firestore.instance.document(DataManager.get().currentJobPath).collection('rooms').add(newRoom).then((doc) {
        childList[index] = {
          'name': room['name'],
          'path': doc.documentID,
          'path_local': null,
          'path_remote': null,
        };
        // Add ACM if present
        if (room['acm'] != null) {
          room['acm'].forEach((acm) {
            var newAcm = {
              'description': acm['description'],
              'material': acm['material'],
              'roomname': room['name'],
              'roompath': doc.documentID,
              'jobnumber': DataManager.get().currentJobNumber,
            };
            Firestore.instance.document(DataManager.get().currentJobPath).collection('acm').add(newAcm);
          });
        }

        print(childList[index].toString());
        Firestore.instance.document(DataManager.get().currentJobPath).collection('rooms').document(doc.documentID).setData({'path': doc.documentID}, merge: true);
        if (index == template['rooms'].length-1) {
          if (roomObj['children'].length > 0) {
            // TODO this should be a new LIST!
            childList = new List.from(roomObj['children'])
              ..addAll(childList);
          }
          print(childList.toString());
          Firestore.instance.document(DataManager
              .get()
              .currentJobPath).collection('rooms')
              .document(roomObj['path'])
              .setData({'children': childList}, merge: true);
        }
        index = index + 1;
      });
    });
  }

  void addAllOrphansToGroup() {
    print ('Adding orphans to ' + roomObj.toString());
    Firestore.instance.document(DataManager.get().currentJobPath).collection('rooms').where('roomtype', isEqualTo: 'orphan').getDocuments().then((documents) {
      print ('Orphans are ' + documents.documents.toString());
      var childList = new List(documents.documents.length);
      var index = 0;
      documents.documents.forEach((doc) {
        print ('Orphans are ' + doc.data.toString());
        // Add room group to room
        Firestore.instance.document(DataManager.get().currentJobPath).collection('rooms').document(doc.documentID).setData(
            { 'roomgroupname': roomObj['name'],
              'roomgrouppath': roomObj['path'],
              'roomtype': null }, merge: true);

        // Add room to room group
        childList[index] = {
          'name': doc.data['name'],
          'path': doc.documentID,
          'path_local': doc.data['path_local'],
          'path_remote': doc.data['path_remote'],
        };
        index = index + 1;
      });
      if (roomObj['children'].length > 0) {
        childList = roomObj['children']..addAll(childList);
      }
      print(childList.toString());
      Firestore.instance.document(DataManager.get().currentJobPath).collection('rooms').document(roomObj['path']).setData({'children': childList}, merge: true);
    });
  }
}
