import 'dart:async';

import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/data/repos/job_header_repo.dart';
import 'package:k2e/model/jobs/job_header.dart';
import 'package:k2e/widgets/wfm_job_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// This page lists all your current jobs
// From here you can click on the Fab Menu to add more jobs
// or click on a job to go to that task e.g. a survey

class WfmFragment extends StatefulWidget {
  WfmFragment() : super();
  @override
  _WfmFragmentState createState() => new _WfmFragmentState();
}

class _WfmFragmentState extends State<WfmFragment> {
  List<JobHeader> _jobs = new List();
  TextEditingController searchController = new TextEditingController();
  String filter;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (JobHeaderRepo.get().wfmJobCache.length == 0) {
      JobHeaderRepo.get().getAllWfmJobs()
          .then((jobs) {
        setState(() {
          _jobs = jobs.body;
          _isLoading = false;
        });
      });
    } else {
      setState(() {
        _jobs = JobHeaderRepo
            .get()
            .wfmJobCache;
        _isLoading = false;
      });
    }
    searchController.addListener(() {
      setState(() {
        filter = searchController.text;
      });
    });
  }

  Future<Null> _refreshWfmJobs() async{
    await JobHeaderRepo.get().getAllWfmJobs().then((jobs) { _jobs = jobs.body; });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    return new Scaffold(
        appBar: new AppBar(
          // here we display the title corresponding to the fragment
          // you can choose to have a static title
          title: new Text("Add Job from WorkflowMax"),
        ),
        body:
            new RefreshIndicator(child:
        new Container(
            padding: new EdgeInsets.all(8.0),
            child: new Stack(
                children: <Widget>[
                  _isLoading?
                    new Center(
                        child:Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new CircularProgressIndicator(),
                          Container(
                            alignment: Alignment.center,
                            height: 64.0,
                            child:
                              Text('Loading jobs from WorkflowMax...')
                          )]))

                : new Container(),
                  Column(
                    children: <Widget>[
                    new TextField(
                      decoration: new InputDecoration(
                          labelText: "Search current jobs on WorkflowMax"
                      ),
                      controller: searchController,
                    ),
                  new Expanded(
                  child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _jobs.length,
                      itemBuilder: (context, index) {
                        return filter == null || filter == "" ? getWfmJobCard(_jobs[index])
                        : _jobs[index].jobNumber.toLowerCase().contains(filter.toLowerCase())
                          || _jobs[index].clientName.toLowerCase().contains(filter.toLowerCase())
                          || _jobs[index].address.toLowerCase().contains(filter.toLowerCase())
                          || _jobs[index].type.toLowerCase().contains(filter.toLowerCase()) ?
                          getWfmJobCard(_jobs[index])
                            : new Container();
                      }
                  )
                  )
                ]
            )
        ]
        ),
        ),
        onRefresh: _refreshWfmJobs,
    ),
    );
  }

  Widget getWfmJobCard(JobHeader jobHeader){
    return new WfmJobCard(
        jobHeader: jobHeader,
        onCardClick: () async {
          String message;
          Map<String, String> dataMap = new Map();
          dataMap['jobNumber'] = jobHeader.jobNumber;
          dataMap['type'] = jobHeader.type;
          dataMap['address'] = jobHeader.address;
          dataMap['clientName'] = jobHeader.clientName;
          // Check if job in user's jobs first
          var job = await Firestore.instance.collection('users').document(DataManager.get().user).collection('myjobs').where('jobNumber', isEqualTo: jobHeader.jobNumber).getDocuments();
          // Check if job in firestore first
          if (job.documents.length == 0){
            print ('No jobs have been added or job not in list');
            // No jobs have been added, or job number not in 'my jobs' list. Add job
            // First check if job has been moved from WFM into firestore
            var query = await Firestore.instance.collection('jobheaders').where('jobNumber',isEqualTo: jobHeader.jobNumber).getDocuments();
            if (query.documents.length == 0) {
              // Job has not been imported from WFM, add
              Firestore.instance.runTransaction((Transaction tx) async {
                var _result = await Firestore.instance.collection('jobheaders')
                    .add(jobHeader.toJson());
                dataMap['path'] = _result.path;
                await Firestore.instance.collection('users').document(DataManager.get().user).collection('myjobs').add(dataMap);
                message = jobHeader.jobNumber + ' added to your jobs.';
              });
            } else {
              print ('job was in firestore');
              // Job is already in firestore, get path
              // TODO change getting job Number to getting path
              print (query.documents.length);
              dataMap['path'] = query.documents.elementAt(0).reference.path;
              print (query.documents.elementAt(0).reference.path);
              await Firestore.instance.collection('users').document(DataManager.get().user).collection('myjobs').add(dataMap);
              message = jobHeader.jobNumber + ' added to your jobs.';
            }
            DataManager.get().jobHeaderRepo.myJobCache.add(jobHeader);
          } else {
            message = jobHeader.jobNumber + ' is already in your jobs.';
          }

          Navigator.pop(context,message);
        }
    );
  }

}