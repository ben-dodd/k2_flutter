import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/styles.dart';
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
  String selected = 'Blank Rows';
  var templates = DataManager.get().roomTemplates;

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
          items: templates.map((item) {
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

void showDeleteRoomGroupDialog(context, roomObj, deleteRoomGroup) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return DeleteRoomGroupDialog(roomObj: roomObj, deleteRoomGroup: deleteRoomGroup);
    },
  );
}

class DeleteRoomGroupDialog extends StatefulWidget {
  DeleteRoomGroupDialog({
    this.roomObj,
    this.deleteRoomGroup,
  }) : super();

  final roomObj;
  final deleteRoomGroup;

  @override
  _DeleteRoomGroupDialogState createState() => new _DeleteRoomGroupDialogState();
}

class _DeleteRoomGroupDialogState extends State<DeleteRoomGroupDialog> {

  bool deleteRooms = false;
  bool deleteAcm = false;

  @override
  void initState() {
//    selected = "Basic";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text('Delete Room'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget> [
          new Text('Are you sure you wish to delete this room group (' + widget.roomObj['name'] + ')?'),
          new Row(children: <Widget> [
            new Container(
              alignment: Alignment.topLeft,
              child: Checkbox(value: deleteRooms,
                  onChanged: (value) => setState(() {
                    deleteRooms = value;
                  })),
            ),
            new Container(
              alignment: Alignment.topLeft,
              child: new Text("Delete Rooms in Group", style: Styles.label,),
            ),
          ]),
          new Row(children: <Widget> [
            new Container(
              alignment: Alignment.topLeft,
              child: Checkbox(value: deleteAcm,
                onChanged: (value) => deleteRooms ? setState(() {
                  deleteAcm = !deleteAcm;
                }) : null,
              ),
            ),
            new Container(
              alignment: Alignment.topLeft,
              child: new Text("Delete ACM in Rooms", style: Styles.label,),
            ),
          ]),
        ],),
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
              widget.deleteRoomGroup(deleteRooms, deleteAcm);
            }
        ),
      ],
    );
  }
}