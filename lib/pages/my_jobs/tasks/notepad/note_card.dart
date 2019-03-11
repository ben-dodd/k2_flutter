import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/theme.dart';

class NoteCard extends StatefulWidget {
  NoteCard({
    this.note,
    @required this.onCardClick,
//    @required this.onCardLongPress,
  });

  final DocumentSnapshot note;
  final VoidCallback onCardClick;
//  final VoidCallback onCardLongPress;

  @override
  _NoteCardState createState() => new _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  String title;
  String note;

  bool hasPhoto;
  bool photoSynced;
  @override
  Widget build(BuildContext context) {
    // todo is there a better way to assert this stuff
    if (widget.note['title'] == null || widget.note['title'] == '') {
      title = 'Untitled';
    } else {
      title = widget.note['title'];
    }
    if (widget.note['note'] == null) {
      note = '';
    } else {
      note = widget.note['note'];
    }

    if (widget.note['path_local'] == null &&
        widget.note['path_remote'] == null) {
      hasPhoto = false;
    } else {
      hasPhoto = true;
      if (widget.note['path_remote'] == null) {
        photoSynced = false;
      } else {
        photoSynced = true;
      }
    }

    return Container(
//      margin: EdgeInsets.symmetric(vertical: 4.0),
      padding: EdgeInsets.fromLTRB(8.0, 0.0, 4.0, 0.0),
      decoration: new BoxDecoration(
        color: Colors.white,
      ),
      child: new ListTile(
          dense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
          leading: new Container(
              width: 40.0,
              padding: EdgeInsets.all(0.0),
              margin: EdgeInsets.all(0.0),
              alignment: Alignment.center,
              child: Icon(Icons.create)),
          title: Text(title),
          subtitle: Text(
            note,
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),

          // Tap -> go through to job task
          onTap: widget.onCardClick,
          // Long tap -> add options to sync or delete
//        onLongPress: widget.onCardLongPress,
          // TODO: Icons display whether sample has photo or not
          trailing: hasPhoto
              ? photoSynced
                  ? Icon(
                      Icons.camera_alt,
                      color: CompanyColors.checkYes,
                    )
                  : Icon(Icons.camera_alt, color: CompanyColors.checkMaybe)
              : Icon(Icons.camera_alt, color: CompanyColors.checkNo)),
    );
  }
}
