import 'package:flutter/material.dart';
//import 'package:flutter_fab_dialer/flutter_fab_dialer.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/data/repos/sample_asbestos_bulk_repo.dart';
import 'package:k2e/model/entities/samples/sample_asbestos_bulk.dart';
import 'package:k2e/model/jobs/job.dart';
import 'package:k2e/pages/cameras/camera_generic.dart';
import 'package:k2e/pages/tasks/check/check.dart';
import 'package:k2e/utils/camera.dart';
import 'package:k2e/pages/tasks/documents/documents_fragment.dart';
import 'package:k2e/pages/tasks/details/job_details_fragment.dart';
import 'package:k2e/pages/tasks/map/map_basic_fragment.dart';
import 'package:k2e/pages/tasks/photo_notes/photo_notes_fragment.dart';
import 'package:k2e/pages/tasks/rooms/room_fragment.dart';
import 'package:k2e/pages/tasks/samples/edit_asbestos_sample_bulk.dart';
import 'package:k2e/pages/tasks/samples/asbestos_samples_fragment.dart';
import 'package:k2e/pages/tasks/samples/meth_samples_fragment.dart';
import 'package:k2e/pages/tasks/timelog/time_log_fragment.dart';
import 'package:k2e/theme.dart';
import 'package:k2e/widgets/fab_dialer.dart';

// This is a base page for jobs, this will be used for any jobs that are not currently supported
// Have full functionality for editing WFM information though

class BasicJobFragment extends StatefulWidget {
  BasicJobFragment() : super();
  @override
  _BasicJobFragmentState createState() => new _BasicJobFragmentState();
}

class _BasicJobFragmentState extends State<BasicJobFragment> {
  final Job job = DataManager.get().currentJob;
  int jobType;

  TabBar tabBar;
  TabBarView tabBarView;
  int tabCount;

  // FAB Methods

  void _addRoom() async {
    String result = await Navigator.of(context).push(
      new MaterialPageRoute(builder: (context) => CameraGeneric()),
    );
//    setState((){
//      _jobs = JobRepository.get().myJobCache;
//      Scaffold.of(context).showSnackBar(
//          new SnackBar(
//              content: new Text(result)));
//    });
  }

  void _addACMBulkSample() async {
    DataManager.get().currentAsbestosBulkSample = null;
    SampleAsbestosBulk result = await Navigator.of(context).push(
      new MaterialPageRoute(builder: (context) => EditAsbestosSampleBulk()),
    );
    setState((){
      if (result != null) {
        DataManager.get().updateSampleAsbestosBulk(result);
      }
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
        tabCount = 8;
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
            Tab(icon: Icon(Icons.check_circle)),
            // Check
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
          new CheckFragment(),
          new DocumentsFragment(),
        ]);
        break;
      case 2: // Meth Jobs
        tabCount = 8;
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
            Tab(icon: Icon(Icons.check_circle)),
            // Check
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
          new CheckFragment(),
          new DocumentsFragment(),
        ]);
        break;
      default: // Default
        tabCount = 6;
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
            Tab(icon: Icon(Icons.check_circle)),
            // Check
            Tab(icon: Icon(Icons.file_download)), // Download documents
          ],
        );
        tabBarView = new TabBarView(children: [
          new JobDetailsFragment(),
          new TimeLogFragment(),
          new PhotoNotesFragment(),
          new MapBasicFragment(),
          new CheckFragment(),
          new DocumentsFragment(),
        ]);
        break;
    }

    List<Widget> asbestosDialer = [
      new SpeedDialerButton(backgroundColor: CompanyColors.accent, icon: Icons.domain, onPressed: () { _addRoom(); }, text: "Add New Room",),
      new SpeedDialerButton(backgroundColor: CompanyColors.accent, icon: Icons.whatshot, onPressed: () { _addACMBulkSample(); }, text: "Add New ACM Bulk Sample",),
    ];
//
//    // Initialize FAB Menu
//    var _asbestosMenuItem = [
//      new FabMiniMenuItem.withText(
//          new Icon(Icons.domain),
//          CompanyColors.accent,
//          4.0,
//          "Add New Room",
//          _addRoom,
//          "Add New Room",
//          CompanyColors.accent,
//          Colors.white),
//
//      new FabMiniMenuItem.withText(
//          new Icon(Icons.whatshot),
//          CompanyColors.accent,
//          4.0,
//          "Add New ACM",
//          _addACMBulkSample,
//          "Add New ACM Bulk Sample",
//          CompanyColors.accent,
//          Colors.white),
//    ];

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
//          _isAsbestos? FabDialer(_asbestosMenuItem, CompanyColors.accent, Icon(Icons.add),):Container(),
        ]),
            floatingActionButton: _isAsbestos? new SpeedDialer(children: asbestosDialer) : Container(),
        ),
    );
  }
}