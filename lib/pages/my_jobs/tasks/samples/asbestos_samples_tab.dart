import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/pages/my_jobs/tasks/samples/edit_sample_asbestos_air.dart';
import 'package:k2e/pages/my_jobs/tasks/samples/edit_sample_asbestos_bulk.dart';
import 'package:k2e/styles.dart';
import 'package:k2e/widgets/sample_asbestos_air_card.dart';
import 'package:k2e/widgets/sample_asbestos_bulk_card.dart';

class AsbestosSamplesTab extends StatefulWidget {
  AsbestosSamplesTab() : super();

  @override
  _AsbestosSamplesTabState createState() => new _AsbestosSamplesTabState();
}

class _AsbestosSamplesTabState extends State<AsbestosSamplesTab> {
  String _loadingText = 'Loading samples...';
  bool hasSamples = true;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Column(children: <Widget>[
        //
        // BULK SAMPLES
        //
      new Container(height: 30.0, padding: EdgeInsets.only(left: 8.0), alignment: Alignment.bottomLeft,child: Text('Bulk Samples',style: Styles.h2,)),
      new Container(
        padding: new EdgeInsets.all(8.0),
        child: StreamBuilder(
            stream: Firestore.instance.collection('samplesasbestosbulk').where('jobnumber',isEqualTo: DataManager.get().currentJobNumber).orderBy("samplenumber").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return
                Container(
                    padding: EdgeInsets.only(top: 16.0),
                    alignment: Alignment.center,
                    color: Colors.white,

                    child: Column(
                        mainAxisAlignment: MainAxisAlignment
                            .center,
                        children: <Widget>[
                          new CircularProgressIndicator(),
                          Container(
                              alignment: Alignment.center,
                              height: 64.0,
                              child:
                              Text(_loadingText)
                          )
                        ]));
              if (snapshot.data.documents.length == 0) setState(() {hasSamples = false;});
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    print(snapshot.data.documents[index]['jobnumber']);
                    return SampleAsbestosBulkCard(
                      doc: snapshot.data.documents[index],
                      onCardClick: () async {
                        Navigator.of(context).push(
                          new MaterialPageRoute(builder: (context) =>
                              EditSampleAsbestosBulk(
                                  sample: snapshot.data.documents[index]
                                      .documentID)),
                        );
                      },
                      onCardLongPress: () {
                        // Delete
                        // Bulk add /clone etc.
                      },
                    );
                  }
              );
            }
        ),
      ),
      //
      // AIR SAMPLES
      //
      new Divider(),
      new Container(height: 30.0, padding: EdgeInsets.only(left: 8.0), alignment: Alignment.bottomLeft,child: Text('Air Samples',style: Styles.h2,)),
      new Container(
        padding: new EdgeInsets.all(8.0),
        child: StreamBuilder(
            stream: Firestore.instance.collection('samplesasbestosair').where('jobnumber',isEqualTo: DataManager.get().currentJobNumber).orderBy("samplenumber").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return
                Container(
                    padding: EdgeInsets.only(top: 16.0),
                    alignment: Alignment.center,
                    color: Colors.white,

                    child: Column(
                        mainAxisAlignment: MainAxisAlignment
                            .center,
                        children: <Widget>[
                          new CircularProgressIndicator(),
                          Container(
                              alignment: Alignment.center,
                              height: 64.0,
                              child:
                              Text(_loadingText)
                          )
                        ]));
              if (snapshot.data.documents.length == 0) setState(() {hasSamples = false;});
                Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.not_interested, size: 64.0),
                          Container(
                              alignment: Alignment.center,
                              height: 64.0,
                              child:
                              Text('This job has no air samples.')
                          )
                        ]
                    )
                );
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    return SampleAsbestosAirCard(
                      doc: snapshot.data.documents[index],
                      onCardClick: () async {
                        Navigator.of(context).push(
                          new MaterialPageRoute(builder: (context) =>
                              EditSampleAsbestosAir(
                                  sample: snapshot.data.documents[index]
                                      .documentID)),
                        );
                      },
                      onCardLongPress: () {
                        // Delete
                        // Bulk add /clone etc.
                      },
                    );
                  }
              );
            }
        ),
      ),
      ],)
    );
  }
}