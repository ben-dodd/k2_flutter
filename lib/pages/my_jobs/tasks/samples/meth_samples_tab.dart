import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/model/jobs/job.dart';
import 'package:k2e/styles.dart';

// The base page for any type of job. Shows address, has cover photo,

class MethSamplesTab extends StatefulWidget {
  MethSamplesTab() : super();
  @override
  _MethSamplesTabState createState() => new _MethSamplesTabState();
}

class _MethSamplesTabState extends State<MethSamplesTab> {

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
                  Text('Meth Samples', style: Styles.h1,),
                  Text('Meth samples list!',
                      style: Styles.comment),
                ]
            )
        )
    );
  }
}