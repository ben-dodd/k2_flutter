import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HistoricCocCard extends StatefulWidget {
  HistoricCocCard({
    this.doc,
    @required this.onCardClick,
    @required this.onCardLongPress,
  });

  final DocumentSnapshot doc;
//  final SampleAsbestosBulk sample;

  final VoidCallback onCardClick;
  final VoidCallback onCardLongPress;

  @override
  _HistoricCocCardState createState() => new _HistoricCocCardState();
}

class _HistoricCocCardState extends State<HistoricCocCard> {
  String jobNumber;
  String sampleType;
  String description;
  String material;
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
    return new Container(
        padding: EdgeInsets.fromLTRB(8.0, 0.0, 4.0, 0.0),
        decoration: new BoxDecoration(
          color: Colors.white,
        ),
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
                  widget.onCardClick;
                },
                child: Text('COC'),
                shape: new StadiumBorder(),
                elevation: 1.0,
//        fillColor: CompanyColors.accentRippled,
                fillColor: color,
                padding: const EdgeInsets.all(10.0),
              ),
            ),
//      leading: const Icon(Icons.whatshot),
            title: Text(widget.doc['jobNumber']),
            subtitle: Text(widget.doc['client']),

//      subtitle: Text(widget.sample.description + '(' + widget.sample.material + ')'),
            // Tap -> go through to job task
            onTap: widget.onCardClick,
            // Long tap -> add options to sync or delete
            onLongPress: widget.onCardLongPress,
            trailing: Container(
                width: 100.0,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    //TODO: Add icons for assessments done
                    Text(widget.doc['personnel'].toString())
                  ],
                ))));
  }
}
