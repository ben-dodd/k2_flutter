import 'dart:async';

import 'package:flutter/material.dart';
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
          Firestore.instance.runTransaction((Transaction tx) async {
            var _result = await Firestore.instance.collection('jobheaders').add(jobHeader.toJson());
            print(_result.path);
            // add result reference to "MyJobs" array in users document
          });
//                              setState(() {_isLoading = true;});
          await JobHeaderRepo.get()
              .updateJob(jobHeader);
          String message;
          if (JobHeaderRepo.get().myJobCache.indexWhere((job) => job.jobNumber.toLowerCase() == jobHeader.jobNumber.toLowerCase()) == -1) {
            JobHeaderRepo
                .get()
                .myJobCache
                .add(jobHeader);
            message = jobHeader.jobNumber + ' added to your jobs.';
          } else {
            message = jobHeader.jobNumber + ' is already in your jobs.';
          }

          Navigator.pop(context,message);
        }
    );
  }
}