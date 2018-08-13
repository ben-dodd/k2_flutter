import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/data/repos/job_repo.dart';
import 'package:k2e/model/jobs/job.dart';
import 'package:k2e/model/jobs/job_header.dart';
import 'package:k2e/styles.dart';
import 'package:path/path.dart';

// The base page for any type of job. Shows address, has cover photo,

class TimeLogFragment extends StatefulWidget {
  TimeLogFragment() : super();
  @override
  _TimeLogFragmentState createState() => new _TimeLogFragmentState();
}

class _TimeLogFragmentState extends State<TimeLogFragment> {

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
                  Text('Log Time',
                  style: Styles.h1),
                  FlatButton(
                    onPressed: () => {},
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      children: <Widget>[
                        new Container(
                          width: 80.0,
                            height: 48.0,
                          child: Icon(Icons.directions_car, size: 24.0,)
                        ),
                        Text('Travel', style: Styles.logButton)
                      ],
                    ),
                  ),
                  FlatButton(
                    onPressed: () => {},
                    padding: EdgeInsets.all(10.0),
                    child: Row( // Replace with a Row for horizontal icon + text
                      children: <Widget>[
                        new Container(
                            width: 80.0,
                            height: 48.0,
                            child: Icon(Icons.build, size: 24.0,)
                        ),
                        Text('Site Work', style: Styles.logButton)
                      ],
                    ),
                  ),
                  FlatButton(
                    onPressed: () => {},
                    padding: EdgeInsets.all(10.0),
                    child: Row( // Replace with a Row for horizontal icon + text
                      children: <Widget>[
                        new Container(
                            width: 80.0,
                            height: 48.0,
                            child: Icon(Icons.colorize, size: 24.0,)
                        ),
                        Text('Analysis', style: Styles.logButton)
                      ],
                    ),
                  ),
                  FlatButton(
                    onPressed: () => {},
                    padding: EdgeInsets.all(10.0),
                    child: Row( // Replace with a Row for horizontal icon + text
                      children: <Widget>[
                        new Container(
                            width: 80.0,
                            height: 48.0,
                            child: Icon(Icons.insert_chart, size: 24.0,)
                        ),
                        Text('Report', style: Styles.logButton)
                      ],
                    ),
                  ),
                  FlatButton(
                    onPressed: () => {},
                    padding: EdgeInsets.all(10.0),
                    child: Row( // Replace with a Row for horizontal icon + text
                      children: <Widget>[
                        new Container(
                            width: 80.0,
                            height: 48.0,
                            child: Icon(Icons.check_circle, size: 24.0,)
                        ),
                        Text('Review', style: Styles.logButton)
                      ],
                    ),
                  ),
                  FlatButton(
                    onPressed: () => {},
                    padding: EdgeInsets.all(10.0),
                    child: Row( // Replace with a Row for horizontal icon + text
                      children: <Widget>[
                        new Container(
                            width: 80.0,
                            height: 48.0,
                            child: Icon(Icons.assignment_ind, size: 24.0,)
                        ),
                        Text('KTP', style: Styles.logButton)
                      ],
                    ),
                  ),
                ]
            )
        )
    );
  }
}