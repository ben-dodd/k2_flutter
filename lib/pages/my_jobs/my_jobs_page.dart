import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/data/repos/job_header_repo.dart';
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

  List<JobHeader> _jobs = new List();

  bool _isLoading = true;
  bool _isEmpty = true;
  String _loadingText = "Loading your jobs...";

  @override
  void initState() {
    super.initState();
    _resetJobs;
  }

  Future<Null> _resetJobs() async {
    print('getjobs called');
    setState(() {
      _jobs = [];
      _isLoading = true;
      _isEmpty = true;
    });
    _jobs = [];
    // TODO try using snapshot listener instead of getDocuments to fix the lag time
    // The problem with using snapshot listener is to get everything working in a chain
    await Firestore.instance.collection('users').document(DataManager.get().user).collection('myjobs').getDocuments().then((jobs) async {
      print(jobs.documents.length.toString() + ' is the documents in myjobs');
      for (var job in jobs.documents) {
        print(job.data['jobNumber']);
        var doc = await Firestore.instance.document(job.data['path']).get();
        JobHeader jobObj = JobHeader.fromMap(doc.data);
        _jobs.add(jobObj);
        print(jobObj.jobNumber + ' ' + jobObj.address);
      }
    });
    print ('get jobs returned');
    DataManager.get().jobHeaderRepo.myJobCache = _jobs;
    setState(() {
      if (_jobs == null || _jobs.length == 0) {
        _jobs = [];
        _isEmpty = true;
      } else {
        _isEmpty = false;
      }
      _isLoading = false;
    });
  }

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
      body:
          new RefreshIndicator(child:
          new Container(
              padding: new EdgeInsets.all(8.0),
              child: new Stack(
                  children: <Widget>[
                    _isEmpty?
                    new Center(
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
                    )
                        : new Container(),
                    ListView.builder(
                        itemCount: _jobs.length,
                        itemBuilder: (context, index) {
                          return JobCard(
                            jobHeader: _jobs[index],
                            onCardClick: () async {
                              setState(() {
                                _loadingText = "Loading " + _jobs[index].jobNumber;
                                _isLoading = true;
                              });
                              await DataManager.get().loadJob(_jobs[index]);
                              DataManager.get().cameras = await getCameras();
                              _isLoading = false;
                              _loadingText = "Loading your jobs...";
//                          JobRepo.get().currentJob = _jobs[index];
                              Navigator.push(context, MaterialPageRoute(builder: (context) => JobPage()));
                            },
                            onCardLongPress: () {

                            },
                          );
                        }
                    ),
                    _isLoading?
                    new Container(
                        alignment: Alignment.center,
                        color: Colors.white,

                        child:Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new CircularProgressIndicator(),
                              Container(
                                  alignment: Alignment.center,
                                  height: 64.0,
                                  child:
                                  Text(_loadingText)
                              )]))

                        : new Container(),
                  ]
              )
          ),
          onRefresh: _resetJobs),
          floatingActionButton: new SpeedDialer(children: modeButtons),
    );
  }

  void _createNewJob() {

  }

  void _addWfmJob() async {
    String result = await Navigator.of(context).push(
      new MaterialPageRoute(builder: (_) => new WfmFragment()),
    );
//    resetJobs().then((length) {
//      setState(() {
//        print('set state calld' + length.toString());
//        if (length == null || length == 0) {
//          _jobs = [];
//          _isEmpty = true;
//        } else {
//          _isEmpty = false;
//        }
//        _isLoading = false;
//      });
//    });
    _jobs = await DataManager.get().jobHeaderRepo.myJobCache;
    setState(() {
      if (result != null) {
      Scaffold.of(context).showSnackBar(
          new SnackBar(
              content: new Text(result)));
      }
    });
  }


}