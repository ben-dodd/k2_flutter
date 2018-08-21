import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/data/repos/sample_asbestos_bulk_repo.dart';
import 'package:k2e/model/entities/samples/sample_asbestos_air.dart';
import 'package:k2e/model/entities/samples/sample_asbestos_bulk.dart';
import 'package:k2e/pages/my_jobs/tasks/samples/edit_asbestos_sample_bulk.dart';
import 'package:k2e/widgets/sample_asbestos_air_card.dart';
import 'package:k2e/widgets/sample_asbestos_bulk_card.dart';

class AsbestosSamplesFragment extends StatefulWidget {
  AsbestosSamplesFragment() : super();

  @override
  _AsbestosSamplesFragmentState createState() => new _AsbestosSamplesFragmentState();
}

class _AsbestosSamplesFragmentState extends State<AsbestosSamplesFragment> {
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
    List<SampleAsbestosBulk> _bulkSamples = new List();
    _bulkSamples = DataManager.get().currentJob.asbestosBulkSamples;
    List<SampleAsbestosAir> _airSamples = new List();
    _airSamples = DataManager.get().currentJob.asbestosAirSamples;
    print('Bulk Size ' + _bulkSamples.length.toString());

    if (_bulkSamples.length > 0) { _isBulk = true; } else { _isBulk = false; }
    if (_airSamples.length > 0) { _isAir = true; } else { _isAir = false; }
    if (!_isBulk && !_isAir) { _isEmpty = true; } else { _isEmpty = false; }

    _bulkSamples.sort((a,b) => a.sampleNumber.compareTo(b.sampleNumber)); // sort samples by sample number

    return new Scaffold(
      body:
      new Container(
          padding: new EdgeInsets.all(8.0),
          child: new Stack(
              children: <Widget>[
                _isEmpty?
                new Center(
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
                )
                    : new Container(),
                ListView.builder(
                    itemCount: _bulkSamples.length,
                    itemBuilder: (context, index) {
                      return SampleAsbestosBulkCard(
                        sample: _bulkSamples[index],
                        onCardClick: () async {
                            DataManager.get().currentAsbestosBulkSample = _bulkSamples[index];
                            SampleAsbestosBulk result = await Navigator.of(context).push(
                              new MaterialPageRoute(builder: (context) => EditAsbestosSampleBulk()),
                            );
                            setState((){
                              if (result != null) {
                                Scaffold.of(context).showSnackBar(
                                    new SnackBar(
                                        content: new Text(result.jobNumber)));
//                                SampleAsbestosBulkRepo.get().updateJob(result);
//                                DataManager
//                                    .get()
//                                    .currentJob
//                                    .asbestosBulkSamples[index] = result;
                              }
//      Scaffold.of(context).showSnackBar(
//          new SnackBar(
//              content: new Text(result.jobNumber + '-' + result.sampleNumber.toString() + " created")));
                            });
                        },
                        onCardLongPress: () async {

                        },
                      );
                    }
                ),
                _isLoading?
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
                              Text(_loadingText)
                          )]))

                    : new Container(),
              ]
          )
      ),
    );
  }
}