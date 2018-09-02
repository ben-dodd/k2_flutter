import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/widgets/loading.dart';
import 'package:validator/validator.dart';

class GeneralDetailsTab extends StatefulWidget {
  @override
  _GeneralDetailsTabState createState() => new _GeneralDetailsTabState();
}

class _GeneralDetailsTabState extends State<GeneralDetailsTab> {
  Stream fireStream;
  final controllerDisplayName = TextEditingController();
  final controllerEmail = TextEditingController();
  final controllerPhone = TextEditingController();
  DocumentSnapshot userDoc;

  @override
  void initState() {
    fireStream = Firestore.instance.collection('users').document(DataManager.get().user).snapshots();
    controllerDisplayName.addListener(_updateDisplayName);
    controllerEmail.addListener(_updateEmail);
    controllerPhone.addListener(_updatePhone);
    super.initState();
  }

  _updateDisplayName(){
    Firestore.instance.collection('users').document(DataManager.get().user).setData({"displayName": controllerDisplayName.text},merge: true);
  }

  _updateEmail(){
    Firestore.instance.collection('users').document(DataManager.get().user).setData({"email": controllerEmail.text},merge: true);
  }

  _updatePhone(){
    Firestore.instance.collection('users').document(DataManager.get().user).setData({"phone": toInt(controllerPhone.text)},merge: true);
  }

  @override
  void dispose() {
    controllerDisplayName.removeListener(_updateDisplayName);
    controllerEmail.removeListener(_updateEmail);
    controllerPhone.removeListener(_updatePhone);
    controllerDisplayName.dispose();
    controllerEmail.dispose();
    controllerPhone.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
//    Firestore.instance.collection('users').document(DataManager.get().user).get().then((doc) {
//      userDoc = doc;
//      myController.text = userDoc.data['displayName'];
//    });
    return new Scaffold(
      body: StreamBuilder(
          stream: fireStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              print(snapshot.data.toString());
              print('details = ${snapshot.data['displayName']} ${snapshot.data['email']} ${snapshot.data['phone']}');
              if (!snapshot.hasData) return
                loadingPage(loadingText: 'Loading user data...');
              if (controllerDisplayName.text == '') {
                controllerDisplayName.text = snapshot.data['displayName'];
                controllerEmail.text = snapshot.data['email'];
                controllerPhone.text = '0' + snapshot.data['phone'].toString();
              }
              return ListView(children: <Widget> [
                Container(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                      TextField(
                        decoration: new InputDecoration(
                            labelText: 'Display Name',
                            hintText: 'Display Name'),
                        controller: controllerDisplayName,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                      TextField(
                        decoration: new InputDecoration(
                            labelText: 'Email',
                            hintText: 'Email'),
                        controller: controllerEmail,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                      TextField(
                        decoration: new InputDecoration(
                            labelText: 'Phone',
                            hintText: 'Phone'),
                        controller: controllerPhone,
                        keyboardType: TextInputType.numberWithOptions(),
                      ),
                    ),
                  ]
                )
              ),
            ]
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              return errorPage();
            }
          }),
    );
  }
}