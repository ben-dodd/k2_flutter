import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/model/samples/sample_asbestos_bulk.dart';
import 'package:uuid/uuid.dart';
import 'package:validator/validator.dart';

class GeneralDetailsTab extends StatefulWidget {
  @override
  _GeneralDetailsTabState createState() => new _GeneralDetailsTabState();
}

class _GeneralDetailsTabState extends State<GeneralDetailsTab> {
//  bool _isLoading = false;
  Stream fireStream;
  final myController = TextEditingController();
  DocumentSnapshot userDoc;

  @override
  void initState() {
    fireStream = Firestore.instance.collection('users').document(DataManager.get().user).snapshots();
    myController.addListener(_printLatestValue);
// TODO populate text fields on init state
    super.initState();
  }

  _printLatestValue(){
    print("Text field: ${myController.text}");
    Firestore.instance.collection('users').document(DataManager.get().user).setData({"displayName": myController.text},merge: true);
  }

  @override
  void dispose() {
    myController.removeListener(_printLatestValue);
    myController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
//    Firestore.instance.collection('users').document(DataManager.get().user).get().then((doc) {
//      userDoc = doc;
//      myController.text = userDoc.data['displayName'];
//    });
    fireStream.single.then((doc) {
      userDoc = doc;
      myController.text = userDoc['displayName'];
      print (userDoc['displayName']);
    });
    return new Scaffold(
      body: StreamBuilder(
          stream: fireStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              print(snapshot.data.toString());
              print('details = ${snapshot.data['displayName']} ${snapshot.data['email']} ${snapshot.data['phone']}');
              return Container(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: myController,
                      ),
                    )
                  ],
                ),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              return Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.error),
                    ),
                    Text('Error loading data')
                  ],
                ),
              );
            }
          }),
    );
  }
}