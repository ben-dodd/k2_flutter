import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/pages/my_jobs/tasks/check/check_tab.dart';
import 'package:k2e/pages/my_jobs/tasks/details/details_tab.dart';
import 'package:k2e/pages/my_jobs/tasks/documents/documents_tab.dart';
import 'package:k2e/pages/my_jobs/tasks/map/maps_tab.dart';
import 'package:k2e/pages/my_jobs/tasks/notepad/edit_note.dart';
import 'package:k2e/pages/my_jobs/tasks/notepad/notepad_tab.dart';
import 'package:k2e/pages/my_jobs/tasks/rooms/edit_room.dart';
import 'package:k2e/pages/my_jobs/tasks/rooms/rooms_tab.dart';
import 'package:k2e/pages/my_jobs/tasks/samples/asbestos_samples_tab.dart';
import 'package:k2e/pages/my_jobs/tasks/samples/edit_acm.dart';
import 'package:k2e/pages/my_jobs/tasks/samples/edit_sample_asbestos_air.dart';
import 'package:k2e/pages/my_jobs/tasks/samples/edit_sample_asbestos_bulk.dart';
import 'package:k2e/pages/my_jobs/tasks/samples/meth_samples_tab.dart';
import 'package:k2e/pages/my_jobs/tasks/timelog/log_time_tab.dart';
import 'package:k2e/theme.dart';
import 'package:k2e/widgets/fab_dialer.dart';
import 'package:k2e/widgets/loading.dart';

// This is a base page for jobs, this will be used for any jobs that are not currently supported
// Have full functionality for editing WFM information though

class JobPage extends StatefulWidget {
  JobPage({Key key, @required this.path, @required this.jobnumber}) : super(key: key);
  String path;
  String jobnumber;
  @override
  _JobPageState createState() => new _JobPageState();
}

class _JobPageState extends State<JobPage> {
  int jobType;

  TabBar tabBar;
  TabBarView tabBarView;
  int tabCount;

//  @override
//  void initState() {
//    _getCocs();
//
//    super.initState();
//  }

  // FAB Methods
  void _addNote() async {
    Navigator.of(context).push(
        new MaterialPageRoute(builder: (context) =>
            EditNote(
                note: null),
        )
    );
  }

  void _addMap() async {
//    Navigator.of(context).push(
//        new MaterialPageRoute(builder: (context) =>
//            EditMap(
//                map: null),
//        )
//    );
  }

  void _addRoom() async {
    Navigator.of(context).push(
        new MaterialPageRoute(builder: (context) =>
            EditRoom(
                room: null),
        )
    );
  }

  void _addACM() async {
//    DataManager.get().currentAsbestosBulkSample = null;
    Navigator.of(context).push(
      new MaterialPageRoute(builder: (context) =>
          EditACM(
              acm: null),
      )
    );
  }

  void _addAirSample() async {
//    DataManager.get().currentAsbestosBulkSample = null;
    Navigator.of(context).push(
        new MaterialPageRoute(builder: (context) =>
            EditSampleAsbestosAir(
                sample: null),
        )
    );
  }

  void _addBulkSample() async {
//    DataManager.get().currentAsbestosBulkSample = null;
    Navigator.of(context).push(
        new MaterialPageRoute(builder: (context) =>
            EditSampleAsbestosBulk(
                sample: null),
        )
    );
  }

//  void _getCocs() async {
//    Firestore.instance.collection('cocs').where('jobnumber',isEqualTo: DataManager.get().currentJobNumber).getDocuments().then((querySnapshot) =>
//        querySnapshot.
//    );
//  }

//  void _getSamples() async {
//    Firestore.instance.collection('samplesasbestos').where('jobNumber',isEqualTo: DataManager.get().currentJobNumber).getDocuments().then((querySnapshot) =>
//    );
//  }

  @override
  Widget build(BuildContext context) {

    print ('job page' + DataManager.get().currentJobPath);

    List<SpeedDialerButton> asbestosDialer = [
      new SpeedDialerButton(backgroundColor: CompanyColors.accent,
        icon: Icons.filter,
        onPressed: () {
          _addNote();
        },
        text: "Note or Photo",),
      new SpeedDialerButton(backgroundColor: CompanyColors.accent,
        icon: Icons.map,
        onPressed: () {
          _addMap();
        },
        text: "Map",),
      new SpeedDialerButton(backgroundColor: CompanyColors.accent,
        icon: Icons.domain,
        onPressed: () {
          _addRoom();
        },
        text: "Room",),
      new SpeedDialerButton(backgroundColor: CompanyColors.accent,
        icon: Icons.ac_unit,
        onPressed: () {
          _addAirSample();
        },
        text: "Air Sample",),
      new SpeedDialerButton(backgroundColor: CompanyColors.accent,
        icon: Icons.whatshot,
        onPressed: () {
          _addACM();
        },
        text: "ACM",),
//      new SpeedDialerButton(backgroundColor: CompanyColors.accent,
//        icon: Icons.colorize,
//        onPressed: () {
//          _addBulkSample();
//        },
//        text: "Bulk Sample",),
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
//                _getCocs();
//                _getSamples();
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
                title: Text(snapshot.data['jobnumber'] + ': ' + snapshot.data['type'],
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