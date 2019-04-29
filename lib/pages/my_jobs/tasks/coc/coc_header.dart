import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:k2e/styles.dart';

class CocHeader extends StatefulWidget {
  CocHeader({
    this.doc,
  });

  final DocumentSnapshot doc;

  @override
  _CocHeaderState createState() => new _CocHeaderState();
}

class _CocHeaderState extends State<CocHeader> {
  String version;
  bool hasPhoto;
  bool photoSynced;
  String location;
  String symbol;
  String title;
  String subtitle;
  Color color;
  Color mColor;
  Color pColor;

  @override
  Widget build(BuildContext context) {
    if (widget.doc['currentVersion'] == null)
      version = 'Not yet issued';
    else {
      version = 'Latest version: ' + widget.doc['currentVersion'].toString();
      if (!widget.doc['versionUpToDate'])
        version = version + ' (needs reissue)';
    }
    return new Container(
        margin: EdgeInsets.symmetric(vertical: 4.0),
        padding: EdgeInsets.fromLTRB(8.0, 0.0, 4.0, 0.0),
        decoration: new BoxDecoration(
          color: Colors.white,
          border: new Border.all(color: Colors.black38, width: 1.0),
          borderRadius: new BorderRadius.circular(4.0),
        ),
        // Make this a proper long card with all current samples and an option to add a new number which will
        // be verified on submit or before
        child: new ListTile(
            contentPadding:
                EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
            dense: true,
            leading: new Container(
              width: 40.0,
              padding: EdgeInsets.all(0.0),
              margin: EdgeInsets.all(0.0),
              alignment: Alignment.center,
              child: new RawMaterialButton(
                onPressed: () {
//                  widget.onCardClick;
                },
                child: Icon(Icons.table_chart),
                shape: new StadiumBorder(),
                elevation: 1.0,
//        fillColor: CompanyColors.accentRippled,
                fillColor: color,
                padding: const EdgeInsets.all(10.0),
              ),
            ),
//      leading: const Icon(Icons.whatshot),
            title: Text(
              widget.doc['jobNumber'] + ": " + widget.doc['client'],
              style: Styles.h3,
            ),
            subtitle: Text(version),

//      subtitle: Text(widget.sample.description + '(' + widget.sample.material + ')'),
            // Tap -> go through to job task
//            onTap: widget.onCardClick,
//            // Long tap -> add options to sync or delete
//            onLongPress: widget.onCardLongPress,
            trailing: Container(
                width: 50.0,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    //TODO: Add icons for if issued etc. or how many samples, dates
                  ],
                ))));
  }
}
