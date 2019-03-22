import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/pages/my_details/general_details_tab.dart';
import 'package:k2e/pages/my_jobs/my_jobs_page.dart';
import 'package:k2e/pages/under_construction_page.dart';
import 'package:k2e/utils/camera.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();

class DrawerItem {
  String title;
  IconData icon;
  DrawerItem(this.title, this.icon);
}

class MainPage extends StatefulWidget {
  // Add all drawer items here
  final drawerItems = [
    new DrawerItem("My Jobs", Icons.assignment),
//    new DrawerItem("To Do", Icons.format_list_bulleted),
//    new DrawerItem("Lab", Icons.colorize),
//    new DrawerItem("Notifications", Icons.notifications),
//    new DrawerItem("Calendar", Icons.date_range),
//    new DrawerItem("My Details", Icons.person),
//    new DrawerItem("Training", Icons.people),
//    new DrawerItem("Equipment", Icons.build),
//    new DrawerItem("Reference", Icons.info_outline), // This page has various reference to methods etc.
//    new DrawerItem("App Settings", Icons.settings),
    new DrawerItem("Log Out", Icons.exit_to_app)
  ];

  @override
  _MainPageState createState() => new _MainPageState();

// Main Navigation Page. Includes drawer etc.

}

class _MainPageState extends State<MainPage> {
  FirebaseUser currentUser;
  bool _isLoading = false;
  bool _isSignedIn = false;
  String _signInError = null;

  GlobalKey _signInKey;

  @override
  void initState() {
    super.initState();
    _testSignInWithGoogle();
  }

  Future<void> _testSignInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    // Load cameras
    getCameras().then((cameras) => DataManager.get().cameras = cameras);
    final FirebaseUser user = await _auth.signInWithCredential(credential);
    print(user.toString());
    try {
      Firestore.instance
          .collection('users')
          .document(user.uid)
          .get()
          .then((userDoc) {
        print(userDoc.data.toString());
        if (userDoc.data == null) {
          setState(() {
            _signInError =
                'The account ' + user.email + ' is not registered with K2.';
            _isLoading = false;
            _isSignedIn = false;
            currentUser = null;
            _googleSignIn.signOut();
          });
        } else {
          setState(() {
            DataManager.get().user = user.uid;
            _signInError = null;
            _isLoading = false;
            _selectedDrawerIndex = 0;
            print('user is ' + user.toString());
            currentUser = user;
            _isSignedIn = true;
            Firestore.instance
                .collection('appsettings')
                .document('constants')
                .get()
                .then((DocumentSnapshot doc) {
              DataManager.get().constants = Map<String, dynamic>.from(doc.data);
              //          DataManager.get().buildingmaterials = doc.data["buildingmaterials"].map((bm) => bm["label"].toString()).toList();
              //          DataManager.get().asbestosmaterials = doc.data["asbestosmaterials"].map((bm) => bm["label"].toString()).toList();
              //          DataManager.get().buildingitems = doc.data["buildingitems"].map((bm) => bm["label"].toString()).toList();
              //          print(DataManager.get().buildingmaterials);
            });
          });
        }
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        _isLoading = false;
        _isSignedIn = false;
        currentUser = null;
        _googleSignIn.signOut();
      });
    }
  }

  int _selectedDrawerIndex = 0;

  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return new MyJobsPage();
//      case 1:
//        return new LabPage();
      case 2:
        return new GeneralDetailsTab();
//      case 3:
//        return new TrainingFragment();
      case 5:
        _signOut();
        break;

      default:
        return new UnderConstructionPage();
    }
  }

  void _signOut() async {
    print(currentUser.displayName + ' signing out.');
    await _googleSignIn.signOut();
    await _auth.signOut();
    setState(() {
      currentUser = null;
      _isSignedIn = false;
      print('Signed out');
    });
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
      drawerOptions.add(new ListTile(
        leading: new Icon(d.icon),
        title: new Text(d.title),
        selected: i == _selectedDrawerIndex,
        onTap: () => _onSelectItem(i),
      ));
    }
    return new Container(
        child: _isSignedIn
            ? new Scaffold(
                appBar: new AppBar(
                  // here we display the title corresponding to the fragment
                  // you can choose to have a static title
                  title:
                      new Text(widget.drawerItems[_selectedDrawerIndex].title),
//            actions: <Widget>[
//              new IconButton(icon: const Icon(Icons.sync), onPressed: () {
////          DataManager.get().currentJob.asbestosBulkSamples.add(sample);
//                DataManager
//                    .get()
//                    .syncAllJobs;
////                print(sample.jobnumber + '-' + sample.sampleNumber.toString() + ': ' + sample.description);
//              })
//            ]
                ),
                drawer: new Drawer(
                    child: ListView(children: <Widget>[
                  UserAccountsDrawerHeader(
                    currentAccountPicture: CircleAvatar(
                        backgroundImage:
                            new NetworkImage(currentUser.photoUrl)),
                    accountName: Text(currentUser.displayName),
                    accountEmail: Text(currentUser.email),
                  ),
                  new SingleChildScrollView(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
                      child: new Column(children: drawerOptions),
                    ),
                  )
                ])),
                body: _getDrawerItemWidget(_selectedDrawerIndex),
              )
            : new Scaffold(
                key: _signInKey,
                appBar: new AppBar(title: new Text('K2 Sign In')),
                body: _isLoading
                    ? new Container(
                        alignment: Alignment.center,
                        color: Colors.white,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new CircularProgressIndicator(),
                              Container(
                                  alignment: Alignment.center,
                                  height: 64.0,
                                  child: Text('Signing In...'))
                            ]))
                    : new Center(
                        child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Container(
                                padding: EdgeInsets.only(bottom: 12.0),
                                child: new Image(
                                  image: new AssetImage(
                                      "assets/images/web_hi_res_512.png"),
                                  width: 120.0,
                                ),
                              ),
                              OutlineButton(
                                onPressed: _testSignInWithGoogle,
                                child: Text('Sign In'),
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(30.0)),
                              ),
                              _signInError != null
                                  ? new Container(
                                      padding: EdgeInsets.only(
                                          top: 12.0, left: 48.0, right: 48.0),
                                      alignment: Alignment.center,
                                      child: new Text(_signInError))
                                  : new Container(),
                            ]),
                      )));
  }
}
