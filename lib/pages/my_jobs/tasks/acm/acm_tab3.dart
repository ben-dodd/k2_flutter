import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/pages/my_jobs/tasks/rooms/room_card.dart';
import 'package:k2e/pages/my_jobs/tasks/rooms/set_up_job.dart';
import 'package:k2e/styles.dart';
import 'package:k2e/widgets/buttons.dart';
import 'package:k2e/widgets/common_widgets.dart';

// The base page for any type of job. Shows address, has cover photo,

class AcmTab extends StatefulWidget {
  AcmTab() : super();
  @override
  _AcmTabState createState() => new _AcmTabState();
}

class _AcmTabState extends State<AcmTab> {
  List<Map<String, dynamic>> roomList = new List<Map<String, dynamic>>();

  String _loadingText = 'Loading ACM...';
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
              child: Text('Asbestos Register', style: Styles.h1),
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
                    return LoadingPage(loadingText: _loadingText);
                  else if (snapshot.data.documents.length == 0)
                    return EmptyList(
                      text: 'This job has no ACM items',
                      action: FunctionButton(
                          text: "Set Up Job",
                          onClick: () {
                            Navigator.of(context).push(
                                new MaterialPageRoute(
                                    builder: (context) => SetUpJob()));
                          }),
                    );
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
