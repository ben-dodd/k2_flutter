import 'package:flutter/material.dart';
import 'package:flutter_fab_dialer/flutter_fab_dialer.dart';
import 'package:k2e/theme.dart';
import 'package:k2e/widgets/fab_menu.dart';

// This page lists all your current jobs
// From here you can click on the Fab Menu to add more jobs
// or click on a job to go to that task e.g. a survey

class MyJobsFragment extends StatefulWidget {
  MyJobsFragment() : super();
  @override
  _MyJobsFragmentState createState() => new _MyJobsFragmentState();
}

class _MyJobsFragmentState extends State<MyJobsFragment> {
  void _createNewJob() {

  }

  void _addWfmJob() {

  }

  @override
  Widget build(BuildContext context) {
    var _fabMiniMenuItemList = [
      new FabMiniMenuItem.withText(
          new Icon(Icons.add),
          CompanyColors.accent,
          4.0,
          "Create New Job",
          _createNewJob,
          "Create New Job",
          CompanyColors.accent,
          Colors.white),

      new FabMiniMenuItem.withText(
          new Icon(Icons.cloud_download),
          CompanyColors.accent,
          4.0,
          "Add Job from WFM",
          _addWfmJob,
          "Add Job from WFM",
          CompanyColors.accent,
          Colors.white),
    ];
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    return new Scaffold(
      body: new Stack(
        children: <Widget>[
          new Center(
            child: new Text('My Jobs'),
          ),
//            new FancyFab(),
          new FabDialer(_fabMiniMenuItemList, CompanyColors.accent, new Icon(Icons.add)),
        ]
      ),
    );
  }
}