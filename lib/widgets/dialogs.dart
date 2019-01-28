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
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return RoomTemplateDialog(roomObj: roomObj, applyTemplate: applyTemplate);
    },
  );
}

class RoomTemplateDialog extends StatefulWidget {
  RoomTemplateDialog({
    this.roomObj,
    this.applyTemplate,
  }) : super();

  final roomObj;
  final applyTemplate;

  @override
  _RoomTemplateDialogState createState() => new _RoomTemplateDialogState();
}

class _RoomTemplateDialogState extends State<RoomTemplateDialog> {
  String selected;
  var templates = [
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

  @override
  void initState() {
//    selected = "Basic";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text("Apply Room Template"),
      content: new DropdownButton<String>(
          value: selected,
          iconSize: 24.0,
          items: templates.map((Map<String, dynamic> item) {
            return new DropdownMenuItem<String>(
              value: item["name"],
              child: new Text(item["name"]),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              print(value);
              selected = value;
              print(selected.toString());
            });
          }
      ),
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
            List<Map<String,String>> buildingmaterials = templates.firstWhere((item) => item["name"] == selected)["buildingmaterials"];
            print(widget.roomObj.toString());
            if (widget.roomObj['buildingmaterials'] != null) {
              buildingmaterials.forEach((item) =>
              widget.roomObj['buildingmaterials'] =
              new List<dynamic>.from(widget.roomObj['buildingmaterials'])
                ..addAll([item]));
            } else {
              widget.roomObj['buildingmaterials'] =
              new List<dynamic>.from(buildingmaterials);
            }
            widget.applyTemplate(widget.roomObj);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}