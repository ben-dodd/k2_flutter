import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RoomCard extends StatefulWidget {

  RoomCard({
    this.doc,
    @required this.onCardClick,
    @required this.onCardLongPress,
  });

  final DocumentSnapshot doc;
  final VoidCallback onCardClick;
  final VoidCallback onCardLongPress;

  @override
  _RoomCardState createState() => new _RoomCardState();

}

class _RoomCardState extends State<RoomCard>{
  String name;

  bool hasPhoto;
  bool photoSynced;
  @override
  Widget build(BuildContext context) {
    // todo is there a better way to assert this stuff
    if (widget.doc['name'] == null) {
      name = 'No name';
    } else {
      name = widget.doc['name'];
    }

    if (widget.doc['path_local'] == null && widget.doc['path_remote'] == null) {
      hasPhoto = false;
    } else {
      hasPhoto = true;
      if (widget.doc['path_remote'] == null) {
        photoSynced = false;
      } else {
        photoSynced = true;
      }
    }


    return new ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
//      leading: const Icon(Icons.whatshot),
        title: Text(name),
//        subtitle: Text(notes),

        // Tap -> go through to job task
        onTap: widget.onCardClick,
        // Long tap -> add options to sync or delete
        onLongPress: widget.onCardLongPress,
        trailing:
        hasPhoto ? photoSynced ? Icon(Icons.camera_alt, color: Colors.green,)
            : Icon(Icons.camera_alt, color: Colors.orange)
            : Icon(Icons.camera_alt, color: Colors.red)
    );
  }
}