import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/pages/my_jobs/tasks/notepad/edit_note.dart';
import 'package:k2e/pages/my_jobs/tasks/notepad/note_card.dart';
import 'package:k2e/styles.dart';
import 'package:k2e/widgets/common_widgets.dart';

// The base page for any type of job. Shows address, has cover photo,

class NotepadTab extends StatefulWidget {
  NotepadTab() : super();
  @override
  _NotepadTabState createState() => new _NotepadTabState();
}

class _NotepadTabState extends State<NotepadTab> {
  String _loadingText = 'Loading notes...';

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.

    return new Scaffold(
      body: new Container(
        padding: new EdgeInsets.all(8.0),
        child: new ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(14.0),
              child: Text('Notepad', style: Styles.h1),
            ),
            new StreamBuilder(
                stream: Firestore.instance
                    .document(DataManager.get().currentJobPath)
                    .collection('notes')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    LoadingPage(loadingText: _loadingText);
                  if (snapshot.data.documents.length == 0)
                    return EmptyList(text: 'This job has no notes.');
                  return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) {
                        return NoteCard(
                          note: snapshot.data.documents[index],
                          onCardClick: () async {
                            Navigator.of(context).push(
                              new MaterialPageRoute(
                                  builder: (context) => EditNote(
                                      note: snapshot
                                          .data.documents[index].documentID)),
                            );
                          },
//                          onCardLongPress: () {
//                            // Delete
//                            // Bulk add /clone etc.
//                          },
                        );
                      });
                }),
          ],
        ),
      ),
    );
  }
}
