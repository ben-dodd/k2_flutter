import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/pages/my_jobs/tasks/acm/acm_tab2.dart';
import 'package:k2e/pages/my_jobs/tasks/acm/edit_acm.dart';
import 'package:k2e/pages/my_jobs/tasks/acm/edit_sample_asbestos_air.dart';
import 'package:k2e/pages/my_jobs/tasks/acm/meth_samples_tab.dart';
import 'package:k2e/pages/my_jobs/tasks/check/check_tab.dart';
import 'package:k2e/pages/my_jobs/tasks/coc/coc_tab.dart';
import 'package:k2e/pages/my_jobs/tasks/coc/edit_coc.dart';
import 'package:k2e/pages/my_jobs/tasks/details/details_tab.dart';
import 'package:k2e/pages/my_jobs/tasks/map/edit_map.dart';
import 'package:k2e/pages/my_jobs/tasks/map/maps_tab.dart';
import 'package:k2e/pages/my_jobs/tasks/notepad/edit_note.dart';
import 'package:k2e/pages/my_jobs/tasks/notepad/notepad_tab.dart';
import 'package:k2e/pages/my_jobs/tasks/rooms/edit_room.dart';
import 'package:k2e/pages/my_jobs/tasks/rooms/edit_room_group.dart';
import 'package:k2e/pages/my_jobs/tasks/rooms/rooms_tab.dart';
import 'package:k2e/pages/my_jobs/tasks/timelog/log_time_tab.dart';
import 'package:k2e/theme.dart';
import 'package:k2e/widgets/common_widgets.dart';
import 'package:k2e/widgets/fab_dialer.dart';

// This is a base page for jobs, this will be used for any jobs that are not currently supported
// Have full functionality for editing WFM information though

class JobPage extends StatefulWidget {
  JobPage({Key key, @required this.path}) : super(key: key);
  String path;
  @override
  _JobPageState createState() => new _JobPageState();
}

class _JobPageState extends State<JobPage> {
  int jobType;

  TabBar tabBar;
  TabBarView tabBarView;
  int tabCount;

  // FAB Methods
  void _addNote() async {
    Navigator.of(context).push(new MaterialPageRoute(
      builder: (context) => EditNote(note: null),
    ));
  }

  void _addMap() async {
    Navigator.of(context).push(new MaterialPageRoute(
      builder: (context) => EditMap(map: null),
    ));
  }
//
//  void _addCoc() async {
//    Navigator.of(context).push(new MaterialPageRoute(
//      builder: (context) => EditCoc(coc: null),
//    ));
//  }

  void _addRoom() async {
    Navigator.of(context).push(new MaterialPageRoute(
      builder: (context) => EditRoom(room: null),
    ));
  }

  void _addRoomGroup() async {
    Navigator.of(context).push(new MaterialPageRoute(
      builder: (context) => EditRoomGroup(roomgroup: null),
    ));
  }

  void _addACM() async {
//    DataManager.get().currentAsbestosBulkSample = null;
    Navigator.of(context).push(new MaterialPageRoute(
      builder: (context) => EditACM(acm: null),
    ));
  }

  void _addAirSample() async {
//    DataManager.get().currentAsbestosBulkSample = null;
    Navigator.of(context).push(new MaterialPageRoute(
      builder: (context) => EditSampleAsbestosAir(sample: null),
    ));
  }

  @override
  Widget build(BuildContext context) {
    List<SpeedDialerButton> asbestosDialer = [
      new SpeedDialerButton(
        backgroundColor: CompanyColors.accentRippled,
        icon: Icons.ac_unit,
        onPressed: () {
          _addAirSample();
        },
        text: "Air Sample",
      ),
      new SpeedDialerButton(
        backgroundColor: CompanyColors.accentRippled,
        icon: Icons.filter,
        onPressed: () {
          _addNote();
        },
        text: "Note or Photo",
      ),
      new SpeedDialerButton(
        backgroundColor: CompanyColors.accentRippled,
        icon: Icons.map,
        onPressed: () {
          _addMap();
        },
        text: "Map",
      ),
//      new SpeedDialerButton(
//        backgroundColor: CompanyColors.accentRippled,
//        icon: Icons.table_chart,
//        onPressed: () {
//          _addCoc();
//        },
//        text: "Chain of Custody",
//      ),
      new SpeedDialerButton(
        backgroundColor: CompanyColors.accentRippled,
        icon: Icons.business,
        onPressed: () {
          _addRoomGroup();
        },
        text: "Room Group",
      ),
      new SpeedDialerButton(
        backgroundColor: CompanyColors.accentRippled,
        icon: Icons.hotel,
        onPressed: () {
          _addRoom();
        },
        text: "Room",
      ),
      new SpeedDialerButton(
        backgroundColor: CompanyColors.accentRippled,
        icon: Icons.whatshot,
        onPressed: () {
          _addACM();
        },
        text: "ACM",
      ),
    ];

    return StreamBuilder(
        stream: Firestore.instance.document(widget.path).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return LoadingPage(
                loadingText: 'Loading ' + DataManager.get().currentJobNumber);

          bool _isAsbestos = false;

          if (snapshot.hasData) {
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
                    Tab(icon: Icon(Icons.table_chart)),
                    // Chain of Custody
                    Tab(icon: Icon(Icons.photo_library)),
                    // Notes and photos
                    Tab(icon: Icon(Icons.map)),
                    // Map
                    Tab(icon: Icon(Icons.check_circle)),
                    // Check
//                  Tab(icon: Icon(Icons.file_download)), // Download documents
                  ],
                );
                tabBarView = new TabBarView(children: [
                  new DetailsTab(),
                  new LogTimeTab(),
                  new RoomsTab(),
                  new AcmTab(),
                  new CocTab(),
                  new NotepadTab(),
                  new MapsTab(),
                  new CheckTab(),
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
                    Tab(icon: Icon(Icons.check_circle)),
                    // Check
//                  Tab(icon: Icon(Icons.file_download)), // Download documents
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
//                new DocumentsTab(),
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
                    Tab(icon: Icon(Icons.check_circle)),
                    // Check
//                  Tab(icon: Icon(Icons.file_download)), // Download documents
                  ],
                );
                tabBarView = new TabBarView(children: [
                  new DetailsTab(),
                  new LogTimeTab(),
                  new NotepadTab(),
                  new MapsTab(),
                  new CheckTab(),
//                new DocumentsTab(),
                ]);
                break;
            }

            return DefaultTabController(
              length: tabCount,
              child: Scaffold(
                appBar: new AppBar(
                  title: Text(
                      snapshot.data['jobNumber'] + ': ' + snapshot.data['type'],
                      overflow: TextOverflow.ellipsis),
                  bottom: tabBar,
                ),
                body: Stack(children: <Widget>[
                  tabBarView,
//          _isAsbestos? FabDialer(_asbestosMenuItem, CompanyColors.accent, Icon(Icons.add),):Container(),
                ]),
                floatingActionButton: _isAsbestos
                    ? new SpeedDialer(children: asbestosDialer)
                    : Container(),
              ),
            );
          }
        });
  }
}
