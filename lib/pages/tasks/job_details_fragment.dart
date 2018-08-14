import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/model/jobs/job.dart';
import 'package:k2e/styles.dart';

// The base page for any type of job. Shows address, has cover photo,

class JobDetailsFragment extends StatefulWidget {
  JobDetailsFragment() : super();
  @override
  _JobDetailsFragment createState() => new _JobDetailsFragment();
}

class _JobDetailsFragment extends State<JobDetailsFragment> {

  final Job job = DataManager.get().currentJob;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.

    return new Scaffold(
        body:
        new Container(
            padding: new EdgeInsets.all(24.0),
            alignment: AlignmentDirectional.topStart,
            child: Column(
                children: <Widget> [
                  Text(job.jobHeader.clientName
                  ,style: Styles.h1),
                  TextField(decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: job.jobHeader.address,
                  )),
                  Text(job.jobHeader.description,
                  style: Styles.comment),
                ]
            )
        )
    );
  }
}