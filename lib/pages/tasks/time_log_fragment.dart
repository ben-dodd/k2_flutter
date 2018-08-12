import 'package:flutter/material.dart';
import 'package:k2e/data/jobrepository.dart';
import 'package:k2e/model/jobs/job_object.dart';

// The base page for any type of job. Shows address, has cover photo,

class TimeLogFragment extends StatefulWidget {
  TimeLogFragment() : super();
  @override
  _TimeLogFragmentState createState() => new _TimeLogFragmentState();
}

class _TimeLogFragmentState extends State<TimeLogFragment> {

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
                  Text('Log Time'),
                  Icon(Icons.directions_car), // travel
                  Icon(Icons.build), // site work
                  Icon(Icons.colorize), // sample analysis
                  Icon(Icons.insert_chart), // report
                  Icon(Icons.check_circle), // review
                  Icon(Icons.assignment_ind), // ktp
                ]
            )
        )
    );
  }
}