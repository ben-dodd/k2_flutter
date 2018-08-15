import 'dart:async';

import 'package:flutter/material.dart';
import 'package:k2e/data/repos/job_header_repo.dart';
import 'package:k2e/model/jobs/job_header.dart';
import 'package:k2e/widgets/wfm_job_card.dart';

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
  }

  Future<Null> _refreshWfmJobs() async{
    await JobHeaderRepo.get().getAllWfmJobs().then((jobs) { _jobs = jobs.body; });
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
                            child: Column(
                        children: <Widget>[
                          new CircularProgressIndicator(),
                          Container(
                            height: 80.0,
                            child:
                              Text('Loading jobs from WorkflowMax...')
                          )]))

                : new Container(),
                  ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _jobs.length,
                      itemBuilder: (context, index) {
                        return WfmJobCard(
                            jobHeader: _jobs[index],
                            onCardClick: () async {
//                              setState(() {_isLoading = true;});
                              await JobHeaderRepo.get()
                                  .updateJob(_jobs[index]);
                              // TODO do not add existing jobs to job list
                              JobHeaderRepo.get().myJobCache.add(_jobs[index]);
//                              setState(() {
//                                _isLoading = false;
//                              });
                              print(_jobs[index].jobNumber + ' added to your jobs.');
                              // TODO say you already have that job loaded if you do
                              Navigator.pop(context,_jobs[index].jobNumber + ' added to your jobs.');
                            }
                        );
                      }
                  )
                ]
            )
        ),
        onRefresh: _refreshWfmJobs,
    ),
    );
  }
}