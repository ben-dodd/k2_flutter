import 'package:flutter/material.dart';
import 'package:k2e/pages/my_jobs/tasks/rooms/edit_room.dart';
import 'package:k2e/pages/my_jobs/tasks/rooms/edit_room_group.dart';
import 'package:k2e/theme.dart';
import 'package:uuid/uuid.dart';

class RoomCard extends StatefulWidget {
  RoomCard({
    @required this.doc,
    @required this.context,
    this.onCardClick,
//    this.onCardLongPress,
  });

  final Map<String, dynamic> doc;
  final BuildContext context;
  final VoidCallback onCardClick;
//  final VoidCallback onCardLongPress;

  @override
  _RoomCardState createState() => new _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
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

    if (doc['children'] == null)
      return new ListTile(
//        contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
//      leading: const Icon(Icons.whatshot),
          title: Text(name),
//        subtitle: Text(notes),

          // Tap -> go through to job task
          onTap: () async {
            Navigator.of(widget.context).push(
              new MaterialPageRoute(
                  builder: (context) => EditRoom(room: doc['path'])),
            );
          },
          // Long tap -> add options to sync or delete
//        onLongPress: widget.onCardLongPress,
          trailing: hasPhoto
              ? photoSynced
                  ? Icon(
                      Icons.camera_alt,
                      color: CompanyColors.checkYes,
                    )
                  : Icon(Icons.camera_alt, color: CompanyColors.checkMaybe)
              : Icon(Icons.camera_alt, color: CompanyColors.checkNo));

    if (doc['children'].length == 0)
      return new ListTile(
          title: Text(
        doc['name'],
        style: new TextStyle(
//          fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold),
      ));

    return ExpansionTile(
      initiallyExpanded: true,
      key: PageStorageKey(new Uuid().v1),
      title: Text(
        doc['name'],
        style: new TextStyle(
//          fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold),
      ),
      trailing: new IconButton(
          icon: new Icon(Icons.edit),
          onPressed: () {
            Navigator.of(widget.context).push(
              new MaterialPageRoute(
                  builder: (context) => EditRoomGroup(roomgroup: doc['path'])),
            );
          }),
      children: doc['children'].length > 0
          ?
//          [ new DragAndDropList(
//            doc['children'].length,
//            itemBuilder: (BuildContext context, index) {
//              return _roomCard(new Map<String,dynamic>.from(doc['children'][index]));
//            },
//            onDragFinish: (before, after) {
//              List newList = new List.from(doc['children']);
//              newList.removeAt(before);
//              newList.insert(after, doc['children'][before]);
//              print(newList.toString());
//              Firestore.instance.document(DataManager.get().currentJobPath).collection('rooms').document(doc['path']).setData({'children': newList,}, merge: true);
//              print('before: ' + before.toString());
//              print('after: ' + after.toString());
//            },
//            canDrag: (index) => true,
//            canBeDraggedTo: (one, two) => true,
//            dragElevation: 8.0,
//          )]
          doc['children'].map<Widget>((child) {
              // Start streams here?
              return _roomCard(new Map<String, dynamic>.from(child));
            }).toList()
          : [new Container()],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _roomCard(widget.doc);
  }
}
