import 'package:flutter/material.dart';
import 'package:flutter_fab_dialer/flutter_fab_dialer.dart';
import 'package:k2e/data/jobrepository.dart';
import 'package:k2e/model/jobs/job_object.dart';
import 'package:k2e/pages/jobs/wfm_fragment.dart';
import 'package:k2e/theme.dart';
import 'package:k2e/widgets/job_card.dart';
import 'package:k2e/pages/tasks/unsupported_job_type.dart';

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

  void _addWfmJob() async {
    String result = await Navigator.of(context).push(
      new MaterialPageRoute(builder: (context) => WfmFragment()),
    );
    setState((){
      _jobs = JobRepository.get().myJobCache;
      Scaffold.of(context).showSnackBar(
      new SnackBar(
          content: new Text(result)));
    });
  }

  List<Job> _jobs = new List();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
      JobRepository.get().getMyJobs()
          .then((jobs) {
        setState(() {
          _jobs = jobs;
          _isLoading = false;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.

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

    return new Scaffold(
      body:
        new Container(
          padding: new EdgeInsets.all(8.0),
          child: new Stack(
            children: <Widget>[
              _isLoading? new CircularProgressIndicator(): new Container(),
              ListView.builder(
                itemCount: _jobs.length,
                itemBuilder: (context, index) {
                  return JobCard(
                      job: _jobs[index],
                      onCardClick: () {
                          JobRepository.get().currentJob = _jobs[index];
                          Navigator.push(context, MaterialPageRoute(builder: (context) => UnsupportedJobType()));
                      }
                  );
                }
            ),
              FabDialer(_fabMiniMenuItemList, CompanyColors.accent, Icon(Icons.add),),
            ]
          )
      )
    );
  }
}