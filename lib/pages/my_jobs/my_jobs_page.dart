import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/pages/my_jobs/tasks/job_page.dart';
import 'package:k2e/pages/my_jobs/wfm_fragment.dart';
import 'package:k2e/theme.dart';
import 'package:k2e/widgets/fab_dialer.dart';
import 'package:k2e/widgets/job_card.dart';
import 'package:k2e/widgets/loading.dart';

// This page lists all your current jobs
// From here you can click on the Fab Menu to add more jobs
// or click on a job to go to that task e.g. a survey

class MyJobsPage extends StatefulWidget {
  MyJobsPage() : super();
  @override
  _MyJobsPageState createState() => new _MyJobsPageState();
}

class _MyJobsPageState extends State<MyJobsPage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.

  List<SpeedDialerButton> modeButtons = [
    new SpeedDialerButton(backgroundColor: CompanyColors.accent, icon: Icons.add, onPressed: () { _createNewJob(); }, text: "Create New Job"),
    new SpeedDialerButton(backgroundColor: CompanyColors.accent, icon: Icons.cloud_download, onPressed: () { _addWfmJob(); }, text: "Add Job from WFM"),
  ];

//    FabDialer _fabDialer = new FabDialer(_fabMiniMenuItemList, CompanyColors.accent, Icon(Icons.add),);

    return new Scaffold(
      body: new Container(
              padding: new EdgeInsets.all(8.0),
                        child: StreamBuilder(
                          // ignore: ambiguous_import
                          stream: Firestore.instance.collection('users').document(DataManager.get().user).collection('myjobs').snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return
                              loadingPage(loadingText: 'Loading your jobs...');
                            if (snapshot.data.documents.length == 0) return
                              Center(
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(Icons.not_interested, size: 64.0),
                                        Container(
                                            alignment: Alignment.center,
                                            height: 64.0,
                                            child:
                                            Text('You have no jobs loaded.')
                                        )
                                      ]
                                  )
                              );
                            return ListView.builder(
                                itemCount: snapshot.data.documents.length,
                                itemBuilder: (context, index) {
                                  print(snapshot.data.documents[index]['path']);
                                  return Dismissible(
                                    key: new Key(snapshot.data.documents[index]['path']),
                                    onDismissed: (direction) async {
                                      await Firestore.instance.collection('users')
                                          .document(DataManager.get().user).collection('myjobs')
                                          .document(snapshot.data.documents[index].documentID).delete();
                                      setState(() {
                                        //
                                      });
                                      print(snapshot.data.documents[index].documentID);
                                      Scaffold.of(context)
                                          .showSnackBar(SnackBar(content: Text("Job deleted")));
                                    },
                                    child: JobCard(
                                        doc: snapshot.data.documents[index],
                                        onCardClick: () async {
                                          DataManager.get().currentJobPath = snapshot.data.documents[index]['path'];
                                          DataManager.get().currentJobNumber = snapshot.data.documents[index]['jobNumber'];
                                          print ('my jobs' + DataManager.get().currentJobPath);
                                          Navigator.push(context, MaterialPageRoute(
                                              builder: (context) => JobPage(path: snapshot.data.documents[index]['path'],)
                                          )
                                          );
                                        },
                                    )
                                  );
                                }
                              );
                          }
              ),
          ),
          floatingActionButton: new SpeedDialer(children: modeButtons),
    );
  }

  void _createNewJob() {

  }

  void _addWfmJob() async {
    String result = await Navigator.of(context).push(
      new MaterialPageRoute(builder: (_) => new WfmFragment()),
    );
    setState(() {
      if (result != null) {
      Scaffold.of(context).showSnackBar(
          new SnackBar(
              content: new Text(result)));
      }
    });
  }
}