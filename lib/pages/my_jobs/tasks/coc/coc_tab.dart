import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/pages/my_jobs/tasks/coc/coc_functions.dart';
import 'package:k2e/pages/my_jobs/tasks/coc/coc_card.dart';
import 'package:k2e/pages/my_jobs/tasks/coc/edit_coc.dart';
import 'package:k2e/styles.dart';
import 'package:k2e/widgets/buttons.dart';
import 'package:k2e/widgets/common_widgets.dart';

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
            child: Text('Chain of Custody', style: Styles.h1),
          ),
          new StreamBuilder(
              stream: Firestore.instance
                  .collection('cocs')
                  .where('jobNumber',
                      isEqualTo: DataManager.get().currentJobNumber)
                  .where('deleted', isEqualTo: false)
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
                  return EmptyList(
                    text: 'This job has no asbestos samples.'
                  );
                return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      print(snapshot.data.documents[index]['jobnumber']);
                      return CocCard(
                        doc: snapshot.data.documents[index],
                        onCardClick: () async {
                          Navigator.of(context).push(
                            new MaterialPageRoute(
                                builder: (context) => EditCoc(
                                    coc: snapshot
                                        .data.documents[index].documentID)),
                          );
                        },
                        onCardLongPress: () {
                          // Delete
                          // Bulk add /clone etc.
                        },
                      );
                    });
              }),
          FunctionButton(
            text: "Add New Chain of Custody",
            onClick: () { addNewCoc(context); },
          ),
          FunctionButton(
            text: "Add Historic Chain of Custody",
            onClick: () { addHistoricCoc(context); },
          ),
        ],
      ),
    ));
  }
}
