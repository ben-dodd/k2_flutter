import 'package:flutter/material.dart';
import 'package:flutter_fab_dialer/flutter_fab_dialer.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/data/repos/sample_asbestos_bulk_repo.dart';
import 'package:k2e/model/entities/samples/sample_asbestos_bulk.dart';
import 'package:k2e/model/jobs/job.dart';
import 'package:k2e/pages/tasks/documents/documents_fragment.dart';
import 'package:k2e/pages/tasks/job_details_fragment.dart';
import 'package:k2e/pages/tasks/map/map_basic_fragment.dart';
import 'package:k2e/pages/tasks/photo_notes/photo_notes_fragment.dart';
import 'package:k2e/pages/tasks/rooms/room_fragment.dart';
import 'package:k2e/pages/tasks/samples/edit_asbestos_sample_bulk.dart';
import 'package:k2e/pages/tasks/samples/asbestos_samples_fragment.dart';
import 'package:k2e/pages/tasks/samples/meth_samples_fragment.dart';
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
  // Todo Change the basic job to one that has everything inside it

  final Job job = DataManager.get().currentJob;
  int jobType;

  TabBar tabBar;
  TabBarView tabBarView;
  int tabCount;

  // FAB Methods

  void _addRoom() async {
//    String result = await Navigator.of(context).push(
//      new MaterialPageRoute(builder: (context) => WfmFragment()),
//    );
//    setState((){
//      _jobs = JobRepository.get().myJobCache;
//      Scaffold.of(context).showSnackBar(
//          new SnackBar(
//              content: new Text(result)));
//    });
  }

  void _addACMBulkSample() async {
    SampleAsbestosBulk result = await Navigator.of(context).push(
      new MaterialPageRoute(builder: (context) => EditAsbestosSampleBulk(null)),
    );
    setState((){
      if (result != null) {
        SampleAsbestosBulkRepo.get().updateJob(result);
        DataManager
            .get()
            .currentJob
            .asbestosBulkSamples
            .add(result);
      }
//      Scaffold.of(context).showSnackBar(
//          new SnackBar(
//              content: new Text(result.jobNumber + '-' + result.sampleNumber.toString() + " created")));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (job.jobHeader.type.toLowerCase().contains('asbestos')) {
      jobType = 1;
    } else if (job.jobHeader.type.toLowerCase().contains('meth')) {
      jobType = 2;
    } else {
      jobType = 0;
    }

    bool _isAsbestos = jobType == 1;

    // Initialize TabView
    switch (jobType) {
      case 1: // Asbestos Jobs
        tabCount = 7;
        tabBar = new TabBar(
          tabs: [
            Tab(icon: Icon(Icons.assignment)),
            // Job Details
            Tab(icon: Icon(Icons.access_time)),
            // Log Time & Sign in + SSSP etc.
            Tab(icon: Icon(Icons.domain)),
            // Rooms
            Tab(icon: Icon(Icons.whatshot)),
            // Asbestos Samples
            Tab(icon: Icon(Icons.photo_library)),
            // Notes and photos
            Tab(icon: Icon(Icons.map)),
            // Map
            Tab(icon: Icon(Icons.file_download)), // Download documents
          ],
        );
        tabBarView = new TabBarView(children: [
          new JobDetailsFragment(),
          new TimeLogFragment(),
          new RoomFragment(),
          new AsbestosSamplesFragment(),
          new PhotoNotesFragment(),
          new MapBasicFragment(),
          new DocumentsFragment(),
        ]);
        break;
      case 2: // Meth Jobs
        tabCount = 7;
        tabBar = new TabBar(
          tabs: [
            Tab(icon: Icon(Icons.assignment)),
            // Job Details
            Tab(icon: Icon(Icons.access_time)),
            // Log Time & Sign in + SSSP etc.
            Tab(icon: Icon(Icons.domain)),
            // Rooms
            Tab(icon: Icon(Icons.lightbulb_outline)),
            // Swabs
            Tab(icon: Icon(Icons.photo_library)),
            // Notes and photos
            Tab(icon: Icon(Icons.map)),
            // Map
            Tab(icon: Icon(Icons.file_download)), // Download documents
          ],
        );
        tabBarView = new TabBarView(children: [
          new JobDetailsFragment(),
          new TimeLogFragment(),
          new RoomFragment(),
          new MethSamplesFragment(),
          new PhotoNotesFragment(),
          new MapBasicFragment(),
          new DocumentsFragment(),
        ]);
        break;
      default: // Default
        tabCount = 5;
        tabBar = new TabBar(
          tabs: [
            Tab(icon: Icon(Icons.assignment)),
            // Job Details
            Tab(icon: Icon(Icons.access_time)),
            // Log Time & Sign in + SSSP etc.
            Tab(icon: Icon(Icons.photo_library)),
            // Notes and photos
            Tab(icon: Icon(Icons.map)),
            // Map
            Tab(icon: Icon(Icons.file_download)), // Download documents
          ],
        );
        tabBarView = new TabBarView(children: [
          new JobDetailsFragment(),
          new TimeLogFragment(),
          new PhotoNotesFragment(),
          new MapBasicFragment(),
          new DocumentsFragment(),
        ]);
        break;
    }

    // Initialize FAB Menu
    var _asbestosMenuItem = [
      new FabMiniMenuItem.withText(
          new Icon(Icons.domain),
          CompanyColors.accent,
          4.0,
          "Add New Room",
          _addRoom,
          "Add New Room",
          CompanyColors.accent,
          Colors.white),

      new FabMiniMenuItem.withText(
          new Icon(Icons.whatshot),
          CompanyColors.accent,
          4.0,
          "Add New ACM",
          _addACMBulkSample,
          "Add New ACM Bulk Sample",
          CompanyColors.accent,
          Colors.white),
    ];

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above
    return DefaultTabController(
        length: tabCount,
        child:
          Scaffold(
            appBar: new AppBar(
              title: Text(job.jobHeader.jobNumber + ': ' + job.jobHeader.type, overflow: TextOverflow.ellipsis),
             bottom: tabBar,
            ),
        body: Stack(
          children: <Widget> [
            tabBarView,
          _isAsbestos? FabDialer(_asbestosMenuItem, CompanyColors.accent, Icon(Icons.add),):Container(),
        ]),
        ),
    );
  }
}