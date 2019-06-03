import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/pages/my_jobs/tasks/coc/edit_coc.dart';
import 'package:k2e/pages/my_jobs/tasks/coc/edit_historic_coc.dart';
import 'package:uuid/uuid.dart';

void addHistoricCoc(BuildContext context) {
//  String docID =
//      DataManager.get().currentJobNumber + '-' + Uuid().v1().toString();
  Map<String, dynamic> currentJob;
  Firestore.instance
      .document(DataManager.get().currentJobPath)
      .get()
      .then((doc) {
    // Might pay to keep job in DataManager
    // and User Name
    currentJob = doc.data;
    Map<String, dynamic> newCoc = {
      'dates': [],
      'samples': {},
      'personnel': [],
      'type': 'Asbestos - Bulk ID',
      'jobNumber': 'Historic',
      'linkedJobNumbers': [DataManager.get().currentJobNumber],
      'uid': null,
      'dueDate': currentJob['dueDate'],
      'address': currentJob['address'],
      'client': currentJob['clientName'],
      'deleted': false,
    };
    Navigator.of(context).push(new MaterialPageRoute(
        builder: (context) => EditHistoricCoc(
          cocObj: newCoc,
        )));
  });
  // Create new CoC in this job
}

void addNewCoc(BuildContext context) {
//  String docID =
//      DataManager.get().currentJobNumber + '-' + Uuid().v1().toString();
  Map<String, dynamic> currentJob;
  Firestore.instance
      .document(DataManager.get().currentJobPath)
      .get()
      .then((doc) {
    // Might pay to keep job in DataManager
    // and User Name
    currentJob = doc.data;
    Map<String, dynamic> newCoc = {
      'dates': [],
      'samples': {},
      'personnel': [],
      'type': 'Asbestos - Bulk ID',
      'jobNumber': DataManager.get().currentJobNumber,
      'uid': null,
      'dueDate': currentJob['dueDate'],
      'address': currentJob['address'],
      'client': currentJob['clientName'],
      'deleted': false,
    };
    Navigator.of(context).push(new MaterialPageRoute(
        builder: (context) => EditCoc(
          cocObj: newCoc,
        )));
  });
  // Create new CoC in this job
}
