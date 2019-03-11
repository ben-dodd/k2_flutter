import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/pages/my_jobs/tasks/rooms/room_card.dart';
import 'package:k2e/pages/my_jobs/tasks/rooms/set_up_job.dart';
import 'package:k2e/styles.dart';

// The base page for any type of job. Shows address, has cover photo,

class RoomsTab extends StatefulWidget {
  RoomsTab() : super();
  @override
  _RoomsTabState createState() => new _RoomsTabState();
}

class _RoomsTabState extends State<RoomsTab> {
  List<Map<String, dynamic>> roomList = new List<Map<String, dynamic>>();

  String _loadingText = 'Loading rooms...';
  String roomGroupTemplateName = '-';
  List roomGroupTemplates = DataManager.get().roomGroupTemplates;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.

    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      body: new Container(
        padding: new EdgeInsets.all(8.0),
        child: new ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(14.0),
              child: Text('Room Overview', style: Styles.h1),
            ),
            new StreamBuilder(
                stream: Firestore.instance
                    .document(DataManager.get().currentJobPath)
                    .collection('rooms')
                    .where('roomtype', isLessThan: 'z')
                    .orderBy('roomtype')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Container(
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
                    return Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                          Icon(Icons.not_interested, size: 64.0),
                          Container(
                              alignment: Alignment.center,
                              height: 64.0,
                              child: Text('This job has no rooms.')),
                          new Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(
                              top: 14.0,
                            ),
                            child: new OutlineButton(
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(30.0)),
                                child: Text("Set Up Job",
                                    style: new TextStyle(
                                        color: Theme.of(context).accentColor,
                                        fontWeight: FontWeight.bold)),
                                //                          color: Colors.white,
                                onPressed: () {
                                  Navigator.of(context).push(
                                      new MaterialPageRoute(
                                          builder: (context) => SetUpJob()));
                                }),
                          )
                        ]));
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data.documents[index].data;
                      doc['path'] = snapshot.data.documents[index].documentID;
//                  print(doc.toString());
                      return RoomCard(
                        doc: doc,
                        context: context,
                      );
                    },
                  );
                }),
          ],
        ),
      ),
    );
  }
}
