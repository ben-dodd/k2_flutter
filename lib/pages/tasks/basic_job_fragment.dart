import 'package:flutter/material.dart';
import 'package:k2e/data/jobrepository.dart';
import 'package:k2e/model/jobs/job_object.dart';
import 'package:k2e/pages/tasks/documents/documents_fragment.dart';
import 'package:k2e/pages/tasks/job_details_fragment.dart';
import 'package:k2e/pages/tasks/map/map_basic_fragment.dart';
import 'package:k2e/pages/tasks/photo_notes/photo_notes_fragment.dart';
import 'package:k2e/pages/tasks/timelog/time_log_fragment.dart';
import 'package:k2e/theme.dart';

// This is a base page for jobs, this will be used for any jobs that are not currently supported
// Have full functionality for editing WFM information though

class BasicJobFragment extends StatefulWidget {
  BasicJobFragment() : super();
  @override
  _BasicJobFragmentState createState() => new _BasicJobFragmentState();
}

class _BasicJobFragmentState extends State<BasicJobFragment> {
  final Job job = JobRepository.get().currentJob;

  TabBarView tabBarView = new TabBarView(children: [
    new JobDetailsFragment(),
    new TimeLogFragment(),
    new PhotoNotesFragment(),
    new MapBasicFragment(),
    new DocumentsFragment(),
  ]);

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above
    return DefaultTabController(
        length: 5,
        child:
          Scaffold(
            appBar: new AppBar(
              title: Text(job.type + ' (' + job.jobNumber + ')', overflow: TextOverflow.ellipsis),
             bottom: TabBar(
               tabs: [
                 Tab(icon: Icon(Icons.assignment)), // Job Details
                 Tab(icon: Icon(Icons.access_time)), // Log Time & Sign in + SSSP etc.
                 Tab(icon: Icon(Icons.photo_library)), // Notes and photos
                 Tab(icon: Icon(Icons.map)), // Map
                 Tab(icon: Icon(Icons.file_download)), // Download documents
               ],
       ),),
        body: tabBarView
        ),
    );
  }
}