import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/styles.dart';
import 'package:uuid/uuid.dart';

class SetUpJob extends StatefulWidget {
  SetUpJob({Key key, this.roomgroup}) : super(key: key);
  final String roomgroup;
  @override
  _SetUpJobState createState() => new _SetUpJobState();
}

class _SetUpJobState extends State<SetUpJob> {
  String _title = "Set Up Job";
  bool addAllOrphans = false;
  String templateName = '-';
  List roomGroupTemplates = DataManager.get().roomGroupTemplates;
  List roomTemplates = DataManager.get().roomTemplates;

//  Map<String, dynamic> roomObj = new Map<String, dynamic>();

  // images
//  String roomgroup;
//  bool localPhoto = false;
//
//  var _formKey = GlobalKey<FormState>();
//  final _focusNodes = List<FocusNode>.generate(
//    5,
//        (i) => FocusNode(),
//  );

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
                onPressed: templateName == '-'
                    ? null
                    : () {
//              if (_formKey.currentState.validate()) {
//                _formKey.currentState.save();
//                Firestore.instance.document(DataManager.get().currentJobPath).collection('rooms').document(roomObj['path']).setData(roomObj, merge: true);
//                if (addAllOrphans) addAllOrphansToGroup();
                        if (templateName != '-' &&
                            roomGroupTemplates.firstWhere((template) =>
                                    template['name'] ==
                                    templateName)['rooms'] !=
                                null) createRoomsFromTemplate();
                        Navigator.pop(context);
//              }
                      })
          ]),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Form(
//          key: _formKey,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: new EdgeInsets.all(8.0),
//                  padding: new EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 200.0),
            children: <Widget>[
              new Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(
                  top: 14.0,
                ),
                child: new Text(
                  "Create Rooms from Template",
                  style: Styles.label,
                ),
              ),
              // TODO Change from dropdown to just a list view
              new DropdownButton<String>(
                  value: templateName,
                  iconSize: 24.0,
                  items: roomGroupTemplates.map((item) {
                    return new DropdownMenuItem<String>(
                      value: item["name"],
                      child: new Text(item["name"]),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      templateName = value;
                    });
                  }),
            ],
          ),
        ),
      ),
    );
  }

  void createRoomsFromTemplate() {
//    print ('Creating rooms from template ' + templateName);
    var template = roomGroupTemplates
        .firstWhere((template) => template['name'] == templateName);
//    print(template.toString());
    if (template == null || template['rooms'] == null) return;
//    print(template['rooms'].length.toString());
//    var childList = new List(template['rooms'].length);
//    var index = 0;
    template['rooms'].forEach((room) {
      var newRoom = {
        'name': room['name'],
        'path_local': null,
        'path_remote': null,
        'buildingmaterials': roomTemplates.firstWhere((template) =>
            template['name'] == room['template'])['buildingmaterials'],
        'roomtype': 'orphan',
//        'roomgroupname': roomObj['name'],
//        'roomgrouppath': roomObj['path'],
        'path': new Uuid().v1(),
      };
      Firestore.instance
          .document(DataManager.get().currentJobPath)
          .collection('rooms')
          .document(newRoom['path'])
          .setData(newRoom, merge: true);
//      childList[index] = {
//        'name': newRoom['name'],
//        'path': newRoom['path'],
//        'path_local': null,
//        'path_remote': null,
//      };

      // Add ACM if present
      if (room['acm'] != null) {
        room['acm'].forEach((acm) {
          var newAcm = {
            'description': acm['description'],
            'material': acm['material'],
            'roomname': room['name'],
            'roompath': newRoom['path'],
            'jobNumber': DataManager.get().currentJobNumber,
          };
          Firestore.instance
              .document(DataManager.get().currentJobPath)
              .collection('acm')
              .add(newAcm);
        });
      }
//      if (index == template['rooms'].length-1) {
//        if (roomObj['children'].length > 0) {
//          childList = new List.from(roomObj['children'])
//            ..addAll(childList);
//        }     sz
//        print(childList.toString());
//        Firestore.instance.document(DataManager
//            .get()
//            .currentJobPath).collection('rooms')
//            .document(roomObj['path'])
//            .setData({'children': childList}, merge: true);
//      }
//      index = index + 1;
    });
  }
}
