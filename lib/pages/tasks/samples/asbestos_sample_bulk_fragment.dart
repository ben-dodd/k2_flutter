import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/model/entities/areas/room.dart';
import 'package:k2e/model/jobs/job.dart';
import 'package:k2e/styles.dart';

class AsbestosSampleBulkFragment extends StatefulWidget {
  AsbestosSampleBulkFragment() : super();

  final Room room = DataManager.get().currentRoom; // current room, last added room if not in room page
  final Job job = DataManager.get().currentJob;

  @override
  _AsbestosSampleBulkFragmentState createState() => new _AsbestosSampleBulkFragmentState();
}

class _AsbestosSampleBulkFragmentState extends State<AsbestosSampleBulkFragment> {

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
                  Text('Asbestos Samples', style: Styles.h1,),
                  Text('Here are all your samples!',
                      style: Styles.comment),
                ]
            )
        )
    );
  }
}