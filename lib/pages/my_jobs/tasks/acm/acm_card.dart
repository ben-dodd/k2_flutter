import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/styles.dart';
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
  String description;
  String material;
  bool hasPhoto;
  bool photoSynced;
  String location;
  String symbol;
  String pumpID;
  String title;
  String subtitle;
  Color color;
  Color mColor;
  Color pColor;
  bool isRunning = false;
  bool isComplete = false;

  @override
  Widget build(BuildContext context) {
    if (widget.doc['idkey'] == 'i') {
      color = CompanyColors.acmPositive;
      if (widget.doc['historic'] != null) {
        symbol = 'H';
        subtitle = 'Historic sample: ' + widget.doc['historic'];
      } else if (widget.doc['samplenumber'] != null) {
        symbol = widget.doc['samplenumber'].toString();
        subtitle = widget.doc['jobnumber'] + '-' + widget.doc['samplenumber'];
      } else {
        symbol = 'I*';
        subtitle = 'Sample number not assigned';
      }
    } else if (widget.doc['idkey'] == 's') {
      color = CompanyColors.strongPresume;
      if (widget.doc['samplenumber'] != null) {
        symbol = 'S*';
        subtitle = 'Strongly presumed as sample ' + widget.doc['jobnumber'] + '-' + widget.doc['samplenumber'];
      } else if (widget.doc['historic'] != null) {
        symbol = 'S*';
        subtitle = 'Strongly presumed as historic sample ' + widget.doc['historic'];
      } else {
        symbol = 'S';
        subtitle = 'Strongly presumed';
      }
    } else if (widget.doc['idkey'] == 'p') {
      color = CompanyColors.weakPresume;
      symbol = 'P';
      subtitle = 'Strongly presumed';
    } else {
      color = Colors.grey;
      symbol = '-';
      subtitle = 'Not presumed or identified';
    }
    if (widget.doc['mRisk'] == true) {
      if (widget.doc['mRiskLevel'] == 0) {
        mColor = CompanyColors.score0;
      } else if (widget.doc['mRiskLevel'] == 1) {
        mColor = CompanyColors.score1;
      } else if (widget.doc['mRiskLevel'] == 2) {
        mColor = CompanyColors.score2;
      } else if (widget.doc['mRiskLevel'] == 3) {
        mColor = CompanyColors.score3;
      } else mColor = Colors.grey;
    }
    if (widget.doc['pRisk'] == true) {
      if (widget.doc['pRiskLevel'] == 0) {
        pColor = CompanyColors.score0;
      } else if (widget.doc['pRiskLevel'] == 1) {
        pColor = CompanyColors.score1;
      } else if (widget.doc['pRiskLevel'] == 2) {
        pColor = CompanyColors.score2;
      } else if (widget.doc['pRiskLevel'] == 3) {
        pColor = CompanyColors.score3;
      } else pColor = Colors.grey;
    }
    if (widget.doc['roomname'] == null) {
      location = 'Location not specified';
    } else {
      location = widget.doc['roomname'];
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
//          margin: EdgeInsets.symmetric(vertical: 4.0),
        padding: EdgeInsets.fromLTRB(8.0,0.0,4.0,0.0),
        decoration: new BoxDecoration(color: Colors.white,),
        child: new ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
          dense: true,
          leading: new Container(width: 40.0, padding: EdgeInsets.all(0.0), margin: EdgeInsets.all(0.0),
          alignment: Alignment.center,
          child: new RawMaterialButton(
            onPressed: () {
              widget.onCardClick;
            },
            child: Text(symbol, style: Styles.acmCard,),
            shape: new StadiumBorder(),
            elevation: 1.0,
//        fillColor: CompanyColors.accentRippled,
            fillColor: color,
            padding: const EdgeInsets.all(10.0),
          ),
        ),
//      leading: const Icon(Icons.whatshot),
        title: Text(location + ': ' + description + ' - ' + material),
        subtitle: Text(subtitle),

//      subtitle: Text(widget.sample.description + '(' + widget.sample.material + ')'),
          // Tap -> go through to job task
        onTap: widget.onCardClick,
          // Long tap -> add options to sync or delete
        onLongPress: widget.onCardLongPress,
        trailing:
          Container(
            width: 100.0,
            alignment: Alignment.centerRight,
            child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  //TODO: Add icons for assessments done
                  widget.doc['pRisk'] == true ?
                  new InkWell(
                    child: new Container(
                      height: 30.0,
                      width: 30.0,
                      alignment: Alignment.center,
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        border: new Border.all(color: pColor, width: 2.0),
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                      child: new Text(widget.doc['pRiskLevel'] < 0 ? '!' : 'P',
                        style: new TextStyle(fontSize: 16.0, color: pColor),
                      ),
                    ),
                  ) : new Container(width: 30.0,),
                  widget.doc['mRisk'] == true ?
                   new InkWell(
                    child: new Container(
                      height: 30.0,
                      width: 30.0,
                      alignment: Alignment.center,
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        border: new Border.all(color: mColor, width: 2.0),
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                      child: new Text(widget.doc['mRiskLevel'] < 0 ? '!' : 'M',
                        style: new TextStyle(fontSize: 16.0, color: mColor),
                      ),
                    ),
                  ) : new Container(width: 30.0,),
                  hasPhoto ? photoSynced ? Icon(
                    Icons.camera_alt, color: CompanyColors.checkYes,)
                      : Icon(Icons.camera_alt, color: CompanyColors.checkMaybe)
                      : Icon(Icons.camera_alt, color: CompanyColors.checkNo)
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
                child: Text(symbol, style: Styles.acmCard,),
                shape: new StadiumBorder(),
                elevation: 1.0,
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
                  isRunning ? Icon(Icons.directions_run, color: CompanyColors.checkMaybe)
                      : Container(),
                  isComplete ? Icon(Icons.done, color: CompanyColors.checkYes)
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
                    Icons.camera_alt, color: CompanyColors.checkYes,)
                      : Icon(Icons.camera_alt, color: CompanyColors.checkMaybe)
                      : Container(),
                ],)
          ))
      );
    }
  }
}