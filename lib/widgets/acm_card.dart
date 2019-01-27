import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/theme.dart';

class AcmCard extends StatefulWidget {

  AcmCard({
    this.doc,
    @required this.onCardClick,
    @required this.onCardLongPress,
  });

  final DocumentSnapshot doc;
//  final SampleAsbestosBulk sample;

  final VoidCallback onCardClick;
  final VoidCallback onCardLongPress;

  @override
  _AcmCardState createState() => new _AcmCardState();

}

class _AcmCardState extends State<AcmCard>{
  String jobnumber;
  String sampletype;
  String sampleNumber;
  String description;
  String material;
  bool hasPhoto;
  bool photoSynced;
  bool presumed;
  String location;
  String pumpID;
  bool isRunning = false;
  bool isComplete = false;

  @override
  Widget build(BuildContext context) {
    if (widget.doc['location'] == null) {
      location = 'Location not specified';
    } else {
      location = widget.doc['location'];
    }
    if (widget.doc['pumpid'] == null) {
      pumpID = 'Pump ID not specified';
    } else {
      pumpID = widget.doc['material'];
    }
    if (widget.doc['starttime'] != null && widget.doc['endtime'] == null){
      isRunning = true;
    }
    if (widget.doc['endtime'] != null) {
      isComplete = true;
    }
    if (widget.doc['jobnumber'] == null) {
      jobnumber = 'AS******';
    } else {
      jobnumber = widget.doc['jobnumber'];
    }
    if (widget.doc['sampletype'] == null) {
      sampletype = 'bulk';
    } else {
      sampletype = widget.doc['sampletype'];
    }
    if (widget.doc['samplenumber'] == null) {
      sampleNumber = '0';
    } else {
      sampleNumber = widget.doc['samplenumber'].toString();
    }
    if (widget.doc['description'] == null) {
      description = 'No description';
    } else {
      description = widget.doc['description'];
    }
    if (widget.doc['material'] == null) {
      material = 'Undefined material';
    } else {
      material = widget.doc['material'];
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
    if (sampletype == 'bulk') {
      return new Container(
          margin: EdgeInsets.symmetric(vertical: 4.0),
    padding: EdgeInsets.fromLTRB(8.0,0.0,4.0,0.0),
    decoration: new BoxDecoration(
    color: Colors.white,
//    border: new Border.all(color: Colors.black38, width: 2.0),
//    borderRadius: new BorderRadius.circular(16.0),
    ),
    child: new ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
          dense: true,
        leading: new Container(width: 70.0, padding: EdgeInsets.all(0.0), margin: EdgeInsets.all(0.0),
          alignment: Alignment.center,
          child: new RawMaterialButton(
            onPressed: () {
              widget.onCardClick;
            },
            child: new Row(children: <Widget>[
              Icon(Icons.whatshot),
              Text(sampleNumber),
            ],
            ),
            shape: new StadiumBorder(),
            elevation: 2.0,
//        fillColor: CompanyColors.accentRippled,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(10.0),
          ),
        ),
//      leading: const Icon(Icons.whatshot),
          title: Text(description),
          subtitle: Text(material),

//      subtitle: Text(widget.sample.description + '(' + widget.sample.material + ')'),
          // Tap -> go through to job task
          onTap: widget.onCardClick,
          // Long tap -> add options to sync or delete
          onLongPress: widget.onCardLongPress,
          trailing:
          Container(width: 100.0,
              alignment: Alignment.centerRight,
              child:
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  //TODO: Add icons for assessments done
//           new InkWell(
//            child: new Container(
//              height: 30.0,
//              width: 30.0,
//              alignment: Alignment.center,
//              decoration: new BoxDecoration(
//                color: Colors.white,
//                border: new Border.all(color: CompanyColors.score3, width: 2.0),
//                borderRadius: new BorderRadius.circular(30.0),
//              ),
//              child: new Text('M',
//                style: new TextStyle(fontSize: 16.0, color: CompanyColors.score3),
//              ),
//            ),
//          ),
//           new InkWell(
//             child: new Container(
//               height: 30.0,
//               width: 30.0,
//               alignment: Alignment.center,
//               decoration: new BoxDecoration(
//                 color: Colors.white,
//                 border: new Border.all(color: CompanyColors.score3, width: 2.0),
//                 borderRadius: new BorderRadius.circular(30.0),
//               ),
//               child: new Text('P',
//                 style: new TextStyle(fontSize: 16.0, color: CompanyColors.score3),
//               ),
//             ),
//           ),
                  hasPhoto ? photoSynced ? Icon(
                    Icons.camera_alt, color: Colors.green,)
                      : Icon(Icons.camera_alt, color: Colors.orange)
                      : Icon(Icons.camera_alt, color: Colors.red)
                ],)
          )
    )
      );
    } else {
      return new Container(
          margin: EdgeInsets.symmetric(vertical: 4.0),
    padding: EdgeInsets.fromLTRB(8.0,0.0,4.0,0.0),
    decoration: new BoxDecoration(
    color: Colors.white,
    border: new Border.all(color: Colors.black38, width: 2.0),
    borderRadius: new BorderRadius.circular(16.0),
    ),
    child: new ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
          dense: true,
          leading: new Container(width: 70.0,
            alignment: Alignment.center,
              child: new RawMaterialButton(
                onPressed: () {
                  widget.onCardClick;
                },
                child: new Row(children: <Widget>[
                  new Icon(Icons.ac_unit),
                  Text(sampleNumber),
                ],
                ),
                shape: new StadiumBorder(),
                elevation: 2.0,
//        fillColor: CompanyColors.accentRippled,
                fillColor: Colors.white,
                padding: const EdgeInsets.all(10.0),
              ),
          ),
//      leading: const Icon(Icons.whatshot),
          title: Text(location),
          subtitle: Text(pumpID),

//      subtitle: Text(widget.sample.description + '(' + widget.sample.material + ')'),
          // Tap -> go through to job task
          onTap: widget.onCardClick,
          // Long tap -> add options to sync or delete
          onLongPress: widget.onCardLongPress,
          // TODO: Icons display whether sample has photo or not
          trailing:
          Container(width: 100.0,
              alignment: Alignment.centerRight,
              child:
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  //TODO: Add icons for assessments done
                  isRunning ? Icon(Icons.directions_run, color: Colors.red)
                      : Container(),
                  isComplete ? Icon(Icons.done, color: Colors.green)
                      : Container(),
//           new InkWell(
//            child: new Container(
//              height: 30.0,
//              width: 30.0,
//              alignment: Alignment.center,
//              decoration: new BoxDecoration(
//                color: Colors.white,
//                border: new Border.all(color: CompanyColors.score3, width: 2.0),
//                borderRadius: new BorderRadius.circular(30.0),
//              ),
//              child: new Text('M',
//                style: new TextStyle(fontSize: 16.0, color: CompanyColors.score3),
//              ),
//            ),
//          ),
//           new InkWell(
//             child: new Container(
//               height: 30.0,
//               width: 30.0,
//               alignment: Alignment.center,
//               decoration: new BoxDecoration(
//                 color: Colors.white,
//                 border: new Border.all(color: CompanyColors.score3, width: 2.0),
//                 borderRadius: new BorderRadius.circular(30.0),
//               ),
//               child: new Text('P',
//                 style: new TextStyle(fontSize: 16.0, color: CompanyColors.score3),
//               ),
//             ),
//           ),
                  hasPhoto ? photoSynced ? Icon(
                    Icons.camera_alt, color: Colors.green,)
                      : Icon(Icons.camera_alt, color: Colors.orange)
                      : Container(),
                ],)
          ))
      );
    }
  }
}