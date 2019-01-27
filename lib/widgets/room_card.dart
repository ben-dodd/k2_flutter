import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/pages/my_jobs/tasks/rooms/edit_room.dart';
import 'package:k2e/styles.dart';

class RoomCard extends StatefulWidget {

  RoomCard({
    @required this.doc,
    @required this.context,
    this.onCardClick,
    this.onCardLongPress,
  });

  final Map<String, dynamic> doc;
  final BuildContext context;
  final VoidCallback onCardClick;
  final VoidCallback onCardLongPress;

  @override
  _RoomCardState createState() => new _RoomCardState();

}

class _RoomCardState extends State<RoomCard>{
  String name;

  bool hasPhoto;
  bool photoSynced;

  Widget _roomCard(Map<String, dynamic> doc) {
    // todo is there a better way to assert this stuff
    if (doc['name'] == null) {
      name = 'No name';
    } else {
      name = doc['name'];
    }

    if (doc['path_local'] == null && doc['path_remote'] == null) {
      hasPhoto = false;
    } else {
      hasPhoto = true;
      if (doc['path_remote'] == null) {
        photoSynced = false;
      } else {
        photoSynced = true;
      }
    }

    if (doc['children'] == null) return new ListTile(
//        contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
//      leading: const Icon(Icons.whatshot),
        title: Text(name),
//        subtitle: Text(notes),

        // Tap -> go through to job task
        onTap: () async {
          print(doc.toString());
          print(widget.context.toString());
          print(doc['path']);
          Navigator.of(widget.context).push(
            new MaterialPageRoute(builder: (context) => EditRoom(room: doc['path'])),
          );
        },
        // Long tap -> add options to sync or delete
        onLongPress: widget.onCardLongPress,
        trailing:
        hasPhoto ? photoSynced ? Icon(Icons.camera_alt, color: Colors.green,)
            : Icon(Icons.camera_alt, color: Colors.orange)
            : Icon(Icons.camera_alt, color: Colors.red)
    );

    if (doc['children'].length == 0) return new ListTile(
      title: Text(doc['name'], style: new TextStyle(
//          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold),
      )
    );

    return ExpansionTile(
      initiallyExpanded: true,
      key: PageStorageKey<Map<String, dynamic>>(doc),
      title: Text(doc['name'], style: new TextStyle(
//          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold
      ),),
      children: doc['children'].length > 0 ? doc['children']
          .map<Widget>((child) {
            print(child.toString());
            // Start streams here?
            return _roomCard(new Map<String,dynamic>.from(child));
      })
          .toList() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _roomCard(widget.doc);
  }
}