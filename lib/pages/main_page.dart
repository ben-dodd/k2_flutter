import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/pages/my_details/my_details_page.dart';
import 'package:k2e/pages/my_jobs/my_jobs_page.dart';
import 'package:k2e/pages/under_construction_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    new DrawerItem("Lab", Icons.colorize),
//    new DrawerItem("Notifications", Icons.notifications),
//    new DrawerItem("Calendar", Icons.date_range),
    new DrawerItem("My Details", Icons.person),
//    new DrawerItem("Training", Icons.people),
//    new DrawerItem("Equipment", Icons.build),
    new DrawerItem("Reference", Icons.info_outline), // This page has various reference to methods etc.
    new DrawerItem("App Settings", Icons.settings),
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

  GlobalKey _signInKey;

  Future<void> _testSignInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    setState(() {
      _isLoading = true;
    });
    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;
    FirebaseUser user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    print(user.email);
    QuerySnapshot query = await Firestore.instance.collection('users').where('email',isEqualTo: user.email).getDocuments();
    if (query.documents.length == 0){
      // User is not registered
      print('This email is not registered with K2.');
      // Todo show pop up snack bar if email not registered
      setState(() {
        _isLoading = false;
        _isSignedIn = false;
        currentUser = null;
        _googleSignIn.signOut();
      });
    } else {
      setState(() {
        DataManager.get().user = query.documents.first.documentID;
        print ('user is !!! ' + DataManager.get().user);
        _isLoading = false;
        _selectedDrawerIndex = 0;
        print('user is ' + user.displayName);
        currentUser = user;
        _isSignedIn = true;
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
//      case 2:
//        return new MyDetailsPage();
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
      print ('Signed out');
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
      drawerOptions.add(
          new ListTile(
            leading: new Icon(d.icon),
            title: new Text(d.title),
            selected: i == _selectedDrawerIndex,
            onTap: () => _onSelectItem(i),
          )
      );
    }
    print (currentUser.toString() + ' is the current user');
      return new Container(
        child: _isSignedIn?
       new Scaffold(
        appBar: new AppBar(
          // here we display the title corresponding to the fragment
          // you can choose to have a static title
            title: new Text(widget.drawerItems[_selectedDrawerIndex].title),
            actions: <Widget>[
              new IconButton(icon: const Icon(Icons.sync), onPressed: () {
//          DataManager.get().currentJob.asbestosBulkSamples.add(sample);
                DataManager
                    .get()
                    .syncAllJobs;
//                print(sample.jobNumber + '-' + sample.sampleNumber.toString() + ': ' + sample.description);
              })
            ]),
        drawer: new Drawer(
          child: ListView(
            children: <Widget> [
              UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(backgroundImage: new NetworkImage(currentUser.photoUrl)),
                accountName: Text(currentUser.displayName),
                accountEmail: Text(currentUser.email),
              ),
              new SingleChildScrollView(
                child:
                Container(
                  margin: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
                  child: new Column(
                      children: drawerOptions
                  ),
                ),
              )
            ]
          )
        ),
        body: _getDrawerItemWidget(_selectedDrawerIndex),
      )
    : new Scaffold(
          key: _signInKey,
        appBar: new AppBar(
          title: new Text('Sign In')
        ),
        body: _isLoading?
        new Container(
            alignment: Alignment.center,
            color: Colors.white,

            child:Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new CircularProgressIndicator(),
                  Container(
                      alignment: Alignment.center,
                      height: 64.0,
                      child:
                      Text('Signing In...')
                  )]))

            : new Center(
          child: RaisedButton(onPressed: _testSignInWithGoogle, child: Text('Sign In'),)
        )
      )
      );
  }
}