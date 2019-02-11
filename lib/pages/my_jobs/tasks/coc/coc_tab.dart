import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/pages/my_jobs/tasks/acm/edit_sample_asbestos_air.dart';
import 'package:k2e/pages/my_jobs/tasks/acm/edit_acm.dart';
import 'package:k2e/styles.dart';
import 'package:k2e/pages/my_jobs/tasks/acm/acm_card.dart';

class CocTab extends StatefulWidget {
  CocTab() : super();

  @override
  _CocTabState createState() => new _CocTabState();
}

class _CocTabState extends State<CocTab> {
  String _loadingText = 'Loading Chain of Custody...';
  bool hasSamples = true;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        padding: new EdgeInsets.all(8.0),
        child: new ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: <Widget>[
        Container(
        alignment: Alignment.center,
          padding: EdgeInsets.all(14.0),
          child: Text('Chain of Custody',
              style: Styles.h1),
        ),
        new StreamBuilder(
            stream: Firestore.instance.collection('cocs').where('jobNumber', isEqualTo: DataManager.get().currentJobNumber).snapshots(),
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
              if (snapshot.data.documents.length == 0) return
                Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.not_interested, size: 64.0),
                          Container(
                              alignment: Alignment.center,
                              height: 64.0,
                              child: Text('This job has no asbestos samples.')
                          )
                        ]
                    )
                );
              return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    print(snapshot.data.documents[index]['jobnumber']);
                    return AcmCard(
                      doc: snapshot.data.documents[index],
                      onCardClick: () async {
                        if (snapshot.data.documents[index]['sampletype'] == 'air'){
                          Navigator.of(context).push(
                              new MaterialPageRoute(builder: (context) =>
                                  EditSampleAsbestosAir(
                                      sample: snapshot.data.documents[index]
                                          .documentID)),
                              );
                        } else {
                          print(context.toString());
                          Navigator.of(context).push(
                            new MaterialPageRoute(builder: (context) =>
                                EditACM(
                                    acm: snapshot.data.documents[index]
                                        .documentID)),
                          );
                        }
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
        ],
      ),
      )
    );
  }
}