import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/autocomplete.dart';
import 'package:k2e/widgets/custom_auto_complete.dart';
import 'package:k2e/widgets/customdialog.dart';

class DuplicateRoomsDialog extends StatefulWidget {
  DuplicateRoomsDialog({
    this.doc,
  }) : super();

  final DocumentSnapshot doc;
  @override
  _DuplicateRoomsDialogState createState() => new _DuplicateRoomsDialogState();
}

class _DuplicateRoomsDialogState extends State<DuplicateRoomsDialog> {
  // Room Duplication Vars
//  final controllerDuplicateRoomName = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _controllerDuplicateRoomName = TextEditingController();
  String _selectedRoomName;
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();
  List<String> rooms = AutoComplete.rooms.split(';');
  bool _duplicateBuildingMaterials = true;
  bool _duplicatePresumedMaterials = false;

  _handleDuplicateBuildingMaterialsCheck(bool newValue) {
    setState(() {
      _duplicateBuildingMaterials = newValue;
    });
  }

  _handleDuplicatePresumedMaterialsCheck(bool newValue) {
    setState(() {
      _duplicatePresumedMaterials = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new CustomAlertDialog(
        title: new Text("Duplicate Room"),
        content: new Container(
          height: 200.0,
          child: new Column(
            children: <Widget>[
              CheckboxListTile(
                title: Text("Duplicate building materials"),
                value: _duplicateBuildingMaterials,
                onChanged: _handleDuplicateBuildingMaterialsCheck,
              ),
              CheckboxListTile(
                  title: Text("Duplicate presumed ACM"),
                  value: _duplicatePresumedMaterials,
                  onChanged: _handleDuplicatePresumedMaterialsCheck
              ),
            ],
          ),),
        actions: <Widget>[
          new FlatButton(
            child: new Text("Cancel", style: new TextStyle(color: Colors.black),),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
          new FlatButton(
            child: new Text("Duplicate"),
            onPressed: () {
              // Check if name has been used
              print(widget.doc.data.toString());
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ]
    );
  }
}


void showValidationAlertDialog(context, title, content) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: new Text(title),
        content: new Text(content),
        actions: <Widget>[
          new FlatButton(
            child: new Text("Close"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void showRoomTemplateDialog(context, roomObj, applyTemplate) {
  var template = new Map<String,dynamic>();

  template = {
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
  };

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: new Text("Apply Room Template"),
        content: new Text("This will load a basic room template."),
        actions: <Widget>[
          new FlatButton(
            child: new Text("Cancel", style: new TextStyle(color: Colors.black),),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          new FlatButton(
            child: new Text("Apply",),
            onPressed: () {
              print(roomObj.toString());
              if (roomObj['buildingmaterials'] != null) {
                template['buildingmaterials'].forEach((item) =>
                roomObj['buildingmaterials'] =
                new List<dynamic>.from(roomObj['buildingmaterials'])
                  ..addAll([item]));
              } else {
                roomObj['buildingmaterials'] = new List<dynamic>.from(template['buildingmaterials']);
              }
              applyTemplate(roomObj);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}