import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/data/wfm_manager.dart';
import 'package:k2e/model/jobs/job_header.dart';
import 'package:k2e/pages/my_jobs/tasks/job_page.dart';
import 'package:k2e/pages/my_jobs/wfm_fragment.dart';
import 'package:k2e/theme.dart';
import 'package:k2e/utils/camera.dart';
import 'package:k2e/widgets/fab_dialer.dart';
import 'package:k2e/widgets/job_card.dart';

// This page lists all your current jobs
// From here you can click on the Fab Menu to add more jobs
// or click on a job to go to that task e.g. a survey

class MyJobsPage extends StatefulWidget {
  MyJobsPage() : super();
  @override
  _MyJobsPageState createState() => new _MyJobsPageState();
}

class _MyJobsPageState extends State<MyJobsPage> {

  String _loadingText = "Loading your jobs...";

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.

  List<Widget> modeButtons = [
    new SpeedDialerButton(backgroundColor: CompanyColors.accent, icon: Icons.add, onPressed: () { _createNewJob(); }, text: "Create New Job",),
    new SpeedDialerButton(backgroundColor: CompanyColors.accent, icon: Icons.cloud_download, onPressed: () { _addWfmJob(); }, text: "Add Job from WFM",),
  ];

//    FabDialer _fabDialer = new FabDialer(_fabMiniMenuItemList, CompanyColors.accent, Icon(Icons.add),);

    return new Scaffold(
      body: new Container(
              padding: new EdgeInsets.all(8.0),
                        child: StreamBuilder(
                          stream: Firestore.instance.collection('users').document(DataManager.get().user).collection('myjobs').snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return
                              Container(
                                  alignment: Alignment.center,
                                  color: Colors.white,

                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      children: <Widget>[
                                        new CircularProgressIndicator(),
                                        Container(
                                            alignment: Alignment.center,
                                            height: 64.0,
                                            child:
                                            Text(_loadingText)
                                        )
                                      ]));
                            if (snapshot.data.documents.length == 0) return
                              Center(
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(Icons.not_interested, size: 64.0),
                                        Container(
                                            alignment: Alignment.center,
                                            height: 64.0,
                                            child:
                                            Text('You have no jobs loaded.')
                                        )
                                      ]
                                  )
                              );
                            return ListView.builder(
                                itemCount: snapshot.data.documents.length,
                                itemBuilder: (context, index) {
                                  return JobCard(
                                    doc: snapshot.data.documents[index],
                                    onCardClick: () async {
                                      setState(() {
                                        // Todo Add loading back in to load jobs oooops
                                        _loadingText =
                                            "Loading " + snapshot.data.documents[index]['jobNumber'];
//                                        _isLoading = true;
                                      });
                                      // Load job from path listed in my jobs
                                      await DataManager.get().loadJob(
                                          snapshot.data.documents[index]['path']);
                                      // Prepare cameras
                                      DataManager
                                          .get()
                                          .cameras = await getCameras();
//                                      _isLoading = false;
                                      _loadingText = "Loading your jobs...";
//                                    JobRepo.get().currentJob = _jobs[index];
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => JobPage()));
                                    },
                                    onCardLongPress: () {
                                      // Delete
                                    },
                                  );
                                });
                          }
              ),
          ),
          floatingActionButton: new SpeedDialer(children: modeButtons),
    );
  }

  void _createNewJob() {

  }

  void _addWfmJob() async {
    String result = await Navigator.of(context).push(
      new MaterialPageRoute(builder: (_) => new WfmFragment()),
    );
    setState(() {
      if (result != null) {
      Scaffold.of(context).showSnackBar(
          new SnackBar(
              content: new Text(result)));
      }
    });
  }
}