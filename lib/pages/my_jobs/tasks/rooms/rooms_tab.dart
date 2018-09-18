import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/pages/my_jobs/tasks/rooms/edit_room.dart';
import 'package:k2e/widgets/room_card.dart';

// The base page for any type of job. Shows address, has cover photo,

class RoomsTab extends StatefulWidget {
  RoomsTab() : super();
  @override
  _RoomsTabState createState() => new _RoomsTabState();
}

class _RoomsTabState extends State<RoomsTab> {

  String _loadingText = 'Loading rooms...';

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.

    return new Scaffold(
      body:
      new Container(
        padding: new EdgeInsets.all(8.0),
        child: StreamBuilder(
            stream: Firestore.instance.document(DataManager.get().currentJobPath).collection('rooms').orderBy("name").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return
                Container(
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
                              child:
                              Text('This job has no rooms.')
                          )
                        ]
                    )
                );
              return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    return RoomCard(
                      doc: snapshot.data.documents[index],
                      onCardClick: () async {
                        // todo Incorporate firestore with samples
//                        DataManager.get().currentAsbestosBulkSample = _bulkSamples[index];
                        print(snapshot.data.documents[index].documentID);
                        Navigator.of(context).push(
                          new MaterialPageRoute(builder: (context) =>
                              EditRoom(
                                  room: snapshot.data.documents[index]
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
    );
  }
}