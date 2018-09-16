import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/model/samples/sample_asbestos_bulk.dart';
import 'package:k2e/model/jobs/job.dart';
import 'package:k2e/pages/cameras/camera_generic.dart';
import 'package:k2e/pages/my_jobs/tasks/check/check_tab.dart';
import 'package:k2e/pages/my_jobs/tasks/details/details_tab.dart';
import 'package:k2e/pages/my_jobs/tasks/documents/documents_tab.dart';
import 'package:k2e/pages/my_jobs/tasks/map/maps_tab.dart';
import 'package:k2e/pages/my_jobs/tasks/notepad/notepad_tab.dart';
import 'package:k2e/pages/my_jobs/tasks/rooms/edit_room.dart';
import 'package:k2e/pages/my_jobs/tasks/rooms/rooms_tab.dart';
import 'package:k2e/pages/my_jobs/tasks/samples/asbestos_samples_tab.dart';
import 'package:k2e/pages/my_jobs/tasks/samples/edit_asbestos_sample_bulk.dart';
import 'package:k2e/pages/my_jobs/tasks/samples/meth_samples_tab.dart';
import 'package:k2e/pages/my_jobs/tasks/timelog/log_time_tab.dart';
import 'package:k2e/theme.dart';
import 'package:k2e/widgets/fab_dialer.dart';
import 'package:k2e/widgets/loading.dart';

// This is a base page for jobs, this will be used for any jobs that are not currently supported
// Have full functionality for editing WFM information though

class JobPage extends StatefulWidget {
  JobPage({Key key, @required this.path, @required this.jobNumber}) : super(key: key);
  String path;
  String jobNumber;
  @override
  _JobPageState createState() => new _JobPageState();
}

class _JobPageState extends State<JobPage> {
  final Job job = DataManager.get().currentJob;
  int jobType;

  TabBar tabBar;
  TabBarView tabBarView;
  int tabCount;

  // FAB Methods

  void _addRoom() async {
    String result = await Navigator.of(context).push(
      new MaterialPageRoute(builder: (context) => EditRoom(room: null,)),
    );
//    setState((){
//      _jobs = JobRepository.get().myJobCache;
//      Scaffold.of(context).showSnackBar(
//          new SnackBar(
//              content: new Text(result)));
//    });
  }

  void _addACMBulkSample() async {
//    DataManager.get().currentAsbestosBulkSample = null;
    Navigator.of(context).push(
      new MaterialPageRoute(builder: (context) =>
          EditAsbestosSampleBulk(
              sample: null),
      )
    );
  }

  @override
  Widget build(BuildContext context) {

    print ('job page' + DataManager.get().currentJobPath);

    List<SpeedDialerButton> asbestosDialer = [
      new SpeedDialerButton(backgroundColor: CompanyColors.accent,
        icon: Icons.domain,
        onPressed: () {
          _addRoom();
        },
        text: "Add Room",),
      new SpeedDialerButton(backgroundColor: CompanyColors.accent,
        icon: Icons.whatshot,
        onPressed: () {
          _addACMBulkSample();
        },
        text: "Add ACM Bulk Sample",),
    ];

    return StreamBuilder(
        stream: Firestore.instance.document(
            widget.path).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return
            loadingPage(loadingText: 'Loading ' + DataManager.get().currentJobNumber);

          bool _isAsbestos = false;

          if (snapshot.hasData){
            if (snapshot.data['type'] != null) {
              if (snapshot.data['type'].toLowerCase().contains('asbestos')) {
                _isAsbestos = true;
                jobType = 1;
              } else if (snapshot.data['type'].toLowerCase().contains('meth')) {
                jobType = 2;
              } else {
                jobType = 0;
              }
            }

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
//                new DetailsTab(path: widget.path),
//                new LogTimeTab(path: widget.path),
//                new RoomsTab(path: widget.path),
//                new AsbestosSamplesTab(path: widget.path),
//                new NotepadTab(path: widget.path),
//                new MapsTab(path: widget.path),
//                new CheckTab(path: widget.path),
//                new DocumentsTab(path: widget.path),
                new DetailsTab(),
                new LogTimeTab(),
                new RoomsTab(),
                new AsbestosSamplesTab(),
                new NotepadTab(),
                new MapsTab(),
                new CheckTab(),
                new DocumentsTab(),
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
                new DetailsTab(),
                new LogTimeTab(),
                new RoomsTab(),
                new MethSamplesTab(),
                new NotepadTab(),
                new MapsTab(),
                new CheckTab(),
                new DocumentsTab(),
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
                new DetailsTab(),
                new LogTimeTab(),
                new NotepadTab(),
                new MapsTab(),
                new CheckTab(),
                new DocumentsTab(),
              ]);
              break;
          }

          return DefaultTabController(
            length: tabCount,
            child:
            Scaffold(
              appBar: new AppBar(
                title: Text(snapshot.data['jobNumber'] + ': ' + snapshot.data['type'],
                    overflow: TextOverflow.ellipsis),
                bottom: tabBar,
              ),
              body: Stack(
                  children: <Widget>[
                    tabBarView,
//          _isAsbestos? FabDialer(_asbestosMenuItem, CompanyColors.accent, Icon(Icons.add),):Container(),
                  ]),
              floatingActionButton: _isAsbestos ? new SpeedDialer(
                  children: asbestosDialer) : Container(),
            ),
          );

          }
        });
  }
}