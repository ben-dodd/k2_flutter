import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/pages/jobs/my_jobs_fragment.dart';
import 'package:k2e/pages/under_construction_fragment.dart';

class DrawerItem {
  String title;
  IconData icon;
  DrawerItem(this.title, this.icon);
}

class MainPage extends StatefulWidget {
  // Add all drawer items here
  final drawerItems = [
    new DrawerItem("My Jobs", Icons.assignment),
    new DrawerItem("To Do", Icons.format_list_bulleted),
    new DrawerItem("Lab", Icons.colorize),
    new DrawerItem("Notifications", Icons.notifications),
    new DrawerItem("Calendar", Icons.date_range),
    new DrawerItem("My Details", Icons.person),
    new DrawerItem("Training", Icons.people),
    new DrawerItem("Equipment", Icons.build),
    new DrawerItem("App Settings", Icons.settings),
    new DrawerItem("Log Out", Icons.exit_to_app)
  ];

  @override
  _MainPageState createState() => new _MainPageState();

// Main Navigation Page. Includes drawer etc.

}

class _MainPageState extends State<MainPage> {
  int _selectedDrawerIndex = 0;

  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return new MyJobsFragment();
//      case 1:
//        return new LabFragment();
//      case 2:
//        return new MyDetailsFragment();
//      case 3:
//        return new TrainingFragment();

      default:
        return new UnderConstructionFragment();
    }
  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop(); // close the drawer
  }

  @override
  Widget build(BuildContext context) {
    var drawerOptions = <Widget>[];
    for (var i = 0; i < widget.drawerItems.length; i++) {
      var d = widget.drawerItems[i];
      drawerOptions.add(
        new ListTile(
          leading: new Icon(d.icon),
          title: new Text(d.title),
          selected: i == _selectedDrawerIndex,
          onTap: () => _onSelectItem(i),
        )
      );
    }

    return new Scaffold(
        appBar: new AppBar(
          // here we display the title corresponding to the fragment
          // you can choose to have a static title
          title: new Text(widget.drawerItems[_selectedDrawerIndex].title),
            actions: <Widget>[
          new IconButton(icon: const Icon(Icons.sync), onPressed: () {
//          DataManager.get().currentJob.asbestosBulkSamples.add(sample);
            DataManager.get().syncAllJobs;
//                print(sample.jobNumber + '-' + sample.sampleNumber.toString() + ': ' + sample.description);
          })
        ]),
        drawer: new Drawer(
          child: new SingleChildScrollView(
            child: new Container(
              margin: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
              child: new Column(
                children: drawerOptions
              ),
            ),
          ),
        ),
        body: _getDrawerItemWidget(_selectedDrawerIndex),
        );
  }
}