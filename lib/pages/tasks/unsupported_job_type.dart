import 'package:flutter/material.dart';
import 'package:k2e/data/jobrepository.dart';
import 'package:k2e/model/jobs/job_object.dart';
import 'package:k2e/pages/tasks/documents_fragment.dart';
import 'package:k2e/pages/tasks/job_details_fragment.dart';
import 'package:k2e/pages/tasks/time_log_fragment.dart';
import 'package:k2e/theme.dart';

// This is a base page for jobs, this will be used for any jobs that are not currently supported
// Have full functionality for editing WFM information though

class UnsupportedJobType extends StatefulWidget {
  UnsupportedJobType() : super();
  @override
  _UnsupportedJobTypeState createState() => new _UnsupportedJobTypeState();
}

class _UnsupportedJobTypeState extends State<UnsupportedJobType> {
  final Job job = JobRepository.get().currentJob;

  TabBarView tabBarView = new TabBarView(children: [
    new JobDetailsFragment(),
    new TimeLogFragment(),
    new DocumentsFragment(),
  ]);

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above
    return MaterialApp(
        theme: CompanyThemeData,
        home: DefaultTabController(
        length: 3,
        child:
          Scaffold(
            appBar: new AppBar(
              title: Text(job.type + ' (' + job.jobNumber + ')'),
             bottom: TabBar(
               tabs: [
                 Tab(icon: Icon(Icons.assignment)), // Job Details
                 Tab(icon: Icon(Icons.access_time)), // Log Time
                 Tab(icon: Icon(Icons.file_download)), // Download documents
               ],
       ),),
        body: tabBarView
        ),
        ),
    );
  }
}