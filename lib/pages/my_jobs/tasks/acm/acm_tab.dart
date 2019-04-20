import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/pages/my_jobs/tasks/acm/acm_card.dart';
import 'package:k2e/pages/my_jobs/tasks/acm/edit_acm.dart';
import 'package:k2e/pages/my_jobs/tasks/acm/edit_sample_asbestos_air.dart';
import 'package:k2e/styles.dart';
import 'package:k2e/widgets/common_widgets.dart';

class AcmTab extends StatefulWidget {
  AcmTab() : super();

  @override
  _AcmTabState createState() => new _AcmTabState();
}

class _AcmTabState extends State<AcmTab> {
  String _loadingText = 'Loading ACM...';
  bool hasSamples = true;
// TODO: Give options to display ACM in different ways. e.g.
  // 1) Tree view with Rooms
  // 2) Order by type (idKey)
  // 3) Order by material
  // 4) Order by risk
  // 5) Display in table
  // 6) Display in table as it would be in a report
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
            child: Text('Asbestos Register', style: Styles.h1),
          ),
          new StreamBuilder(
              stream: Firestore.instance
                  .document(DataManager.get().currentJobPath)
                  .collection('acm')
                  .orderBy('roompath')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Container(
                      padding: EdgeInsets.only(top: 16.0),
                      alignment: Alignment.center,
                      color: Colors.white,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new CircularProgressIndicator(),
                            Container(
                                alignment: Alignment.center,
                                height: 64.0,
                                child: Text(_loadingText))
                          ]));
                if (snapshot.data.documents.length == 0)
                  return EmptyList(text: 'This job has no ACM items.');
                return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      return AcmCard(
                        doc: snapshot.data.documents[index],
                        onCardClick: () async {
                          if (snapshot.data.documents[index]['sampletype'] ==
                              'air') {
                            Navigator.of(context).push(
                              new MaterialPageRoute(
                                  builder: (context) => EditSampleAsbestosAir(
                                      sample: snapshot
                                          .data.documents[index].documentID)),
                            );
                          } else {
                            Navigator.of(context).push(
                              new MaterialPageRoute(
                                  builder: (context) => EditACM(
                                      acm: snapshot
                                          .data.documents[index].documentID)),
                            );
                          }
                        },
                        onCardLongPress: () {
                          // Delete
                          // Bulk add /clone etc.
                        },
                      );
                    });
              })
        ],
      ),
    ));
  }
}
