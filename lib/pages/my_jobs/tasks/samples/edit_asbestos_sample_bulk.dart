import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/model/samples/sample_asbestos_bulk.dart';
import 'package:k2e/widgets/loading.dart';
//import 'package:uuid/uuid.dart';
//import 'package:validator/validator.dart';

class EditAsbestosSampleBulk extends StatefulWidget {
  EditAsbestosSampleBulk({Key key, this.sample}) : super(key: key);
  String sample;
  @override
  _EditAsbestosSampleBulkState createState() => new _EditAsbestosSampleBulkState();
}

class _EditAsbestosSampleBulkState extends State<EditAsbestosSampleBulk> {
//  bool _isLoading = false;
  String _title = "Edit Sample";
  Stream sampleDoc;

  final controllerSampleNumber = TextEditingController();
  final controllerDescription = TextEditingController();
  final controllerMaterial = TextEditingController();


  @override
  void initState() {
    if (widget.sample == null){
      Map<String, dynamic> dataMap = new Map();
      print('null sample');
      print('creating new sample');
      _title = "Add New Sample";
      dataMap['jobNumber'] = DataManager.get().currentJobNumber;
//      sample.sampleNumber = DataManager.get().getHighestSampleNumber(DataManager.get().currentJob) + 1;
      dataMap['sampleNumber'] = 1;
      Firestore.instance.collection('samplesasbestosbulk').add(dataMap).then((ref) {
        widget.sample = ref.documentID;
      });
      controllerSampleNumber.addListener(_updateSampleNumber);
      controllerDescription.addListener(_updateDescription);
      controllerMaterial.addListener(_updateMaterial);
    }

    sampleDoc = Firestore.instance.collection('samplesasbestosbulk').document(widget.sample).get().asStream();

    super.initState();
  }

  _updateSampleNumber() {
    Firestore.instance.collection('samplesasbestosbulk').document(widget.sample).setData(
        {"sampleNumber": controllerSampleNumber.text}, merge: true);
  }

  _updateDescription() {
    Firestore.instance.collection('samplesasbestosbulk').document(widget.sample).setData(
        {"sampleNumber": controllerDescription.text}, merge: true);
  }

  _updateMaterial() {
    Firestore.instance.collection('samplesasbestosbulk').document(widget.sample).setData(
        {"sampleNumber": controllerMaterial.text}, merge: true);
  }

  Widget build(BuildContext context) {
    final DateTime today = new DateTime.now();

    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar:
        new AppBar(title: Text(_title),
            actions: <Widget>[
              new IconButton(icon: const Icon(Icons.check), onPressed: () {
                Navigator.pop(context);
              })
            ]),
        body: new StreamBuilder(stream: sampleDoc,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                print(snapshot.data.toString());
                if (!snapshot.hasData) return
                  loadingPage(loadingText: 'Loading sample info...');
                if (snapshot.hasData) {
                  if (controllerSampleNumber.text == '') {
                    controllerSampleNumber.text = snapshot.data['sampleNumber'];
                    controllerDescription.text = snapshot.data['description'];
                    controllerMaterial.text = snapshot.data['material'];
                  }
                  return GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                      },
                      child: Container(
                          padding: new EdgeInsets.all(8.0),
                          child: ListView(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.topLeft,
                                child: TextField(
                                  decoration: const InputDecoration(
                                      labelText: "Sample Number"),
                                  autocorrect: false,
                                  controller: controllerSampleNumber,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              Container(
                                alignment: Alignment.topLeft,
                                child: TextField(
                                  decoration: const InputDecoration(
                                      labelText: "Description"),
                                  autocorrect: false,
                                  controller: controllerDescription,
                                  keyboardType: TextInputType.text,
                                ),
                              ),
                              Container(
                                alignment: Alignment.topLeft,
                                child: TextField(
                                  decoration: const InputDecoration(
                                      labelText: "Material"),
                                  autocorrect: false,
                                  controller: controllerMaterial,
                                  keyboardType: TextInputType.text,
                                ),
                              ),
                            ],
                          )
                      )
                  );
                }
              }
            }
        )
    );
  }
}