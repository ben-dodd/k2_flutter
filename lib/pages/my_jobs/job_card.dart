import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/styles.dart';
import 'package:k2e/theme.dart';

class JobCard extends StatefulWidget {
  JobCard({
    this.doc,
    @required this.onCardClick,
    this.onCardLongPress,
  });

//  final JobHeader jobHeader;
  final DocumentSnapshot doc;
//  final DocumentSnapshot jobHeader;

  final VoidCallback onCardClick;
  final VoidCallback onCardLongPress;

  @override
  _JobCardState createState() => new _JobCardState();
}

class _JobCardState extends State<JobCard> {
  Icon icon;
  @override
  Widget build(BuildContext context) {
    if (widget.doc['type'].toLowerCase().contains("asbestos")) {
      icon = CompanyColors.asbestosIcon;
    } else if (widget.doc['type'].toLowerCase().contains("meth")) {
      icon = CompanyColors.methIcon;
    } else if (widget.doc['type'].toLowerCase().contains("noise")) {
      icon = CompanyColors.noiseIcon;
    } else if (widget.doc['type'].toLowerCase().contains("stack")) {
      icon = CompanyColors.stackIcon;
    } else if (widget.doc['type'].toLowerCase().contains("bio")) {
      icon = CompanyColors.bioIcon;
    } else {
      icon = CompanyColors.generalIcon;
    }
    return Container(
        margin: EdgeInsets.symmetric(vertical: 4.0),
        padding: EdgeInsets.fromLTRB(8.0, 0.0, 4.0, 0.0),
        decoration: new BoxDecoration(
          color: Colors.white,
          border: new Border.all(color: Colors.black38, width: 1.0),
          borderRadius: new BorderRadius.circular(4.0),
        ),
        child: new ListTile(
          leading: icon,
          title: Row(children: <Widget>[
            Text(
              widget.doc['jobnumber'] + ': ',
              style: Styles.h2,
            ),
            Flexible(
                child: Text(
              ' ' + widget.doc['clientname'],
              overflow: TextOverflow.ellipsis,
            ))
          ]),
          subtitle: Text(widget.doc['address']),
          // Tap -> go through to job task
          onTap: widget.onCardClick,
          // Long tap -> add options to sync or delete
          onLongPress: widget.onCardLongPress,
        ));
  }
}
