import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/styles.dart';
import 'package:k2e/widgets/loading.dart';
import 'package:uuid/uuid.dart';

class AssignSampleNumbers extends StatefulWidget {
  AssignSampleNumbers({Key key, this.acm}) : super(key: key);
  final Map<String, dynamic> acm;
  @override
  _AssignSampleNumbersState createState() => new _AssignSampleNumbersState();
}

class _AssignSampleNumbersState extends State<AssignSampleNumbers> {
  String _title = "Assign Sample Numbers";

  Map<String, dynamic> acm = new Map<String, dynamic>();
  // images

  @override
  void initState() {
    acm = widget.acm;
    _loadSampleNumbers();
    super.initState();
  }

  Widget build(BuildContext context) {
    return new Scaffold(
        appBar:
        new AppBar(title: Text(_title),
            leading: new IconButton(
              icon: new Icon(Icons.clear),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: <Widget>[
              new IconButton(icon: const Icon(Icons.check), onPressed: () {
                // Assign
              })
            ]
        ),
        body: new Container(
          padding: new EdgeInsets.all(8.0),
          child: new ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: <Widget>[
              new StreamBuilder(
                  stream: Firestore.instance.collection('cocs').where('jobNumber', isEqualTo: DataManager.get().currentJobNumber).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return
                      Container(
                          padding: EdgeInsets.only(top: 16.0),
                          alignment: Alignment.center,
                          color: Colors.white,

                          child: Column(
                              mainAxisAlignment: MainAxisAlignment
                                  .center,
                              children: <Widget>[
                                new CircularProgressIndicator(),
                                Container(
                                    alignment: Alignment.center,
                                    height: 64.0,
                                    child:
                                    Text('Loading Chains of Custody')
                                )
                              ]));
                    if (snapshot.data.documents.length == 0) return
                      Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
//                                Icon(Icons.not_interested, size: 64.0),
                                Container(
                                    alignment: Alignment.center,
                                    height: 64.0,
                                    child:
                                    Text('This job has no Chains of Custody.')
                                ),
                              ]
                          )
                      );
                    return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          return Text(snapshot.data.documents[index]['jobNumber']);
                        }
                    );
                  }
              ),
              new Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 14.0,),
                child: new OutlineButton(
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                    child: Text("Add New Chain of Custody",
                        style: new TextStyle(color: Theme.of(context).accentColor, fontWeight: FontWeight.bold
                        )
                    ),
                    //                          color: Colors.white,
                    onPressed: () {
                      _addNewCoC();
                    }
                ),
              ),
              Divider(),
              Container(
                padding: EdgeInsets.fromLTRB(32.0,16.0,32.0,16.0),
                child: Text('Add historic samples if there have been any samples previously tested by K2 Environmental or any other testing lab.', style: Styles.comment)),
              new StreamBuilder(
                  stream: Firestore.instance.document(DataManager.get().currentJobPath).collection('historicsamples').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return
                      Container(
                          padding: EdgeInsets.only(top: 16.0),
                          alignment: Alignment.center,
                          color: Colors.white,

                          child: Column(
                              mainAxisAlignment: MainAxisAlignment
                                  .center,
                              children: <Widget>[
                                new CircularProgressIndicator(),
                                Container(
                                    alignment: Alignment.center,
                                    height: 64.0,
                                    child:
                                    Text('Loading Historic Samples')
                                )
                              ]));
                    if (snapshot.data.documents.length == 0) return
                      Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
//                                Icon(Icons.not_interested, size: 64.0),
                                Container(
                                    alignment: Alignment.center,
                                    height: 64.0,
                                    child:
                                    Text('This job has no historic samples.')
                                ),
                              ]
                          )
                      );
                    return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          return Text(snapshot.data.documents[index]['jobNumber']);
                        }
                    );
                  }
              ),
              new Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 14.0,),
                child: new OutlineButton(
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                    child: Text("Add Historic Sample",
                        style: new TextStyle(color: Theme.of(context).accentColor, fontWeight: FontWeight.bold
                        )
                    ),
                    //                          color: Colors.white,
                    onPressed: () {
                      _addHistoricSample();
                    }
                ),
              ),
            ],
          ),
        )
    );
  }

  void _loadSampleNumbers() {
    Firestore.instance.collection('cocs').where(
        'jobNumber', isEqualTo: DataManager
        .get()
        .currentJobNumber).getDocuments().then((doc) {
      if (doc.documents.length == 0) {
        // No COC
        print('No COC for this job');
      } else {
        // Get samples from CoCs
        doc.documents.forEach((doc) {
          print(doc.data.toString());
        });
      }
    });
  }
}

void _addHistoricSample() {
  // Add sample from other K2 Job or other company
}

_addNewCoC() {
  String docID = DataManager.get().currentJobNumber + '-' + Uuid().v1().toString();
  Map<String,dynamic> currentJob;
  Firestore.instance.document(DataManager.get().currentJobPath).get().then((doc) {
    // Might pay to keep job in DataManager
    // and User Name
    currentJob = doc.data;
    Map<String, dynamic> newCoC = {
      'dates': [new DateTime.now()],
      'samples': {},
      'personnel': [DataManager.get().user],
      'type': 'Asbestos - Bulk ID',
      'jobNumber': DataManager.get().currentJobNumber,
      'uid': docID,
      'address': currentJob['address'],
      'client': currentJob['clientname'],
    };
    Firestore.instance.collection('cocs').document(docID).setData(newCoC);
  });
  // Create new CoC in this job
}