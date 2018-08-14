import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/model/jobs/job.dart';
import 'package:k2e/styles.dart';

// The base page for any type of job. Shows address, has cover photo,

class PhotoNotesFragment extends StatefulWidget {
  PhotoNotesFragment() : super();
  @override
  _PhotoNotesFragmentState createState() => new _PhotoNotesFragmentState();
}

class _PhotoNotesFragmentState extends State<PhotoNotesFragment> {

  final Job job = DataManager.get().currentJob;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.

    return new Scaffold(
        body:
        new Container(
            padding: new EdgeInsets.all(24.0),
            alignment: Alignment.center,
            child: Column(
                children: <Widget> [
                  Text('Notepad', style: Styles.h1,),
                  Text('Add any notes and photos in this page that don''t relate specifically to a task.',
                  style: Styles.comment),
                ]
            )
        )
    );
  }
}