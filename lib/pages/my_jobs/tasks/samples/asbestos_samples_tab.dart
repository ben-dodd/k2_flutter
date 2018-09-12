import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/model/samples/sample_asbestos_air.dart';
import 'package:k2e/model/samples/sample_asbestos_bulk.dart';
import 'package:k2e/pages/my_jobs/tasks/samples/edit_asbestos_sample_bulk.dart';
import 'package:k2e/widgets/sample_asbestos_bulk_card.dart';

class AsbestosSamplesTab extends StatefulWidget {
  AsbestosSamplesTab() : super();

  @override
  _AsbestosSamplesTabState createState() => new _AsbestosSamplesTabState();
}

class _AsbestosSamplesTabState extends State<AsbestosSamplesTab> {
  bool _isLoading = false;
  bool _isBulk = false;
  bool _isAir = false;
  bool _isEmpty = false;
  String _loadingText = 'Loading samples...';

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.

    // This shouldn't be called on every build!
//    List<SampleAsbestosBulk> _bulkSamples = new List();
//    _bulkSamples = DataManager.get().currentJob.asbestosBulkSamples;
//    List<SampleAsbestosAir> _airSamples = new List();
//    _airSamples = DataManager.get().currentJob.asbestosAirSamples;
//    print('Bulk Size ' + _bulkSamples.length.toString());

//    if (_bulkSamples.length > 0) { _isBulk = true; } else { _isBulk = false; }
//    if (_airSamples.length > 0) { _isAir = true; } else { _isAir = false; }
//    if (!_isBulk && !_isAir) { _isEmpty = true; } else { _isEmpty = false; }
//
//    _bulkSamples.sort((a,b) => a.sampleNumber.compareTo(b.sampleNumber)); // sort samples by sample number

    return new Scaffold(
      body:
      new Container(
        padding: new EdgeInsets.all(8.0),
        child: StreamBuilder(
            stream: Firestore.instance.collection('samplesasbestosbulk').where('jobNumber',isEqualTo: DataManager.get().currentJobNumber).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return
                Container(
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
                              Text(_loadingText)
                          )
                        ]));
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
                              Text('This job has no samples.')
                          )
                        ]
                    )
                );
              return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    return SampleAsbestosBulkCard(
                      doc: snapshot.data.documents[index],
                      onCardClick: () async {
                        // todo Incorporate firestore with samples
//                        DataManager.get().currentAsbestosBulkSample = _bulkSamples[index];
                        Navigator.of(context).push(
                          new MaterialPageRoute(builder: (context) =>
                              EditAsbestosSampleBulk(
                                  sample: snapshot.data.documents[index]
                                      .getDocumentID)),
                        );
                      },
//                        setState((){
//                          if (result != null) {
//                            Scaffold.of(context).showSnackBar(
//                                new SnackBar(
//                                    content: new Text(result.jobNumber)));
//                            SampleAsbestosBulkRepo.get().updateSample(result);
//                            DataManager
//                                .get()
//                                .currentJob
//                                .asbestosBulkSamples[index] = result;
//                          }
//      Scaffold.of(context).showSnackBar(
//          new SnackBar(
//              content: new Text(result.jobNumber + '-' + result.sampleNumber.toString() + " created")));
//                        }
//                        );
//                      },
                      onCardLongPress: () {
                        // Delete
                      },
                    );
                  }
                );
            }
        ),
      ),
    );
  }
}