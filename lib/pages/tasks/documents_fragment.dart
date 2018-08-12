import 'package:flutter/material.dart';
import 'package:k2e/data/jobrepository.dart';
import 'package:k2e/model/jobs/job_object.dart';

// The base page for any type of job. Shows address, has cover photo,

class DocumentsFragment extends StatefulWidget {
  DocumentsFragment() : super();
  @override
  _DocumentsFragmentState createState() => new _DocumentsFragmentState();
}

class _DocumentsFragmentState extends State<DocumentsFragment> {

  final Job job = JobRepository.get().currentJob;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.

    return new Scaffold(
        body:
        new Container(
          padding: new EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Column(
            children: <Widget> [
              Text('Job Documents'),
            ]
          )
        )
    );
  }
}