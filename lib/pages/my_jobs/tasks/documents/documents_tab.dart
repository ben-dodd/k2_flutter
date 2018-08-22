import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/model/jobs/job.dart';
import 'package:k2e/styles.dart';

// The base page for any type of job. Shows address, has cover photo,

class DocumentsTab extends StatefulWidget {
  DocumentsTab() : super();
  @override
  _DocumentsTabState createState() => new _DocumentsTabState();
}

class _DocumentsTabState extends State<DocumentsTab> {

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
              Text('Job Documents', style: Styles.h1),
              Text('This page is where you can produce and download reports and documents.',
                  style: Styles.comment),
            ]
          )
        )
    );
  }
}